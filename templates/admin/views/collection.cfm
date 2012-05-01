<cfparam name="url.parentid" default="">
<cfscript>
	srv = CreateObject("%cfcdotpath%.%objdisplayname%Service");
	
	if(IsDefined("url.delete")){
		obj = EntityLoadByPK("%objdisplayname%", url.delete);
		obj.delete();
		ORMFlush();
	}
	
	if(Len("url.parentid") && IsDefined("url.parenttype")){
		// get only objects related to parentid
		objs = srv.getChildrenOf(url.parentid,url.parenttype);
	} else {
		objs = srv.getAll();	
	}
</cfscript>
<!DOCTYPE html>
<html>
<head>
	<title>%projname% Back-end: %objdisplayname% Collection</title>
</head>
<body>
	<cfoutput>
		<h2>%objdisplayname% Collection</h2>
		<hr>
		<a href="../index.cfm">[Admin Home]</a>%parentlink%
		<a href="%objname%Object.cfm?id=&parentid=#url.parentid#">[Create New %objdisplayname%]</a><br><br>
		
		<h3>Choose an object to view/edit:</h3>
		<cfloop array="#objs#" index="o">
			<a href="%objname%Object.cfm?id=#o.getId()#&parentid=#url.parentid#">#o.get%objlabel%()#</a> <a href="%objname%Collection.cfm?delete=#o.getId()#">[delete]</a><br>
		</cfloop>
	</cfoutput>
</body>
</html>