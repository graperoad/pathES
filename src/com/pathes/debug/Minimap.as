package com.pathes.debug
{
	import com.pathes.system.ForceCompilation;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Minimap extends Sprite
	{
		
		protected var uPoints:Array;
		
		public function Minimap()
		{
			uPoints = new Array();
			
			this.graphics.beginFill(0x0000FF);
			this.graphics.drawRect(0,0,100,100);
			
			//new point
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0x00FF00);
			s.graphics.drawCircle(0,0,10);
			s.buttonMode = true;
			s.addEventListener(MouseEvent.MOUSE_DOWN, onMdown);
			s.addEventListener(MouseEvent.MOUSE_UP, onMup);
			uPoints.push(s);
			addChild(s);
			
			//eeee
			this.addEventListener(Event.ENTER_FRAME, onE);
		}
		
		protected function onE(e:Event):void {
			ForceCompilation.get().updateWeights(uPoints);
		}
		
		protected function onMdown(e:MouseEvent):void {
			Sprite(e.target).startDrag();
		}
		
		protected function onMup(e:MouseEvent):void {
			Sprite(e.target).stopDrag();
		}
	}
}