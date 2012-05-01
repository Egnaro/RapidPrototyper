<cfparam name="request.view" default="">
<cfparam name="request.type" default="">
<cfscript>
	if(IsDefined("url.view")){
		request.view = url.view;
	}
	if(IsDefined("url.type")){
		request.type = url.type;
	}
</cfscript>

<cfset pageTitle = "%projname%">
<cfmodule template="__lib/templates/layout.cfm" title="#pageTitle#">
<div class="main">
<cfif Len(request.view) AND Len(request.type)>
	<cfinclude template="__lib/templates/#request.type#_#request.view#.cfm" >
<cfelse>
	<h1>Pages</h1>
	%pagelinks%
	
	<h1>Available Collections</h1>
	%collectionlinks%
</cfif>
</div>
</cfmodule>