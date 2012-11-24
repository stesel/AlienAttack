package game
{
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import components.InfoText;
	import components.SimpleButton;
	import events.ButtonEvent;
	import events.StateEvent;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.BlurFilter;
	import flash.filters.GradientGlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...This class creates Menu
	 * @author Leonid Trofumchuk
	 */
	public class Menu extends EventDispatcher
	{
		static public const NEW_GAME:String = "NEW GAME";			//Action New Game Const 
		static public const RESUME:String = "RESUME";				//Action Resume Const 
		static public const EXIT:String = "EXIT";					//Action Exit Const 
		static public const SOUND_SWITCH:String = "soundSwitch"; 	//Sound Switch Const
		
		private var resumeFlag:Boolean;								//Resume Game Availability
		private var newFlag:Boolean =true;							//New Game Availability
		private var exitFlag:Boolean =true;							//Exit Game Availability
		
		private var numOfBut:int;									//Number of Buttons in Menu
			
		private var buttonActions:Object = {};						//Menu Actions
		
		private var initButtonPos:int = 150;						//Initial Button Position
		private var initButHeight:int = 50;							//Initial Button Height
		private var yOffSet:int = 100;								//Button Y OffSet
		private var hMultiply:int = 60;								//Height Multiply
		private var nextX:int;										//Finite Button X value
		
		private var _stage:Stage;									//Stage
		private var _container:Sprite;								//Main container
		private var buttonArray:Vector.<Sprite>;					//Main container
		private var bkgr:Shape;										//Background
		private var header:InfoText;								//Header
		private var help:InfoText;									//Help text
		private var sButton:SoundButton_graph;						//Sound Button
		private var sButtFlag:Boolean;								//Sound Button Flag
		
		/**
		 * Constructor
		 * @param	stage		Stage
		 * @param	container	Main container
		 */
		public function Menu(stage:Stage = null, container: Sprite = null) 
		{
			this._stage = stage;
			this._container = container;
			init(true);
		}
		
		public function init(sFlag:Boolean = true, rFlag:Boolean = false):void
		{
			sButtFlag = sFlag;
			resumeFlag = rFlag;
			//Background
			bkgr = new Shape();
			bkgr.graphics.beginFill(0x000000, 0.3);
			bkgr.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			_container.addChild(bkgr);
			
			//Header
			header = new InfoText(70, 0xffba16, true);
			header.setText("Alien Attack");
			header.x = (_stage.stageWidth - header.width) / 2;
			header.y = header.height * 1.5;
			_container.addChild(header);
			
			//Help Text
			help = new InfoText(18, 0x0cf43b);
			help.setText("Press «Space Button» to call Menu from the Game");
			help.x = (_stage.stageWidth - help.width) / 2;
			help.y = _stage.stageHeight - help.height * 2;
			_container.addChild(help);
			
			initActions();
			initMenu();
			initSoundButton();
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Methods
//
//-------------------------------------------------------------------------------------------------
		/**
		 * Actions Initialization
		 */
		private function initActions():void 
		{
			buttonActions[RESUME] = onResume;
			buttonActions[NEW_GAME] = onNewGame;
			buttonActions[EXIT] = onExit;
		}
		
		/**
		 * Menu Initialization
		 */
		private function initMenu():void
		{
			buttonArray = new Vector.<Sprite>();
			//Check Flags And Create Buttons
			if (resumeFlag)
			{
				createButton("RESUME");
			}
			if (newFlag)
			{
				createButton("NEW GAME");
			}
			if (exitFlag)
			{
				createButton("EXIT");
			}
		}
		
		/**
		 * @param	st	Button Name
		 * Create Button
		 */
		private function createButton(st:String):void 
		{
			var button: SimpleButton = new SimpleButton(st);
			button.scaleY = 0.001;
			button.x = - 150;
			button.y = _stage.stageHeight/2 + numOfBut * hMultiply + initButHeight; 
			_container.addChild(button);
			nextX = _stage.stageWidth / 2;
			TweenLite.to(button, 0.5, { x:nextX, y: button.y, scaleY:1, ease:Back.easeOut } );
			numOfBut++;
			button.addEventListener(ButtonEvent.BUTTON_PRESSED, buttonPressed);
			buttonArray.push(button);
		}
		
		private function initSoundButton():void 
		{
			sButton = new SoundButton_graph();
			if(sButtFlag)
				sButton.gotoAndStop(1);
			else
				sButton.gotoAndStop(2);
			sButton.buttonMode = true;
			sButton.x = _stage.stageWidth - sButton.width - 30;
			sButton.y = _stage.stageHeight - sButton.height - 20;
			_container.addChild(sButton);
			sButton.addEventListener(MouseEvent.CLICK, sButton_click);
		}
			
		private function onNewGame(): void
		{
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, false, false, Menu.NEW_GAME));
			deactivate();
			resumeFlag = true;
		}
		
		private function onResume(): void
		{
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, false, false, Menu.RESUME));
			deactivate();
		}
		
		public function onExit(): void
		{
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, false, false, Menu.EXIT));
		}
		
		/**
		 * Remove Buttons 
		 */
		private function deactivate():void
		{
			numOfBut = 0;
			for (var i:int = 0; i < buttonArray.length; i++)
			{	
				var button:Sprite = buttonArray[i];
				button.removeEventListener(ButtonEvent.BUTTON_PRESSED, buttonPressed);
				_container.removeChild(button);
				button = null;
			}
			buttonArray.length = 0;
			sButton.removeEventListener(MouseEvent.CLICK, sButton_click);
			with (_container)
			{
				removeChild(sButton);
				removeChild(help);
				removeChild(header);
				removeChild(bkgr);
			}
			sButton = null;
			header = null;
			help = null;
			bkgr = null;
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------	
		
		private function buttonPressed(e:ButtonEvent):void 
		{
			var method:Function = buttonActions[e.label];
			if (method != null) method.call(this);
		}
		
		
		private function sButton_click(e:MouseEvent):void 
		{
			if (sButton.currentFrame == 1)
				sButton.gotoAndStop(2);
			else
				sButton.gotoAndStop(1);
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, false, false, Menu.SOUND_SWITCH));
		}
		
	}

}