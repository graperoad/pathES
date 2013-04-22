package com.growth.test
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.*;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.*;
	import away3d.primitives.CubeGeometry;
	
	public class Grower extends ObjectContainer3D
	{
		private var high:Number = 0;
		
		private var lo:Array;
		
		public function Grower(l:StaticLightPicker)
		{
			lo = new Array();
			for(var i:Number = 0; i < 6; i++) {
				if(Math.random() < .5) {
					lo.push(1);
				} else {
					lo.push(0);
				}
			}
			generate(l);
		}
		
		public function generate(l:StaticLightPicker):void {
			
			for(var i:Number = 0; i < 6; i++) {
				var prev:Number = lo[i-1];
				var next:Number = lo[i+1];
				
				if(prev == 1 && next == 1) {
					
				}
			}
			
			var r:Number = Math.random();
			
			var mat:ColorMaterial =  new ColorMaterial(0x00FF00);
			mat.lightPicker = l;
			
			var m:Mesh = new Mesh( new CubeGeometry(), mat );
			
			addChild(m);
			
			high++;
			
			if(high < 5) {
				generate(l);
			}
		}
	}
}