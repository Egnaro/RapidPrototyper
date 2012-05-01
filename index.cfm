<cfdump var="#form#" expand="false">

<cfparam name="generated" default="false" >
<cfparam name="session.step" default="1">
<cfparam name="session.views" default="#ArrayNew(1)#">
<cfparam name="session.projectname" default="">
<cfparam name="session.dsn" default="">

<cfif IsDefined("form.generate")>
	<cfset session.targetmode = form.targetmode>
	<cfinclude template="generator.cfm">
	<cfset generated = true> 
</cfif>

<cfscript>
	if(IsDefined("url.reset")){
		session.step = 1;
		session.views = ArrayNew(1);
		session.projectname = "";
		session.dsn = "";
	}

	if(IsDefined("form.step") && form.step == 1){
		session.projectname = form.projectname;
		for(i = 1; i <= ListLen(form.views); i++){
			session.views[i] = StructNew();
			session.views[i].name = ListGetAt(form.views,i);
		}
		session.step = form.step + 1;
	}
	
	if(IsDefined("form.step") && form.step == 2){
		for(i=1; i <= ArrayLen(session.views); i++){
			vt = form['VT'&i];
			session.views[i].type = vt;
			session.views[i].objects = ArrayNew(1);
			
			if(vt == "object"){
				obj = StructNew();
				obj.name = session.views[i].name;
				tmp = ArrayAppend(session.views[i].objects, obj);
			}
		}
		
		session.step = form.step + 1;
	}
	
	if(IsDefined("form.step") && form.step == 3){
		// process the object parameters
		for(i=1; i <= ArrayLen(session.views); i++){
			if(session.views[i].type == "object"){
				tmpparams = form["objectparams_" & session.views[i].objects[1].name];
				for(j=1; j <= ListLen(tmpparams); j++){
					curritem = ListGetAt(tmpparams, j);
					tmp = StructInsert(session.views[i].objects[1], ListFirst(curritem,"-"), ListLast(curritem,"-"));
					session.views[i].objects[1].label = form["objectlabel_" & session.views[i].objects[1].name];
				}
			}
		}
		
		session.step = form.step + 1;
	}
	
	if(IsDefined("form.step") && form.step == 4){
		for(i=1; i <= ArrayLen(session.views); i++){
			if(session.views[i].type == "object"){
				// set defaults
				session.views[i].objects[1].ischild = false;
				session.views[i].objects[1].children = "";
				session.views[i].objects[1].isparent = false;
			}
		}
			
		for(i=1; i <= ArrayLen(session.views); i++){
			if(session.views[i].type == "object" && session.views[i].objects[1].ischild != true){
				writeoutput("inspecting object: #session.views[i].objects[1].name#<br>");	
				if(ListFindNoCase(form.fieldnames, "objectchildren_#session.views[i].objects[1].name#")){
					children = form["objectchildren_" & session.views[i].objects[1].name];
					session.views[i].objects[1].children = children;
					session.views[i].objects[1].isparent = true;
					writeoutput("found form field: objectchildren_#session.views[i].objects[1].name#<br>");
					writeoutput("children: #children#<br>");
					// mark other objects as children and name their parent
					for(c=1; c <= ListLen(children); c++){
						// loop over objects to look for names that match the child name
						for(o=1; o <= ArrayLen(session.views); o++){
							if(session.views[o].type == "object" 
								&& session.views[o].objects[1].name == ListGetAt(children, c)
								&& session.views[o].objects[1].ischild != true){
								session.views[o].objects[1].ischild = true;
								session.views[o].objects[1].parent = session.views[i].objects[1].name;
							}
						}
					}
				}
			}
		}
		
		session.step = form.step + 1;
	}
	
	if(IsDefined("form.step") && form.step == 5){
		for(i=1; i <= ArrayLen(session.views); i++){
			if(session.views[i].type == "collection"){
				sltobj = form["obj" & i];
				session.views[i].objectmap = sltobj;
			} else {
				session.views[i].objectmap = "";
			}
		}

		session.step = form.step + 1;
	}
	
	if(IsDefined("form.step") && form.step == 6){
		session.dsn = form.dsn;
		session.filedest = form.filedest;
		session.step = form.step + 1;
	}
