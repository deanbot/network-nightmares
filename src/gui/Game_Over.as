package gui
{
	import engine.Game;
	import engine.GameInstance;
	import engine.NetworkSounds;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class Game_Over extends Sprite
	{
	// constants:
	// private properties:
		private var gameOverScreen:Game_Over_Screen = new Game_Over_Screen();
		private var addedToStage:NativeSignal;
		private var keyPressed:NativeSignal;
		
	// public properties:
		public var exit:Signal = new Signal();
		
	// constructor:
		public function Game_Over()
		{
			super();
			addedToStage = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
			addedToStage.addOnce(onStage);
		}
		
	// public getter/setters:
	// public methods:
	// private methods:	
		private function onStage(e:Event):void
		{
			NetworkSounds.playSound(NetworkSounds.GAME_OVER_THEME, .8, 999);
			gameOverScreen.score.tf.text=GameInstance.points;
			this.stage.focus=this;
			keyPressed = new NativeSignal(this.stage, KeyboardEvent.KEY_UP, KeyboardEvent);
			keyPressed.addOnce(onKeyPressed);
			addChild(gameOverScreen);
		}
		
		private function onKeyPressed(e:KeyboardEvent):void
		{
			NetworkSounds.fadeSound(NetworkSounds.GAME_OVER_THEME, 0, .8);
			keyPressed=null;
			this.removeChild(gameOverScreen);
			gameOverScreen=null;
			this.exit.dispatch();
		}
	}
}