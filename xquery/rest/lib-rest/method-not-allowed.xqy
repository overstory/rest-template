xquery version "1.0-ml";

import module namespace re="urn:overstory:rest:modules:rest:errors" at "errors.xqy";

declare variable $method as xs:string? := xdmp:get-request-method();

re:throw-xml-error ('REST-METHODNOTALLOWED', 405, 'Method not allowed', re:not-allowed-error ($method))
