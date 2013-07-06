xquery version "1.0-ml";

module namespace rc="urn:overstory:rest:modules:constants";

declare variable $MEDIA-TYPE-ERROR-XML as xs:string := "application/vnd.overstory:rest.error+xml";
declare variable $MEDIA-TYPE-STANDARD-XML as xs:string := "application/xml";

declare variable $HTTP-OK as xs:int := 200;
declare variable $HTTP-CREATED as xs:int := 201;
declare variable $HTTP-NO-CONTENT as xs:int := 204;
declare variable $HTTP-NOT-MODIFIED as xs:int := 304;
declare variable $HTTP-BAD-REQUEST as xs:int := 400;
declare variable $HTTP-UNAUTHORIZED as xs:int := 401;
declare variable $HTTP-PAYMENT-REQUIRED as xs:int := 402;
declare variable $HTTP-NOT-FOUND as xs:int := 404;
declare variable $HTTP-NOT-ACCEPTABLE as xs:int := 406;
declare variable $HTTP-CONFLICT as xs:int := 409;
declare variable $HTTP-PRECONDITION-FAILED as xs:int := 412;
declare variable $HTTP-UNSUPPORTED-NEDIA-TYPE as xs:int := 415;
declare variable $HTTP-INTERNAL-SERVER-ERROR as xs:int := 500;
declare variable $HTTP-SERVICE-UNAVAILABLE as xs:int := 503;

