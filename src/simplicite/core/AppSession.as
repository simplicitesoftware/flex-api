/*
 * Simplicite(R) for Adobe Flex(R)
 * http://www.simplicite.fr
 */
package simplicite.core {
	import mx.rpc.http.HTTPService;
	import mx.rpc.events.ResultEvent;
	import com.adobe.serialization.json.JSON;

	/**
	 * Simplicit&eacute;(R) core application session
	 * @example Typical usage :<listing version="3.0">
	 * var a:AppSession = new AppSession();
	 * a.getGrant(grantLoaded);
	 * function grantLoaded():void {
	 *    Alert.show("Hello " + a.grant.firstname + " !");
	 *    // ZZZ Grant data must be loaded prior to any other loadings to avoid multiple sessions to be started on server side
	 *    a.getSystemParams(sysparamsLoaded);
	 * }
	 * function sysparamsLoaded():void {
	 *    Alert.show("Current version = " + a.getSystemParam("VERSION"));
	 * }
	 * </listing>
	 */
    public class AppSession extends Common {
		/**
		 * Constructor
		 * @param login User login
		 * @param password Password (only used for external usage)
		 * @param baseURL Base URL of webservice gateway (only used for external usage)
		 */
		public function AppSession(login:String = null, password:String = null, baseURL:String = null) {
			super(login, password, baseURL);
			serviceURL = this.baseURL + "/" + (internal ? "jsp/SYS_json.jsp" : "jsonappservice.jsp");
		}

		/** @private */
		protected function getServiceParams(data:String, extraParams:Object = null):Object {
			var params:Object = new Object();
			
			params.data = data;

			if (extraParams != null) {
				for (var i:String in extraParams) {
					if (extraParams[i] != null) {
						params[i] = extraParams[i];
					}
				}
			}
			
			return params;
		}
				
		/**
		 * Grant
		 * <br/>User data (login, firstname, lastname, lang, ...)
		 * <br/>Array of responsibilities
		 * <br/>...
		 * @see #getGrant()
		 */
		public var grant:Object;

		/**
		 * Loads grant
		 * @param loadHandler Function called back when data is loaded
		 */
		public function getGrant(getGrantHandler:Function):void {			
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object =  com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("getGrant", res.response.message);
				} else {
					grant = res.response;
					if (getGrantHandler != null) getGrantHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("grant"));
		}

		/**
		 * Menu entries array (can be used as a DataProvider for standard menu controls)
		 * @see #getMenu()
		 */
		public var menu:Array;

		/**
		 * Loads menu
		 * @param getMenuHandler Function called back when data is loaded
		 */
		public function getMenu(getMenuHandler:Function):void {			
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
				
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("getMenu", res.response.message);
				} else {
					menu = new Array();
					for (var i:String in res.response) {
						menu[i] = new Object();
						menu[i].label = res.response[i].label;
						menu[i].data = res.response[i].name;
						menu[i].children = new Array();
						for (var j:String in res.response[i].items) {
							menu[i].children[j] = new Object();
							menu[i].children[j].label = res.response[i].items[j].label;
							menu[i].children[j].data = res.response[i].items[j].name;
						}
					}
					
					if (getMenuHandler != null) getMenuHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("menu"));
		}

		/**
		 * System parameters array (single system parameter can be retreived using getSystemParameter)
		 * @see #getSystemParams()
		 * @see #getSystemParam()
		 */
		public var sysparams:Array;

		/**
		 * Loads system parameters
		 * @param getSystemParamsHandler Function called back when data is loaded
		 */
		public function getSystemParams(getSystemParamsHandler:Function):void {			
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("getSystemParams", res.response.message);
				} else {
					sysparams = new Array();
					for (var i:String in res.response) {
						sysparams[res.response[i].name] = res.response[i].value;
					}
	
					if (getSystemParamsHandler != null) getSystemParamsHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("sysparams"));
		}

		/**
		 * Get single system parameter (requires that system parameters are loaded)
		 * @param name System parameter name
		 */
		public function getSystemParam(name:String):String {
			if (sysparams == null) {
				fault("getSystemParam", "System parameters not yet loaded");
				return null;
			} else {
				return sysparams[name];
			}
		}

		/**
		 * Texts array (single text can be retreived using getSystemParameter)
		 * @see #getTexts()
		 * @see #getText()
		 */
		public var texts:Array;

		/**
		 * Loads texts
		 * @param getTextsHandler Function called back when data is loaded
		 */
		public function getTexts(getTextsHandler:Function):void {			
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("getTexts", res.response.message);
				} else {
					texts = new Array();
					for (var i:String in res.response) {
						texts[res.response[i].code] = res.response[i].value;
					}
					
					if (getTextsHandler != null) getTextsHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("texts"));
		}

		/**
		 * Get single text (requires that texts are loaded)
		 * @param code Text code
		 */
		public function getText(code:String):String {
			if (texts == null) {
				fault("getText", "Texts not yet loaded");
				return null;
			} else {
				return texts[code];
			}
		}

		/**
		 * Get business object from current application context
		 * @param name Object name
		 * @param instance Object instance name (if null the instance name &quot;fx_<name>&quot; is be used)
		 */
		public function getBusinessObject(name:String, instance:String = null):BusinessObject {
			return new BusinessObject(name, instance, login, password, baseURL);
		}

		/**
		 * Get business process from current application context
		 * @param name Process name
		 */
		public function getBusinessProcess(name:String, instance:String):BusinessProcess {
			return new BusinessProcess(name, login, password, baseURL);
		}

		/**
		 * Read document
		 * @param id Document ID
		 */
		public function readDocument(readDocumentHandler:Function, id:String):void {
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("readDocument", res.response.message);
				} else {
					var d:Object = res.response;
					if (readDocumentHandler != null) readDocumentHandler.call(this, d);
				}
			});
			
			srv.send(getServiceParams("readdocument", { id: id }));
		}

		/**
		 * Write document
		 * @param doc Document
		 */
		public function writeDocument(writeDocumentHandler:Function, doc:Object):void {
			var srv:HTTPService = getService("POST");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("writeDocument", res.response.message);
				} else {
					var d:Object = res.response;
					if (writeDocumentHandler != null) writeDocumentHandler.call(this, d);
				}
			});
			
			srv.send(getServiceParams("writedocument", doc));
		}
	}
}