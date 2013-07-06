xquery version "1.0-ml";

module namespace httpmodule = "urn:overstory:rest:modules:rest:http";

import module namespace re="urn:overstory:rest:modules:rest:errors" at "errors.xqy";

declare namespace e = "http://overstory.co.uk/ns/errors";

declare function http-date (
	$date as xs:dateTime
) as xs:string
{
	(: Sat, 29 Oct 1994 19:43:31 GMT :)
	(: xdmp:strftime ("%a, %d %b %Y %H:%M:%S GMT", date-as-utc ($date)) Broken in ML6 on Windows :)
	fn:format-dateTime (date-as-utc ($date), "[FNn,*-3], [D01] [MNn,*-3] [Y] [H01]:[m01]:[s01] GMT")
};

declare function date-as-utc (
	$date as xs:dateTime
) as xs:dateTime
{
	fn:adjust-dateTime-to-timezone ($date, xs:dayTimeDuration("PT0H"))
};

declare function request-url()
{
	fn:concat (xdmp:get-request-protocol(), "://", xdmp:get-request-header ("Host"), xdmp:get-original-url())
};

(: ----------------------------------------------------------------- :)

declare private function malformed-body (
	$error as element(error:error)
) as element(e:malformed-body)
{
	let $msg :=
		if ($error)
		then $error/error:message/fn:string()
		else "Unknown error occurred"

	return
	<e:malformed-body>
		<e:message>{$msg}</e:message>
	</e:malformed-body>
};

declare private function empty-body (
	$msg as xs:string
) as element(e:empty-body)
{
	<e:empty-body>
		<e:message>{$msg}</e:message>
	</e:empty-body>
};

(: ----------------------------------------------------------------- :)

declare function get-simple-contenttype (
	$default-type as xs:string?
) as xs:string?
{
	let $value as xs:string? := xdmp:get-request-header ("Content-Type", $default-type)
	let $value as xs:string? := if (fn:contains ($value, ";")) then fn:substring-before ($value, ";") else $value
	let $value as xs:string? := fn:normalize-space ($value)
	let $value as xs:string? := if ($value = "*/*") then () else $value

	return if ($value) then $value else $default-type
};

(: ----------------------------------------------------------------- :)

(: Never returns if validation fails :)
declare function validate-content-type (
	$expected-type as xs:string,
	$default-type as xs:string?,
	$allowed-types as xs:string*
) as empty-sequence()
{
	let $type as xs:string? := get-simple-contenttype ($default-type)

	return
	if ($type = $allowed-types)
	then ()
	else
		re:throw-xml-error ('HTTP-BADCONTENTYPE', 415, "Unsupported Media Type",
		<e:unsupported-content-type>
			<e:message>{fn:concat ("The mediatype '", $type, "' is not supported by this endpoint")}</e:message>
			<e:content-type>{ $type }</e:content-type>
		</e:unsupported-content-type>)
};

(: ----------------------------------------------------------------- :)


(: ToDo: Look at Content-Type header, check for unsupported mediatypes, return 415 if so :)
declare private function get-body (
	$type as xs:string
) as node()
{
    try {
        let $xml := xdmp:get-request-body ($type)
        let $node as node()? := ($xml/(element(), $xml/binary(), $xml/text()))[1]
        return
        if (fn:empty ($node))
        then re:throw-xml-error ('HTTP-EMPTYBODY', 400, "Empty body", empty-body ("Expected XML body is empty"))
        else $node
    } catch ($e) {
        re:throw-xml-error ('HTTP-MALXMLBODY', 400, "Malformed body", malformed-body ($e))
    }
};

declare function get-xml-body (
) as element()
{
	get-body ("xml")
};

declare function get-binary-body (
) as node()
{
	let $type as xs:string := xdmp:get-request-header('Content-Type')[1]
        let $format
          := if (fn:contains($type, "application/xml") or fn:contains($type, "+xml"))
             then "xml"
             else
               if (fn:contains($type, "text/"))
               then "text"
               else "binary"
        return get-body ($format)
};

(: ----------------------------------------------------------------- :)

declare private function throw-missing-param-value-error (
	$field-name as xs:string
) as empty-sequence()
{
	re:throw-xml-error ('HTTP-DUPPARAM', 400, "Only one value allowed",
		<e:duplicate-parameter-value>
			<e:message>{fn:concat ("Only one value allowed for '", $field-name, "'")}</e:message>
			<e:request-field>{$field-name}</e:request-field>
		</e:duplicate-parameter-value>)
};

declare function get-optional-single-request-field (
	$field-name as xs:string,
	$default as xs:string?
) as xs:string?
{
	let $values as xs:string* := xdmp:get-request-field ($field-name, $default)
	return
	if (fn:count ($values) gt 1)
	then throw-missing-param-value-error ($field-name)
	else $values
};

declare function get-required-single-request-field (
	$field-name as xs:string,
	$default as xs:string?
) as xs:string?
{
	let $values as xs:string* := xdmp:get-request-field ($field-name, $default)
	let $values-count as xs:int := fn:count ($values)
	return
	if ($values-count gt 1)
	then throw-missing-param-value-error ($field-name)
	else if ($values-count ne 1)
	then
		re:throw-xml-error ('HTTP-MISSINGPARAM', 400, "Required parameter missing",
			<e:missing-parameter-value>
				<e:message>{fn:concat ("No value provided for '", $field-name, "'")}</e:message>
				<e:request-field>{$field-name}</e:request-field>
			</e:missing-parameter-value>)
	else $values
};

(: ----------------------------------------------------------------- :)

