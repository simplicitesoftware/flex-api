/*
 * Simplicite(R) for Adobe Flex(R)
 * http://www.simplicite.fr
 */
package simplicite.ui {
	import simplicite.core.*;
	import flash.events.*;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.core.ScrollPolicy;
	import mx.containers.VBox;
	import mx.containers.HBox;
	import mx.containers.HDividedBox;
	import mx.containers.Form;
	import mx.containers.FormItem;
	//import mx.containers.FormHeading;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.controls.TextInput;
	//import mx.controls.ComboBox;
	import mx.controls.Tree;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.Button;
	import mx.controls.ButtonBar;
	import mx.collections.ArrayCollection;
	import mx.events.ListEvent;
	import mx.events.ItemClickEvent;
			
	/**
	 * Simplicit&eacute;(R) business object UI helper class - <b>EXPERIMENTAL</b>
	 */
    public class BusinessObjectHelper extends CommonHelper {
    	private var a:AppSession;
    	private var o:BusinessObject;
    	
    	public var helpBox:VBox;

    	public var searchBox:VBox;
    	public var searchForm:Form;
    	public var searchFields:Array;
    	public var searchButton:Button;
    	
    	public var listBox:VBox;
    	public var listCount:Text;
    	public var listPagine:ButtonBar;
    	public var listGrid:DataGrid;
    	public var createButton:Button;

    	public var editBox:HDividedBox;
    	public var editForm:Form;
    	public var editFields:Array;
    	public var saveButton:Button;

		private var searchCallback:Function;
		private var getCallback:Function;
		private var saveCallback:Function;

		/**
		 * Constructor
		 */
		public function BusinessObjectHelper(a:AppSession, o:BusinessObject) {
			this.a = a;
			this.o = o;
		}
	
		/**
		 * Initializes help components inside specified container
		 */
		public function initHelp(parent:Container):void {
			helpBox = new VBox();
			helpBox.name = "helpBox";
			helpBox.label = a.getText("HELP");
			helpBox.percentWidth = 100;
			helpBox.percentHeight = 100;
			parent.addChild(helpBox);
		}

		/**
		 * Initializes search form components inside specified parent container
		 * @param parent Parent container
		 * @param searchCallBack Function called back when searches are completed
		 */
		public function initSearchForm(parent:Container, searchCallback:Function = null):void {
			this.searchCallback = searchCallback;

			searchBox = new VBox();
			searchBox.name = "searchBox";
			searchBox.label = a.getText("SEARCH");
			searchBox.styleName = "searchBox";
			searchBox.percentWidth = 100;
			searchBox.percentHeight = 100;
			
			searchForm = new Form();
			searchForm.name = "searchForm";
			searchForm.styleName = "searchForm";
			searchForm.percentWidth = 100;
			searchForm.percentHeight = 100;
			
			var fi:FormItem = new FormItem();

			searchFields = new Array();
			for (var i:String in o.metadata.fields) {
				if (o.metadata.fields[i].searchable && !o.metadata.fields[i].refId && !o.isTimestampField(o.metadata.fields[i])) {
					fi = new FormItem();
					fi.label = o.metadata.fields[i].label;
					var ti:TextInput = new TextInput();
					ti.addEventListener(KeyboardEvent.KEY_DOWN, searchKeyPressed);
					fi.addChild(ti);
					searchFields[o.metadata.fields[i].name] = ti;
					searchForm.addChild(fi);
				}
			}

			fi = new FormItem();
			searchButton = new Button();
			searchButton.label = a.getText("SEARCH");
			searchButton.addEventListener(MouseEvent.MOUSE_DOWN, searchClicked);
			searchButton.addEventListener(KeyboardEvent.KEY_DOWN, searchKeyPressed);
			fi.addChild(searchButton);
			searchForm.addChild(fi);

			searchForm.defaultButton = searchButton;

			searchBox.addChild(searchForm);

			parent.addChild(searchBox);
		}
		
		private function searchClicked(event:MouseEvent):void {
			doSearch(0);
		}
		
		private function searchKeyPressed(event:KeyboardEvent):void {
			if (event.keyCode == 13) doSearch(0);
		}

		private function doSearch(page:int):void { 
			var filters:Object = new Object();
			if (page >= 0) filters["page"] = page;
			for (var i:String in o.metadata.fields) {
				if (o.metadata.fields[i].searchable && !o.metadata.fields[i].refId && !o.isTimestampField(o.metadata.fields[i]))
					filters[o.metadata.fields[i].name] = searchFields[o.metadata.fields[i].name].text;
			}
			o.search(onSearch, filters);
		}

		private function onSearch():void {
			listCount.text = "Count: " + (o.page != -1 ? o.count + " Page: " + (o.page + 1) + "/" + (o.maxpage + 1) : "");
			listGrid.dataProvider = new ArrayCollection(o.list);
			
			if (searchCallback != null) searchCallback.call(this);
		}
		
		/**
		 * Initializes list components inside specified parent container
		 * @param parent Parent container
		 * @param searchCallBack Function called back when list item retreival is completed
		 */
		public function initListBox(parent:Container, getCallback:Function):void {
			this.getCallback = getCallback;

			listBox = new VBox();
			listBox.name = "listBox";
			listBox.label = a.getText("LIST");
			listBox.styleName = "listBox";
			listBox.percentWidth = 100;
			listBox.percentHeight = 100;

			var b:HBox = new HBox();
			
			listPagine = new ButtonBar();
			var pb:Array = [ "<<", "<", ">", ">>"];
			listPagine.dataProvider = new ArrayCollection(pb);
			listPagine.addEventListener(mx.events.ItemClickEvent.ITEM_CLICK, listPagineClicked);
			b.addChild(listPagine);
			
			listCount = new Text();
			b.addChild(listCount);
			
			createButton = new Button();
			createButton.label = a.getText("CREATE");
			createButton.addEventListener(MouseEvent.MOUSE_DOWN, createClicked);
			createButton.addEventListener(KeyboardEvent.KEY_DOWN, createKeyPressed);
			searchForm.addChild(createButton);
			b.addChild(createButton);

			listBox.addChild(b);
			
			var lc:Array = new Array();
			for (var i:String in o.metadata.fields) {
				var f:Object = o.metadata.fields[i];
				if ((f.visible == BusinessObject.VIS_LIST || f.visible == BusinessObject.VIS_BOTH) && !f.refId && !o.isRowIdField(f) && !o.isTimestampField(f)) {
					var col:DataGridColumn = new DataGridColumn();
					col.headerText = f.label;
					col.dataField = f.name;
					col.width = Math.min(200, f.length * 20);
					lc.push(col);
				}
			}
			listGrid = new DataGrid();
			listGrid.rowCount = a.grant.minrows;
			listGrid.addEventListener(mx.events.ListEvent.ITEM_CLICK, listClicked);
			listBox.addChild(listGrid);
			listGrid.columns = lc;

			parent.addChild(listBox);
		}

		private function listPagineClicked(event:ItemClickEvent):void {
			if (event.index == 0)
				listFirst();
			else if (event.index == 1)
				listPrev();
			else if (event.index == 2)
				listNext();
			else if (event.index == 3)
				listLast();
		}
		
		public function listFirst():void {
			doSearch(0);
		}
		
		public function listPrev():void {
			var page:int = o.page - 1;
			if (page < 0) page = 0;
			doSearch(page);
		}
		
		public function listNext():void {
			var page:int = o.page + 1;
			if (page > o.maxpage) page = o.maxpage;
			doSearch(page);
		}
		
		public function listLast():void {
			doSearch(o.maxpage);
		}

		private function listClicked(event:ListEvent):void {
			doGet(event.currentTarget.selectedItem[o.metadata.rowidfield]);
		}
		
		private function doGet(rowId:String, inlineDocs:Boolean = false):void {
			o.get(onGet, rowId);
		}
		
		private function onGet():void {
			for (var i:String in o.metadata.fields) {
				editFields[o.metadata.fields[i].name].text = o.item[o.metadata.fields[i].name];
			}
			
			if (getCallback != null) getCallback.call(this);
		}

		private function createClicked(event:MouseEvent):void {
			doCreate();
		}

		private function createKeyPressed(event:KeyboardEvent):void {
			if (event.keyCode == 13) doCreate();
		}
		
		private function doCreate():void {
			for (var i:String in o.metadata.fields) {
				editFields[o.metadata.fields[i].name].text = o.metadata.fields[i].defaultValue;
			}

			if (getCallback != null) getCallback.call(this);
		}

		private function formItem(field:Object, input:UIComponent):FormItem {
			var fi:FormItem = new FormItem();
			
			fi.label = field.label;
			//fi.required = field.required;
			if (field.required && !o.isTimestampField(field))
				fi.setStyle("color", 0xFF0000);
			if (field.refId || o.isRowIdField(field)) {
				fi.visible = false;
				fi.includeInLayout = false; 
			}
			
			fi.addChild(input);
			
			return fi;
		}
		
		private function textInput(field:Object):FormItem {
			var ti:TextInput = new TextInput();
			ti.name = field.name;
			var ts:Boolean = o.isTimestampField(field);
			ti.editable = !ts && !field.ref;
			if (field.ref)
				ti.setStyle("backgroundColor", 0xFFF6D6);
			else if (ts || !field.updatable)
				ti.setStyle("backgroundColor", 0xF0F0F0);
			ti.setStyle("color", 0x000000);
			ti.width = Math.max(50, Math.min(300, field.length * 20));
			ti.maxChars = field.length;
			
			editFields[field.name] = ti;
			
			return formItem(field, ti);
		}

		private function booleanInput(field:Object):FormItem {
			return null;
		}

		/**
		 * Initializes edit form components inside specified parent container
		 * @param parent Parent container
		 */
		public function initEditForm(parent:Container):void {
			editBox = new HDividedBox();
			editBox.name = "editBox";
			editBox.label = a.getText("UPDATE");
			editBox.styleName = "editBox";
			editBox.percentWidth = 100;
			editBox.percentHeight = 100;

			editForm = new Form();
			editForm.name = "editForm";
			editForm.styleName = "editForm";
			editForm.percentWidth = (o.metadata.links.length > 0) ? 75 : 100;
			editForm.percentHeight = 100;
					
			editFields = new Array();
			
			/*var areas:Array;
			if (o.metadata.areas == null || o.metadata.areas.length == 0) {
				var area:Object = new Object();
				area["area"] = 0;
				area["label"] = "";
				areas = new Array();
				areas.push(areas);
			} else
				areas = o.metadata.areas;*/

			var fi:FormItem;
			/*for (var n:String in areas) {
Alert.show("n " + n + " " + areas[n].label + " " + areas[n].area);
				var fh:FormHeading = new FormHeading();
				fh.label = areas[n].label;
				editForm.addChild(fh);

				var fields:Array = o.getFieldsByArea(areas[n].area);
Alert.show("fields " + fields.length);*/
var fields:Array = o.metadata.fields;
				for (var i:String in fields) {
					if (fields[i].type == BusinessObject.TYPE_STRING) {
						fi = textInput(fields[i]);
					} else {
						fi = textInput(fields[i]);
					}
					editForm.addChild(fi);
				}
			/*}*/

			fi = new FormItem();
			saveButton = new Button();
			saveButton.label = a.getText("SAVE");
			saveButton.addEventListener(MouseEvent.MOUSE_DOWN, saveClicked);
			saveButton.addEventListener(KeyboardEvent.KEY_DOWN, saveKeyPressed);
			fi.addChild(saveButton);
			editForm.addChild(fi);
			
			editForm.defaultButton = saveButton;

			editBox.addChild(editForm);

			if (o.metadata.links.length > 0) {
				var editLinks:Tree = new Tree();
				editLinks.styleName = "editLinks";
				editLinks.percentWidth = 25;
				editLinks.percentHeight = 100;
				editLinks.labelField = "label";
				editLinks.dataProvider = new ArrayCollection(o.metadata.links);
			}
						
			if (o.metadata.links.length > 0)
				editBox.addChild(editLinks);
			
			parent.addChild(editBox);
		}
		
		private function saveClicked(event:MouseEvent):void {
			doSave();
		}

		private function saveKeyPressed(event:KeyboardEvent):void {
			if (event.keyCode == 13) doSave();
		}
		
		private function doSave():void {
			var item:Object = new Object();
			for (var i:String in o.metadata.fields) {
				item[o.metadata.fields[i].name] = editFields[o.metadata.fields[i].name].text;
			}
			if (item[o.metadata.rowidfield] == "" || item[o.metadata.rowidfield] == BusinessObject.DEFAULT_ROW_ID) {
				o.create(onSave, item);
			} else {
				o.update(onSave, item);
			}
		}
		
		private function onSave():void {
			onGet();
			doSearch(o.page);
		}
	}
}