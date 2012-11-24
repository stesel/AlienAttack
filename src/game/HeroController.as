package game 
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	/**
	 * ...This Class is Contraller for 2D characters
	 * @author Leonid Trofimchuk
	 */
	public class HeroController
	{
		public static const ACTION_UP:String = "ACTION_UP";
		public static const ACTION_DOWN:String = "ACTION_DOWN";
		public static const ACTION_LEFT:String = "ACTION_LEFT";
		public static const ACTION_RIGHT:String = "ACTION_RIGHT";
		
		public var _speed:Number = 0;
		public var speedMultiplier:Number;
		private var friction:Number = 0.95;
		
		private var speedX:Number = 0;
		private var speedY:Number = 0;
		
		private var gradus:Number = 0;
		private var gradusRot:Number = 1;
		private var radian:Number = 0;
		private var deltaX:Number;
		private var deltaY:Number;
		
		private var angleShift: int = 90;			//Angle shift
		
		private var minX:Number;
		private var minY:Number;
		private var maxX:Number;
		private var maxY:Number;
		
		private var _up:Boolean;
		private var _down:Boolean;
		private var _left:Boolean;
		private var _right:Boolean;
		
		private var _stage:Stage;
		private var _object:DisplayObject;
		private var _container:DisplayObject;
		
		private var actionBindings:Object = {};
		private var dx:Number;
		private var dy:Number;
			
		protected var keyBindings:Object = {};
		
		public function HeroController(intObj: DisplayObject = null, stage:Stage = null, container: DisplayObject = null, speed:Number = 3) 
		{
			this._object = intObj;
			this._stage = stage;
			this._container = container;
			this.speedMultiplier = speed;
			
			minX = this._object.width / 2;
			minY = this._object.height / 2;
			
			maxX = this._stage.width - this._object.width / 2;
			maxY = this._stage.height - this._object.height / 2;
			
			actionBindings[ACTION_LEFT] = moveLeft;
			actionBindings[ACTION_RIGHT] = moveRight;
			actionBindings[ACTION_UP] = moveUp;
			actionBindings[ACTION_DOWN] = moveDown;
			
			setDefaultBindings();
			
			enable();
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------
		
		public function get object():DisplayObject 
		{
			return _object;
		}
		
		public function set object(value:DisplayObject):void
		{
			_object = value;
		}
		
		
		public function enable():void 
		{
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
		}
			
		public function disable():void 
		{
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
					
			_up = false;
			_down = false;
			_left = false;
			_right = false;
		}
		
		public function addSpeed(speedX:Number, speedY:Number):void 
		{
			if (_object.alpha != 1)
				return;
			this.speedX = speedX;
			this.speedY = speedY;
		}
		
		public function update():void
		{
			setObjectPos();
			lookAtXY(_stage.mouseX, _stage.mouseY);
		}
		
		public function setObjectPos():void 
		{
			if (_left)
			{
				speedX -= speedMultiplier;
			}
			if (_up)
			{
				speedY -= speedMultiplier;
			}
			if (_right)
			{
				speedX += speedMultiplier;
			}
			if (_down)
			{
				speedY += speedMultiplier;
			}
				
			speedX *=friction;
			speedY *=friction;
				
			_object.rotation = gradus;
			_object.x +=speedX;
			_object.y +=speedY;
			
			if (_object.x < minX)
				_object.x = minX;
				
			if (_object.x > maxX)
				_object.x = maxX;
				
			if (_object.y < minY)
				_object.y = minY;
				
			if (_object.y > maxY)
				_object.y = maxY;	
		}
		
		public function lookAtXY(x:Number, y:Number):void
		{
			deltaX = x - _object.x;
			deltaY = y - _object.y;
			_object.rotation = 180 * Math.atan2(deltaY,deltaX) / Math.PI + angleShift;
		}
		
		public function moveLeft(value:Boolean):void 
		{
			_left = value;
		}
		
		public function moveRight(value:Boolean):void 
		{
			_right = value;
		}
		
		public function moveUp(value:Boolean):void 
		{
			_up = value;
		}
		
		public function moveDown(value:Boolean):void 
		{
			_down = value;
		}
		
		//Bind Key
		public function bindKey(keyCode:uint, action:String):void
		{
			var method:Function = actionBindings[action];
			if (method != null) keyBindings[keyCode] = method;
		}
		
		//UnBind Key
		public function unbindKey(keyCode:uint):void
		{
			delete keyBindings[keyCode];
		}
		
		//UnBind All Keys
		public function unbindAll():void 
		{
			for (var key:String in keyBindings) delete keyBindings[key];
		}
		//Default Bindings
		public function setDefaultBindings():void 
		{
			bindKey(65, ACTION_LEFT);
			bindKey(68, ACTION_RIGHT);
			bindKey(87, ACTION_UP);
			bindKey(83, ACTION_DOWN);
			//
			bindKey(Keyboard.UP, ACTION_UP);
			bindKey(Keyboard.DOWN, ACTION_DOWN);
			bindKey(Keyboard.LEFT, ACTION_LEFT);
			bindKey(Keyboard.RIGHT, ACTION_RIGHT);
		}

//-------------------------------------------------------------------------------------------------
//
//	Event Handlers Definition
//
//-------------------------------------------------------------------------------------------------	
		
		private function onKey(e:KeyboardEvent):void 
		{
			var method:Function = keyBindings[e.keyCode];
			if (method != null)
				method.call(this, e.type == KeyboardEvent.KEY_DOWN);
		}
		
		
	}

}