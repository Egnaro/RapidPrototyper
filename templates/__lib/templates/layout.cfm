<cfprocessingdirective pageencoding="utf-8">
<cfparam name="attributes.pageTitle" default="%projname%" >
<!--- output the header code at the start of tag execution --->
<cfif thisTag.executionMode is "start">
<!DOCTYPE html>
<html>
<head>
	<cfoutput><title>#attributes.pagetitle#</title></cfoutput>

	<link rel="stylesheet" type="text/css" media="all" href="__lib/styles/screen.css" />
	<script language="javascript" type="text/javascript" src="__lib/scripts/global.js"></script>
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
	
	<!--- fire the jQuery document ready --->
	<script type="text/javascript">
		$(document).ready(
		
		);
	</script>
</head>
<body>

<!--- output the footer code at the end of tag execution --->
<cfelse>

</body>
</html>
</cfif>
