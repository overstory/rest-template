xquery version "1.0-ml";

import module namespace re="urn:overstory:rest:modules:rest:errors" at "lib-rest/errors.xqy";
import module namespace rc="urn:overstory:rest:modules:constants" at "lib-rest/constants.xqy";

declare namespace e = "http://overstory.co.uk/ns/errors";

declare variable $error:errors as node()* external;

(: ------------------------------------------------------------- :)

(:~
 : Parse the fn:error 3d param, contained in $error:errors/error:data.
 :
 : If there is not exactly one such error:datum element, or if there is an
 : error parsing it, the empty sequence is returned. If not, the resulting
 : parsed document node is returned.
 :)
declare function local:parse-third-param(
) as document-node()?
{
   if ( count($error:errors/error:data/error:datum) eq 1 ) then
      try {
         xdmp:unquote($error:errors/error:data/error:datum)
      }
      catch ( $err ) {
         ()
      }
   else
      ()
};

(:~
 : Return an element e:error.
 :
 : If the error was thrown by the REST layer error library, then such an
 : element is embedded as the fn:error 3d param.  In order to know whether it
 : is the case, we cannot look at the error QName code, as it is included as
 : content, without the proper prefix bound to a namespace URI.  So the only
 : way is to try to parse the 3d param and if it is an e:error element.  If
 : not, we generate a new one with HTTP code 500.
 :
 : TODO: Should we log or return some info from $error:errors?  In addition to
 : the e:error element...
 :)
declare function local:handle-thrown-exception (
) as element(e:error)
{
   (
      local:parse-third-param()/*[. instance of element(e:error)]
      ,
      (: TODO: Do we really want to include the whole $error:errors here,
         with stacktrace and everything? Probably not... :)
      <e:error>
         <e:code>ERRHANDLER001</e:code>
         <e:http-code>500</e:http-code>
         <e:http-status>Internal Server Error</e:http-status>
         <e:description>Uncaught, unexpected XQuery error in the error handler</e:description>
         <e:unspecified-error>{ $error:errors }</e:unspecified-error>
      </e:error>
   )[1]
};

(:~
 : Make an e:error element from atomic values.
 :)
declare function local:make-elem (
   $code as xs:string,
   $http-code as xs:integer,
   $status as xs:string,
   $desc as xs:string,
   $extra as element()?
) as element(e:error)
{
   <e:error>
      <e:code>{ $code }</e:code>
      <e:http-code>{ $http-code }</e:http-code>
      <e:http-status>{ $status }</e:http-status>
      <e:description>{ $desc }</e:description>
      {
         $extra
      }
   </e:error>
};

(:~
 : Return an element e:error.
 :
 : If the error was not thrown by our REST layer error library, it handles some
 : cases specifically (e.g. include the URI when 404).
 :)
declare function local:handle-general-error (
) as element(e:error)
{
   let $resp := xdmp:get-response-code()
   let $code := $resp[1]
   let $msg  := $resp[2]
   return
      if ( $code eq $rc:HTTP-UNAUTHORIZED ) then
         local:make-elem('ERRHANDLER002', $code, 'Unauthorized',
                         'User identity is not valid or is not authorized', ())
      else if ( $code eq $rc:HTTP-NOT-FOUND ) then
         local:make-elem('ERRHANDLER003', $code, 'Not Found', 'Cannot find requested resource',
                         <e:no-resource><e:uri>{ xdmp:get-request-path() }</e:uri></e:no-resource>)
      else if ( $code eq $rc:HTTP-INTERNAL-SERVER-ERROR ) then
         local:make-elem('ERRHANDLER004', $code, 'Internal Server Error',
                         'Unexpected service failure, no further information available', ())
      else
         local:make-elem('ERRHANDLER005', $code, $msg, fn:concat('Unanticipated error code: ', $code), ())
};

(: ------------------------------------------------------------- :)

let $error as element(e:error) :=
      if (fn:exists ($error:errors))
      then local:handle-thrown-exception()
      else local:handle-general-error()

return (
	xdmp:set-response-content-type ($rc:MEDIA-TYPE-ERROR-XML),
	xdmp:set-response-code ($error/e:http-code, $error/e:http-status),
	$error
)
