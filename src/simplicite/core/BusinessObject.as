/*
 * Simplicite(R) for Adobe Flex(R)
 * http://www.simplicite.fr
 */
package simplicite.core {
	import mx.rpc.http.HTTPService;
	import mx.rpc.events.ResultEvent;
	import com.adobe.serialization.json.JSON;

	/**
	 * Simplicit&eacute;(R) business object
	 * @example Typical usage :<listing version="3.0">
	 * var obj:Object = new BusinessObject("MyObject");
	 * obj.getMetaData(onGetMetaData);
	 * function onGetMetaData():void {
	 *    obj.info(obj.metadata.label);
	 * }
	 * </listing>
	 */
    public class BusinessObject extends Common {
    	/** @private */
		protected var name:String;
    	/** @private */
		protected var instance:String;

		public static const DEFAULT_ROW_ID:String = "0";

		public static const CONTEXT_NONE:int            = 0;
		public static const CONTEXT_SEARCH:int          = 1;
		public static const CONTEXT_LIST:int            = 2;
		public static const CONTEXT_CREATE:int          = 3;
		public static const CONTEXT_COPY:int            = 4;
		public static const CONTEXT_UPDATE:int          = 5;
		public static const CONTEXT_DELETE:int          = 6;
		public static const CONTEXT_GRAPH:int           = 7;
		public static const CONTEXT_CROSSTAB:int        = 8;
		public static const CONTEXT_PRINTTMPL:int       = 9;
		public static const CONTEXT_UPDATEALL:int       = 10;
		public static const CONTEXT_REFSELECT:int       = 11;
		public static const CONTEXT_DATAMAPSELECT:int   = 12;
	    public static const CONTEXT_PREVALIDATE:int     = 13;
	    public static const CONTEXT_POSTVALIDATE:int    = 14;
	    public static const CONTEXT_STATETRANSITION:int = 15;
	    public static const CONTEXT_EXPORT:int          = 16;
	    public static const CONTEXT_IMPORT:int          = 17;
	    public static const CONTEXT_ASSOCIATE:int       = 18;
	    public static const CONTEXT_PANELLIST:int       = 19;
		
		public static const TYPE_ID:int          = 0;
		public static const TYPE_INT:int         = 1;
		public static const TYPE_FLOAT:int       = 2;
		public static const TYPE_STRING:int      = 3;
		public static const TYPE_DATE:int        = 4;
		public static const TYPE_DATETIME:int    = 5;
		public static const TYPE_TIME:int        = 6;
		public static const TYPE_ENUM:int        = 7;
		public static const TYPE_BOOLEAN:int     = 8;
		public static const TYPE_PASSWORD:int    = 9;
		public static const TYPE_URL:int         = 10;
		public static const TYPE_HTML:int        = 11;
		public static const TYPE_EMAIL:int       = 12;
		public static const TYPE_LONG_STRING:int = 13;
		public static const TYPE_ENUM_MULTI:int  = 14;
		public static const TYPE_REGEXP:int      = 15;
		public static const TYPE_DOC:int         = 17;
		public static const TYPE_FLOAT_EMPTY:int = 18;
		public static const TYPE_EXTFILE:int     = 19;
		public static const TYPE_IMAGE:int       = 20;
		public static const TYPE_NOTEPAD:int     = 21;
		public static const TYPE_PHONENUM:int    = 22;
		public static const TYPE_COLOR:int       = 23;
		public static const TYPE_OBJECT:int      = 24;
		
		public static const VIS_NOT:int  = 0;
		public static const VIS_LIST:int = 1;
		public static const VIS_FORM:int = 2;
		public static const VIS_BOTH:int = 3;
		
		public static const SEARCH_NONE:int = 0;
		public static const SEARCH_MONO:int = 1;
		public static const SEARCH_MULTI_CHECK:int = 2;
		public static const SEARCH_MULTI_LIST:int = 3;
			
		/** Current meta data */
		public var metadata:Object;
		
		/** Get field for specified name */
		public function getFieldByName(name:String):Object {
			for (var i:String in metadata.fields) {
				if (metadata.fields[i].name == name) return metadata.fields[i];
			}
			return null;
		}
		
		/** Get fields for specified area */
		public function getFieldsByArea(area:int):Array {
			var fields:Array = new Array();
			for (var i:String in metadata.fields) {
				if (metadata.fields[i].area == area) fields.push(metadata.field[i]);
			}
			return fields;
		}
		
		/** Current search filters */
		public var filters:Object;
		/** Current search result count */
		public var count:int;
		/** Current search page (if paginated search, -1 otherwise) */
		public var page:int;
		/** Current search max page (if paginated search, -1 otherwise) */
		public var maxpage:int;
		/** Current search result */
		public var list:Array;
		
		/** Current item */
		public var item:Object;

		/** Current cross table data */
		public var crosstabdata:Array;

		/**
		 * Constructor
		 * @param name Object name
		 * @param instance Object instance name (if null the instance name &quot;fx_<name>&quot; is be used)
		 * @param login Login (only used for external usage)
		 * @param password Password (only used for external usage)
		 * @param baseURL Base URL of webservice gateway (only used for external usage)
		 */
		public function BusinessObject(name:String, instance:String = null, login:String = null, password:String = null, baseURL:String = null) {
			super(login, password, baseURL);
			serviceURL = this.baseURL + "/" + (internal ? "jsp/ALL_json.jsp" : "jsonservice.jsp");

			this.name = name;
			this.instance = (instance == null || instance == "") ? "fx_" + name : instance;
		}

		/** @private */
		protected function getServiceParams(action:String, extraParams:Object = null):Object {
			var params:Object = new Object();
			
			params.object = name;
			params.inst = instance;
			params.action = action;

			if (extraParams != null) {
				for (var i:String in extraParams) {
					if (extraParams[i] != null) {
						if (extraParams[i] is String)
							params[i] = extraParams[i];
							//params[i] = convert(extraParams[i], "utf-8");
						else if (extraParams[i] is Boolean
							||	extraParams[i] is Number
							||	extraParams[i] is int) {
							params[i] = extraParams[i];
						} else {
							params[i] = "";
							for (var j:String in extraParams[i]) {
								params[i] += (params[i] == "" ? "" : "|") + j + "|" + extraParams[i][j];
							}
						}
					}
				}
			}
			
			return params;
		}
				
		/**
		 * Get meta data (for an indicated usage context)
		 * @param getMetaDataHandler Function called back when meta data is loaded
		 * @param context Usage context (see CONTEXT_* constants)
		 * @param contextParam Usage context parameter (only useful for CONTEXT_GRAPH, CONTEXT_CROSSTAB and CONTEXT_PRINTTMPL usage contexts for indicating the corresponding item)
		 */
		public function getMetaData(getMetaDataHandler:Function, context:int = CONTEXT_NONE, contextParam:String = null):void {			
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("getMetaData", res.response.message);
				} else {
					metadata = res.response;
					if (getMetaDataHandler != null) getMetaDataHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("metadata", {context: context, contextparam: contextParam}));
		}

		/**
		 * Search and get list
		 * @param searchHandler Function called back when search result list is loaded
		 * @param filters Search filters (if null current search filters are applied)
		 * @param inlineDocs Inline documents and images as base64 string
		 * @param inlineThumbs Inline thumbnail images as base64 string
		 */
		public function search(searchHandler:Function, filters:Object = null, inlineDocs:Boolean = false, inlineThumbs:Boolean = false):void {			
			if (filters == null)
				filters = this.filters;
			else
				this.filters = filters;

			var srv:HTTPService = getService("POST");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("search", res.response.message);
				} else {
					list = res.response.list;
					count = res.response.count;
					page = res.response.page == null ? -1 : res.response.page;
					maxpage = res.response.maxpage == null ? -1 : res.response.maxpage;
					if (searchHandler != null) searchHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("search", filters));
		}

		/**
		 * Get item
		 * @param getHandler Function called back when item is loaded
		 * @param rowId Row ID of item to get (if null current item's row ID is used)
		 * @param inlineDocs Inline documents and images as base64 string
		 * @param inlineThumbs Inline thumbnail images as base64 string
		 */
		public function get(getHandler:Function, rowId:String = null, inlineDocs:Boolean = false, inlineThumbs:Boolean = false):void {
			if (rowId == null) rowId = this.item[metadata.rowidfield];
			
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("get", res.response.message);
				} else {
					item = res.response;
					if (getHandler != null) getHandler.call(this);
				}
			});
			
			var p:Object = new Object();
			p[metadata.rowidfield] = rowId; 
			p.inline_documents = inlineDocs;
			p.inline_thumbnails = inlineThumbs;
			srv.send(getServiceParams("get", p));
		}

		/**
		 * Populate item
		 * @param populateHandler Function called back when populate is done and populated item is loaded
		 * @param item Item to be populated (if null current item will be used)
		 */
		public function populate(populateHandler:Function, itm:Object = null):void {
			if (itm == null) itm = this.item;

			var srv:HTTPService = getService("POST");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("populate", res.response.message);
				} else {
					item = res.response;
					if (populateHandler != null) populateHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("populate", itm));
		}

		/**
		 * Create item
		 * @param createHandler Function called back when creation is done and created item is loaded
		 * @param itm Item to be created (if null current item will be used with row ID reinitialized)
		 */
		public function create(createHandler:Function, itm:Object = null):void {
			if (itm == null) itm = this.item;
			itm[metadata.rowidfield] = DEFAULT_ROW_ID;

			var srv:HTTPService = getService("POST");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("create", res.response.message);
				} else {
					item = res.response;
					if (createHandler != null) createHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("create", itm));
		}

		/**
		 * Update item
		 * @param updateHandler Function called back when update is done and updated item is loaded
		 * @param item Item to be updated (if null current item will be used)
		 */
		public function update(updateHandler:Function, itm:Object = null):void {
			if (itm == null) itm = this.item;

			var srv:HTTPService = getService("POST");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("update", res.response.message);
				} else {
					item = res.response;
					if (updateHandler != null) updateHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("update", itm));
		}

		/**
		 * Delete item
		 * @param delHandler Function called back when item is deleted
		 * @param rowId Row ID of item to delete (if null current item's row ID is used)
		 */
		public function del(delHandler:Function, rowId:String = null):void {			
			if (rowId == null) rowId = this.item[metadata.rowidfield];

			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("del", res.response.message);
				} else {
					item = new Object();
					if (delHandler != null) delHandler.call(this);
				}
			});
			
			var p:Object = new Object();
			p[metadata.rowidfield] = rowId; 
			srv.send(getServiceParams("delete", p));
		}

		/**
		 * Action
		 * @param actionHandler Function called back when action is done (action result is passed to this function)
		 * @param actionName Action name
		 * @param rowId Row ID of item for action (if null no row ID is passed)
		 */
		public function action(actionHandler:Function, actionName:String, rowId:String):void {			
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("action", res.response.message);
				} else {
					var result:String = res.response.result;
					if (actionHandler != null) actionHandler.call(this, result);
				}
			});
			
			var p:Object = new Object();
			if (metadata!=null)
				p[metadata.rowidfield] = rowId;
			else 
				p["row_id"] = rowId;
			srv.send(getServiceParams(actionName, rowId == null ? null : p));
		}

		/**
		 * Get crosstab data
		 * @param getCrosstabDataHandler Function called back when crosstab data is loaded
		 * @param crosstab Crosstab name
		 */
		public function getCrosstabData(getCrosstabDataHandler:Function, crosstab:String):void {
			var srv:HTTPService = getService("GET");
			srv.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var rawData:String = String(event.result);
	
				var res:Object = com.adobe.serialization.json.JSON.decode(rawData) as Object;
				if (res.type == "error") {
					fault("loadCrosstabData", res.response.message);
				} else {
					crosstabdata = res.response;
					if (getCrosstabDataHandler != null) getCrosstabDataHandler.call(this);
				}
			});
			
			srv.send(getServiceParams("crosstabcubes", { crosstab: crosstab }));
		}

		/**
		 * Checks if field is the row ID field
		 * @param field Field name
		 */
		public function isRowIdField(field:Object):Boolean {
			return !field.refId && !field.ref && field.name == metadata.rowidfield;
		}

		/**
		 * Checks if field is a timestamp field
		 * @param field Field name
		 */
		public function isTimestampField(field:Object):Boolean {
			return !field.ref && (
				   field.name == "created_by"
				|| field.name == "created_dt"
				|| field.name == "updated_by"
				|| field.name == "updated_dt"
			);
		}
		
		/**
		 * Helper for building a document object suitable for AppSession.writeDocument for current item and specified field
		 * @param fieldName Field name (field must be of type TYPE_DOC or TYPE_IMAGE)
		 * @param docFileName Document file name
		 * @param docContent Document content (base64 encoded)
		 */
		public function buildDocument(fieldName:String, docFileName:String, docContent:String):Object {
			var field:Object = getFieldByName(fieldName);
			if (field == null) {
				throw new Error("Unknown field " + fieldName); 
			} else if (field.type != TYPE_DOC && field.type != TYPE_IMAGE) {
				throw new Error("Field " + fieldName + " is not a document or an image field"); 
			}

			var doc:Object = new Object();
			if (item[field.name] is String)
				doc.id = item[field.name];
			else
				doc.id = item[field.name].id;
			doc.object = metadata.name;
			doc.rowid = item[metadata.rowidfield];
			doc.field = field.name;
			doc.name = docFileName;
			doc.content = docContent;
			
			return doc;
		}
	}
}