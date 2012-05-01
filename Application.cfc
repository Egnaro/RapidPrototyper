component output="false"  
{
	this.name = "RapidPrototyper";
	this.applicationTimeout = CreateTimeSpan(0,0,10,0);
	this.clientManagement = true;
	this.datasource = "";
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan(0,2,0,0);
	this.setClientCookies = true;
	this.setDomainCookies = true;
	this.enablerobustexception = true;
	this.ormenabled = false;
		
	/* **************************** APPLICATION METHODS **************************** */

	/**
	@hint "Runs when an application times out or the server is shutting down."
	@ApplicationScope "The application scope."
	*/
	public void function onApplicationEnd(struct ApplicationScope=structNew()) {
	
		return;
	}
	
	
	/**
	@hint "Runs when ColdFusion receives the first request for a page in the application."
	*/
	public boolean function onApplicationStart() {

		return true;
	}
	
	
	/**
	@hint "Intercepts any HTTP or AMF calls to an application based on CFC request."
	@cfcname "Fully qualified dotted path to the CFC."
	
	@method "The name of the method invoked."
	@args "The arguments (struct) with which the method is invoked."
	*/
	public void function onCFCRequest(required string cfcname, required string method, required string args) {
	
		return;
	}
	
	
	/**
	@hint "Runs when an uncaught exception occurs in the application."
	@Exception "The ColdFusion Exception object. For information on the structure of this object, see the description of the cfcatch variable in the cfcatch description."
	@EventName "The name of the event handler that generated the exception. If the error occurs during request processing and you do not implement an onRequest method, EventName is the empty string."
	
	note: This method is commented out because it should only be used in special cases
	*/
	/*
	public void function onError(required any Exception, required string EventName) {
	return;
	}
	*/
	
	
	/**
	@hint "Runs when a request specifies a non-existent CFML page."
	@TargetPage "The path from the web root to the requested CFML page."
	note: This method is commented out because it should only be used in special cases
	*/
	/*
	public boolean function onMissingTemplate(required string TargetPage) {
	return true;
	}
	*/
	
	
	/**
	@hint "Runs when a request starts, after the onRequestStart event handler. If you implement this method, it must explicitly call the requested page to process it."
	@TargetPage "Path from the web root to the requested page."
	note: This method is commented out because it should only be used in special cases
	*/
	/*
	public void function onRequest(required string TargetPage) {
	return;
	}
	*/
	
	
	/**
	@hint "Runs at the end of a request, after all other CFML code."
	
	*/
	public void function onRequestEnd() {
		
			return;
	}
	
	
	/**
	@hint "Runs when a request starts."
	@TargetPage "Path from the web root to the requested page."
	*/
	public boolean function onRequestStart(required string TargetPage) {
	
		return true;
	}
	
	
	/**
	@hint "Runs when a session ends."
	@SessionScope "The Session scope"
	
	@ApplicationScope "The Application scope"
	*/
	public void function onSessionEnd(required struct SessionScope, struct ApplicationScope=structNew()) {
	
		return;
	}
	
	
	/**
	@hint "Runs when a session starts."
	*/
	public void function onSessionStart() {
	
		return;
	}
}