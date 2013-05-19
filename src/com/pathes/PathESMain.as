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
			_view.camera.z = -600;
			_view.camera.y = 500;
			_view.camera.lookAt(new Vector3D());
			
			light1 = new DirectionalLight();
			light1.direction = new Vector3D(0, -1, 0);
			light1.color = 0xFFFF99;
			light1.ambientColor = 0xFFFF99;
			light1.specular = 0.1;
			light1.ambient = 0.3;
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
			worldData.x = -400;
			worldData.z = -400;
			_view.scene.addChild( worldData );
			
			_view.backgroundColor = 0xDDDDFF;
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			t = new Timer(PathesData.updateInterval);
			t.addEventListener(TimerEvent.TIMER, onTimer);
			t.start();
			onTimer();
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void {
			var f:FlightController = new FlightController(_view.camera, this.stage);
		}
		
		protected function onTimer(e:TimerEvent = null):void {
			trace("Sending data");
			RemoteLink.sendWorldData(worldData.dataString);
		}
		
		protected function onEnterFrame(e:Event):void {
			worldData.update();
			_view.render();
		}
		
		
	}
}