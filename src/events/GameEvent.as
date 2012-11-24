package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Leonid Trofimckuk
	 */
	public class GameEvent extends Event 
	{
		static public const GAME_COMPLETE:String = "gameComplete";
		static public const GAME_OVER:String = "gameOver";
		static public const HERO_DAMAGED:String = "heroDamaged";
		static public const ENEMY_SHOOTED:String = "enemyShooted";
		static public const CALL_MENU:String = "callMenu";
		static public const HERO_BONUS:String = "heroBonus";
		static public const HERO_COLLIDED:String = "heroCollided";
		
		public var title:String;
		
		
		public function GameEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, title:String = null) 
		{
			super(type, bubbles, cancelable);
			this.title = title;
		}
		
		override public function clone():Event
		{
			return new GameEvent(type, bubbles, cancelable, title);
		}
		
		override public function toString():String
		{
			return formatToString("PromptEvent", "type", "bubbles", "cancelable", "eventPhase", "title");
		}
		
	}

}