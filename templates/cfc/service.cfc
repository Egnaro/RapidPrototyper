<cfcomponent displayname="%objdisplayname% Service" hint="Facade for all %objdisplayname% related model interactions" output="false">
	
	<cffunction 
		name="getObjectsByIds" 
		access="remote" 
		displayname="Get %objdisplayname% Items"
		output="false"
		>
		
		<cfargument name="ids" required="true" type="array">
		<cfargument name="pageSize" required="false" type="numeric" default="100">
		<cfargument name="page" required="false" type="numeric" default="1">
		<cfargument name="sortby" required="false" type="string">
		
		<cfscript>
			var local.ormoptions = {maxResults = arguments.pageSize, offset = (arguments.page - 1) * arguments.pageSize, cacheable=true, cachename='%objname%set', timeout=120};
		</cfscript>
		
		<cfquery name="qResult" dbtype="hql" ormoptions="#local.ormoptions#">
			SELECT o
			FROM %objdisplayname% o
			WHERE o.id IN ('#ArrayToList(arguments.ids)#')
			<cfif IsDefined("arguments.sortby") AND Len(arguments.sortby) AND arguments.sortby NEQ "undefined">
				ORDER BY #arguments.sortby#
			</cfif>
		</cfquery>
		
		<cfreturn qResult>
	</cffunction>
	
	%getChildrenFunc%
	
	<cffunction 
		name="getAll" 
		displayname="Get all %objdisplayname%" 
		access="remote" 
		returntype="array" 
		output="false"
		>
	
		<cfreturn EntityLoad("%objdisplayname%")>
	</cffunction>
	
</cfcomponent>
