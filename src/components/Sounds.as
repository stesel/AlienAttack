package components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	/**
	 * ... This class is for play sounds
	 * @author Leonid Trofimchuk
	 */
	public class Sounds extends	EventDispatcher
	{
		static public const COLLISION_COMPLETE:String = "collisionComplete";
		
		[Embed(source="../../lib/sounds/Shoot1.mp3")]			//Embed Shoot Sound 1 file
		static private const sShoot1:Class;
		
		[Embed(source="../../lib/sounds/Shoot2.mp3")]			//Embed Shoot Sound 2 file
		static private const sShoot2:Class;
		
		[Embed(source="../../lib/sounds/Shoot3.mp3")]			//Embed Shoot Sound 3 file
		static private const sShoot3:Class;
		
		[Embed(source="../../lib/sounds/SoundExplosion.mp3")]	//Embed Eplosion Sound file
		static private const sExplosion:Class;
		
		[Embed(source = "../../lib/sounds/SoundCollision.mp3")]//Embed Collision Sound file	
		static private const sCollision:Class;
				
		private var soundShoot1: Sound;							//Shoot Sound
		private var soundShoot2: Sound;							//Shoot Sound
		private var soundShoot3: Sound;							//Shoot Sound
		private var soundExplosion: Sound;						//Eplosion Sound
		private var soundCollision: Sound;						//Collision Sound

		private var sShootChannel1: SoundChannel;				//Shoot Channel 1
		private var sShootChannel2: SoundChannel;				//Shoot Channel 2
		private var sShootChannel3: SoundChannel;				//Shoot Channel 3
		private var sExplosionChannel: SoundChannel;			//Explosion Channel
		private var sCollisionChannel: SoundChannel;			//Collision Channel
		
		//Constructor
		public function Sounds() 
		{
			soundShoot1 = (new sShoot1) as Sound;
			soundShoot2 = (new sShoot2) as Sound;
			soundShoot3 = (new sShoot3) as Sound;
			soundExplosion = (new sExplosion) as Sound;
			soundCollision = (new sCollision) as Sound;
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------		
		
		public function onShoot(type:int = 1):void
		{
			switch (type)
			{
				case 1:
					sShootChannel1 = soundShoot1.play(0, 0);
					break;
				case 2:
					sShootChannel2 = soundShoot2.play(0, 0);
					break;
				case 3:
					sShootChannel3 = soundShoot3.play(0, 0);
					break;
				default:
					sShootChannel1 = soundShoot1.play(0, 0);
			}
		}
		
		public function onExplosion():void
		{
			sExplosionChannel = soundExplosion.play(0, 0);
			sExplosionChannel.addEventListener(Event.SOUND_COMPLETE, sExplosionChannel_soundComplete);
		}
		
		private function sExplosionChannel_soundComplete(e:Event):void 
		{
			sExplosionChannel = null;
		}
		public function onCollision():void
		{
			sCollisionChannel = soundCollision.play(0, 0);
			sCollisionChannel.addEventListener(Event.SOUND_COMPLETE, sCollisionChannel_soundComplete);
		}
		
		private function sCollisionChannel_soundComplete(e:Event):void 
		{
			sCollisionChannel = null;
			dispatchEvent(new Event(Sounds.COLLISION_COMPLETE));
		}
	}

}