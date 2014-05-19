/*
 * Simplicite(R) for Adobe Flex(R)
 * http://www.simplicite.fr
 */
package simplicite.core {
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.rpc.http.HTTPService;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	import mx.utils.Base64Decoder;
	
	/**
	 * Simplicit&eacute;(R) common abstract class (on top of which other classes are built)
	 */
    public class Common {
		/** @private */
		protected var internal:Boolean;    
		/** @private */
    	protected var baseURL:String;
		/** @private */
    	protected var serviceURL:String;
    	/** @private */
    	protected var login:String;
    	/** @private */
    	protected var password:String;

		/**
		 * Constructor (checks presence of the &quot;approot&quot; application parameter for internal usage, if absent external usage is assumed)
		 * @param login User login (if null value is looked up in the &quot;login&quot; application parameter)
		 * @param password Password (only used for external usage, if null value is looked up in the &quot;password&quot; application parameter)
		 * @param baseURL Base URL of webservice gateway (only used for external usage, if null value is looked up in the &quot;baseurl&quot; application parameter)
		 */
		public function Common(login:String = null, password:String = null, baseURL:String = null) {
			if (FlexGlobals.topLevelApplication.parameters.approot != null) {
				// Internal usage
				internal = true;
				this.login = (login != null) ? login : FlexGlobals.topLevelApplication.parameters.login;
				this.password = null;
				this.baseURL = FlexGlobals.topLevelApplication.parameters.approot;
			} else {
				// External usage
				internal = false;
				this.login = (login != null) ? login : FlexGlobals.topLevelApplication.parameters.login;
				this.password = (password != null) ? password : FlexGlobals.topLevelApplication.parameters.password;
				this.baseURL = (baseURL != null) ? baseURL : FlexGlobals.topLevelApplication.parameters.baseurl;
				if (this.baseURL == null) 
					throw new Error("Base URL of webservices gateway cannot be null for external usage");
			}
			this.serviceURL = this.baseURL;
		}
		
		/** @private */
		protected function getService(method:String):HTTPService {
			if (serviceURL == null)
				throw new Error("Service URL cannot be null");

			var srv:HTTPService = new HTTPService();
			
			srv.method = method;
			srv.url = serviceURL;
			srv.showBusyCursor = true;
			srv.resultFormat = "text";
			srv.addEventListener(FaultEvent.FAULT, serviceFault);
			
			if (!internal && login != null && password != null) {
				var encoder:Base64Encoder = new Base64Encoder();
				encoder.insertNewLines = false;
				encoder.encode(login + ":" + password);
				srv.headers = { Authorization: "Basic " + encoder.toString() };
			}

			return srv;
		}

		/** @private */
		protected function serviceFault(event:FaultEvent):void {
			error("Error (service fault): " + event.fault.faultString);
		}

		/** @private */
		protected function fault(method:String, message:String):void {
			error("Error (" + method + "): " + message);
		}

		/**
		 * Simple alert box for error messages
		 * @param message Error message
		 */
		public function error(message:String):void {
			Alert.show(message, "ERROR");
		}

		/**
		 * Simple alert box for information messages
		 * @param message Information message
		 */
		public function info(message:String):void {
			Alert.show(message, "INFO");
		}

		/**
		 * Simple base64 to byte array decoder
		 * @param data Data as base64 string
		 */
		public function convert(data:String, charset:String):String {
			var b:ByteArray = new ByteArray();
			b.writeMultiByte(data, charset);
			return b.toString();
		}

		/**
		 * Simple byte array to base64 encoder
		 * @param data Data as byte array
		 */
		public function base64Encode(data:*):String {
			if (data == null) return "";
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.insertNewLines = false;
			encoder.encodeBytes(data);
			return encoder.toString();
		}

		/**
		 * Simple base64 to byte array decoder
		 * @param data Data as base64 string
		 */
		public function base64Decode(data:String):ByteArray {
			if (data == null) return new ByteArray();
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode(data);
			return decoder.toByteArray();
		}
		
		/**
		 * Parse a datetime
		 * @param s String date YYYY-MM-DD HH:MM:SS
		 */
		public function parseDatetime(s:String):Date { 
			var a:Array = s.split(" ");
			var d:Array = a[0].split("-");
			var h:Array = a[1].split(":");
			var newDate:Date = new Date(d[0], d[1]-1, d[2], h[0], h[1], h[2]);
			return newDate;
		}
		/**
		 * Parse a date
		 * @param s String date YYYY-MM-DD
		 */
		public function parseDate(s:String):Date { 
			var a:Array = s.split(" ");
			var d:Array = a[0].split("-");
			var newDate:Date = new Date(d[0], d[1]-1, d[2]);
			return newDate;
		}
	}
}