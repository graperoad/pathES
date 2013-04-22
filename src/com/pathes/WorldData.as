package com.pathes
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.*;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class WorldData extends ObjectContainer3D
	{
		
		protected var height:Number;
		protected var width:Number;
		protected var data:Array;
		
		protected var noiseMap:BitmapData;
		
		public function WorldData(h:Number = 10, w:Number = 10)
		{
			width = w;
			height = h;
			data = new Array();
		
			noiseMap = new BitmapData(h, w);
			noiseMap.perlinNoise(4, 4, 10, 5, false, false, 7, true);
			
			//init world!
			for(var x:Number = 0; x < width; x++) {
				data.push(new Array());
				for(var y:Number = 0; y < height; y++) {
					data[x].push(1);
					
					var pixel:uint = noiseMap.getPixel(x,y);
					var rpixel:uint = pixel >> 16;
					pixel = 0 << 16 | rpixel << 8 | 0;
					
					var geo:CubeGeometry = new CubeGeometry(100,rpixel);
					var mat:ColorMaterial = new ColorMaterial(pixel);
					mat.lightPicker = PathesData.lightPicker;
					var m:Mesh = new Mesh(geo, mat);
					m.x = y * 100;
					m.z = x * 100;
					//draw
					this.addChild( m );
					
					if(Math.random() < .5) {
						
						noiseMap = new BitmapData(16, 16);
						noiseMap.perlinNoise(4, 4, 10, 5, false, false, 7, true);
						
						var bd:BitmapData = new BitmapData(32, 32, true, 0x00000000);
						var g:Sprite = new Sprite();
						var tree_height:Number = 25;
						
						g.graphics.lineStyle(4, 0x330000);
						g.graphics.moveTo(10, 35);
						g.graphics.lineTo(10, tree_height);
						
						g.graphics.lineStyle(0, 0x000000, 0);
						g.graphics.beginFill(0x000000, .3);
						g.graphics.drawCircle(10, 35, 5);
						
						g.graphics.lineStyle(1, 0x330000);
						for ( var i:Number = 0; i< 14; i++ ) {
							g.graphics.moveTo(10, tree_height);
							var dx:Number = (Math.random() * 20 ) + 3;
							var dy:Number = tree_height - (Math.random() * 15 );
							
							g.graphics.lineStyle(2, 0x330000);
							g.graphics.lineTo(dx, dy);
							
							g.graphics.lineStyle(0, 0x000000, 0);
							var c:Number = ( 0 << 16 ) | ( ((i / 14) * 255) << 8 ) | 0;
							g.graphics.beginFill(c, 1);
							g.graphics.drawCircle(dx, dy, 3);
						}
						
						bd.draw(g);
						
						//make tree
						var text:BitmapTexture = new BitmapTexture(bd); // Local var which we will be free up after
						var tmap:TextureMaterial = new TextureMaterial(text,true);
						tmap.alphaBlending = true;
						var tree:Sprite3D = new Sprite3D(tmap, 100, 100);
						tree.x = y * 100;
						tree.z = x * 100;
						tree.y = 100;
						this.addChild(tree);
					}
				}
			}
		}
		
		private function makeCube():Mesh {
			var m:Mesh = new Mesh(new CubeGeometry(), new ColorMaterial(Math.random() * 0xFFFFFF));
			
			return m;
		}
	}
}