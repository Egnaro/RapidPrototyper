<cfflush interval="50">

<cfscript>
	/*
		 Capitalizes the first letter in each word.
		 Made udf use strlen, rkc 3/12/02
		 v2 by Sean Corfield.
		 
		 @param string      String to be modified. (Required)
		 @return Returns a string. 
		 @author Raymond Camden (ray@camdenfamily.com) 
		 @version 2, March 9, 2007 
	*/
	
	function CapFirst(str){
		var newstr = "";
		var word = "";
		var separator = "";
		
		for(i=1; i <= ListLen(str, " "); i++){
			word = ListGetAt(str, i, " ");
			newstr = newstr & separator & UCase(Left(word,1));
			if(Len(word) > 1){
				newstr = newstr & Right(word, Len(word)-1);
			}
			separator = " ";
		}
		return newstr;	
	}
	
	/*
		 Checks for Directory existence and creates it if not exists
		 v1 by Rick Mason
		 
		 @param newdir       path of new directory to create. (Required)
		 @return Returns a string. 
		 @author Rick Mason 
		 @version 1, Apr 5, 2012
	*/
	
	function newDirectory(newdir){
		if(!DirectoryExists(newdir)){
			DirectoryCreate(newdir);
		}
		
		return newdir;
	}
	
	/* ************************************************************ */
	
	// setup and create required directories
	
	basedir = ExpandPath( "./" );
	dirname = LCase(ReplaceNoCase(session.projectname, " ", "all"));
	projdir = basedir & "output/" & dirname;
	cfcdir = projDir & "/__lib/com/" & dirname;
	cfcpath = "RapidPrototyper/output/" & dirname & "/__lib/com/" & dirname;
	cfcdotpath = Replace(cfcpath, "/", ".", "all");
	if(Len(session.filedest)){
		fileuploaddir = session.filedest;
	} else {
		fileuploaddir = "#projdir#/_assets/uploads/";
	}
	
	writeoutput("baseDir: #baseDir#<br>");
	writeoutput("dirname: #dirname#<br>");
	writeoutput("projdir: #projdir#<br>");
	writeoutput("cfcdir: #cfcdir#<br>");
	writeoutput("fileuploaddir: #fileuploaddir#<br>");
	
	reqDirs = ["#projdir#",
		"#cfcdir#",
		"#projDir#/admin",
		"#projDir#/admin/views",
		"#projDir#/__lib",
		"#projDir#/__lib/scripts",
		"#projDir#/__lib/styles",
		"#projDir#/__lib/templates",
		"#projDir#/__lib/handlers",
		"#projdir#/_assets",
		"#projdir#/_assets/uploads"];
	
	for(i=1; i <= ArrayLen(reqDirs); i++){
		newDirectory(reqDirs[i]);
	}
	
	
	// write default files: Application.cfc, etc
	if(ListFind("nowtorontov2,nowtorontov3", session.targetmode)){
		cfcpath = dirname & "/__lib/com/" & dirname;
		cfcdotpath = Replace(cfcpath, "/", ".", "all");
		
		appcfc = FileRead("#baseDir#/templates/ApplicationExtended.txt");
		// we're embedded the app in the nowtoronto.com framework so we need to extend the root Application.cfc
		// NOTE: ApplicationProxy.cfc must go in the webroot with the Application.cfc that is being extended
	} else {
		appcfc = FileRead("#baseDir#/templates/Application.txt");	
	}
	appname = dirname & RandRange(1,100);
	appcfc = Replace(appcfc, "%appname%", appname, "all");
	appcfc = Replace(appcfc, "%appdsn%", session.dsn, "all");
	appcfc = Replace(appcfc, "%cfcpath%", cfcpath, "all");
	appcfc = Replace(appcfc, "%cfcdir%", cfcdir, "all");
	appcfc = Replace(appcfc, "%fileuploaddir%", fileuploaddir, "all");
	appcfc = Replace(appcfc, '%appextends%', 'extends="ApplicationProxy"', 'all');
	
	FileWrite("#projDir#/Application.cfc", appcfc);
	FileCopy("#baseDir#templates/cfc/SimpleBasePersistentObject.cfc", "#projDir#/__lib/com/#dirname#/SimpleBasePersistentObject.cfc");
