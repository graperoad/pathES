package com.pathes
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.*;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.BasicAmbientMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;
	
	import com.pathes.system.ForceCompilation;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	public class WorldData extends ObjectContainer3D
	{
		
		protected var height:Number;
		protected var width:Number;
		protected var data:Array;
		protected var gData:Array;
		
		protected var noiseMap:BitmapData;
		protected var copyMap:BitmapData;
		protected var waterPoint:Object;
		protected var waterPoints:Array;
		
		protected var pathColor:Object = { r: 240, g: 185, b: 5 };
		
		[Embed(source="assets/cloud.png")]
		private var Cloud:Class;
		private var clouds:Array;
		
		public function WorldData(h:Number = 10, w:Number = 10)
		{
			width = w;
			height = h;
			data = new Array();
			gData = new Array();
		
			waterPoints = new Array();
			waterPoints[0] = {
				x: 5,//Math.floor( Math.random() * width ),
				y: 5 //Math.floor( Math.random() * height)
			}
				
			noiseMap = new BitmapData(h, w);
			noiseMap.perlinNoise(4, 4, 10, 5, false, false, 7, true);
			
			copyMap = new BitmapData(h,w);
			copyMap.draw(noiseMap);
			
			//init world!
			for(var x:Number = 0; x < width; x++) {
				
				data.push(new Array());
				gData.push(new Array());
				
				for(var y:Number = 0; y < height; y++) {
					
					var tile:Object = {};
					
					var pixel:uint = noiseMap.getPixel(x,y);
					var rpixel:uint = pixel >> 16;
					pixel = 0 << 16 | rpixel << 8 | 0;
					
					copyMap.setPixel(x,y, pixel);
					
					var holder:ObjectContainer3D = new ObjectContainer3D();
					
					var geo:CubeGeometry = new CubeGeometry(100, 100, 100);
					var mat:ColorMaterial = new ColorMaterial(pixel);
					mat.lightPicker = PathesData.lightPicker;
					mat.addMethod(PathesData.fog);
					mat.colorTransform = new ColorTransform(1,1,1);
					
					var bd:BitmapData = new BitmapData(32,32);
					bd.perlinNoise(12,12,5,4,true,true,7, true);
					var cPer:Number = rpixel / 255;
					trace(cPer);
					bd.colorTransform(bd.rect, new ColorTransform(cPer/2,cPer*2,cPer/2, 1, 0, 1));
					var text:BitmapTexture = new BitmapTexture(bd); // Local var which we will be free up after
					var tmap:TextureMaterial = new TextureMaterial(text,true);
					tmap.lightPicker = PathesData.lightPicker;
					tmap.addMethod(PathesData.fog);
					tmap.colorTransform = new ColorTransform(1,1,1);
					
					var m:Mesh = new Mesh(geo, tmap);
					holder.addChild(m);
					holder.x = y * 100;
					holder.z = x * 100;
					holder.y = rpixel;
					
					//make water
					geo = new CubeGeometry(110,110,110);
					mat = new ColorMaterial(0x000099);
					mat.alpha = .4;
					
					var water:Mesh = new Mesh(geo, mat);
					water.y = 5;
					water.visible = false;
					holder.addChild(water);
					
					//make air
					geo = new CubeGeometry(100,30,100);
					mat = new ColorMaterial(0x999900);
					mat.alpha = .4;
					
					var airc:Mesh = new Mesh(geo, mat);
					airc.y = 65;
					airc.visible = false;
					holder.addChild(airc);
					
					//draw
					this.addChild( holder );
					
					data[x].push( { holder: holder, mesh: m, height: holder.y, water: water, air: airc } );
					
					tile.color = 1;
					tile.originalColor = rpixel;
					tile.y = rpixel;
					tile.height = holder.y;
					tile.water = {};
					tile.water.visible = false;
					tile.air = {};
					tile.air.visible = false;
					
					if(Math.random() < 1) {
						
						var tree:Treeform = new Treeform(Math.random() * 0xFFFFFF);
						tree.y = 100;
						tree.x = 20;
						//tree.z = -60;
						holder.addChild(tree);
						
						if(holder.y < 0 ) {
							tree.visible = false;
						} else {
							tree.visible = true;
						}
						
						data[x][y].foliage = tree;
						
						tile.foliage = {};
						tile.foliage.color = tree.color;
						tile.foliage.visible = tree.visible;
						tile.foliage.height = tree.height;
					}
					
					gData[x].push(tile);
				}
			}
			
			//now some clouds!
			clouds = new Array();
			for(var c:Number = 0; c < 8; c++) {
				var clawd:Cloudform = new Cloudform();
				clouds.push(clawd);
				this.addChild( clawd );
			}
		}
		
		public function get dataString():Object {
			return gData;
		}
		
		public function update():void {
			var weights:Array = ForceCompilation.get().weights;
			var m:Object3D;
			
			for each(var entry:Object in weights) {
				var mx:Number = Math.floor( entry.x / width );
				var my:Number = Math.floor( entry.y / height );
				
			//	var colors:Object = toRGB( noiseMap.getPixel(mx, my) );
			//	colors.red ++;
				//colors.blue --;
				//noiseMap.setPixel(mx, my, fromRBG(colors) );
				
				var surrounding:Number = 1;//Math.floor(entry.weight / 10)
				for(var ix:Number = -surrounding; ix <= surrounding; ix ++) {
					for(var iy:Number = -surrounding; iy <= surrounding; iy ++) {
						
						if( ix != 0 || iy != 0) {
							var indX:Number = mx + ix;
							var indY:Number = my + iy;
							
							if( indX >= 0 && indY >=0 && indX < width && indY < height) {	
								var mo:Object3D = data[indX][indY].holder;
								mo.y -= (entry.weight / 10) * PathesData.timeScale;
							}
						}
					}
				}
				
				if(mx >=0 && my >= 0 && mx < width && my < height) {
					m = data[mx][my].holder;
					m.y -= (entry.weight) / 5 * PathesData.timeScale;
					
					
					/* OLD COLOR UPDATE
					var mesh:Mesh = data[mx][my].mesh;
					var mat:ColorMaterial = ColorMaterial(mesh.material);
					
					//update path color
					var col:Object = toRGB( mat.color );
					col.red += (pathColor.r - col.red) * (.1 * PathesData.timeScale);
					col.green += (pathColor.g - col.green) * (.1 * PathesData.timeScale);
					col.blue += (pathColor.b - col.blue) * (.1 * PathesData.timeScale);
					mat.color = fromRBG(col);
					*/
					
					var mesh:Mesh = data[mx][my].mesh;
					var mat:TextureMaterial = TextureMaterial(mesh.material);
					mat.colorTransform.redMultiplier += .08 * PathesData.timeScale;
					
					
					//update tree!
					var twee : Treeform =  data[mx][my].foliage;
					twee.applyDamage(10);
					
					if(!twee.visible ) {
						data[mx][my].air.visible = true;
					}
				}
				
			}
			
			for(var x:Number = 0; x < width; x++) {
				for(var y:Number = 0; y < height; y++) {
					m = data[x][y].holder;
					
					/* OLD COLOR UPDATE
					var mesh:Mesh = data[x][y].mesh;
					var mat:ColorMaterial = ColorMaterial(mesh.material);
					var colors:Object = toRGB(copyMap.getPixel(x,y));
					
					//trace(colors.green);
					
					var col:Object = toRGB( mat.color );
					col.red += (colors.red - col.red) * (.0001 * PathesData.timeScale);
					col.green += (colors.green - col.green) * (.0001 * PathesData.timeScale);
					col.blue += (colors.blue - col.blue) * (.0001 * PathesData.timeScale);
					mat.color = fromRBG( col );
					*/
					
					var mesh:Mesh = data[x][y].mesh;
					var mat:TextureMaterial = TextureMaterial(mesh.material);
					mat.colorTransform.redMultiplier -= (mat.colorTransform.redMultiplier) * .002 * PathesData.timeScale;
					
					var diff:Number = data[x][y].height - m.y;
					m.y += diff * .01 * PathesData.timeScale;;
					
					
					if( data[x][y].foliage ) {
						
						var foliage:Treeform = data[x][y].foliage;
						
						for(var ix:Number = -1; ix <=1; ix++) {
							for(var iy:Number = -1; iy <=1; iy++) {
								
								var tx:Number = x + ix;
								var ty:Number = y + iy;
								
								if(ix != 0 && iy != 0) {
									if(tx >=0 && tx < width && ty >= 0 && ty < height) {
										if(data[tx][ty].water.visible) {
											foliage.height += 1 * PathesData.timeScale;
											foliage.width += 1 * PathesData.timeScale;
											
											foliage.height = (foliage.height < 260) ? foliage.height : 260;
											foliage.width = (foliage.width < 260) ? foliage.width : 260;
											
											Treeform(foliage).addLife(1);
											
											break;
										}
									}
								}
								
								
							}
						}
						
						
						//Sprite3D(data[x][y].foliage).height = 100 + diff;
						//Sprite3D(data[x][y].foliage).width =  100 + diff;
						
						foliage.update();
						
						if(m.y < 0 ) {
						//	foliage.visible = false;
						} else {
						//	foliage.visible = true;
						}
						
						//foliage.visible = false;
					}
					
					//update string data
					var strTile:Object = gData[x][y];
					
					strTile.foliage.visible = Sprite3D(data[x][y].foliage).visible;
					strTile.foliage.height = Sprite3D(data[x][y].foliage).height;
					strTile.height = m.y;
					//OLD COLOR UPDATE
					//strTile.color = ColorMaterial(Mesh(data[x][y].mesh).material).color;
					strTile.color = TextureMaterial(Mesh(data[x][y].mesh).material).colorTransform.redMultiplier;
					
					strTile.water.visible = false;
					strTile.air.visible = data[x][y].air.visible;
					
					//late water update
					data[x][y].water.visible = false;	
				}
			}
			
		//	if( weights.length < 2 && weights.length > 0) {
				
				//var path:Array = calcPath({ x: Math.floor( weights[0].x / 10), y: Math.floor( weights[0].y / 10) }, waterPoint);
				
				var path:Array = calcPath(waterPoints[0], waterPoints[0]);
				
				for each( var pathEntry:Object in path) {
					
					
					var water:Mesh = data[pathEntry.x][pathEntry.y].water;
					water.visible = true;
					
					//trace(water.visible);
					
					/*if(pathEntry.x >= 0 && pathEntry.y >= 0 && pathEntry.x < width && pathEntry.y < height) {
					m = data[pathEntry.x][pathEntry.y].holder;
					//	ColorMaterial(m.material).color = 0x0000FF;
					m.y -= (1.5) * PathesData.timeScale;
					}*/
					
					var strTile:Object = gData[pathEntry.x][pathEntry.y];
					strTile.water.visible = true;
				}
		//	}
				
			for each(var clawd:Cloudform in clouds) {
				clawd.update();
			}
		}
		
		private function calcPath(a:*, b:*):Array {
			var path:Array = new Array();
			
			var cur_node:Object = { x: a.x, y: a.y, height: data[a.x][b.y].holder.y  };
			var targ_node:Object = { x: b.x, y: b.y };
			var cutoff:Number = 0;
			
			path.push(cur_node);

			while(cutoff < 10) {
				var potentialNodes:Array = [];
				
				for(var ix:Number = -1; ix <= 1; ix ++) {
					for(var iy:Number = -1; iy <= 1; iy ++) {
						
						if( ix != 0 && ix != 0) {
							var tx:Number = cur_node.x + ix;
							var ty:Number = cur_node.y + iy;
							
							if( tx >= 0 && tx < width && ty >= 0 && ty < height) {
								
								var tempNode:Object = {
									x: cur_node.x + ix,
										y: cur_node.y + iy,
										height: data[tx][ty].holder.y
								}
								
								tempNode.d = cur_node.height - tempNode.height;
								
								//trace(data[cur_node.x + ix][cur_node.y + iy].holder.y);
								//trace(tempNode.x);
								if( tempNode.d >= 0) potentialNodes.push(tempNode);
							}
						}
						
					}
				}
				
				
				//get out of here if there are no potential nodes
				if(potentialNodes.length <= 0) break;
				
				//else, keep on trucking
				potentialNodes.sortOn("d", Array.NUMERIC);
				cur_node = potentialNodes[0];
				
				//trace("next", potentialNodes[0]);
				
				if(! (cur_node.x < width && cur_node.x > -1 && cur_node.y > -1 && cur_node.y < height) ) {
					break;
				}
				
				path.push(cur_node);
				
				cutoff++;
			}
			
			/*
			while( cur_node.x != targ_node.x || cur_node.y != targ_node.y ) {
				var potentialNodes:Array = [];
				
				for(var ix:Number = -1; ix <= 1; ix ++) {
					for(var iy:Number = -1; iy <= 1; iy ++) {
						var tempNode:Object = {
							x: cur_node.x + ix,
							y: cur_node.y + iy
						}
						
						tempNode.d = dist(tempNode, targ_node);
						//trace(tempNode.x);
						potentialNodes.push(tempNode);
					}
				}
				
				potentialNodes.sortOn("d", Array.NUMERIC);
				cur_node = potentialNodes[0];
				path.push(cur_node);
				if(cutoff++ > 10) {
					break;
				}
			}
			
			path.push(targ_node);
			
			*/
			
			//trace(path.length);
			
			return path;
		}
		
		private function dist(a:*, b:*):Number {
			var dx:Number = a.x - b.x;
			var dy:Number = a.y - b.y;
			return Math.abs( Math.sqrt( (dx*dx) + (dy*dy) ));
		}
		
		private function toRGB(color:uint):Object {
			
			return {
				red: color >> 16 & 0xFF,
				green: color >> 8 & 0xFF,
				blue: color & 0xFF
			}
		}
		
		private function fromRBG(o:Object):uint {
			return ( o.red << 16 ) | ( o.green << 8 ) | o.blue;
		}
		
		private function makeCube():Mesh {
			var m:Mesh = new Mesh(new CubeGeometry(), new ColorMaterial(Math.random() * 0xFFFFFF));
			return m;
		}
	}
}