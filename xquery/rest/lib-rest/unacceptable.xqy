xquery version "1.0-ml";

import module namespace re="urn:overstory:rest:modules:rest:errors" at "../lib-rest/errors.xqy";

declare variable $mediatype as xs:string? := xdmp:url-decode (xdmp:get-request-field ("mediatype"));

re:throw-xml-error ('REST-UNACCEPT', 406, 'Requested mediatype not supported', re:unacceptable-error ($mediatype))
