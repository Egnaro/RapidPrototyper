component 
	output="false" 
	persistent="true" 
	table="%objname%" 
	extends="%cfcdotpath%.SimpleBasePersistentObject" 
	displayname="%objdisplayname%" 
	cacheuse="transactional" 
	cachename="%objname%"
	singularname="%objname%" 
	hint="%objdisplayname% is the base object for displaying %objname%"
{
	%objproperties%
	
	public %objdisplayname% function init() 
	{
		return this;
	}
}