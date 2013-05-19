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
	
	import com.pathes.system.ForceCompilation;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;

	public class WorldData extends ObjectContainer3D
	{
		
		protected var height:Number;
		protected var width:Number;
		protected var data:Array;
		protected var gData:Array;
		
		protected var noiseMap:BitmapData;
		protected var waterPoint:Object;
		
		protected var pathColor:Object = { r: 240, g: 185, b: 5 };
		
		public function WorldData(h:Number = 10, w:Number = 10)
		{
			width = w;
			height = h;
			data = new Array();
			gData = new Array();
			
			waterPoint =  {
				x: 5,//Math.floor( Math.random() * width ),
				y: 5 //Math.floor( Math.random() * height)
			}
		
			noiseMap = new BitmapData(h, w);
			noiseMap.perlinNoise(4, 4, 10, 5, false, false, 7, true);
			
			//init world!
			for(var x:Number = 0; x < width; x++) {
				
				data.push(new Array());
				gData.push(new Array());
				
				for(var y:Number = 0; y < height; y++) {
					
					var tile:Object = {};
					
					var pixel:uint = noiseMap.getPixel(x,y);
					var rpixel:uint = pixel >> 16;
					pixel = 0 << 16 | rpixel << 8 | 0;
					
					var holder:ObjectContainer3D = new ObjectContainer3D();
					
					var geo:CubeGeometry = new CubeGeometry(100, 200, 100);
					var mat:ColorMaterial = new ColorMaterial(pixel);
					mat.lightPicker = PathesData.lightPicker;
					mat.addMethod(PathesData.fog);
					
					var m:Mesh = new Mesh(geo, mat);
					holder.addChild(m);
					holder.x = y * 100;
					holder.z = x * 100;
					holder.y = rpixel;
					
					//make water
					geo = new CubeGeometry(110,210,110);
					mat = new ColorMaterial(0x000099);
					mat.alpha = .4;
					
					var water:Mesh = new Mesh(geo, mat);
					water.y = 5;
					water.visible = false;
					holder.addChild(water);
					
					//draw
					this.addChild( holder );
					
					data[x].push( { holder: holder, mesh: m, height: holder.y, water: water } );
					
					tile.color = pixel;
					tile.y = rpixel;
					tile.height = holder.y;
					
					if(Math.random() < 1) {
						
						var tree:Treeform = new Treeform(Math.random() * 0xFFFFFF);
						tree.y = 100;
						tree.x = 20;
						tree.z = -60;
						holder.addChild(tree);
						
						if(holder.y < 100 ) {
							tree.visible = false;
						} else {
							tree.visible = true;
						}
						
						data[x][y].foliage = tree;
						
						tile.foliage = {};
						tile.foliage.color = tree.color;
						tile.foliage.visible = tree.visible;
					}
					
					gData[x].push(tile);
				}
			}
		}
		
		public function get dataString():Object {
			return gData;
		}
		
		public function update():void {
			var weights:Array = ForceCompilation.get().weights;
			var m:Object3D;
			
			for each(var entry:Object in weights) {
				var mx:Number = Math.floor( entry.x / 10 );
				var my:Number = Math.floor( entry.y / 10 );
				
				var colors:Object = toRGB( noiseMap.getPixel(mx, my) );
				colors.red ++;
				colors.blue --;
				noiseMap.setPixel(mx, my, fromRBG(colors) );
				
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
					
					var mesh:Mesh = data[mx][my].mesh;
					var mat:ColorMaterial = ColorMaterial(mesh.material);
					
					//update path color
					var col:Object = toRGB( mat.color );
					col.red += (pathColor.r - col.red) * .1;
					col.green += (pathColor.r - col.green) * .1;
					col.blue += (pathColor.b - col.blue) * .1;
					mat.color = fromRBG(col);
				}
				
			}
			
			for(var x:Number = 0; x < width; x++) {
				for(var y:Number = 0; y < height; y++) {
					m = data[x][y].holder;
					
					data[x][y].water.visible = false;
					var diff:Number = data[x][y].height - m.y;
					m.y += diff * .01 * PathesData.timeScale;;
					
					if( data[x][y].foliage ) {
						
						Sprite3D(data[x][y].foliage).height = 100 + diff;
						Sprite3D(data[x][y].foliage).width =  100 + diff;
						
						if(m.y < 100 ) {
							Sprite3D(data[x][y].foliage).visible = false;
						} else {
							Sprite3D(data[x][y].foliage).visible = true;
						}
					}
					
					//update string data
					var strTile:Object = gData[x][y];
					
					strTile.foliage.visible = Sprite3D(data[x][y].foliage).visible;
					strTile.height = m.y;
					strTile.color = ColorMaterial(Mesh(data[x][y].mesh).material).color;
					
				}
			}
			
		//	if( weights.length < 2 && weights.length > 0) {
				
				var path:Array = calcPath({ x: Math.floor( weights[0].x / 10), y: Math.floor( weights[0].y / 10) }, 
					waterPoint);
				
				for each( var pathEntry:Object in path) {
					
					var water:Mesh = data[pathEntry.x][pathEntry.y].water;
					water.visible = true;
					
					/*if(pathEntry.x >= 0 && pathEntry.y >= 0 && pathEntry.x < width && pathEntry.y < height) {
					m = data[pathEntry.x][pathEntry.y].holder;
					//	ColorMaterial(m.material).color = 0x0000FF;
					m.y -= (1.5) * PathesData.timeScale;
					}*/
				}
		//	}
		}
		
		private function calcPath(a:*, b:*):Array {
			var path:Array = new Array();
			
			var cur_node:Object = { x: a.x, y: a.y };
			var targ_node:Object = { x: b.x, y: b.y };
			var cutoff:Number = 0;
			
			path.push(cur_node);

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