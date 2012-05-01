<cfprocessingdirective pageencoding="utf-8">
<cfparam name="section" default="home">
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
<cfsavecontent variable="headextras">
	<link rel="stylesheet" type="text/css" media="all" href="__lib/styles/screen.css" />
	<script language="javascript" type="text/javascript" src="__lib/scripts/global.js"></script>
</cfsavecontent>
<cfset pageTitle = "%projname%">
<cfmodule template="#application.relPath#_templates/tags/layout.cfm" title="#pageTitle#" section="#section#">
<cfhtmlhead text="#headextras#">
<div class="whatever">
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