</cfscript>

<!--- generate the SQL to create tables --->
<!--- ditching this in favour of using ORM based generation --->
<!---<cfoutput>
<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
	<cfif session.views[i].type EQ "object">
		<cfset item = session.views[i]>
		<cfset obj = item.objects[1]>
		<cfset keys = StructKeyArray(obj)>
		<cfsavecontent variable="sqlcode">
			CREATE TABLE #obj.name#
			<cfloop from="1" to="#ArrayLen(keys)#" index="j">
				<cfif keys[j] NEQ "name">
					#keys[j]# #obj[keys[j]]#<cfif j LT ArrayLen(keys)>,</cfif>
				</cfif>
			</cfloop>
		</cfsavecontent>
		<cffile action="write" file="#projDir#\sql\#obj.name#.sql" output="#sqlcode#" >
	</cfif>
</cfloop>
</cfoutput>--->

<!--- generate the CFC's for objects and services --->
<cfoutput>
<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
	<cffile action="read" file="#baseDir#/templates/cfc/object.cfc" variable="objcfc">
	<cffile action="read" file="#baseDir#/templates/cfc/service.cfc" variable="srvcfc">
	<cfif session.views[i].type EQ "object">
		<cfset item = session.views[i]>
		<cfset obj = item.objects[1]>
		<cfset keys = StructKeyArray(obj)>
		
		<!--- write the object cfc --->
		<cfsavecontent variable="objprops">
			property name="id" type="string" fieldtype="id" ormtype="string" generator="guid" length="40" notnull="true";
			<cfloop from="1" to="#ArrayLen(keys)#" index="j">
				<cfif keys[j] EQ "children">
					<cfset children = obj[keys[j]]>
					<cfloop list="#children#" index="c">
						property name="#c#s" singularname="#c#" fieldtype="one-to-many" cfc="#CapFirst(c)#" fkcolumn="fk_#obj.name#id" type="array";
					</cfloop>
				<cfelseif NOT ListFindNoCase("name,label", keys[j])>
					<cfset dt = obj[keys[j]]>
					<cfset dtlen = ListLast(dt,"(")>
					<cfset dtlen = Replace(dtlen, ")", "")>
					<cfset dt = ListFirst(dt, "(")>
					<cfset pname = keys[j]>
					
					<cfswitch expression="#dt#">
						<cfcase value="string">
							property name="#pname#" type="string" fieldtype="column" ormtype="string" length="#dtlen#";
						</cfcase>
						<cfcase value="text">
							property name="#pname#" type="string" fieldtype="column" ormtype="text" length="#dtlen#";
						</cfcase>
						<cfcase value="timestamp">
							property name="#pname#" type="date" fieldtype="column" ormtype="timestamp" notnull="true";
						</cfcase>
						<cfcase value="boolean">
							property name="#pname#" type="boolean" fieldtype="column" ormtype="boolean" default="#dtlen#";
						</cfcase>
						<cfcase value="float">
							property name="#pname#" type="numeric" fieldtype="column" ormtype="float";
						</cfcase>
						<cfcase value="integer">
							property name="#pname#" type="numeric" fieldtype="column" ormtype="integer" length="#dtlen#";
						</cfcase>
						<cfcase value="file">
							property name="#pname#" type="string" fieldtype="column" ormtype="string" length="255";
						</cfcase>
						<cfdefaultcase>
							<!--- do nothing --->
						</cfdefaultcase>
					</cfswitch>
				</cfif>
			</cfloop>
		</cfsavecontent>
		<cfscript>
			objcfc = Replace(objcfc, "%cfcdotpath%", cfcdotpath, "all");
			objcfc = Replace(objcfc, "%projname%", dirname, "all");
			objcfc = Replace(objcfc, "%objdisplayname%", CapFirst(obj.name), "all");
			objcfc = Replace(objcfc, "%objname%", obj.name, "all");
			objcfc = Replace(objcfc, "%objproperties%", objprops, "all");
		</cfscript>
		
		<cffile action="write" file="#cfcdir#/#CapFirst(obj.name)#.cfc" output="#objcfc#" >
		
		<!--- write the service cfc --->
		<cfsavecontent variable="getChildrenFunc" >
			<cfif obj.ischild>
				|[cffunction 
					name="getChildrenOf" 
					access="remote" 
					displayname="Get #obj.name# That Are Children of a #obj.parent# based on id"
					output="false"
					]|
					
					|[cfargument name="parentid" required="true" type="string"]|
					
					|[cfscript]|
						var obj = EntityLoadByPK("#CapFirst(obj.parent)#",arguments.parentid);
						var children = obj.get#ListFirst(obj.name)#s();
						return children;
					|[/cfscript]|
			
				|[/cffunction]|
			</cfif>
		</cfsavecontent>
		<cfscript>
			srvcfc = Replace(srvcfc, "%projname%", dirname, "all");
			srvcfc = Replace(srvcfc, "%getChildrenFunc%", getChildrenFunc, "all");
			srvcfc = Replace(srvcfc, "%objdisplayname%", CapFirst(obj.name), "all");
			srvcfc = Replace(srvcfc, "%objname%", obj.name, "all");
			srvcfc = Replace(srvcfc, "%cfcdotpath%", cfcdotpath, "all");
			srvcfc = Replace(srvcfc, "|[", "<", "all");
			srvcfc = Replace(srvcfc, "]|", ">", "all");
		</cfscript>
		
		<cffile action="write" file="#cfcdir#/#CapFirst(obj.name)#Service.cfc" output="#srvcfc#" >
	</cfif>
