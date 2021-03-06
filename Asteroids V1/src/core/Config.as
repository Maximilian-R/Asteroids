package core {
	import XML
	import XMLList;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.events.EventDispatcher;
	
	public class Config {
		public function Config() {}
		
		public static const WORLD_WIDTH:Number = 1920;
		public static const WORLD_HEIGHT:Number = 1080;
	
		public static const SHOT_EVENT_STRING:String = "playerShot";
		public static const ASTEROID_BREAK:String = "asteroidBreakEvent";
		public static const WARP_EVENT_STRING:String = "playerWarp";
		
		public static var DISPATCHER:EventDispatcher = new EventDispatcher();
		private static var _cache:Object = {};
		private static var _data:XML;
			
		public static function loadConfig():void {
			var loader:URLLoader = new URLLoader();
			var url:URLRequest = new URLRequest("settings.xml");
			
			loader.addEventListener(Event.COMPLETE, Config.completeHandler, false, 0, true);
            loader.addEventListener(Event.OPEN, Config.openHandler, false, 0, true);
            loader.addEventListener(ProgressEvent.PROGRESS, Config.progressHandler, false, 0, true);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, Config.securityErrorHandler, false, 0, true);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, Config.httpStatusHandler, false, 0, true);
            loader.addEventListener(IOErrorEvent.IO_ERROR, Config.ioErrorHandler, false, 0, true);
			
			try {
				loader.load(url);
			} catch (error:Error) {
				trace("Error when loading: " + error);
			}
		}
		
		private static function completeHandler(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			var data:XML = XML(loader.data);
			Config._data = data;
			DISPATCHER.dispatchEvent(event);
        }

        private static function openHandler(event:Event):void {
            trace("openHandler: " + event);
        }

        private static function progressHandler(event:ProgressEvent):void {
			var loadProgress:Number = 0;
			if (event.bytesTotal != 0) {
				loadProgress = event.bytesLoaded / event.bytesTotal;
			}
            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal + " percentage loaded: " + loadProgress);
        }

        private static function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }

        private static function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event);
        }

        private static function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }
		
		public static function getSetting(attribute:String, node:String):String {
			var nodeKey:String = node+attribute;
			if (_cache[nodeKey] !== undefined) {
				return _cache[nodeKey];
			}
			var values:XMLList = Config._data[node].attribute(attribute);
			if (values.length() == 0) {
				trace("Warning: no attribute " + attribute + " for tag <" + node + ">");
			}
			if (values.length() > 1) {
				trace("Warning: duplicated setting for " + attribute)
			}
			_cache[nodeKey] = values.toString();
			return _cache[nodeKey];
		}
		
		public static function getLevel(id:Number):Level {
			var values:XMLList = Config._data["level"].(@id == id.toString());
			var level:Level = new Level(id, values.attribute("asteroids_spawn"), values.attribute("completionScore"));
			return level;
		}
		
		public static function getString(attribute:String, node:String):String {
			return getSetting(attribute, node);
		}
		
		public static function getInt(attribute:String, node:String):int {
			return parseInt(getSetting(attribute, node));
		}
		
		public static function getNumber(attribute:String, node:String):Number {
			return parseFloat(getSetting(attribute, node));
		}
		
		public static function getBool(attribute:String, node:String):Boolean {
			var s:String = (getSetting(attribute, node));
			return (s == "1" || s == "true");
		}
		
		public static function getColor(attribute:String, node:String):uint {
			return parseInt(getSetting(attribute, node), 16);
		}
	}
}