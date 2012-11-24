package game
{
	import adobe.utils.CustomActions;
	import components.FPSText;
	import components.Messages;
	import components.ReadXML;
	import events.GameEvent;
	import events.StateEvent;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.system.fscommand;
	import flash.utils.setTimeout;
	/**
	 * ...View Class
	 * @author Leonid Trofimchuk
	 */
	public class View extends Sprite 
	{
		private var fps:FPSText;				//FPS meter
		
		private var _stage:Stage;				//Main Stage 
		private var _container:Sprite;			//Main Container
		private var playerName:String;			//Player Name
		
		private var totalScore:int = 0;			//Game Score
		private var levelSettings: Object ={}	//Level Settings
		private var xmlFile:ReadXML;			//XML File of Settings
		private var xmlList:XMLList;			//XML List of Settings
		
		private var gameSound:Boolean = true;	//Sound in game
		private var resume:Boolean = false;		//Resume in menu
		
		private var _game:Game;
		private var _menu:Menu;				
		private var missionStatus:String;			
		private var levelComplete:int = 0;		//Complete levels
		private var levels:int = 0;				//Complete levels
		
		/**
		 * Constructor
		 * @param	stage		Main Stage 
		 * @param	container	Main Container
		 */
		public function View(stage:Stage, container: Sprite) 
		{
			this._stage = stage;
			this._container = container;
			
			playerName = String(LoaderInfo(_container.root.loaderInfo).parameters.player);
			
			xmlFile = new ReadXML();
			xmlFile.addEventListener(ReadXML.LIST_LOADED, xmlFile_listLoaded);
			
			fps = new FPSText();
			fps.x = 2;
			fps.y = this._stage.stageHeight - fps.height - 18;
			fps.enable();
			_container.addChild(fps);
		}
			
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------	
			
		private function initMenu():void 
		{
			_menu = new Menu(_stage, _container);
			_menu.addEventListener(StateEvent.STATE_CHANGED, menu_stateChanged);
		}
			
		private function setSound():void
		{
			gameSound = !gameSound;
			if (_game != null)
				_game.withSound = gameSound;
		}
		
		private function preGame():void
		{
			leaveGame();
			levelSettings["enemyCount"] = int(xmlList[levelComplete].attribute("enemyCount"));
			levelSettings["enemyInt"] = int(xmlList[levelComplete].attribute("enemyInt"));
			levelSettings["enemySpeed"] = int(xmlList[levelComplete].attribute("enemySpeed"));
			levelSettings["health"] = int(xmlList[levelComplete].attribute("health"));
			levelSettings["score"] = totalScore;
			levelSettings["player"] = playerName;
			
			var numMiss: String = "Mission " + String(levelComplete + 1);
			var message:Messages = new Messages(_stage, _container, numMiss);
			message.addEventListener(Messages.REMOVE_MESSAGE, initGame);
		}
		
		private function leaveGame():void
		{
			if (_game != null)
			{
				_game.deactivate();
				_game.removeAll();
				_game = null;
			}
		}
		
		private function initGame(e:Event):void
		{	
			_game = new Game(_stage, _container, levelSettings);
			_game.addEventListener(GameEvent.GAME_COMPLETE, game_levelComplete);
			_game.addEventListener(GameEvent.GAME_OVER, game_levelComplete);
			_game.addEventListener(GameEvent.CALL_MENU, game_callMenu);
			_game.withSound = gameSound;
			_container.setChildIndex(fps, _container.numChildren - 1);
		}
		
		private function gameComplete():void 
		{
			resume = false;
			var message:Messages = new Messages(_stage, _container, String("Congratulations!!! \n Game Complete \n Total Score: "  + totalScore), 0x3bb437);
			message.addEventListener(Messages.REMOVE_MESSAGE, onGameComplete);
		}
		
		private function closeApp():void 
		{
			fscommand("quit");
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Event Handlers Definition
//
//-------------------------------------------------------------------------------------------------	
		
		private function game_levelComplete(e:GameEvent):void 
		{
			missionStatus = e.title;
			var message:Messages;
			switch (e.title)
			{
				case "MissionComplete":
					message = new Messages(_stage, _container, "Mission Complete", 0x3bb437);
					break;
				case "GameOver":
					message = new Messages(_stage, _container, "Game Over", 0xff3300);
					break;
				default:
					message = new Messages(_stage, _container, "Game Over", 0xff3300);
			}
			totalScore = _game.score;
			message.addEventListener(Messages.REMOVE_MESSAGE, message_removeMessage);
		}
		
		private function game_callMenu(e:GameEvent):void 
		{
			resume = true;
			_menu.init(gameSound,resume);
		}
			
		private function menu_stateChanged(e:StateEvent):void 
		{
			switch (e.onState)
			{
				case "RESUME":
					_game.activate();
					break;
				case "NEW GAME":
					levelComplete = 0;
					totalScore = 0;
					preGame();
					break;
				case "EXIT":
					closeApp();
				case "soundSwitch":
					setSound();
					break;
				default:
					closeApp();
			}
		}
		
		private function message_removeMessage(e:Event):void 
		{
			switch (missionStatus)
			{
				case "MissionComplete":
					levelComplete++
					if (levelComplete != levels)
					{
						preGame();
					}
					else
					{
						gameComplete();
					}
					break;
				case "GameOver":
					totalScore = 0;
					levelComplete = 0;
					resume = false;
					leaveGame();
					_menu.init(gameSound,resume);
					break;
				default:
					levelComplete = 0;
					resume = false;
					_menu.init(gameSound,resume);
			}
		}
		
		private function onGameComplete(e:Event):void 
		{
			leaveGame();
			_menu.init(gameSound,resume);
		}
		
		private function xmlFile_listLoaded(e:Event):void 
		{	
			xmlList = xmlFile.getList();
			levels = xmlList.length();
			xmlFile.removeEventListener(ReadXML.LIST_LOADED, xmlFile_listLoaded);
			setTimeout(initMenu, 300);
		}
		
	}

}