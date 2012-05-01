<!---
Name    : 404.cfm
Purpose	: OnMissing Template Handler File - Change it based on your Requirement. 
--->
<cfparam name="URL.thePage" default="">
<cfif Not Len(Trim(URL.thePage))>
	<cflocation url="index.cfm" addToken="false">
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<title>Error 404 - DANG IT! Page Not Found!</title>
	</head>
	<body>
		<h2>Error 404 - DANG IT! Page Not Found!</h2>
		<p>
			The page you were looking for <cfoutput>#URL.thePage#</cfoutput> could not be found on the site. 
			<br/>We even asked the FBI and CIA, but neither one of them were able to find the page.
		</p>
		<p>Try one of these instead:<br/>
			<a href="index.cfm">Home</a> | <a href="javascript:window.history.go(-1)">Go Back</a>
		</p>
</body>
</html>