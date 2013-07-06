
Generic template code to setup a customized REST interface on MarkLogic
----

Use this project as a starting point to setup RESTful endpoints on
a MarkLogic appserver.

Do the following

1. Create an HTTP appserver on MarkLogic.  Set the appserver
root to the directory where you've unpacked the content of
this respository, or copy the top-level content of this repo
to the place where you want your appserver root to be.  At
the root there should be: this README file, css, images,
and xquery directories at the top level.

3. Set the error handler and URL rewriter for the appserver.
For the error handler,
enter "/xquery/rest/error-handler.xqy", for the rewriter,
enter "/xquery/rest/rewriter.xqy".

4. Edit rest/endpoints.xqy to add URL patterns to describe
each endpoint and to name an XQuery module under the "handlers"
directory which is a peer to "rest" under "xquery.
This code makes use of the Open Source REST library
provided by MarkLogic, details about how to define endpoints
can be found in the GitHub repo for
[ml-rest-lib](https://github.com/marklogic/ml-rest-lib).

5. Develop your XQuery code to respond to each of the
endpoint URL patterns you've defined.


2013-07-06
Ron Hitchens
ron@overstory.co.uk

