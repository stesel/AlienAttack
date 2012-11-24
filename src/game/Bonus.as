package game 
{
	import events.GameEvent;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
	 * ...Bonuses
	 * @author Leonid Trofimchuk
	 */
	public class Bonus extends Sprite 
	{
		private var _stage:Stage;
		private var _container:Sprite;
		private var _hero:Sprite;
		private var _type:String; 			
		private var speedY:int = 3;
		private var bonus:Sprite;
		
		private var minX:Number;
		private var minY:Number;
		private var maxX:Number;
		private var maxY:Number;
		
		/**
		 * 
		 * @param	stage			Main Stage
		 * @param	container		Main cont
		 * @param	hero			Hero
		 */
		public function Bonus(stage: Stage = null, container: Sprite = null, hero: Sprite = null) 
		{
			this._stage = stage;
			this._container = container;
			this._hero = hero;
		}
		
		/**
		 * 
		 * @param	type	Bonus Type	//1- Gun, 2 - Heal
		 */
		public function initBonus(type:String = null):void 
		{
			this._type = type;
			switch (this._type)
			{
				case "Gun":
					bonus = new GunBonus_graphic();
					break;
				case "Health":
					bonus = new HealthBonus_graphic();
					break;
				default:
					bonus = new GunBonus_graphic();
			}
			minX = bonus.width / 2;
			minY = - bonus.height;
			maxX = this._stage.width - this.bonus.width;
			maxY = this._stage.height + this.bonus.height;
			
			this.x = minX + int(Math.random() * (maxX - minX));
			this.y = minY;
			
			this.addChild(bonus);
			_container.addChild(this);
			enable();
		}
		
		private function checkHeroCollision():void
		{
			if (this.hitTestObject(_hero))
			{
				deactivate();
				_hero.dispatchEvent(new GameEvent(GameEvent.HERO_BONUS, false, false, _type));
			}	
		}
		
		public function enable():void
		{
			this.addEventListener(Event.ENTER_FRAME, this_enterFrame);
		}
		
		public function disable():void
		{
			this.removeEventListener(Event.ENTER_FRAME, this_enterFrame);
		}
		
		public function deactivate():void
		{
			disable();
			if(_container.contains(this))
				_container.removeChild(this);
			bonus = null;
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Event Handlers Definition
//
//-------------------------------------------------------------------------------------------------	
		
		private function this_enterFrame(e:Event):void 
		{
			this.y += speedY;
			if (this.y > maxY)
				deactivate();
			checkHeroCollision();
		}
	}

}