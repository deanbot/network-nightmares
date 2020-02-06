package gui
{
	import com.greensock.TweenLite;
	
	import engine.GameInstance;
	import engine.NetworkSounds;
	
	import fl.transitions.Wipe;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class You_Won extends Sprite
	{
	// constants:
	// private properties:
		private var screen:Win_Screen = new Win_Screen();
		private var addedToStage:NativeSignal;
		private var keyPressed:NativeSignal;
		
		
	// public properties:
		public var exit:Signal = new Signal();
		
	// constructor:
		public function You_Won()
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
			Sprite(screen.scoreItem).alpha = 0;
			TextField(Win_Screen_Score(screen.scoreItem).tf).text = String(GameInstance.points).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,");
			this.stage.focus=this;
			//keyPressed = new NativeSignal(this.stage, KeyboardEvent.KEY_UP, KeyboardEvent);
			Sprite(screen.button).buttonMode = true;
			keyPressed = new NativeSignal( Sprite(screen.button), MouseEvent.CLICK, MouseEvent);
			keyPressed.addOnce(onKeyPressed);
			addChild(screen);
			TweenLite.to(screen.scoreItem, 1, {delay: 2, alpha:1});
		}
		
		//private function onKeyPressed(e:KeyboardEvent):void
		private function onKeyPressed(e:MouseEvent):void
		{
			NetworkSounds.fadeSound(NetworkSounds.GAME_OVER_THEME, 0, .8);
			TweenLite.killTweensOf(screen.scoreItem);
			keyPressed=null;
			this.removeChild(screen);
			screen=null;
			this.exit.dispatch();
		}

	}
}