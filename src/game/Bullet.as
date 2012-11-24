package game 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author ...Leonid Trofimchuk
	 */
	public class Bullet extends Sprite 
	{
		private var _x:Number = 0; 
		private var _y:Number = 0; 
		private var _rot:Number = 0; 
		private var _speed:int = 0; 
		private var _type:int = 0; 
		private var _hitObj:Sprite = null;
		private var _container:Sprite = null;
		private var _point:int = 0; 
		private var _bullet:Sprite = null; 
		private var _speedX:Number = 0; 
		private var _speedY:Number = 0; 
		private var _radian:Number = 0;
		private var _angleShift:Number = 90;
		private var minX:Number;
		private var minY:Number;
		private var maxX:Number;
		private var maxY:Number;
		/**
		 * 
		 * @param	x			Bullet X
		 * @param	y			Bullet Y
		 * @param	rot			Bullet Degree
		 * @param	speed		Bullet Speed
		 * @param	type		Bullet Type
		 * @param	container	Bullet Container
		 * @param	hitObj		Hit Test Object 
		 * @param	point		Hit test Point Flag
		 */
		public function Bullet(x:Number = 0, y:Number = 0, rot:Number = 0,speed:int = 0,type:int =1,container:Sprite = null, hitObj:Sprite = null, point:Boolean = true) 
		{
			this._x = x;
			this._y = y;
			this._rot = rot;
			this._speed = speed;
			this._type = type;
			this._container = container;
			this._hitObj = hitObj;
			this._pointj = point;
			initBullet();
		}
		
		private function initBullet():void 
		{
			switch(_type)
			{
				case 1:
					this._bullet = new Bullet1_graphic();
					break;
				case 2:
					this._bullet = new Bullet2_graphic();
					break;
				default:
					this._bullet = new Bullet1_graphic();
			}
			
			this.minX = - this._bullet.width;
			this.minY = - this._bullet.height;
			this.maxX = this._stage.width + this._bullet.width;
			this.maxY = this._stage.height + this._bullet.height;
			this.addChild(_bullet);
			this.rotation = _rot;
			
			this._radian = ((this.rotation - this._angleShift) * Math.PI)/180;
			this._speedX = this._speed * Math.cos(radian);
			this._speedX = this._speed * Math.sin(radian);
			
			this._container.addChildAt(this);
		}
		
		
		private function bulletTraectory():void
		{
			if (maxX < bullet.x || bullet.x < minX || maxY < bullet.y || bullet.y < minY)
				removeBullet();
				
			this.x += speedX;
			this.y += speedY;
			
			if (_hitObj.alpha == 1 && _hitObj.hitTestPoint(this.x, this.y, true))
			{
				removeBullet();
				_heroController.addSpeed(2*speedX, 2*speedY);
				_hero.dispatchEvent(new GameEvent(GameEvent.HERO_DAMAGED));	
			}	
		}
	}

}