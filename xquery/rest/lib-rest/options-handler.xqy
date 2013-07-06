xquery version "1.0-ml";

(: FIXME: improve the format of this result, hide internal module names :)

import module namespace rest="http://marklogic.com/appservices/rest" at "/MarkLogic/appservices/utils/rest.xqy";

import module namespace endpoints="urn:overstory:rest:modules:endpoints" at "../rest/endpoints.xqy";

declare option xdmp:mapping "false";

declare variable $request as element(rest:request) :=
	<request xmlns="http://marklogic.com/appservices/rest" uri="^(.*)$" endpoint="/options.xqy" user-params="allow">
		<uri-param name="__ml_options__">$1</uri-param>
		<http method="OPTIONS"/>
	</request>;

try {
	let $params  := rest:process-request ($request)
	let $ruri    := map:get ($params, "__ml_options__")
	let $accept  := xdmp:get-request-header ("Accept")
	let $params := map:map()
	let $_ :=
		for $name in xdmp:get-request-field-names()
		return map:put ($params, $name, xdmp:get-request-field($name))

	return
		<options xmlns="http://marklogic.com/appservices/rest">{
			if ($ruri = "/")
			then
			  endpoints:options()/rest:request
			else
			  rest:matching-request (endpoints:options(), $ruri, "GET", $accept, $params)
		}</options>
} catch ($e) {
	rest:report-error ($e)
}