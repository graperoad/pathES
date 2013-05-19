package com.pathes
{
	import away3d.entities.Sprite3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class Treeform extends Sprite3D
	{
		public var color:uint;
		
		protected var bd:BitmapData;
		
		
		public function Treeform(col:uint)
		{
			
			color = col;
			
			stage(2);
			
			//make tree
			var text:BitmapTexture = new BitmapTexture(bd); // Local var which we will be free up after
			var tmap:TextureMaterial = new TextureMaterial(text,true);
			tmap.addMethod(PathesData.fog);
			tmap.alphaBlending = true;

			//make me!
			super(tmap, 100, 100);
		}
		
		public function stage(n:Number = 3):void {
			bd = new BitmapData(512, 512, true, 0x00000000);
			var g:Sprite = new Sprite();
			var tree_height:Number = 512 - (n * 80);
			
			var r:uint = color >> 16 & 0xFF;
			var gee:uint = color >> 8 & 0xFF;
			var b:uint = color & 0xFF;
			
			
			g.graphics.lineStyle(20, 0x330000);
			g.graphics.moveTo(250, 512);
			g.graphics.lineTo(250, tree_height);
			
			g.graphics.lineStyle(0, 0x000000, 0);
			g.graphics.beginFill(0x000000, .3);
			g.graphics.drawCircle(250, 512, 5);
			
			g.graphics.lineStyle(1, 0x330000);
			for ( var i:Number = 0; i< (n*10); i++ ) {
				g.graphics.moveTo(250, tree_height);
				var dx:Number = (Math.random() * n * 120 ) + 150;
				var dy:Number = tree_height - (Math.random() * n * 120 );
				
				if( i < (n*4)) {
					g.graphics.lineStyle(10, 0x330000);
					g.graphics.lineTo(dx, dy);
				}
				
				g.graphics.lineStyle(0, 0x000000, 0);
				var c:Number = ( r << 16 ) | ( ((i / 30) * 255) << 8 ) | b;
				g.graphics.beginFill(c, 1);
				g.graphics.drawCircle(dx, dy, 50);
			}
			
			bd.draw(g);
		}
	}
}