xquery version "1.0-ml";

module namespace rc="urn:overstory:rest:modules:common:endpoints";

declare namespace rest="http://marklogic.com/appservices/rest";

declare variable $DEFAULT-ENDPOINTS as element(rest:request)+ :=
	<options xmlns="http://marklogic.com/appservices/rest">
		<!-- Generic handler for requests using OPTIONS method -->
		<request uri="^(.+)$" endpoint="/xquery/lib-rest/options-handler.xqy" user-params="allow">
			<uri-param name="__ml_options__">$1</uri-param>
			<http method="OPTIONS"/>
		</request>

		<!-- Non xquery stuff -->
		<request uri="((.+)\.(css|js|png|jpg|jpeg|gif|pdf|xml|txt))$" user-params="allow">
			<http method="GET"/>
		</request>

		<!-- Catch anything that that didn't match elsewhere -->
		<request uri="(.+)$" endpoint="/xquery/lib-rest/catch-all.xqy" user-params="allow">
			<uri-param name="uri">$1</uri-param>
			<http method="GET"/>
		</request>
	</options>/element();