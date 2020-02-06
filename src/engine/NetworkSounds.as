package engine
{
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.sound.SoundManager;
	
	import org.osflash.signals.natives.NativeSignal;

	public class NetworkSounds
	{
		private static var soundManager:SoundManager;
		private static var timers:Dictionary;
		private static var timerCallbacks:Dictionary;
		
		public static const MENU_THEME:String = "MenuTheme";
		public static const GAME_OVER_THEME:String = "GameOverTheme";
		public static const MAIN_THEME:String = "MainTheme";
		public static const GAIN_LIFE:String = "GainLife";
		public static const LAUNCH:String = "Launch";
		public static const ADMIN_ALERT:String = "Alert";
		public static const NODE_HIT:String = "NodeHit";
		public static const HUB_HIT:String = "HubHit";
		public static const ROVING:String = "Roving";
		public static const TRANSITION_1:String = "Trans1";
		public static const TRANSITION_2:String = "Trans2";
		
		public static function activate():void
		{
			soundManager = SoundManager.getInstance();
			timers = new Dictionary(true);
			timerCallbacks = new Dictionary(true);
			// add network sounds
			soundManager.addLibrarySound( new Sound_MenuTheme(), MENU_THEME );
			soundManager.addLibrarySound( new Sound_GameOverTheme(), GAME_OVER_THEME );
			soundManager.addLibrarySound( new Sound_MainTheme(), MAIN_THEME );
			soundManager.addLibrarySound( new Sound_GainLife(), GAIN_LIFE );
			soundManager.addLibrarySound( new Sound_Launch(), LAUNCH );
			soundManager.addLibrarySound( new Sound_AdminAlert(), ADMIN_ALERT );
			soundManager.addLibrarySound( new Sound_NodeHit(), NODE_HIT );
			soundManager.addLibrarySound( new Sound_HubHit(), HUB_HIT );
			soundManager.addLibrarySound( new Sound_Roving(), ROVING );
			soundManager.addLibrarySound( new Sound_Transition1(), TRANSITION_1);
			soundManager.addLibrarySound( new Sound_Transition2(), TRANSITION_2);
		}
		
		public static function deactivate():void
		{
			soundManager.removeAllSounds();
		}
		
		public static function playSound(sound:String, vol:Number = 1, loops:uint = 0, callback:Function = null):void
		{
			soundManager.playSound(sound, vol, 0, loops, callback);
		}
		
		public static function fadeSound(sound:String, to:Number = 0, duration:Number = 1, stopWhenFaded:Boolean = true):void
		{
			if(stopWhenFaded)
			{
				timers[sound]=new Timer(duration);
				timerCallbacks[sound]=new NativeSignal(Timer(timers[sound]),TimerEvent.TIMER,TimerEvent);
				NativeSignal(timerCallbacks[sound]).addOnce(stopSound);
			}
			soundManager.fadeSound(sound,to,duration);
			
			function stopSound()
			{
				timerCallbacks[sound]=null;
				delete timerCallbacks[sound];
				timers[sound] = null;
				delete timers[sound];
				soundManager.stopSound(sound);
			}
		}
		
		public static function stopSound(sound:String):void
		{
			soundManager.stopSound(sound);
		}
		
		public static function muteAllSounds():void
		{
			soundManager.muteAllSounds();
		}
		
		public static function unmuteAllSounds():void
		{
			soundManager.unmuteAllSounds();
		}
	}
}