package com.pathes
{
	import away3d.entities.Sprite3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	
	import com.pathes.PathesData;
	import com.pathes.disp.*;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class Treeform extends Sprite3D
	{
		public var color:uint;
		protected var bd:BitmapData;
		public var life:Number = 100;
		public var lifeStage:Number = 2;
		protected var renderer:TreeformRenderer;
		
		public function Treeform(col:uint)
		{
			
			if(Math.random() < .5) {
				renderer = new TreeformRenderer1(col);
			} else {
				renderer = new TreeformRenderer2(col);
			}
			
			color = col;
			
			renderer.stage(lifeStage);
			
			//make tree
			var text:BitmapTexture = new BitmapTexture(renderer.bd); // Local var which we will be free up after
			var tmap:TextureMaterial = new TextureMaterial(text,true);
			tmap.addMethod(PathesData.fog);
			tmap.alphaBlending = true;

			//make me!
			super(tmap, 100, 100);
		}
		
		public function applyDamage(n:Number):void {
			life -= n * PathesData.timeScale;
			
			if(life <= -25) {
				life = -25;
				this.visible = false;
			}
		}
		
		public function addLife(n:Number):void {
			life += n * PathesData.timeScale;
			
			if(life > 125) life = 125;
			
			//if(life > 0) this.visible = true;
		}
		
		public function update():void {
			if(life > 100) {
				life -= 1 * PathesData.timeScale;
				this.height -= .7 * PathesData.timeScale
				this.width -= .7 * PathesData.timeScale;
				
				var newLifeStage:Number = 2;
				
				if(life < 30) {
					newLifeStage = 1;
				}
				
				if(life > 85) {
					newLifeStage = 3;
				}
				
				if(newLifeStage != lifeStage) {
					renderer.stage(lifeStage);
					var text:BitmapTexture = new BitmapTexture(renderer.bd); // Local var which we will be free up after
					var tmap:TextureMaterial = new TextureMaterial(text,true);
					tmap.addMethod(PathesData.fog);
					tmap.alphaBlending = true;
					this.material = tmap;
					lifeStage = newLifeStage;
				}
				
			} else {
				if(life <= -25 && Math.random() < .000001) {
					this.life = 10;
					this.visible = true;
				}
			}
		}
		
	}
}