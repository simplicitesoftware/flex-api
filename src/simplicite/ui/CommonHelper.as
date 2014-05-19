/*
 * Simplicite(R) for Adobe Flex(R)
 * http://www.simplicite.fr
 */
package simplicite.ui {
	import simplicite.core.*;
	import flash.events.*;
	import mx.core.Container;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.controls.TextInput;
	import mx.controls.Button;
	
	/**
	 * Simplicit&eacute;(R) common UI helper abstract class (on top of which other UI helper classes are built) - <b>EXPERIMENTAL</b>
	 */
    public class CommonHelper {
		/**
		 * Constructor
		 */
		public function CommonHelper() {
		}

		private var loginForm:Form;
    	private var loginFormSubmitCallback:Function;

		/**
		 * Login form
		 * @param parent Parent container
		 * @param loginFormSubmitCallback Function called back after login form submission
		 * @param defLogin Default value of login text input
		 * @param defPassword Default value of login text input
		 * @param defBaseURL Default value of login text input
		 */
		public function initLoginForm(parent:Container, loginFormSubmitCallback:Function, defLogin:String = "designer", defPassword:String = "designer", defBaseURL:String = "http://localhost:8080/simplicitews"):void {
			loginForm = new Form();
			loginForm.name = "loginForm";
			
			this.loginFormSubmitCallback = loginFormSubmitCallback;
		
			var fi:FormItem = new FormItem();
			fi.name = "loginItem";
			fi.label = "Login";
			var l:TextInput = new TextInput();
			l.name = "loginInput";
			l.text = defLogin;
			l.addEventListener(KeyboardEvent.KEY_DOWN, loginFormSubmitKeyPressed);
			fi.addChild(l);
			loginForm.addChild(fi);
				
			fi = new FormItem();
			fi.name = "passwordItem";
			fi.label = "Password";
			var p:TextInput = new TextInput();
			p.name = "passwordInput";
			p.displayAsPassword = true;
			p.text = defPassword;
			p.addEventListener(KeyboardEvent.KEY_DOWN, loginFormSubmitKeyPressed);
			fi.addChild(p);
			loginForm.addChild(fi);
			
			fi = new FormItem();
			fi.name = "baseURLItem";
			fi.label = "URL";
			var u:TextInput = new TextInput();
			u.name = "baseURLInput";
			u.text = defBaseURL;
			u.addEventListener(KeyboardEvent.KEY_DOWN, loginFormSubmitKeyPressed);
			fi.addChild(u);
			loginForm.addChild(fi);
			
			fi = new FormItem();
			var b:Button = new Button();
			b.label = "OK";
			b.addEventListener(MouseEvent.MOUSE_DOWN, loginFormSubmitClicked);
			b.addEventListener(KeyboardEvent.KEY_DOWN, loginFormSubmitKeyPressed);
			fi.addChild(b);
			loginForm.addChild(fi);

			loginForm.defaultButton = b;
			
			parent.addChild(loginForm);
			parent.focusManager.setFocus(l);
		}
		
		private function loginFormSubmitClicked(event:MouseEvent):void {
			loginFormSubmit();
		}
		
		private function loginFormSubmitKeyPressed(event:KeyboardEvent):void {
			if (event.keyCode == 13) loginFormSubmit();
		}

		private function loginFormSubmit():void {
			if (loginFormSubmitCallback != null) loginFormSubmitCallback.call(this);
		}

		/**
		 * Login value entered in the login form
		 */
		public function getLoginFromLoginForm():String {
			return getTextInputText(loginForm, "login");
		}
		
		/**
		 * Password value entered in the login form
		 */
		public function getPasswordFromLoginForm():String {
			return getTextInputText(loginForm, "password");
		}
		
		/**
		 * Base URL value entered in the login form
		 */
		public function getBaseURLFromLoginForm():String {
			return getTextInputText(loginForm, "baseURL");
		}

		/**
		 * Retreive specified value from input name in specified form
		 * @param form Form
		 * @param name Name of input
		 */
		public function getTextInputText(form:Form, name:String):String {
			var fi:FormItem = FormItem(form.getChildByName(name + "Item"));
			var ti:TextInput = TextInput(fi.getChildByName(name + "Input"));
			return ti.text;
		}
	}
}
