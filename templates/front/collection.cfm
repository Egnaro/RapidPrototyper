<cfscript>
	srv = CreateObject("%cfcdotpath%.%objdisplayname%Service");
	objs = srv.getAll();
</cfscript>
<cfoutput>
<h2>%objdisplayname% Collection</h2>
<input type="button" value="Back" onclick="goBack();" />
<hr>
<cfloop array="#objs#" index="o">
	<a href="index.cfm?view=%objname%&type=object&id=#o.getId()#">#o.get%objlabel%()#</a><br>
</cfloop>
</cfoutput>