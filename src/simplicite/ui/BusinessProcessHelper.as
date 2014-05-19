/*
 * Simplicite(R) for Adobe Flex(R)
 * http://www.simplicite.fr
 */
package simplicite.ui {
	import simplicite.core.*;
			
	/**
	 * Simplicit&eacute;(R) business process UI helper class - <b>EXPERIMENTAL</b>
	 */
    public class BusinessProcessHelper extends CommonHelper {
    	private var a:AppSession;
    	private var p:BusinessProcess;

		/**
		 * Constructor
		 */
		public function BusinessProcessHelper(a:AppSession, p:BusinessProcess) {
			this.a = a;
			this.p = p;
		}
	}
}