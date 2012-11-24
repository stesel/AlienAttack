package components {
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 * This class makes preloader
	 */
	
	public class SimplePreloader extends Sprite
	{
		private var preloader:Sprite;				//Preloader Sprite
		private var bar:Sprite;						//Progress Bar
		
		public function SimplePreloader() 
		{
			
			initPreloader();
		}
		
		/**
		 * Initialization
		 */
		private function initPreloader():void
		{
			//Preloader Sprite Initialization
			preloader = new Sprite();
			preloader.graphics.lineStyle(1, 0xffdc16);
			preloader.graphics.beginFill(0xff1616, 0.9);
			preloader.graphics.drawRect(0, 0, 80, 15);
			preloader.graphics.endFill();
			addChild(preloader);
			
			//Progress Bar Initialization
			bar = new Sprite();
			bar.graphics.beginFill(0x05FF9F, 1);
			bar.graphics.drawRect(0, 0, 78, 13);
			bar.graphics.endFill();
			bar.x = (preloader.width - bar.width) / 2;
			bar.y = (preloader.height - bar.height) / 2;
			preloader.addChild(bar);
		}
		
		public function setBar(width:Number):void
		{
			bar.scaleX = width;
		}
		
	}

}