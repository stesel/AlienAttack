package components
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...	Class for XML Loading
	 * @author Leonid Trofimchuk
	 */
	public class ReadXML extends EventDispatcher
	{
		
		public static const LIST_LOADED:String = "listLoaded";
		
		private var dataXML:XML;
		private var xmlList:XMLList;
		
		public var attribute1:String = "empty";
		
		public function ReadXML(url:String = "settings/settings.xml")
		{
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			
			try
			{
				loader.load(request);
			}
			catch (error:ArgumentError)
			{
				trace("An ArgumentError has occurred.");
			}
			catch (error:SecurityError)
			{
				trace("A SecurityError has occurred.");
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Methods
//
//-------------------------------------------------------------------------------------------------
		
		public function getList():XMLList
		{
			return xmlList;
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------

		private function loader_ioError(e:IOErrorEvent):void 
		{
			trace("IOErrorEvent");
		}
		
		private function completeHandler(e:Event):void
		{
			dataXML = XML(e.target.data);
			xmlList = dataXML.children();
			
			dispatchEvent(new Event(ReadXML.LIST_LOADED));
		}
		
		
	
	}

}