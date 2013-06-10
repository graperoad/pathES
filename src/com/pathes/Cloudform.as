package com.pathes
{
	import away3d.entities.Sprite3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;

	public class Cloudform extends Sprite3D
	{
		
		[Embed(source="assets/cloud.png")]
		private var Cloud:Class;
		
		private var startX:Number;
		private var startZ:Number;
		private var cloudAl:Number;
		
		public function Cloudform()
		{
			var cloudBMP:Bitmap = new Cloud();
			var text:BitmapTexture = new BitmapTexture(cloudBMP.bitmapData); // Local var which we will be free up after
			var tmap:TextureMaterial = new TextureMaterial(text,true);
			tmap.alphaBlending = true;
			
			super(tmap, 200, 200);
			
			
			
			this.y = 500;
			this.x = (Math.random() * 2400) - 1200;
			this.z = (Math.random() * 2400) - 1200;
			
			this.startX = this.x;
			this.startZ = this.z;
			
			cloudAl = Math.random() * 1000;
			
		}
		
		public function update():void {
			this.x += .8;
			this.z += .8;
			
			cloudAl += .013;
			TextureMaterial(this.material).alpha = (Math.sin(cloudAl) + 1) / 2
			
			if(this.x > (this.startX + 312) && TextureMaterial(this.material).alpha  < .1 ) {
				this.x = startX;
				this.x = startZ;
			}
		}

	}
}