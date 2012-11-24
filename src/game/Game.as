package game 
{
	import components.BackGround;
	import components.HealthIndicator;
	import components.InfoText;
	import components.Sounds;
	import events.GameEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	/**
	 * Game
	 * @author Leonid Trofimchuk
	 */
	public class Game extends Sprite
	{
		private var _stage:Stage;											//Main Stage
		private var _container:Sprite;										//Main Container
		private var bkGround:BackGround;									//Background
		private var hero:Sprite;											//Hero Ship;
		private var heroSpeed:int = 1;										//Hero Speed;
		private var bonus:Bonus;											//Hero Bonuses;
		private var gunBonus:String = "Gun";								//Gun Bonus String
		private var healthBonus:String = "Health";							//Gun Bonus String
		private var invulFilter:GradientGlowFilter;							//Hero Gradient Glow Filter
		private var hadGunBonus:Boolean;									// Gun Bonus Flag
		private var hadHealthBonus:Boolean;									// Health Bonus Flag
		private var enemyLeft:int = 20;										//Number of Enemies
		private var enemyCount:int = 20;									//Number of Enemies
		private var enemyOnStage:int = 4;									//Enemy at stage on init
		private var enemySpeed:int = 8;										//Enemy Speed;
		private var sight:Sprite;											//Sight
		private var sightOnTarget:Boolean;									//Sight On Target
		private var enemyArray:Vector.<Enemy>;								//Enemy Array
		private var enemyContainer:Sprite;									//Enemy Container
		private var bulletArray:Vector.<Sprite> = new Vector.<Sprite>();	//Bullet Array
		private var deadZoneMin:int;										//Delete bullet if it achieve deadZone
		private var deadZoneMax:int;										//Delete bullet if it achieve deadZone
		private var bulletSpeed:Number = 15;								//Bullet Speed
		private var speedX:Number;											//Bullet Speed X
		private var speedY:Number;											//Bullet Speed Y
		private var radian:Number;											//Bullet Angle in Radians
		private var angleShift: int = 90;									//Angle shift
		private var sounds:Sounds;											//Sound Manager
		private var heroController:HeroController;							//Controller
		private var enemyIntID:uint;										//Enemy Call Interval Id
		private var bulletType:int = 1;										//Hero Bullet Type
		private var enemyInt:int = 1500;									//Enemy Call Interval					
		private var soundFlaf:Boolean;										//Sound Flag
		private var _healthMax:int = 5;										//Hero Max Helth;
		private var _health:int = 5;										//Hero Current Helth
		private var healthIndicator:HealthIndicator;						//Hero Helth Indicator
		private var scoreText:InfoText;										//Score Text
		private var levelScore:int;											//Level Score
		private var _playerName:String;										//Player Name
		private var _playerText:InfoText;									//Player Name Text
		private var isMenuAvailable:Boolean = true;							//Menu Availablity	
		
		//Constructor
		public function Game(stage:Stage, container: Sprite, levelSettings: Object = null) 
		{
			//Container Initialization
			this._stage = stage; 
			this._container = container;
			
			this.enemyCount = levelSettings["enemyCount"];
			this.enemyInt = levelSettings["enemyInt"];
			this.enemySpeed = levelSettings["enemySpeed"];
			this._healthMax = levelSettings["health"];
			this.levelScore = levelSettings["score"];
			this._playerName = levelSettings["player"];
			
			initBackground();
			initHero();
			initBonus();
			initEnemies();
			initSight();
			initIndicator();
			initScoreText();
			initPlayerName();
			initSounds();
			activate();
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------
		
		private function initBackground():void 
		{
			bkGround = new BackGround(_stage);
			_container.addChild(bkGround);
		}
		
		private function initHero():void 
		{
			_health = _healthMax;
			hero = new Hero_graphic();
			//hero align
			hero.x = _stage.stageWidth / 2;
			hero.y = _stage.stageHeight / 2;
			this._container.addChild(hero);
			deadZoneMin = -50;
			deadZoneMax = _stage.stageWidth + 50;
			
			enemyContainer = new Sprite();
			_container.addChild(enemyContainer);
			heroController = new HeroController(hero, _stage, enemyContainer, heroSpeed);
			addHeroDamage();
			hero.addEventListener(GameEvent.HERO_BONUS, hero_heroBonus);
			hero.addEventListener(GameEvent.HERO_COLLIDED, hero_heroCollided);
			
			invulFilter = new GradientGlowFilter();
			invulFilter.distance = 0; 
			invulFilter.angle = 45; 
			invulFilter.colors = [0x000000, 0x0091FF];
			invulFilter.alphas = [0, 1]; 
			invulFilter.ratios = [0, 255]; 
			invulFilter.blurX = 8; 
			invulFilter.blurY = 8; 
			invulFilter.strength = 2;
			invulFilter.quality = BitmapFilterQuality.LOW;
			invulFilter.type = BitmapFilterType.OUTER;
		}
		
		private function addHeroDamage():void 
		{
			if(hero.alpha != 1)
				hero.alpha = 1;
			if(hero.filters != null)
				hero.filters = null;
			hero.addEventListener(GameEvent.HERO_DAMAGED, hero_heroDamaged);
		}
		
		private function setInvulnerability():void 
		{
			hero.removeEventListener(GameEvent.HERO_DAMAGED, hero_heroDamaged);
			hero.filters = [invulFilter];
			setTimeout(addHeroDamage, 15000);
		}
		
		private function initBonus():void 
		{
			bonus = new Bonus(_stage, _container, hero);
		}
		
		private function initEnemies():void 
		{
			enemyArray = new Vector.<Enemy>();
			
			enemyLeft = enemyCount;
			
			if (enemyOnStage > enemyLeft)
				enemyOnStage = enemyLeft;
			
			for (var i:int = 0; i < enemyLeft; i++)
			{
				var enemy: Enemy = new Enemy(_stage, enemyContainer, hero, heroController, enemySpeed);
				enemyArray.push(enemy);
			}
			
			for (var j:int = 0; j < enemyOnStage; j++)
			{
				var enemy_: Enemy = enemyArray[j];
				if (!enemy_.active)
				{
					enemy_.activate();
				}
			}
		}
		
		//Activate enemy if he isn't active
		private function activateEnemy():void 
		{
			for (var i:int = 0; i < enemyLeft; i++)
			{
				var enemy: Enemy = enemyArray[i];
				if (!enemy.active)
				{
					enemy.activate();
					break;
				}
			}
		}
		
		private function enableEnemies():void
		{
			for (var i:int = 0; i < enemyLeft; i++)
			{
				var enemy: Enemy = enemyArray[i];
				if (enemy.active)
				{
					enemy.enable();
				}
			}
		}
		
		private function disableEnemies():void
		{
			for (var i:int = 0; i < enemyLeft; i++)
			{
				var enemy: Enemy = enemyArray[i];
				if (enemy.active)
				{
					enemy.disable();
				}
			}
		}
		
		private function enemiesControll():void
		{
			if (enemyContainer.hitTestPoint(sight.x, sight.y, true))
				setSight(true);
			else
				setSight(false);
		}
		
		private function initSight():void 
		{
			sight = new Sight_graphic;
			_container.addChild(sight);
			
		}
		
		private function setSight(flag:Boolean):void 
		{
			if (flag && !sightOnTarget)
			{
				sight.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 255, -100, 0, 0);
				sightOnTarget = true;
			}
			if (!flag && sightOnTarget)
			{
				sight.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
				sightOnTarget = false;
			}
		}
		
		private function initIndicator():void 
		{
			healthIndicator = new HealthIndicator();
			healthIndicator.x = _stage.stageWidth - healthIndicator.width - 2;
			healthIndicator.y = _stage.stageHeight - healthIndicator.height - 2;
			_container.addChild(healthIndicator);
		}
		
		private function initScoreText():void 
		{
			scoreText = new InfoText(20);
			setScore();
			scoreText.x = 2;
			scoreText.y = 2;
			_container.addChild(scoreText);
		}
		
		private function initPlayerName():void 
		{
			if (_playerName == "undefined")
				_playerName = "Player";
			_playerText = new InfoText(18);
			_playerText.setText(_playerName);
			_playerText.x = _stage.stageWidth - _playerText.width - 2;
			_playerText.y = 2;
			_container.addChild(_playerText);
		}
		
		private function setScore(value:int = 0):void
		{
			levelScore += value;
			scoreText.setText("Score: " + String(levelScore));
		}
		
		private function initBullets():void
		{
			var bullet1:Sprite;
			var bullet2:Sprite;
			switch (bulletType)
			{
				case 1:
					bullet1 = new Bullet1_graphic();
					bullet2 = new Bullet1_graphic();
					break;
				case 2:
					bullet1 = new Bullet2_graphic();
					bullet2 = new Bullet2_graphic();
					break;
				default:
					bullet1 = new Bullet1_graphic();
					bullet2 = new Bullet1_graphic();
			}
			
			bullet1.rotation = hero.rotation;
			var point1:Point = localToLocal(hero, _container, new Point(hero.getChildAt(1).x, hero.getChildAt(1).y));
			bullet1.x = point1.x;
			bullet1.y = point1.y;
			_container.addChildAt(bullet1,1);
			
			bullet2.rotation = hero.rotation;
			var point2:Point = localToLocal(hero, _container, new Point(hero.getChildAt(2).x, hero.getChildAt(2).y));
			bullet2.x = point2.x;
			bullet2.y = point2.y;
			_container.addChildAt(bullet2, 1);
			
			bulletArray.push(bullet1, bullet2);
			
			if(soundFlaf)
				sounds.onShoot(bulletType);
		}
		
		private function bulletControll():void
		{
			if (bulletArray.length == 0)
				return;
			for (var i:int = 0; i < bulletArray.length; i++)
			{
				var item:Sprite =  bulletArray[i];
				//Traectory
				radian = ((item.rotation - angleShift) * Math.PI)/180;
				speedX = bulletSpeed * Math.cos(radian);
				speedY = bulletSpeed * Math.sin(radian);
				item.x += speedX;
				item.y += speedY;
			}
			checkBullets();
		}
		
		private function addMouseClick():void 
		{
			_stage.addEventListener(MouseEvent.CLICK, stage_click);
		}
		
		private function checkBullets():void 
		{
			for (var i:int = 0; i < bulletArray.length; i++)
			{
				var item:Sprite = bulletArray[i];
				if (deadZoneMax < item.x || item.x < deadZoneMin || deadZoneMax < item.y ||item.y < deadZoneMin)
				{
					_container.removeChild(item);
					bulletArray.splice(i, 1);
					return;
				}
				if (enemyContainer.hitTestPoint(item.x, item.y, true))
				{	
					var graph:Sprite;
					var array:Array;
					array = (enemyContainer.getObjectsUnderPoint(new Point(item.x, item.y))) as Array;
					
					if (array.length > 0)
					{
						if (item.parent.contains(item))
							item.parent.removeChild(item);
						bulletArray.splice(i, 1);
						graph = (array[0].parent.parent) as Sprite;
						if (graph.numChildren > 1 && bulletType == 1)
						{
							graph.removeChildAt(0);
							setScore(100);
						}
						else
						{
							var index: int;
							index = enemyArray.indexOf(graph.parent);
							if (index == -1)
							return;
							if(soundFlaf)
								sounds.onExplosion();
							var enemy:Enemy = (enemyArray[index]) as Enemy
							enemy.deactivate();
							enemyArray.splice(index, 1);
							if (enemyContainer.contains(enemy))
								enemyContainer.removeChild(enemy);
							addFire(enemy.x, enemy.y);
							enemyLeft--;
							setScore(300);
							checkEnemyArray();
						}
					}
				}
			}
		}
		private function addFire(x:int = 0, y:int = 0):void
		{
			var fire:Explosion_graphic = new Explosion_graphic();
			fire.x = x;
			fire.y = y;
			_container.addChild(fire);
			fire.addEventListener(Event.ENTER_FRAME, fire_enterFrame);
		}
		
		private function checkEnemyArray():void 
		{
			if (enemyLeft < 1)
			{
				setTimeout(gameComplete, 2000);
				isMenuAvailable = false;
			}	
				
			if (enemyLeft <= (enemyCount -  enemyCount / 3) && !hadGunBonus)
			{
				hadGunBonus = true;
				bonus.initBonus(gunBonus);
			}
			if (enemyLeft <= (enemyCount -  enemyCount / 2) && !hadHealthBonus)
			{
				hadHealthBonus = true;
				bonus.initBonus(healthBonus);
			}
		}
		
		private function initSounds():void
		{
			sounds = new Sounds();
			sounds.addEventListener(Sounds.COLLISION_COMPLETE, sounds_collisionComplete);
		}
			
		//Transform Local To Local
		public function localToLocal(containerFrom:Sprite, containerTo:Sprite, origin:Point=null):Point
		{
			var point:Point = origin ? origin : new Point();
			point = containerFrom.localToGlobal(point);
			point = containerTo.globalToLocal(point);
			return point;
		}
		
		private function gameComplete():void
		{
			deactivate();
			this.dispatchEvent(new GameEvent(GameEvent.GAME_COMPLETE, false, false, "MissionComplete"));
		}
		
		private function gameOver():void 
		{
			setTimeout(addGameOverMess, 2000);
			addFire(hero.x, hero.y);
			if(soundFlaf)
				sounds.onExplosion();
			deactivate();
			isMenuAvailable = false;
			hero.removeChildAt(1);
			hero.transform.colorTransform = new ColorTransform(1, 1, 1, 1, -200, -200, -200, 0);
		}
		
		private function addGameOverMess():void 
		{
			this.dispatchEvent(new GameEvent(GameEvent.GAME_OVER, false, false, "GameOver"));
		}
		
		public function activate():void 
		{
			Mouse.hide();
			sight.visible = true;
			heroController.enable();
			enableEnemies();
			if (bonus != null)
				bonus.enable();
			enemyIntID = setInterval(activateEnemy, enemyInt);
			_stage.addEventListener(Event.ENTER_FRAME, stage_enterFrame)
			_stage.addEventListener(GameEvent.ENEMY_SHOOTED, stage_enemyShooted);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
			_stage.addEventListener(MouseEvent.CLICK, stage_click);
			_stage.focus = _container;
		}
				
		public function deactivate():void 
		{
			_stage.removeEventListener(MouseEvent.CLICK, stage_click);
			disableEnemies();
			_stage.removeEventListener(Event.ENTER_FRAME, stage_enterFrame);
			_stage.removeEventListener(GameEvent.ENEMY_SHOOTED, stage_enemyShooted);
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
			heroController.disable();
			clearInterval(enemyIntID);
			Mouse.show();
			if(sight != null)
				sight.visible = false;
			if (bonus != null)
				bonus.disable();
		}
		
		public function removeAll():void 
		{
			hero.removeEventListener(GameEvent.HERO_BONUS, hero_heroBonus);
			hero.removeEventListener(GameEvent.HERO_COLLIDED, hero_heroCollided);
			sounds.removeEventListener(Sounds.COLLISION_COMPLETE, sounds_collisionComplete);
			
			with (_container)
			{
				removeChild(bkGround);
				removeChild(scoreText);
				removeChild(_playerText);
				removeChild(healthIndicator);
				removeChild(sight);
				removeChild(enemyContainer);
				removeChild(hero);
			}
			if (bonus != null)
				bonus.deactivate();
			hero = null;
			enemyContainer = null;
			sight = null;
			sounds = null;
			enemyArray = null;
			healthIndicator = null;
			scoreText = null;
			_playerText = null;
			bkGround = null;
			
			if (bulletArray.length != 0)
			{
				for (var i:int = 0; i < bulletArray.length; i++)
				{
					var item:Sprite = bulletArray[i];
					if (_container.contains(item))
						_container.removeChild(item);
				}
				bulletArray.length = 0;
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Event Handlers Definition
//
//-------------------------------------------------------------------------------------------------
		
		private function stage_enterFrame(e:Event):void 
		{
			sight.x = _stage.mouseX;
			sight.y = _stage.mouseY;
			heroController.update();
			bkGround.updateBkgr();
			bulletControll();
			enemiesControll();
		}
			
		private function stage_click(e:MouseEvent):void 
		{
			_stage.removeEventListener(MouseEvent.CLICK, stage_click);
			setTimeout(addMouseClick, 800);
			initBullets();
		}
		
		
		private function stage_enemyShooted(e:GameEvent):void 
		{
			if (soundFlaf)
				sounds.onShoot(3);
		}
		
		private function hero_heroDamaged(e:GameEvent):void 
		{
			this._health --;
			setScore( -50);
			healthIndicator.setBar(_health, _healthMax);
			if (this._health < 1)
			{
				gameOver();
				return;
			}
			hero.alpha = 0.5;
			hero.removeEventListener(GameEvent.HERO_DAMAGED, hero_heroDamaged);
			setTimeout(addHeroDamage, 3000);
		}
		
		private function hero_heroCollided(e:GameEvent):void 
		{
			if (soundFlaf)
			{
				sounds.onCollision();
				hero.removeEventListener(GameEvent.HERO_COLLIDED, hero_heroCollided);
			}
		}
		
		private function sounds_collisionComplete(e:Event):void 
		{
			hero.addEventListener(GameEvent.HERO_COLLIDED, hero_heroCollided);
		}
			
		private function hero_heroBonus(e:GameEvent):void 
		{
			switch (e.title)
			{
				case "Gun":
					bulletType = 2;
					break;
				case "Health":
					if (this._health < this._healthMax)
					{
						this._health ++;
						healthIndicator.setBar(_health, _healthMax);
					}
					else
						setInvulnerability();
					break;
				default:
					bulletType = 2;
			}
		}
		
		private function stage_keyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE && isMenuAvailable)
			{
				deactivate();
				this.dispatchEvent(new GameEvent(GameEvent.CALL_MENU));	
			}
		}
			
		private function fire_enterFrame(e:Event):void 
		{
			var fire: MovieClip = (e.target) as MovieClip
			if (fire.currentFrame >= fire.totalFrames)
			{
				try
				{
					fire.removeEventListener(Event.ENTER_FRAME, fire_enterFrame);
					if (fire.parent.contains(fire))
						fire.parent.removeChild(fire);
					fire = null;
				}
				catch (error:Error)
				{
					trace(error.message);
				}
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Getters and Setters
//
//-------------------------------------------------------------------------------------------------		
	
		public function get withSound():Boolean
		{
			return soundFlaf;
		}
		
		public function set withSound(value:Boolean):void
		{
			soundFlaf = value;
		}
		
		public function get score():int
		{
			return levelScore;
		}
	}

}