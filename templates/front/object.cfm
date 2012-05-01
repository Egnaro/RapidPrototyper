<cfscript>
	srv = CreateObject("%cfcdotpath%.%objdisplayname%Service");
	if(IsDefined("url.id") && Len(Trim(url.id))){
		objs = srv.getObjectsByIds([Trim(url.id)]);
		if(ArrayLen(objs)){
			obj = objs[1];
		}
	}
</cfscript>
<cfoutput>
<cfif IsDefined("obj")>
	<h2>#obj.get%objlabel%()#</h2>
</cfif>
<input type="button" value="Back" onclick="goBack();" />
<hr>
<cfif IsDefined("obj")>
%objoutput%
<hr>
%childrenoutput%
<cfelse>
	Object not found.
</cfif>
</cfoutput>