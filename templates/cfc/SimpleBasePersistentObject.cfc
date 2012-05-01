<!---
	// **************************************** LICENSE INFO **************************************** \\
	
	Copyright 2009, Bob Silverberg
	
	Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
	compliance with the License.  You may obtain a copy of the License at 
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software distributed under the License is 
	distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
	implied.  See the License for the specific language governing permissions and limitations under the 
	License.
--->
<cfcomponent output="false">

	<cffunction name="Init" access="Public" returntype="any" output="false" hint="I build a new object.">
		<cfset variables.Metadata = getMetadata(this) />
		<cfparam name="variables.Metadata.cleanseInput" default="false" />
		<cfset configure() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="private" returntype="void" output="false" hint="I do setup specific to an object.">
	</cffunction>

	<cffunction name="populate" access="public" returntype="any" output="false" hint="Populates the object with values from the arguments">
		<cfargument name="data" type="any" required="yes" />
		<cfargument name="propList" type="any" required="no" default="#ArrayNew(1)#" />
		
		<cfloop array="#variables.Metadata.properties#" index="local.theProperty">
			<!--- If a propList was passed in, use it to filter --->
			<cfif NOT ArrayLen(arguments.propList) OR ArrayContains(arguments.propList,local.theProperty.name)>
				<!--- Do columns --->
				<cfif NOT StructKeyExists(local.theProperty,"fieldType") OR local.theProperty.fieldType EQ "column">
					<cfif StructKeyExists(arguments.data,local.theProperty.name)>
						<!--- The property has a matching argument --->
						<cfset local.varValue = arguments.data[local.theProperty.name] />
						<!--- For nullable fields that are blank, set them to null --->
						<cfif (NOT StructKeyExists(local.theProperty,"notNull") OR NOT local.theProperty.notNull) AND NOT Len(local.varValue)>
							<cfset _setPropertyNull(local.theProperty.name) />
						<cfelse>
							<!--- Cleanse input? --->
							<cfparam name="local.theProperty.cleanseInput" default="#variables.Metadata.cleanseInput#" />
							<cfif local.theProperty.cleanseInput>
								<cfset local.varValue = _cleanse(local.varValue) />
							</cfif>
							<cfset _setProperty(local.theProperty.name,local.varValue) />
						</cfif>
					</cfif>
				<!--- do many-to-one --->
				<cfelseif local.theProperty.fieldType EQ "many-to-one">
					<cfif StructKeyExists(arguments.data,local.theProperty.fkcolumn)>
						<cfset local.fkValue = arguments.data[local.theProperty.fkcolumn] />
					<cfelseif StructKeyExists(arguments.data,local.theProperty.name)>
						<cfset local.fkValue = arguments.data[local.theProperty.name] />
					</cfif>
					<cfif StructKeyExists(local,"fkValue")>
						<cfset local.varValue = EntityLoadByPK(local.theProperty.name,local.fkValue) />
						<cfif IsNull(local.varValue)>
							<cfif NOT StructKeyExists(local.theProperty,"notNull") OR NOT local.theProperty.notNull>
								<cfset _setPropertyNull(local.theProperty.name) />
							<cfelse>
								<cfthrow detail="Trying to load a null into the #local.theProperty.name#, but it doesn't accept nulls." />
							</cfif>
						<cfelse>
							<cfset _setProperty(local.theProperty.name,local.varValue) />
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="save" access="public" returntype="any" output="false" hint="Persists the object to the database.">
		<cfset entitySave(this) />
	</cffunction>

	<cffunction name="delete" access="public" output="false" returntype="any" hint="Deletes an object from the database.">
		<cfset entityDelete(this) />
	</cffunction>
	
	<!--- These private methods are used by the populate() method --->

	<cffunction name="_setProperty" access="private" returntype="void" output="false" hint="I set a dynamically named property">
		<cfargument name="name" type="any" required="yes" />
		<cfargument name="value" type="any" required="false" />
		<cfset var theMethod = this["set" & arguments.name] />
		<cfif IsNull(arguments.value)>
			<cfset theMethod(javacast('NULL', '')) />
		<cfelse>
			<cfset theMethod(arguments.value) />
		</cfif>
	</cffunction>
	
	<cffunction name="_setPropertyNull" access="private" returntype="void" output="false" hint="I set a dynamically named property to null">
		<cfargument name="name" type="any" required="yes" />
		<cfset _setProperty(arguments.name) />
	</cffunction>

	<cffunction name="_cleanse" access="private" returntype="any" output="false" hint="I cleanse input via HTMLEditFormat. My implementation can be changed to support other cleansing methods.">
		<cfargument name="data" type="any" required="yes" />
		<cfreturn HTMLEditFormat(arguments.data) />
	</cffunction>

</cfcomponent>

