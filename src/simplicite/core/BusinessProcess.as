/*
 * Simplicite(R) for Adobe Flex(R)
 * http://www.simplicite.fr
 */
package simplicite.core {
	import mx.rpc.http.HTTPService;
	import mx.rpc.events.ResultEvent;
	import com.adobe.serialization.json.JSON;

	/**
	 * Simplicit&eacute;(R) business process
	 */
    public class BusinessProcess extends Common {
    	/** @private */
		protected var name:String;

		/**
		 * Constructor
		 * @param name Process name
		 * @param login Login (only used for external usage)
		 * @param password Password (only used for external usage)
		 * @param baseURL Base URL of webservice gateway (only used for external usage)
		 */
		public function BusinessProcess(name:String, login:String = null, password:String = null, baseURL:String = null) {
			super(login, password, baseURL);
			serviceURL = this.baseURL + "/" + (internal ? "jsp/PCS_json.jsp" : "jsonpcsservice.jsp");

			this.name = name;
		}
	}
}