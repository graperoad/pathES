package com.pathes
{
	import away3d.containers.*;
	import away3d.controllers.HoverController;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.*;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.CubeTextureBase;
	import away3d.utils.*;
	
	import com.pathes.system.ForceCompilation;
	import com.pathes.system.RemoteLink;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display3D.textures.CubeTexture;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Vector3D;
	import flash.utils.Timer;

	public class PathESMain extends Sprite
	{
		
		protected var t:Timer;
		
		private var _view:View3D;
		
		//scene objects
		private var _plane:Mesh;
		private var light1:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		private var worldData:WorldData;
		private var skybox:SkyBox;
		private var cameraController:HoverController;
		
		public function PathESMain(size:Number)
		{
			//setup the view
			_view = new View3D();
			addChild(_view);
			
			//setup the camera
			_view.camera.z = 0;
			_view.camera.x = 600;
			_view.camera.y = 600;
			
			
			light1 = new DirectionalLight();
			light1.direction = new Vector3D(0, -1, 0);
			light1.color = 0xFFFF66;
			light1.ambientColor = 0x0000FF;
			light1.specular = .3;
			light1.ambient = 0.5;
			light1.diffuse = 0.7;
			
			
			lightPicker = new StaticLightPicker([light1]);
			PathesData.lightPicker = lightPicker;
			
			PathesData.fog = new FogMethod(400, 1800, 0xFFFFFF);
			
			_view.scene.addChild(light1);
			
			//setup the scene
			_plane = new Mesh(new PlaneGeometry(1000, 1000), new ColorMaterial(0x0000FF, .5));
			_plane.y = -20;
			_plane.material.lightPicker = lightPicker;
			_view.scene.addChild(_plane);
			
			worldData = new WorldData(size, size);
			worldData.x = -600;
			worldData.z = -600;
			_view.scene.addChild( worldData );
			//
			
			_view.backgroundColor = 0xDDDDFF;
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			t = new Timer(PathesData.updateInterval);
			t.addEventListener(TimerEvent.TIMER, onTimer);
			t.start();
			onTimer();
			
			//every 5 minutes
			var cacheTimer:Timer = new Timer(300000);
			cacheTimer.addEventListener(TimerEvent.TIMER, saveSnapshot);
			cacheTimer.start();
			saveSnapshot();
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void {
			var f:FlightController = new FlightController(_view.camera, this.stage);
		}
		
		protected function onTimer(e:TimerEvent = null):void {
			trace("Sending data");
			RemoteLink.sendWorldData(worldData.dataString);
			
		}
		
		protected function saveSnapshot(e:TimerEvent = null):void {
			
			//make sure directory exists
			var dir:File = File.desktopDirectory.resolvePath("pathesCache");
			dir.createDirectory();
			

			
			//save file
			var d:Date = new Date();
			var nom:String = "cache-" + d.day + "-" + d.hours + "-" + d.minutes + ".txt";
			var file:File = File.desktopDirectory.resolvePath("pathesCache/"+nom); 
			
			var myFileStream:FileStream = new FileStream(); 
			myFileStream.open(file, FileMode.WRITE); 
			
			myFileStream.writeUTFBytes(JSON.stringify(worldData.dataString));
			
		}
		
		protected function onEnterFrame(e:Event):void {
		//	_view.camera.lookAt(new Vector3D(-600,0,0));
			worldData.update();
			_view.render();
		}
		
		
	}
}