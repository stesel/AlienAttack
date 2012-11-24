package components 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	/**
	 * ...This class creates Background
	 * @author Leonid Trofimchuk 
	 */
	public class BackGround extends Sprite 
	{
		private var _stage:Stage;					//Stage
		private var _width:int;						//Stage Width
		private var _height:int;					//Stage Height
		private var starCont1:Sprite;				//Container 1 for stars
		private var starCont2:Sprite;				//Container 2 for stars
		private var starbitMapData1: BitmapData;	//BitmapData for Container 1
		private var starbitMapData2: BitmapData;	//BitmapData for Container 2
		private var matrix1:Matrix;					//Matrix for traslating Container 1
		private var matrix2:Matrix;					//Matrix for traslating Container 2
		private var delta1: int = 0;				//Delta for Container 1
		private var delta2: int = 0;				//Delta for Container 2
		private var _speed: int = 4;				//Speed for Containers
		private var starAmount:int = 50; 			//Amount of stars
		private var starColor:uint = 0xffffff; 		//Color of stars
		private var starRadius:int = 3; 			//Radius of stars
		private var starX:int = 0; 					//X coordinate of star
		private var starY:int = 0; 					//Y coordinate of star
		private var starArray:Vector.<Sprite>;		//Array of stars
		private var speedMultiply:Number = 1;		//Speed multiply
			
		/**
		 * Constructor
		 * @param	stage		Main Stage
		 * @param	container	Main Container
		 */
		public function BackGround(stage:Stage = null)
		{
			if (stage)
			{
				this._stage = stage;
				initBackGround();
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------	
		
		//Create Stars Animation Background
		private function initBackGround():void 
		{
			this._width = _stage.stageWidth;
			this._height = _stage.stageHeight;
			
			starCont1 = new Sprite();
			starCont2 = new Sprite();
			
			starbitMapData1 = new BitmapData(this._width, this._height, true, 0x000000);
			starbitMapData2 = new BitmapData(this._width, this._height, true, 0x000000);
			
			starArray = new Vector.<Sprite>();
			for (var i:int = 0; i < starAmount; i++)
			{
				starRadius = Math.round(Math.random()) + 1;
				starX = Math.floor(Math.random() * this._width);
				starY = Math.floor(Math.random() * this._height);
				
				var star:Sprite = new Sprite();
				star.graphics.beginFill(starColor, 1);
				star.graphics.drawCircle(0, 0, starRadius);
				star.graphics.endFill();
				star.x = starX;
				star.y = starY;
				
				if(starRadius == 1)
					starCont1.addChild(star);
				else
					starCont2.addChild(star);
					
				starArray.push(star);
			}
			
			starbitMapData1.draw(starCont1);
			starbitMapData2.draw(starCont2);
			
			while (starCont1.numChildren > 0)
				starCont1.removeChildAt(0)
			while (starCont2.numChildren > 0)
				starCont2.removeChildAt(0)
			starArray = null;
			
			this.addChild(starCont1);
			this.addChild(starCont2);
			
		}
		
		//Deactivate
		public function deactivate():void
		{
			starCont1 = null;
			starCont2 = null;
			
			this.removeChild(starCont1);
			this.removeChild(starCont2);
			starbitMapData1 = null;
			starbitMapData2 = null;
		}
		
		public function updateBkgr():void
		{
			if (delta1 >= this._height)
				delta1 = 0;
				
			delta1 += _speed;
			delta2 = 2 * delta1;
			
			matrix1 = new Matrix();
			matrix1.translate(0, delta1);
			starCont1.graphics.clear();
			starCont1.graphics.beginBitmapFill(starbitMapData1, matrix1, true, false);
			starCont1.graphics.drawRect(0, 0, this._width, this._height);
			starCont1.graphics.endFill();
			
			matrix2 = new Matrix();
			matrix2.translate(0, delta2);
			starCont2.graphics.clear();
			starCont2.graphics.beginBitmapFill(starbitMapData2, matrix2, true, false);
			starCont2.graphics.drawRect(0, 0, this._width, this._height);
			starCont2.graphics.endFill();
		}
		
	}

}