package com.pathes.disp
{
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class TreeformRenderer1 extends TreeformRenderer
	{
		
		public function TreeformRenderer1(c:uint)
		{
			super(c);
		}
		
		override public function stage(n:Number = 3):void {
			bd = new BitmapData(512, 512, true, 0x00000000);
			var g:Sprite = new Sprite();
			var tree_height:Number = 512 - (n * 80);
			
			var r:uint = color >> 16 & 0xFF;
			var gee:uint = color >> 8 & 0xFF;
			var b:uint = color & 0xFF;
			
			
			g.graphics.lineStyle(20, 0x330000);
			g.graphics.moveTo(250, 490);
			g.graphics.lineTo(250, tree_height);
			
			g.graphics.lineStyle(0, 0x000000, 0);
			g.graphics.beginFill(0x000000, .3);
			g.graphics.drawEllipse(220, 470, 60, 40);
			
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