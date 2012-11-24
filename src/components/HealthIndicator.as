package components 
{
	import flash.display.Sprite;
	
	/**
	 * ...Health Indicator
	 * @author Leonid Trofimchuk
	 */
	public class HealthIndicator extends Sprite 
	{
		private var indicator:Sprite;			//Indicator Sprite
		private var indWidth:int = 70;			//Indicator Width
		private var indHeight:int = 15;			//Indicator Height
		private var bar:Sprite;					//Progress Bar
		private var barWidth:int = 68;			//Bar Width
		private var barHeight:int = 13;			//Bar Height
		
		public function HealthIndicator() 
		{
			initPreloader();
		}
		
		/**
		 * Initialization
		 */
		private function initPreloader():void
		{
			//Indicator Sprite Initialization
			indicator = new Sprite();
			indicator.graphics.clear();
			indicator.graphics.lineStyle(1, 0xffdc16);
			indicator.graphics.beginFill(0xff1616, 0.9);
			indicator.graphics.drawRect(0, 0, indWidth, indHeight);
			indicator.graphics.endFill();
			this.addChild(indicator);
			
			//Progress Bar Initialization
			bar = new Sprite();
			bar.graphics.clear();
			bar.graphics.beginFill(0x02ef29, 1);
			bar.graphics.drawRect(0, 0, barWidth, barHeight);
			bar.graphics.endFill();
			bar.x = (indicator.width - bar.width) / 2;
			bar.y = (indicator.height - bar.height) / 2;
			indicator.addChild(bar);
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Methods
//
//-------------------------------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	current	Current Value
		 * @param	max		Max Value
		 */
		public function setBar(current:int = 68, max:int = 68):void
		{
			var _width:int = barWidth / max * current;
			bar.graphics.clear();
			if (_width == 0)
				return;
			bar.graphics.beginFill(0x02ef29, 1);
			bar.graphics.drawRect(0, 0, _width, barHeight);
			bar.graphics.endFill();
		}
		
	}
}