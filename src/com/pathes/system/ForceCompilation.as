package com.pathes.system
{
	import com.pathes.PathesData;
	
	import flash.display.DisplayObject;

	public class ForceCompilation
	{
		static private var _instance:ForceCompilation;
	
		public var lastWeights:Array;
		public var weights:Array;
		
		public function ForceCompilation() {
			weights = new Array();	
		}
		
		public function updateWeights(positions:Array):void {
			lastWeights = weights;
			weights = new Array();
			for each(var entry:Object in positions) {
				//mod values
				var x:Number = (entry.x + .7 ) * ( 8 * PathesData.worldSize );
				var y:Number = (entry.y - .9) * ( 5 * PathesData.worldSize );
				
				x = clamp(x,0,PathesData.worldSize * 8);
				y = clamp(y,0,PathesData.worldSize * 8);
				
				weights.push( { x: x, y: y, weight: 10 } );
			}
		}
		
		//gettar
		static public function get():ForceCompilation
		{
			if(!_instance) _instance = new ForceCompilation();
			
			return _instance;
		}
		
		static public function clamp(value:Number, min:Number, max:Number):Number {
			if(value > max) return max;
			if(value < min) return min;
			return value;
		}
	}
}