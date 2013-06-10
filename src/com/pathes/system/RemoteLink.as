package com.pathes.system
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class RemoteLink
	{
		static private var serviceLoc:String;
		static private var netConnection:NetConnection;
		static private var responder:Responder;
		static private var l:URLLoader;
		
		static public function init(serviceURL:String):void {
			serviceLoc = serviceURL;
			l = new URLLoader();
			l.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
			l.addEventListener(ErrorEvent.ERROR, _errorHandler);
		}
		
		static public function sendWorldData(d:Object, f:Function = null):void {
			f = (f!=null) ? f : genericResponder;
			var req:URLRequest = new URLRequest(serviceLoc+"setWorld.php");
			var dat:URLVariables = new URLVariables();
			dat.worldState = JSON.stringify(d);
			req.data = dat;
			req.method = URLRequestMethod.POST;
			l.addEventListener(Event.COMPLETE, f);

			l.load(req);
		}
		
		static private function _ioErrorHandler(e:IOErrorEvent):void {
			//fail silently
		}
		
		static private function _errorHandler(e:ErrorEvent):void {
			//fail silently
		}
		
		static public function genericResponder(e:Event):void {
			trace(e.target.data);
			trace("WAGH");
		}
		
		static public function getWorldData(f:Function):void {
			netConnection.call("PathESWorld/setWorld", responder);
			var responder:Responder = new Responder(f, null);
		}
		
		/*
		static public function sendWorldData(d:Object, f:Function = null):void {
			trace("HI");
			f = (f!=null) ? f : genericResponder;
			var responder:Responder = new Responder(f, null);
			netConnection.call("PathESWorld/getWorld", responder, d);
		}
		
		static public function genericResponder(d:Object):void {
			trace("WAGH"+d);
		}
		
		static public function getWorldData(f:Function):void {
			netConnection.call("PathESWorld/setWorld", responder);
			var responder:Responder = new Responder(f, null);
		}
		*/
	}
}