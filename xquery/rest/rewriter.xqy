xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest" at "/MarkLogic/appservices/utils/rest.xqy";
import module namespace endpoints="urn:overstory:rest:modules:endpoints" at "endpoints.xqy";

declare variable $uri := xdmp:get-request-url();
declare variable $rewrite as xs:string? := rest:rewrite (endpoints:options());

if (fn:empty ($rewrite)) then $uri else $rewrite
