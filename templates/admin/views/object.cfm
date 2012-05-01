<cfscript>
	srv = CreateObject("%cfcdotpath%.%objdisplayname%Service");
	
	if(IsDefined("form.submit")){
		if(form.id == ""){
			obj = new %cfcdotpath%.%objdisplayname%();
		} else {
			ids = [form.id];
			objs = srv.getObjectsByIds(ids);
			if(ArrayLen(objs)){
				obj = objs[1];
			} else {
				obj = new %cfcdotpath%.%objdisplayname%();
			}
		}
		%objsetprops%
		obj.save();
		
		%addobjecttoparent%
		
		ORMFlush();
		
	} else {
		if(url.id == ""){
			obj = new %cfcdotpath%.%objdisplayname%();
		} else {
			ids = [url.id];
			objs = srv.getObjectsByIds(ids);
			if(ArrayLen(objs)){
				obj = objs[1];
			} else {
				obj = new %cfcdotpath%.%objdisplayname%();
			}
		}
	}
</cfscript>
<!DOCTYPE html>
<html>
<head>
	<title>%projname% Back-end: %objdisplayname%</title>
</head>
<body>
	<cfoutput>
		<h2>#obj.get%objlabel%()#</h2>
		<h3>#obj.getId()#</h3>
		%returnlink%
		<hr>
		<form method="post" enctype="multipart/form-data">
			<input type="hidden" name="id" value="#obj.getId()#" />
			%formfields%
			<input type="submit" name="submit" value="Save" />
		</form>
		<hr>
		%childobjects%
	</cfoutput>
</body>
</html>