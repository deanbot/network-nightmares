package
{
	import engine.Game;
	import engine.GameInstance;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	import gui.Game_Over;
	import gui.Start_Menu;
	import gui.You_Won;

	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	public class Network_Nightmares extends Sprite
	{
	// constants:
	// private properties:
		private var difficulty:uint = 1;
		private var addedToStage:NativeSignal;
		private var startMenu:Start_Menu;
		private var startMenuRemoved:NativeSignal;
		private var gameRemoved:NativeSignal;
		private var game:Game;
		private var gameOver:Game_Over;
		private var youWon:You_Won;
		private var beatLevel:Boolean;

	// public properties:
	// constructor:
		public function Network_Nightmares()
		{
			addedToStage = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
			addedToStage.addOnce(onStage);
		}

		// public getter/setters:
		// public methods:
		// private methods:
		/**
		 * When Network Nightmares is added to the stage create the Start Menu
		 */

		private function onStage(e:Event):void
		{
			addedToStage = null;
			createStartMenu();
		}

		/**
		 * Create and add Start_Menu screen to stage
		 *
		 * Prior to adding set up listener for difficultyChanged and uiDestroyed signals
		 */
		private function createStartMenu():void
		{
			startMenu = new Start_Menu();
			startMenu.difficultyChanged.add(onDifficultyChanged);
			startMenu.uiDestroyed.addOnce(onUIDestroyed);
			addChild(startMenu);

			GameInstance.lives=3;
			GameInstance.level=1;
			GameInstance.points=0;
		}

		private function onDifficultyChanged(diff:Number):void
		{
			GameInstance.difficulty = diff;
		}

		private function onUIDestroyed(e:String):void
		{
			startMenu.difficultyChanged.remove(onDifficultyChanged);
			startMenuRemoved = new NativeSignal(startMenu, Event.REMOVED_FROM_STAGE, Event);
			startMenuRemoved.addOnce(onStartMenuRemoved);
			removeChild(startMenu);
		}

		private function onStartMenuRemoved(e:Event):void
		{
			startMenuRemoved = null;
			startMenu = null;
			createGame();
		}

		/**
		 * Create the game based on Difficulty and
		 * Add Game to the stage
		 *
		 */
		private function createGame():void
		{
			game = new Game();
			addChild(game);
			game.gameOver.addOnce(onGameOver);
			game.quitToMenu.addOnce(onQuitToMenu);
			game.beatLevel.addOnce(onBeatLevel);
		}

		private function onGameOver():void
		{
			removeGame();
			gameOver=new Game_Over();
			addChild(gameOver);
			gameOver.exit.addOnce(onGameOverRemoved);
		}

		private function onQuitToMenu():void
		{
			removeGame();
			createStartMenu();
		}

		private function onBeatLevel():void
		{
			beatLevel=true;
			removeGame();
		}

		private function onGameOverRemoved():void
		{
			removeChild(gameOver);
			gameOver=null;
			createStartMenu();
		}

		private function onWinScreenRemoved():void
		{
			removeChild(youWon);
			youWon=null;
			createStartMenu();
		}

		private function removeGame():void
		{
			gameRemoved = new NativeSignal(this.game, Event.REMOVED_FROM_STAGE, Event);
			gameRemoved.addOnce(onGameRemoved);
			removeChild(game);
		}

		private function onGameRemoved(e:Event):void
		{
			gameRemoved = null;
			game = null;
			if(beatLevel)
				nextLevel();
		}

		private function nextLevel():void
		{
			beatLevel=false;
			GameInstance.level++;
			if(GameInstance.level==1)
			{
				//shouldn't be here, do start menu
				trace("next level = level 1");
				createStartMenu();
			} else if (GameInstance.level==2||GameInstance.level==3)
			{
				createGame();
			} else if (GameInstance.level>=4)
			{
				youWon=new You_Won();
				addChild(youWon);
				youWon.exit.addOnce(onWinScreenRemoved);
			}
		}
	}
}