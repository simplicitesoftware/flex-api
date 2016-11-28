package simplicite.ui {
	import flash.events.MouseEvent;
	import mx.containers.Panel;
	import mx.controls.Button;

	[Event(name="buttonClick", type="flash.events.Event")]

	public class ButtonPanel extends Panel {
		[Bindable] public var buttonLabel:String;
		[Bindable] public var buttonPadding:Number = 10;
		private var btn:Button;

		public function ButtonPanel() {
			super();
		}

		protected override function createChildren():void {
			super.createChildren();
			if (!buttonLabel) return;

			btn = new Button();
			btn.label = buttonLabel;
			btn.visible = true;
			btn.includeInLayout = true;
			btn.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			rawChildren.addChild(btn);
		}

		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			var x:int = width - (btn.width + buttonPadding);
			btn.width = btn.measuredWidth;
			btn.height = btn.measuredHeight;
			this.setStyle("headerHeight", btn.height + buttonPadding);            
			btn.move(x,5);
		}

		private function buttonClickHandler(event:MouseEvent):void {
			this.dispatchEvent(new Event("buttonClick", false));
		}
	}
}