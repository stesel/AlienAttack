package components
{
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * ...FPS
	 * @author Leonid Trofimchuk
	 */
	public class FPSText extends TextField 
	{
		private var format:TextFormat;
		private var gradientGlow:GradientGlowFilter;
		
		private var fpsLast:uint = getTimer();
		private var fpsTicks:uint = 0;
		private var fps:Number;
		private var fpsStr:String;
		
		public function FPSText(size:int = 15, color:uint = 0xffd21e, bold:Boolean = false) 
		{
			format = new TextFormat();
			format.font = "Arial";
            format.color = color;
            format.size = size;
			format.align = "left";
			format.bold = bold;
			
			this.defaultTextFormat = format;
			this.selectable = false;
			this.multiline = true;
			this.antiAliasType = AntiAliasType.ADVANCED;
			this.autoSize = TextFieldAutoSize.LEFT;
			
			gradientGlow = new GradientGlowFilter();
			gradientGlow.distance = 0; 
			gradientGlow.angle = 45; 
			gradientGlow.colors = [0xfff201, 0x000000];
			gradientGlow.alphas = [0, 1]; 
			gradientGlow.ratios = [0, 255]; 
			gradientGlow.blurX = 2; 
			gradientGlow.blurY = 2; 
			gradientGlow.strength = 3;
			gradientGlow.quality = BitmapFilterQuality.LOW;
			gradientGlow.type = BitmapFilterType.OUTER;
			this.filters = [gradientGlow];
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Methods
//
//-------------------------------------------------------------------------------------------------
		public function enable():void
		{
			this.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function disable():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			//FPS
			fpsTicks++;
			var now:uint = getTimer();
			var delta:uint = now - fpsLast;
			if (delta >= 1000)
			{
				fps = fpsTicks / delta * 1000;
				fpsStr = fps.toFixed(1) + " fps";
				this.text = fpsStr;
				fpsTicks = 0;
				fpsLast = now;
			}
		}
		
	}

}