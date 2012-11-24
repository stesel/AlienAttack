package game 
{
	import events.GameEvent;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * ...Enemy Prototype
	 * @author Leonid Trofimchuk
	 */
	public class Enemy extends Sprite 
	{
		private var _stage:Stage;
		private var _container:Sprite;
		private var _hero:Sprite;
		private var _heroController:HeroController;
		private var enemyType:int;
		private var enemy:Sprite;
		private var _rotationRandom:int =0;
		
		private var _rotationRad:Number;
		
		private var bullet:Sprite;
		private var bSpeed:int = 20;
		private var bSpeedX:Number = 0;
		private var bSpeedY:Number = 0;
		
		private var _speed:int = 3;
		private var speedX:Number = 0;
		private var speedY:Number = 0;
		
		private var minX:Number;
		private var minY:Number;
		private var maxX:Number;
		private var maxY:Number;
		private var _active:Boolean;
		
		private var shootimeOut:uint;		
		private var timeOut:int;
		
		/**
		 * 
		 * @param	stage			Stage		
		 * @param	container		Enemy Container	
		 * @param	hero			Hero
		 * @param	speed			Enemy Speed
		 * @param	heroController	Hero Controller
		 */
		public function Enemy(stage: Stage = null, container: Sprite = null, hero: Sprite = null, heroController:HeroController = null, speed:int = 3) 
		{
			this._stage = stage;
			this._container = container;
			this._hero = hero;
			this._speed = speed;
			this._heroController = heroController;
			initEnemy();
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------
			
		private function initEnemy():void 
		{
			enemyType = Math.round(Math.random()) + 1;
			//Choose enemy type	
			switch (enemyType)
			{
				case 1:
					enemy = new Enemy1_graphic();
					break;
				case 2:
					enemy = new Enemy2_graphic();
					break;
				default:
					enemy = new Enemy1_graphic();
			}
			
			minX = - enemy.width;
			minY = - enemy.height;
			maxX = this._stage.width + this.enemy.width;
			maxY = this._stage.height + this.enemy.height;
		}
		
		private function onShoot():void 
		{
			if (!_container.contains(this))
				return;
			bSpeedX =  - bSpeed * Math.sin(_rotationRad);
			bSpeedY = bSpeed * int(Math.cos(_rotationRad));
			
			switch (enemyType)
			{
				case 1:
					bullet = new Bullet1_graphic();
					break;
				case 2:
					bullet = new Bullet2_graphic();
					break;
				default:
					bullet = new Bullet1_graphic();
			}
			bullet.x = this.x;
			bullet.y = this.y;
			bullet.rotation = this.rotation;
			_container.addChildAt(bullet, 0);
			_stage.dispatchEvent(new GameEvent(GameEvent.ENEMY_SHOOTED));
		}
		
		private function bulletControll():void
		{
			if (bullet == null)
				return;
			//Traectory
			if (maxX < bullet.x || bullet.x < minX || maxY < bullet.y || bullet.y < minY)
				removeBullet();
			bullet.x += bSpeedX;
			bullet.y += bSpeedY;
			//Collision
			if (_hero.alpha == 1 && bullet.hitTestObject(_hero))
			{
				removeBullet();
				_heroController.addSpeed(2*speedX, 2*speedY);
				_hero.dispatchEvent(new GameEvent(GameEvent.HERO_DAMAGED));	
				_hero.dispatchEvent(new GameEvent(GameEvent.HERO_COLLIDED));	
			}	
		}	
		
		private function removeBullet():void 
		{
			if(bullet != null && _container.contains(bullet))
				_container.removeChild(bullet)
			bullet == null;
		}
		public function activate():void
		{
			_rotationRandom = Math.round(Math.random() * 3);
			
			switch (_rotationRandom)
			{
				case 0:
					this.rotation = 0;
					this.x = Math.random() * _stage.stageWidth; 
					this.y = - enemy.height;
					break;
				case 1:
					this.rotation = -90;
					this.x = -enemy.width;
					this.y =  Math.random() *_stage.stageHeight;
					break;
				case 2:
					this.rotation = 90;
					this.x = _stage.stageWidth + enemy.width;
					this.y = Math.random() * _stage.stageHeight;
					break;
				case 3:
					this.rotation = 180;
					this.x = Math.random() * _stage.stageWidth;
					this.y = _stage.stageHeight + enemy.height;
					break;
				default:
					this.rotation = 180;
					this.x = Math.random() * _stage.stageWidth;
					this.y = _stage.stageHeight + enemy.height;
			}
			
			_rotationRad = this.rotation / 180 * Math.PI;
				
				speedX = -_speed * Math.sin(_rotationRad);
				speedY = _speed * int(Math.cos(_rotationRad));
			
			this.addChild(enemy);
			_container.addChild(this);
			enable();
			timeOut = int(Math.random() * 50) * 100;
			shootimeOut = setTimeout(onShoot, timeOut);
			_active = true;
		}
		
		public function deactivate():void
		{
			clearTimeout(shootimeOut);
			_active = false;
			if (bullet != null)
				return;	
			if(_container.contains(this))
				_container.removeChild(this);
			this.removeEventListener(Event.ENTER_FRAME, this_enterFrame);
			
			
		}
		public function enable():void
		{
			this.addEventListener(Event.ENTER_FRAME, this_enterFrame);
		}
		public function disable():void
		{
			this.removeEventListener(Event.ENTER_FRAME, this_enterFrame);
		}
		
		private function checkHeroCollision():void
		{
			if (!_active)
				return;
			if (_hero.alpha == 1 && this.hitTestObject(_hero))
			{
				_heroController.addSpeed(2*speedX, 2*speedY);
				_hero.dispatchEvent(new GameEvent(GameEvent.HERO_DAMAGED));	
				_hero.dispatchEvent(new GameEvent(GameEvent.HERO_COLLIDED));
			}	
		}
//-------------------------------------------------------------------------------------------------
//
//	Event Handlers Definition
//
//-------------------------------------------------------------------------------------------------	
		
		private function this_enterFrame(e:Event):void 
		{
			this.x += speedX;
			this.y += speedY;
			//
			if (this.x < minX)
				deactivate();
			if (this.y < minY)
				deactivate();
			if (this.x > maxX)
				deactivate();
			if (this.y > maxY)
				deactivate();
				
			checkHeroCollision();
			
			bulletControll();
		}
			
//-------------------------------------------------------------------------------------------------
//
//	Getters and Setters
//
//-------------------------------------------------------------------------------------------------		
		public function get active():Boolean
		{
			return _active;
		}
		
	}

}