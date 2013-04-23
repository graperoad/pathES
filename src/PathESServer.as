package
{
	import com.pathes.PathESMain;
	import com.pathes.debug.Minimap;
	
	import flash.display.Sprite;
	
	public class PathESServer extends Sprite
	{
		
		protected var worldDisp:PathESMain;
		
		public function PathESServer()
		{
			worldDisp = new PathESMain();
			addChild(worldDisp);
			
			var debugMap:Minimap = new Minimap();
			addChild(debugMap);
		}
	}
}