</cfloop>
</cfoutput>
	
<!--- 
	*****************************************
	* Backend forms and lists 
	*****************************************
--->

<!--- write the admin home page --->
<cffile action="read" file="#baseDir#/templates/admin/index.cfm" variable="adminindex">
<cfoutput>
<cfsavecontent variable="objectlinks">
	<!--- create a link to an edit form for all parent objects --->
	<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
		<cfif session.views[i].type EQ "object" && !session.views[i].objects[1].ischild>
			<cfset item = session.views[i]>
			<cfset obj = item.objects[1]>
			<a href="views/#obj.name#Collection.cfm">#obj.name#</a><br/>
		</cfif>
	</cfloop>
</cfsavecontent>
</cfoutput>
<cfscript>
	adminindex = Replace(adminindex, "%projname%", dirname, "all");
	adminindex = Replace(adminindex, "%objectlinks%", objectlinks, "all");
</cfscript>
<cffile action="write" file="#projDir#/admin/index.cfm" output="#adminindex#">

<!--- write the collection and object views --->
<cfoutput>
<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
	Looking at view: #session.views[i].name# of type #session.views[i].type#... <br>
	<cfif session.views[i].type EQ "object">
		<!--- generate the collection view --->
		<cfset obj = session.views[i].objects[1]>
		<cfset formfields = "">
		<cffile action="read" file="#baseDir#/templates/admin/views/collection.cfm" variable="admincollection">
		<cfsavecontent variable="parentlink">
			<cfif obj.ischild>
				| <a href="#obj.parent#Object.cfm?id=##url.parentid##">[Back to #obj.parent#]</a>
			</cfif>
		</cfsavecontent>
		<cfscript>
			admincollection = Replace(admincollection, "%projname%", dirname, "all");
			admincollection = Replace(admincollection, "%cfcdotpath%", cfcdotpath, "all");
			admincollection = Replace(admincollection, "%objdisplayname%", CapFirst(obj.name), "all");
			admincollection = Replace(admincollection, "%objname%", obj.name, "all");
			admincollection = Replace(admincollection, "%objlabel%", obj.label, "all");
			admincollection = Replace(admincollection, "%parentlink%", parentlink, "all");
		</cfscript>
		<cffile action="write" file="#projDir#/admin/views/#obj.name#Collection.cfm" output="#admincollection#">
		#projDir#/admin/views/#obj.name#Collection.cfm written.<br>
		
		<!--- generate the object view / edit form --->
		<cffile action="read" file="#baseDir#/templates/admin/views/object.cfm" variable="adminobject">
		<cfset keys = StructKeyArray(obj)>
		<cfsavecontent variable="objsetprops">
			<cfloop from="1" to="#ArrayLen(keys)#" index="j">
				<cfset pname = keys[j]>
				<cfif ListFirst(obj[keys[j]], "(") EQ "file">
					thefile = FileUpload(application.#appname#.fileuploaddir, "#pname#", "image/jpeg,image/png,image/gif", "MakeUnique");
					fileloc = thefile.serverFile;
					obj.set#Pname#(fileloc);
				<cfelseif NOT ListFindNoCase("name,label", keys[j])>
					<cfset pname = keys[j]>
					<cfif NOT ListFindNoCase("parent,children,isparent,ischild", pname)>
						obj.set#Pname#(form.#pname#);
					</cfif>
				</cfif>
			</cfloop>
		</cfsavecontent>
		<cfsavecontent variable="addobjecttoparent">
			<cfif obj.ischild>
				if(IsDefined("url.parentid") && Len(url.parentid)){
					parentobj = EntityLoadByPK("#obj.parent#",url.parentid);
					parentobj.add#obj.name#(obj);
					parentobj.save();
				}
			</cfif>
		</cfsavecontent>
		<cfsavecontent variable="returnlink">
			<cfif obj.ischild>
				<a href="%objname%Collection.cfm?parentid=##url.parentid##&parenttype=#obj.name#">[return to parent collection]</a>
			<cfelse>
				<a href="%objname%Collection.cfm">[return to collection]</a>
			</cfif>
		</cfsavecontent>
		<cfsavecontent variable="childobjects">
			<cfif obj.isparent>
				<cfset child = ListFirst(obj.children)>
				Manage Children:<br>
				<a href="#child#Collection.cfm?parentid=##url.id##&parenttype=#obj.name#">#child#</a><br>
			</cfif>
		</cfsavecontent>
		<cfsavecontent variable="formfields">
			<cfloop from="1" to="#ArrayLen(keys)#" index="j">
				<cfif NOT ListFindNoCase("name,label", keys[j])>
					<cfset dt = ListFirst(obj[keys[j]], "(")>
					<cfset pname = keys[j]>
					<cfswitch expression="#dt#">
						<cfcase value="string">
							<label for="#pname#">#pname#:</label> 
							<input type="text" name="#pname#" value="##obj.get#pname#()##"><br>
						</cfcase>
						<cfcase value="text">
							<label for="#pname#">#pname#:</label><br>
							<textarea name="#pname#">##obj.get#pname#()##</textarea><br>
						</cfcase>
						<cfcase value="file">
							<label for="#pname#">#pname#:</label> 
							<input type="file" name="#pname#"><br>
							Current file: ##obj.get#pname#()##<br>
						</cfcase>
						<cfcase value="timestamp">
							<label for="#pname#">#pname#:</label> 
							<input type="text" name="#pname#" value="##obj.get#pname#()##"><br>
						</cfcase>
						<cfcase value="boolean">
							<label for="#pname#">#pname#:</label> 
							<select name="#pname#">
								<option value="1" <<%cfif obj.get#pname#() EQ 1%>>selected<<%/cfif%>>>true</option>
								<option value="0" <<%cfif obj.get#pname#() EQ 0%>>selected<<%/cfif%>>>false</option>
							</select><br>
						</cfcase>
						<cfcase value="float">
							<label for="#pname#">#pname#:</label> 
							<input type="text" name="#pname#" value="##obj.get#pname#()##"><br>
						</cfcase>
						<cfcase value="integer">
							<label for="#pname#">#pname#:</label> 
							<input type="text" name="#pname#" value="##obj.get#pname#()##"><br>
						</cfcase>
						<cfdefaultcase>
							 <!--- do nothing --->
						</cfdefaultcase>
					</cfswitch>
				</cfif>
			</cfloop>
		</cfsavecontent>
		<cfscript>
			adminobject = Replace(adminobject, "%projname%", dirname, "all");
			adminobject = Replace(adminobject, "%formfields%", formfields, "all");
			adminobject = Replace(adminobject, "%childobjects%", childobjects, "all");
			adminobject = Replace(adminobject, "%addobjecttoparent%", addobjecttoparent, "all");
			adminobject = Replace(adminobject, "%returnlink%", returnlink, "all");
			adminobject = Replace(adminobject, "%cfcdotpath%", cfcdotpath, "all");
			adminobject = Replace(adminobject, "%objdisplayname%", CapFirst(obj.name), "all");
			adminobject = Replace(adminobject, "%objname%", obj.name, "all");
			adminobject = Replace(adminobject, "%objsetprops%", objsetprops, "all");
			adminobject = Replace(adminobject, "<<%", "<", "all");
			adminobject = Replace(adminobject, "%>>", ">", "all");
			adminobject = Replace(adminobject, "%objlabel%", obj.label, "all");
		</cfscript>
		<cffile action="write" file="#projDir#/admin/views/#obj.name#Object.cfm" output="#adminobject#">
		#projDir#/admin/views/#obj.name#Object.cfm written.<br>
	</cfif>
</cfloop>


<!--- write the front-end pages --->
Writing Front-end<br>
<!---generate the index, layout and other standard files --->
<cfswitch expression="#session.targetmode#">
	<cfcase value="nowtorontov2">
		<cffile action="read" file="#baseDir#/templates/front/index_nowtorontov2.cfm" variable="idxtmpl">
	</cfcase>
	<cfcase value="nowtorontov3">
		<cffile action="read" file="#baseDir#/templates/front/index_nowtorontov3.cfm" variable="idxtmpl">
	</cfcase>
	<cfdefaultcase>
		<cffile action="read" file="#baseDir#/templates/front/index.cfm" variable="idxtmpl">
	</cfdefaultcase> 
</cfswitch>
<cffile action="read" file="#baseDir#/templates/__lib/scripts/global.js" variable="jstmpl">
<cffile action="read" file="#baseDir#/templates/__lib/styles/screen.css" variable="csstmpl">
<cffile action="read" file="#baseDir#/templates/__lib/templates/layout.cfm" variable="layouttmpl">

<cfsavecontent variable="collectionlinks">
	<ul class="app">
	<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
		<cfif session.views[i].type EQ "collection">
			<li><a href="index.cfm?view=#session.views[i].objectmap#&type=collection">#session.views[i].name#</a></li>
		</cfif>
	</cfloop>
	</ul>
</cfsavecontent>
<cfsavecontent variable="pagelinks">
	<ul class="app">
	<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
		<cfif session.views[i].type EQ "home">
			<li><a href="index.cfm?view=#session.views[i].name#&type=home">#session.views[i].name#</a></li>
		</cfif>
	</cfloop>
	</ul>
</cfsavecontent>

<cfscript>
	layouttmpl = Replace(layouttmpl, "%projname%", session.projectname, "all");
	idxtmpl = Replace(idxtmpl, "%projname%", session.projectname, "all");
	idxtmpl = Replace(idxtmpl, "%collectionlinks%", collectionlinks, "all");
	idxtmpl = Replace(idxtmpl, "%pagelinks%", pagelinks, "all");
</cfscript>


<cffile action="write" file="#projDir#/index.cfm" output="#idxtmpl#">
<cffile action="write" file="#projDir#/__lib/scripts/global.js" output="#jstmpl#">
<cffile action="write" file="#projDir#/__lib/styles/screen.css" output="#csstmpl#">
<cffile action="write" file="#projDir#/__lib/templates/layout.cfm" output="#layouttmpl#">
standard templates (index, scripts, css, etc) written.<br>

<!--- generate the home, collection and object views --->
<cfloop from="1" to="#ArrayLen(session.views)#" index="i">
	Looking at view: #session.views[i].name# of type #session.views[i].type#... <br>
	<!--- object view --->
	<cfif session.views[i].type EQ "object">
		<cffile action="read" file="#baseDir#/templates/front/object.cfm" variable="objtmpl">
		<cfset item = session.views[i]>
		<cfset obj = item.objects[1]>
		<cfset keys = StructKeyArray(obj)>
		<cfsavecontent variable="objoutput">
			<cfloop from="1" to="#ArrayLen(keys)#" index="j">
				<cfif NOT ListFindNoCase("name,label,isparent,ischild,children,parent", keys[j])>
					<cfset pname = keys[j]>
					<cfif ListFirst(obj[keys[j]], "(") EQ "file">
						<img src="/RapidPrototyper/output/#dirname#/_assets/uploads/##obj.get#pname#()##" border="0" width="150" />
					</cfif>
					#pname#: ##obj.get#pname#()##<br>
				</cfif>
			</cfloop>
		</cfsavecontent>
		<cfsavecontent variable="childrenoutput">
			<cfif obj.isparent>
				|[cfset childrenobjs =  obj.get#ListFirst(obj.children)#s()]|
				|[cfoutput]|
				|[cfloop from="1" to="##ArrayLen(childrenobjs)##" index="c"]|
					<a href="index.cfm?view=#ListFirst(obj.children)#&type=object&id=##childrenobjs[c].getId()##">##childrenobjs[c].getId()##</a><br>
				|[/cfloop]|
				|[/cfoutput]|
			</cfif>
		</cfsavecontent>
		<cfscript>
			objtmpl = Replace(objtmpl, "%projname%", dirname, "all");
			objtmpl = Replace(objtmpl, "%cfcdotpath%", cfcdotpath, "all");
			objtmpl = Replace(objtmpl, "%objdisplayname%", CapFirst(obj.name), "all");
			objtmpl = Replace(objtmpl, "%objname%", obj.name, "all");
			objtmpl = Replace(objtmpl, "%objoutput%", objoutput, "all");
			objtmpl = Replace(objtmpl, "%objlabel%", obj.label, "all");
			objtmpl = Replace(objtmpl, "%childrenoutput%", childrenoutput, "all");
			objtmpl = Replace(objtmpl, "|[", "<", "all");
			objtmpl = Replace(objtmpl, "]|", ">", "all");
		</cfscript>
		<cffile action="write" file="#projDir#/__lib/templates/object_#obj.name#.cfm" output="#objtmpl#">
		#projDir#/__lib/templates/object_#obj.name#.cfm written.<br>
	<!--- collection view --->
	<cfelseif session.views[i].type EQ "collection">
		<cffile action="read" file="#baseDir#/templates/front/collection.cfm" variable="collectiontmpl">
		<cfset item = session.views[i]>
		<cfscript>
			for(k = 1; k <= ArrayLen(session.views); k++){
				if(session.views[k].type == "object" && session.views[k].name == item.objectmap){
					thislbl = session.views[k].objects[1].label;
					break;
				} else {
					thislbl = "";
				}
			}
			
			collectiontmpl = Replace(collectiontmpl, "%projname%", dirname, "all");
			collectiontmpl = Replace(collectiontmpl, "%cfcdotpath%", cfcdotpath, "all");
			collectiontmpl = Replace(collectiontmpl, "%objdisplayname%", CapFirst(item.objectmap), "all");
			collectiontmpl = Replace(collectiontmpl, "%objname%", item.objectmap, "all");
			collectiontmpl = Replace(collectiontmpl, "%objlabel%", thislbl, "all");
		</cfscript>
		<cffile action="write" file="#projDir#/__lib/templates/collection_#item.objectmap#.cfm" output="#collectiontmpl#">
		#projDir#/__lib/templates/collection_#item.objectmap#.cfm written.<br>
	<!--- home view --->
	<cfelseif session.views[i].type EQ "home">
		<cffile action="read" file="#baseDir#/templates/front/home.cfm" variable="hometmpl">
		<cfscript>
			hometmpl = Replace(hometmpl, "%objdisplayname%", CapFirst(session.views[i].name), "all");
		</cfscript>
		<cffile action="write" file="#projDir#/__lib/templates/home_#session.views[i].name#.cfm" output="#hometmpl#">
		#projDir#/__lib/templates/home_#session.views[i].name#.cfm written.<br>
	</cfif>
</cfloop>
</cfoutput>
<hr>
Finished!<hr>