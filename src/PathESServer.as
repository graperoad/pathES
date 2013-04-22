package
{
	import com.pathes.PathESMain;
	
	import flash.display.Sprite;
	
	public class PathESServer extends Sprite
	{
		
		protected var worldDisp:PathESMain;
		
		public function PathESServer()
		{
			worldDisp = new PathESMain();
			addChild(worldDisp);
		}
	}
}