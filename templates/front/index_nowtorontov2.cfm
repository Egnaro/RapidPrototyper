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
<cfmodule template="/_templates/tags/layout.cfm" title="#pageTitle#" section="#section#">
<cfhtmlhead text="#headextras#">
<div id="content">
	<div id="colLeft">
		<cfif Len(request.view) AND Len(request.type)>
			<cfinclude template="__lib/templates/#request.type#_#request.view#.cfm" >
		<cfelse>
			<div class="genre">Pages</div>
			%pagelinks%
			
			<div class="genre">Available Collections</div>
			%collectionlinks%
		</cfif>
	</div>
	<div id="colRight">
		<cfinclude template="/_templates/includes/ads/big_box.cfm">
		<div class="hr"></div>
	</div>
	<div style="clear: both;"></div>
</div>
</cfmodule>