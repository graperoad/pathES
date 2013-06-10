package
{
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.UserEvent;
	import com.pathes.PathESMain;
	import com.pathes.PathesData;
	import com.pathes.debug.Minimap;
	import com.pathes.system.ForceCompilation;
	import com.pathes.system.RemoteLink;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	

	//[SWF(backgroundColor="0xec9900" , width="950" , height="600")]
	[SWF(backgroundColor="0xec9900" , width="1200" , height="800")]
	public class PathESServer extends Sprite
	{
		
		protected var worldDisp:PathESMain;
		protected var l:URLLoader;
		
		private var depthBitmap:Bitmap;
		private var device:Kinect;
		
		private var userMasks:Vector.<Bitmap>;
		private var userMaskDictionary:Dictionary;
		
		public function PathESServer()
		{
			l = new URLLoader();
			l.addEventListener(Event.COMPLETE, onComplete);
			l.load(new URLRequest("data/config.xml"));
		}
		
		protected function onComplete(e:Event):void {
			var d:XML = XML(l.data);
			RemoteLink.init(d.remote.toString());
			
			PathesData.timeScale = Number(d.timeModifier.toString());
			PathesData.updateInterval = Number(d.updateInterval.toString()) * 1000;
			PathesData.worldSize = Number(d.worldSize.toString());
			
			worldDisp = new PathESMain(PathesData.worldSize);
			addChild(worldDisp);
			
			//kinect stuff
			if (Kinect.isSupported()) {
				
				userMasks = new Vector.<Bitmap>();
				userMaskDictionary = new Dictionary();
				
				device = Kinect.getDevice();
				depthBitmap = new Bitmap();
				addChild(depthBitmap);
				
				depthBitmap.x = stage.stageWidth - 400;
				
				device.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthImageUpdateHandler);
				device.addEventListener(UserEvent.USERS_ADDED, usersAddedHandler, false, 0, true);
				device.addEventListener(UserEvent.USERS_REMOVED, usersRemovedHandler, false, 0, true);
				device.addEventListener(UserEvent.USERS_MASK_IMAGE_UPDATE, usersMaskImageUpdateHandler, false, 0, true);
				
				var settings:KinectSettings = new KinectSettings();
				settings.depthEnabled = true;
				settings.depthResolution = CameraResolution.RESOLUTION_320_240;
				
				settings.userMaskEnabled = true;
				settings.userMaskResolution = CameraResolution.RESOLUTION_320_240;
				device.start(settings);
			}
			
			if(PathesData.debug) {
				var debugMap:Minimap = new Minimap();
				addChild(debugMap);
			}
		}
		
		protected function usersAddedHandler(event:UserEvent):void {
			for each(var user:User in event.users) {
				var bmp:Bitmap = new Bitmap();
				userMasks.push(bmp);
				userMaskDictionary[user.userID] = bmp;
				addChild(bmp);
			}
		}
		
		protected function usersRemovedHandler(event:UserEvent):void {
			for each(var user:User in event.users) {
				var bmp:Bitmap = userMaskDictionary[user.userID];
				if (bmp != null) {
					if (bmp.parent != null) {
						bmp.parent.removeChild(bmp);
					}
					var index:int = userMasks.indexOf(bmp);
					if (index > -1) {
						userMasks.splice(index, 1);
					}
				}
				delete userMaskDictionary[user.userID];
			}
		}
		
		protected function usersMaskImageUpdateHandler(event:UserEvent):void {
			//add the users to the world forces
			var forceArray:Array = new Array();
			
			for each(var user:User in event.users) {
				
				//forceArray.push( user.position.depth );
				forceArray.push( { x: user.position.worldRelative.x, y: user.position.worldRelative.z } );
				var bmp:Bitmap = userMaskDictionary[user.userID];
				if (bmp != null) {
					bmp.bitmapData = user.userMaskData;
				}
			}
			
			ForceCompilation.get().updateWeights( forceArray );
		}
		
		protected function depthImageUpdateHandler(event:CameraImageEvent):void {
			depthBitmap.bitmapData = event.imageData;
		}
	}
}