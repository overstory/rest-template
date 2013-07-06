xquery version "1.0-ml";

module namespace emodule = "urn:overstory:rest:modules:rest:errors";

import module namespace rc="urn:overstory:rest:modules:constants" at "constants.xqy";

declare namespace e = "http://overstory.co.uk/ns/errors";

declare private variable $http-codes :=
	(: source: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html :)
	<http-codes>
		<code code="100" msg="Continue"/>
		<code code="101" msg="Switching Protocols"/>
		<code code="200" msg="OK"/>
		<code code="201" msg="Created"/>
		<code code="202" msg="Accepted"/>
		<code code="203" msg="Non-Authoritative Information"/>
		<code code="204" msg="No Content"/>
		<code code="205" msg="Reset Content"/>
		<code code="206" msg="Partial Content"/>
		<code code="300" msg="Multiple Choices"/>
		<code code="301" msg="Moved Permanently"/>
		<code code="302" msg="Found"/>
		<code code="303" msg="See Other"/>
		<code code="304" msg="Not Modified"/>
		<code code="305" msg="Use Proxy"/>
		<code code="307" msg="Temporary Redirect"/>
		<code code="400" msg="Bad Request"/>
		<code code="401" msg="Unauthorized"/>
		<code code="402" msg="Payment Required"/>
		<code code="403" msg="Forbidden"/>
		<code code="404" msg="Not Found"/>
		<code code="405" msg="Method Not Allowed"/>
		<code code="406" msg="Not Acceptable"/>
		<code code="407" msg="Proxy Authentication Required"/>
		<code code="408" msg="Request Timeout"/>
		<code code="409" msg="Conflict"/>
		<code code="410" msg="Gone"/>
		<code code="411" msg="Length Required"/>
		<code code="412" msg="Precondition Failed"/>
		<code code="413" msg="Request Entity Too Large"/>
		<code code="414" msg="Request-URI Too Long"/>
		<code code="415" msg="Unsupported Media Type"/>
		<code code="416" msg="Requested Range Not Satisfiable"/>
		<code code="417" msg="Expectation Failed"/>
		<code code="500" msg="Internal Server Error"/>
		<code code="501" msg="Not Implemented"/>
		<code code="502" msg="Bad Gateway"/>
		<code code="503" msg="Service Unavailable"/>
		<code code="504" msg="Gateway Timeout"/>
		<code code="505" msg="HTTP Version Not Supported"/>
		<code code="550" msg="Permission Denied"/>
	</http-codes>;

declare private function get-code($code as xs:integer)
	as element(code)
{
	let $elem := $http-codes/code[@code eq $code]
	let $fiveoo := $http-codes/code[@code eq 500]
	return
		(: if the code is not known, get 500 :)
		( $elem, $fiveoo )[1]
};

declare private function generate-payload (
	$code as xs:string,
	$http-code as xs:integer,
	$message as xs:string,
	$specifics as element()*
) as element()
{
	let $code-elem := get-code ($http-code)
	return
	<e:error>
		<e:code>{ $code }</e:code>
		<e:http-code>{ $code-elem/fn:string(@code) }</e:http-code>
		<e:http-status>{ $code-elem/fn:string(@msg) }</e:http-status>
		<e:description>{ $message }</e:description>
		{ $specifics }
	</e:error>
};

declare function throw-xml-error (
	$code as xs:string,
	$http-code as xs:integer,
	$message as xs:string,
	$specifics as element()*
) as empty-sequence()
{
	let $payload := generate-payload ($code, $http-code, $message, $specifics)
	return fn:error (xs:QName (fn:concat ('e:', $code)), $message, xdmp:quote ($payload))
};

declare function return-xml-error (
	$http-code as xs:integer,
	$message as xs:string,
	$specifics as element()*
) as element()
{
	let $payload := generate-payload ("NORMAL-RESPONSE", $http-code, $message, $specifics)
	let $_ := xdmp:set-response-code ($http-code, $message)
	let $_ := xdmp:set-response-content-type ($rc:MEDIA-TYPE-ERROR-XML)
	return $payload
};

(: ------------------------------------------------------------------ :)

declare function unacceptable-error (
	$mediatype as xs:string
) as element(e:unsupported-mediatype)
{
	<e:unsupported-mediatype>
		<e:message>Cannot produce requested mediatype: {$mediatype}</e:message>
		<e:mediatype>{$mediatype}</e:mediatype>
	</e:unsupported-mediatype>
};

(: ------------------------------------------------------------------ :)

declare function not-allowed-error (
	$method as xs:string
) as element(e:method-not-allowed)
{
	<e:method-not-allowed>
		<e:message>Method not allowed: {$method}</e:message>
		<e:method>{$method}</e:method>
	</e:method-not-allowed>
};

(: ------------------------------------------------------------------ :)

declare function no-resource (
	$uri as xs:string?
) as element(e:no-resource)
{
	let $msg :=
		if ($uri)
		then fn:concat ("No resource found for URI '", $uri, "'")
		else "No entity URI provided"

	return
	<e:no-resource>
		<e:message>{$msg}</e:message>
		{ if ($uri) then <e:uri>{ $uri }</e:uri> else () }
	</e:no-resource>
};

declare function no-resource-for-id (
	$identifier as xs:string?
) as element(e:no-resource-for-id)
{
	let $msg :=
		if ($identifier)
		then fn:concat ("No resource found for identifier '", $identifier, "'")
		else "No identifier provided"

	return
	<e:no-resource-for-id>
		<e:message>{$msg}</e:message>
		{ if ($identifier) then <e:identifier>{ $identifier }</e:identifier> else () }
	</e:no-resource-for-id>
};

(: ------------------------------------------------------------------ :)
