xquery version "1.0-ml";

import module namespace re="urn:overstory:rest:modules:rest:errors" at "errors.xqy";

declare variable $uri as xs:string? := xdmp:url-decode (xdmp:get-request-field ("uri"));

re:throw-xml-error('REST001', 404, 'No such resource', re:no-resource($uri))
