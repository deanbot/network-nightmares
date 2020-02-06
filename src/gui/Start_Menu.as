package gui
{
	import engine.GameInstance;
	import engine.NetworkSounds;
	
	import fl.controls.Button;
	import fl.controls.CheckBox;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	public class Start_Menu extends Sprite
	{
		// Prefix for error tracing
		private var prefix:String = "";
		private var _difficulty:Number;
		public var difficultyChanged:Signal;
		public var uiDestroyed:Signal;
		
		private var addedToStage:NativeSignal;
		public function Start_Menu()
		{
			super();
			prefix = "Start Menu: ";
			this.difficultyChanged = new Signal(Number);
			this.uiDestroyed = new Signal(String);
			addedToStage = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
			addedToStage.addOnce(onStage); 
		}
		
		// Display Objects
		private var start_menu:Sprite = new Start_Menu_Screen();
		private var how_to_play:Sprite;
		private var difficulty_selection:Sprite;
		private var how_to_play_btn:Sprite;
		private var play_game_btn:Sprite;
		private var credits_btn:Sprite;
		private var how_to_play_next_btn:Button;
		private var difficulty_selection_next_btn:Button;
		private var easy_checkbox:CheckBox;
		private var medium_checkbox:CheckBox;
		private var hard_checkbox:CheckBox;
		/**
		 * Add Start_Menu_Screen to stage
		 * 
		 * Prior to adding set up event listeners and hide sub menus
		 */
		private function onStage(e:Event):void
		{
			NetworkSounds.activate();
			NetworkSounds.playSound(NetworkSounds.MENU_THEME,0,999);
			NetworkSounds.fadeSound(NetworkSounds.MENU_THEME,.5,1.5,false);
			addedToStage = null;
			
			// get screens
			how_to_play = start_menu.getChildByName("how_to_play") as Sprite;
			difficulty_selection = start_menu.getChildByName("difficulty_selection") as Sprite;
			
			// get buttons
			play_game_btn = start_menu.getChildByName("play_btn") as Sprite;
			how_to_play_btn = start_menu.getChildByName("how_to_play_btn") as Sprite;
			credits_btn = start_menu.getChildByName("credits_btn") as Sprite;
			how_to_play_next_btn = how_to_play.getChildByName("how_to_play_next_btn") as Button;
			difficulty_selection_next_btn = difficulty_selection.getChildByName("difficulty_next_btn") as Button;
			play_game_btn.buttonMode = how_to_play_btn.buttonMode = credits_btn.buttonMode = true;
			
			// get checkboxes 
			easy_checkbox = difficulty_selection.getChildByName("easy_checkbox") as CheckBox;
			medium_checkbox = difficulty_selection.getChildByName("medium_checkbox") as CheckBox;
			hard_checkbox = difficulty_selection.getChildByName("hard_checkbox") as CheckBox;
			
			// add event listeners to buttons
			play_game_btn.addEventListener(MouseEvent.CLICK, on_start_button_click, false, 0, true);
			how_to_play_btn.addEventListener(MouseEvent.CLICK, on_start_button_click, false, 0, true);
			credits_btn.addEventListener(MouseEvent.CLICK, on_start_button_click, false, 0, true);
			how_to_play_next_btn.addEventListener(MouseEvent.CLICK, on_start_button_click, false, 0, true);
			difficulty_selection_next_btn.addEventListener(MouseEvent.CLICK, on_start_button_click, false, 0, true);
			
			// add event listeners to checkboxes
			easy_checkbox.addEventListener(MouseEvent.CLICK, on_checkbox_button_click, false, 0, true);
			medium_checkbox.addEventListener(MouseEvent.CLICK, on_checkbox_button_click, false, 0, true);
			hard_checkbox.addEventListener(MouseEvent.CLICK, on_checkbox_button_click, false, 0, true);
			
			// Hide how to play screen & difficulty selector
			how_to_play.alpha = difficulty_selection.alpha = 0;
			how_to_play.visible = difficulty_selection.visible = false;
			
			this.addChild(start_menu);
		}
		
		private function on_start_button_click(e:Event):void
		{
			switch(e.target.name) {
				case "play_btn":
					difficulty_selection.alpha = 1;
					difficulty_selection.visible = true;
					break;
				case "how_to_play_btn":
					how_to_play.alpha = 1;
					how_to_play.visible = true;
					break;
				case "credits_btn":
					trace("show credits");
					break;
				case "difficulty_next_btn":
					difficulty_selection.alpha = 0;
					difficulty_selection.visible = false;
					NetworkSounds.fadeSound(NetworkSounds.MENU_THEME,0,.8);
					doEndTransition();
					break;
				case "how_to_play_next_btn":
					how_to_play.alpha = 0;
					how_to_play.visible = false;
					break;
				default:
					trace(prefix + "some sort of button error");
			}
		}
		
		private function on_checkbox_button_click(e:Event):void
		{
			var newDifficulty:Number = 0;
			switch(e.target.name) {
				case "easy_checkbox":
					newDifficulty = GameInstance.DIFFICULTY_EASY;
					easy_checkbox.selected = true;
					medium_checkbox.selected = hard_checkbox.selected = false;
					break;
				case "medium_checkbox":
					newDifficulty = GameInstance.DIFFICULTY_MEDIUM;
					medium_checkbox.selected = true;
					easy_checkbox.selected = hard_checkbox.selected = false;
					break;
				case "hard_checkbox":
					newDifficulty = GameInstance.DIFFICULTY_HARD;
					hard_checkbox.selected = true;
					easy_checkbox.selected = medium_checkbox.selected = false;
					break;
				default:
					trace(prefix + "some sort of checkbox error");
			}
			
			if ( newDifficulty != _difficulty ) {
				_difficulty = newDifficulty;
				this.difficultyChanged.dispatch(_difficulty);
			}
		}
		
		private function doEndTransition():void
		{
			//TODO take bitmapsnapshot and tween width/height to 1 and then call destroy
			destroy();
		}
		
		private function destroy():void
		{
			//remove event listeners
			play_game_btn.removeEventListener(MouseEvent.CLICK, on_start_button_click);
			how_to_play_btn.removeEventListener(MouseEvent.CLICK, on_start_button_click);
			credits_btn.removeEventListener(MouseEvent.CLICK, on_start_button_click);
			how_to_play_next_btn.removeEventListener(MouseEvent.CLICK, on_start_button_click);
			difficulty_selection_next_btn.removeEventListener(MouseEvent.CLICK, on_start_button_click);
			easy_checkbox.removeEventListener(MouseEvent.CLICK, on_checkbox_button_click);
			medium_checkbox.removeEventListener(MouseEvent.CLICK, on_checkbox_button_click);
			hard_checkbox.removeEventListener(MouseEvent.CLICK, on_checkbox_button_click);
			this.start_menu.addEventListener(Event.REMOVED_FROM_STAGE, onAssetRemoved, false, 0, true);
			this.removeChild(start_menu);
		}
		
		private function onAssetRemoved(e:Event):void
		{
			start_menu = null;
			this.uiDestroyed.dispatch("destroyed");
		}
	}
}