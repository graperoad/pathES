package com.pathes
{
	import away3d.containers.*;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.primitives.*;
	import away3d.utils.*;
	
	import com.pathes.system.ForceCompilation;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	public class PathESMain extends Sprite
	{
		private var _view:View3D;
		
		//scene objects
		private var _plane:Mesh;
		private var light1:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		private var worldData:WorldData;
		
		public function PathESMain()
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
			
			_view.scene.addChild(light1);
			
			//setup the scene
			_plane = new Mesh(new PlaneGeometry(700, 700), new ColorMaterial(0xFF0000));
			_plane.y = -20;
			_plane.material.lightPicker
			_view.scene.addChild(_plane);
			
			worldData = new WorldData();
			worldData.x = -400;
			worldData.z = -400;
			_view.scene.addChild( worldData );
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onEnterFrame(e:Event):void {
			worldData.update();
			_view.render();
		}
	}
}