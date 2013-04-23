package com.pathes.system
{
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
				weights.push( { x: entry.x, y: entry.y, weight: 10 } );
			}
		}
		
		//gettar
		static public function get():ForceCompilation
		{
			if(!_instance) _instance = new ForceCompilation();
			
			return _instance;
		}
	}
}