</cfscript>
<cfdump var="#session#" expand="false">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Rapid Prototyper</title>
</head>
<body>
	<h2>Generate A Rapid Prototype</h2>
	<a href="index.cfm?reset=1">[reset]</a>
	<hr>
	<cfoutput>
		<cfif session.step EQ 1>	
			<h3>Step 1. Define the views</h3>
			<form method="post" action="index.cfm">
				<input type="hidden" name="step" value="1">
				<label for="projectname">Project name:</label> 
				<input type="text" name="projectname"><br>
				<label for="views">Views:</label> 
				<input type="text" name="views">
				<input type="submit" name="submit" value="submit">
			</form>
			<p>Enter your list of views in a comma separated list. The views represent each page in the application. ie. index, browse, profile</p>
		
		<cfelseif session.step EQ 2>
			<h3>Step 2. Define types for the views</h3>
			<form method="post" action="index.cfm">
				<input type="hidden" name="step" value="2">
				<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
					#session.views[i].name#: 
					<select name="vt#i#">
						<option value="home">home</option>
						<option value="collection">collection</option>
						<option value="object">object</option>
					</select>
					<br>
				</cfloop>
				<input type="submit" name="submit" value="submit">
			</form>	
		
		<cfelseif session.step EQ 3>
			<h3>Step 3. Define objects</h3>
			<form method="post" action="index.cfm">
				<input type="hidden" name="step" value="3">
				<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
					<cfif session.views[i].type EQ "object">
						#session.views[i].objects[1].name# <input type="text" name="objectparams_#session.views[i].objects[1].name#" size="60"><br>
						What field should be used as a display label? <input type="text" name="objectlabel_#session.views[i].objects[1].name#" size="10"><br>
						(hint: typically the label would be a title field)<br>
						<hr>
					</cfif>
				</cfloop>
				<input type="submit" name="submit" value="submit">
			</form>
			<p>For each object enter in the name of the required parameters and put it's datatype after ie. <br>
				fname-string(20),desc-text(20),isactive-boolean(1),age-integer(4),src-file(1)</p>
				
		<cfelseif session.step EQ 4>
			<h3>Step 4. Assign Object Relationships</h3>
			
			<!--- create a list of objects for re-use in form --->
			<cfset objlist = "">
			<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
				<cfif session.views[i].type EQ "object">
					<cfset objlist = ListAppend(objlist, session.views[i].objects[1].name)>
				</cfif>
			</cfloop>
			
			<form method="post" action="index.cfm">
				<input type="hidden" name="step" value="4">
				<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
					<cfif session.views[i].type EQ "object">
						#session.views[i].objects[1].name# HAS <br>
						<select name="objectchildren_#session.views[i].objects[1].name#" multiple="true" size="4">
							<cfloop list="#objlist#" index="o">
								<option value="#o#">#o#</option>
							</cfloop>
						</select>	
						<br>
					</cfif>
				</cfloop>
				Notes: <br>
				<ul>
					<li>you can select multiple child objects for each parent.</li>
					<li>errors may occur if you try creating parent-child-child type relationships</li>
					<li>recommend sticking to simple parent-child relationships and adding more complex relationships manually once code is generated</li>
				</ul> 
				<input type="submit" name="submit" value="submit">
			</form>
		
		<cfelseif session.step EQ 5>
			<h3>Step 5. Assign Objects to Front End Collection Views</h3>

			<form method="post" action="index.cfm">
				<input type="hidden" name="step" value="5">
				<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
					<cfif session.views[i].type EQ "collection">
						#session.views[i].name#: 
						<select name="obj#i#">
							<cfloop from="1" to="#ArrayLen(session.views)#" index="j">
								<cfif session.views[j].type EQ "object">
									<option value="#session.views[j].objects[1].name#">#session.views[j].objects[1].name#</option>
								</cfif>
							</cfloop>
						</select>
						<br>
					</cfif>
				</cfloop>
				<input type="submit" name="submit" value="submit">
			</form>
		
		<cfelseif session.step EQ 6>
			<h3>Step 6. Settings</h3>
			<cfscript>
				dsnService = createobject("java","coldfusion.server.ServiceFactory").getDatasourceService();
				dsnObj = dsnService.getNames();
				//writedump(dsnObj);abort;
			</cfscript>
			<form method="post" action="index.cfm">
				<input type="hidden" name="step" value="6">
				<label for="dsn">Choose a datasource: </label>
				<select name="dsn">
					<cfloop array="#dsnObj#" index="dsn">
						<option value="#dsn#">#dsn#</option>
					</cfloop>
				</select>
				<br>
				<label for="filedest">File upload directory:</label> 
				<input type="text" name="filedest"><br>
				Hint: if any of your objects use the "file" type, they will be able to upload files. The default path for uploads 
				is @appdir@/_assets/uploads/. If you want to use a different directory enter the absolute file path here.<br>
				<input type="submit" name="submit" value="submit">
			</form>
			
		<cfelseif session.step EQ 7>
			<h3>Step 7. Review</h3>
			<hr>
			<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
				<div style="float: left; width: 200px; height: 300px; border: 1px solid black; margin: 4px; padding: 4px;">
					page: #session.views[i].name#<br>
					template: #session.views[i].type#<br>
					<cfif session.views[i].type EQ "collection">collection of: #session.views[i].objectmap#<br></cfif>
					<cfif session.views[i].type EQ "object">
						object: <cfdump var="#session.views[i].objects[1]#">
					</cfif>
				</div>
			</cfloop>
			<div style="clear: both;"></div>
			<hr>
			<form method="post" action="index.cfm">
				<input type="hidden" name="generate" value="true">
				<label for="targetmode">Choose a target mode: </label>
				<select name="targetmode">
					<option value="standalone">Standalone App</option>
					<option value="nowtorontov2">nowtoronto.com v2</option>
					<option value="nowtorontov3">nowtoronto.com v3</option>
				</select>
				<input type="submit" name="submit" value="Generate Code!">
			</form>
			<hr>
			<cfif generated>
				<a href="output/#LCase(ReplaceNoCase(session.projectname, ' ', 'all'))#/index.cfm" target="_blank">Launch Site</a><br>
				<a href="output/#LCase(ReplaceNoCase(session.projectname, ' ', 'all'))#/admin/index.cfm" target="_blank">Launch Admin</a><br>
			</cfif>
		</cfif>
	</cfoutput>
</body>
</html>