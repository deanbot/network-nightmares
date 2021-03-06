package engine
{
	import com.greensock.TweenLite;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import net.deanverleger.utils.ClipUtils;
	import net.deanverleger.utils.DictionaryUtils;
	import net.deanverleger.utils.TweenUtils;

	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

	public class Game extends Sprite
	{
	// constants:
		private static const POPUP_TRANSITION_TIME:Number = .35;
		private static const POPUP_VISIBLE_TIME:Number = .6;

	// private properties:
		private var vStartX:Number = 158;
		private var vStartY:Number	= 262;
		private var virusScale:Number;
		private var gravity:Number;
		private var speedReductionConstant:Number;
		private var stageEdgeN:uint;
		private var stageEdgeE:uint;
		private var stageEdgeS:uint;
		private var stageEdgeW:uint;
		private var virusOffset:Number;
		private var addedToStage:NativeSignal;
		private var flinger:Sprite;
		private var gainedVirus:Sprite;
		private var virusIcons:Array;
		private var virus:Sprite;
		private var virusDown:NativeSignal;
		private var virusUp:NativeSignal;
		private var stageUp:NativeSignal;
		private var virusMoved:NativeSignal;
		private var enterFrame:NativeSignal;
		private var dx:Number;
		private var dy:Number;
		private var livesHolder:Sprite;
		private var virusDestroyed:MovieClip;
		private var virusDestroyedEndFrame:uint;
		private var onVirusDestroyedComplete:NativeSignal;
		private var virusLoading:MovieClip;
		private var virusLoaded:NativeSignal;
		private var virusLoadedEndFrame:uint;
		private var container:Sprite;
		private var tweenHolder:Sprite;
		private var bg:Sprite;
		private var volumeMuteButton:VolumeMuteButton;
		private var volumeMuteClicked:NativeSignal;
		private var quitToMainConfirm:QuitToMainConfirm;
		private var quitConfirmYes:NativeSignal;
		private var quitConfirmNo:NativeSignal;
		private var menuHit:Sprite;
		private var menuClick:NativeSignal;
		private var port0_l1:Sprite;
		private var port0_l2:Sprite;
		private var port1_l2:Sprite;
		private var port0_l3:Sprite;
		private var port1_l3:Sprite;
		private var port2_l3:Sprite;
		private var ports:Dictionary;
		private var portIDs:Dictionary;
		private var numPorts:uint;
		private var numInfectedPorts:uint;
		private var clonedVirusAdded:NativeSignal;
		private var collisionNode:Boolean;
		private var tempNodeID:String;
		private var tempPortID:uint;
		private var nodeHitSp:Sprite;
		private var portClips:Dictionary;
		private var virusInfections:Dictionary;
		private var infectedNodeIDs:Dictionary;
		private var levelText:String;
		private var virusAwardsWindow:Sprite;
		private var numActiveViruses:uint=0;
		private var popupOut:Boolean = false;
		private var popupIn:Boolean = false;
		private var awardVirusIn:Boolean=false;
		private var awardVirusOut:Boolean=false;
		private var virusAwardsEnterFrame:NativeSignal;
		private var popupDelay:Timer;
		private var popupDelayed:NativeSignal;
		private var virusAwardsProgress:Number;
		private var virusIndex:uint;
		private var playerOutOfFlings:Boolean=false;
		private var levelIntroScreen:Sprite;
		private var introTimer:Timer;
		private var introTimerComplete:NativeSignal;
		private var goToNextLevel:Boolean=false;

	// public properties:
		public var gameOver:Signal;
		public var quitToMenu:Signal;
		public var gameDestroyed:Signal;
		public var beatLevel:Signal;

	// constructor:
		public function Game()
		{
			super();
			this.gameDestroyed = new Signal(String);
			this.gameOver = new Signal();
			this.quitToMenu = new Signal();
			this.beatLevel = new Signal();
			addedToStage = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
			addedToStage.addOnce(onStage);

			var config:GameConfig = new GameConfig();
			virusScale = config.virusScale;
			gravity = config.gravity;
			speedReductionConstant = config.speedReductionConstant;
			config = null;
		}

	// public getter/setters:
	// public methods:
	// private methods:
		/**
		 * Add Game Assets to Stage
		 */
		private function onStage(e:Event):void
		{
			ports=new Dictionary(true);
			portIDs=new Dictionary(true);
			portClips=new Dictionary(true);
			virusInfections=new Dictionary(true);
			numPorts=numInfectedPorts=numActiveViruses=0;

			virusAwardsWindow=new VirusAwardsWindow() as Sprite;
			container = new Sprite();

			switch(GameInstance.level)
			{
				case 1:
					container.addChild(bg=new Bg_l1() as Sprite);
					container.addChild(port0_l1=new Port0_l1() as Sprite);
					port0_l1.x=250.95;
					port0_l1.y=58.3;
					virusAwardsWindow.x=328.45;
					virusAwardsWindow.y=350.35;
					ClipUtils.stopChildren(port0_l1);
					var port1:NetworkPort=new NetworkPort(port0_l1,MovieClip(port0_l1["body"]));
					registerPort(port1,port0_l1,0);

					// PORT 1
					// HAND 0
					port1.addHand( new Array(
						new Point(231.65, 218.05),
						new Point(252.8, 218.05),
						new Point(282.15, 116)
						), MovieClip(port0_l1["hand0"]));
					port1.addFinger( new Array(
						new Point( 298.4, 60.8),
						new Point( 311.65, 18.45),
						new Point( 329.65, 18.45)
						), MovieClip(port0_l1["finger0_h0"]), MovieClip(port0_l1["hand0"]));
					port1.addFinger( new Array(
						new Point( 260.7, 88.7),
						new Point( 233.6, 88.7),
						new Point( 211.8, 65.55)
						), MovieClip(port0_l1["finger1_h0"]), MovieClip(port0_l1["hand0"]));
					// HAND 1
					port1.addHand( new Array(
						new Point( 231.65, 200.85),
						new Point( 288.65, 200.85)
						), MovieClip(port0_l1["hand1"]));
					port1.addFinger( new Array(
						new Point( 336.1, 222.2),
						new Point( 345.65, 231.4),
						new Point( 382.55, 231.4)
					), MovieClip(port0_l1["finger0_h1"]), MovieClip(port0_l1["hand1"]));
					port1.addFinger( new Array(
						new Point( 346.15, 200.85),
						new Point( 371.35,200.85),
						new Point( 432.4, 138.9)
					), MovieClip(port0_l1["finger1_h1"]), MovieClip(port0_l1["hand1"]));
					// HAND 2
					port1.addHand( new Array(
						new Point( 141.25, 218.35),
						new Point( 121.9, 218.35),
						new Point( 107.55, 184.35)
						), MovieClip(port0_l1["hand2"]));
					port1.addFinger( new Array(
						new Point( 118.95, 140.75),
						new Point( 131.65, 125.45)
					), MovieClip(port0_l1["finger0_h2"]), MovieClip(port0_l1["hand2"]));
					port1.addFinger( new Array(
						new Point( 85.4, 131.15),
						new Point( 63.6, 79.15),
						new Point( 45.15, 79.15)
					), MovieClip(port0_l1["finger1_h2"]), MovieClip(port0_l1["hand2"]));
					// HAND 3
					port1.addHand( new Array(
						new Point( 215.3, 239.3),
						new Point( 234.9, 258.55),
						new Point( 271.45, 258.55)
						), MovieClip(port0_l1["hand3"]));
					port1.addFinger( new Array(
						new Point( 317.35, 291.7),
						new Point( 347, 321.4)
					), MovieClip(port0_l1["finger0_h3"]), MovieClip(port0_l1["hand3"]));
					port1.addFinger( new Array(
						new Point( 325.15, 272.5),
						new Point( 353.05, 272.5)
					), MovieClip(port0_l1["finger1_h3"]), MovieClip(port0_l1["hand3"]));
					levelText=GameConfig.INTRO_TEXT_PRE+1+GameConfig.INTRO_TEXT_SUF;
					break;
				case 2:
					container.addChild(bg=new Bg_l2() as Sprite);
					container.addChild(port0_l2=new Port0_l2() as Sprite);
					container.addChild(port1_l2=new Port1_l2() as Sprite);
					port0_l2.x=336.15;
					port0_l2.y=154.7;
					port1_l2.x=208.25;
					port1_l2.y=49.3;
					virusAwardsWindow.x=395.95;
					virusAwardsWindow.y=367.95;
					ClipUtils.stopChildren(port0_l2);
					ClipUtils.stopChildren(port1_l2);
					var l2p1:NetworkPort=new NetworkPort(port0_l2,MovieClip(port0_l2["body"]));
					var l2p2:NetworkPort=new NetworkPort(port1_l2,MovieClip(port1_l2["body"]));
					registerPort(l2p1,port0_l2,0);
					registerPort(l2p2,port1_l2,1);
					// PORT 1
					// HAND 0
					l2p1.addHand( new Array(
						new Point( 204.45, 192.15),
						new Point( 222.65, 192.15),
						new Point( 273.6, 16.25),
						new Point( 288.6, 16.25 )
					), MovieClip(port0_l2["hand0"]));
					// HAND 1
					l2p1.addHand( new Array(
						new Point( 204.55, 176.8),
						new Point( 253.45, 176.8)
					), MovieClip(port0_l2["hand1"]));
					l2p1.addFinger( new Array(
						new Point( 299.75, 195.65),
						new Point( 312.15, 206.85),
						new Point( 341.55, 206.85)

					), MovieClip(port0_l2["finger0_h1"]), MovieClip(port0_l2["hand1"]));
					l2p1.addFinger( new Array(
						new Point( 307.05, 176.8),
						new Point( 327.75, 176.8),
						new Point( 380.75, 123.2)
					), MovieClip(port0_l2["finger1_h1"]), MovieClip(port0_l2["hand1"]));
					// HAND 2
					l2p1.addHand( new Array(
						new Point( 124.45, 193),
						new Point( 107.05, 193),
						new Point( 95, 163.55)
					), MovieClip(port0_l2["hand2"]));
					l2p1.addFinger( new Array(
						new Point( 101.25, 120.25),
						new Point( 112.7, 109.1)
					), MovieClip(port0_l2["finger0_h2"]), MovieClip(port0_l2["hand2"]));
					l2p1.addFinger( new Array(
						new Point( 75, 113.2),
						new Point( 57.05, 70.2),
						new Point( 40.85, 70.2)
					), MovieClip(port0_l2["finger1_h2"]), MovieClip(port0_l2["hand2"]));

					// PORT 2
					// HAND 0
					l2p2.addHand( new Array(
						new Point( 283.7, 88.45),
						new Point( 323.95, 88.45),
						new Point( 424.1, 187.65)
					), MovieClip(port1_l2["hand0"]));
					// HAND 1
					l2p2.addHand( new Array(
						new Point( 283.8, 62.65),
						new Point( 363.8, 62.65),
						new Point( 390.1, 35.85)
					), MovieClip(port1_l2["hand1"]));
					// HAND 2
					l2p2.addHand( new Array(
						new Point( 203.9, 69.75),
						new Point( 143.9, 69.75)
					), MovieClip(port1_l2["hand2"]));
					l2p2.addFinger( new Array(
						new Point( 135.5, 50.4),
						new Point( 140.5, 45.9)
					), MovieClip(port1_l2["finger0_h2"]), MovieClip(port1_l2["hand2"]));
					l2p2.addFinger( new Array(
						new Point( 90.15, 69.45),
						new Point( 85.65, 69.45),
						new Point( 48.95, 34.2)
					), MovieClip(port1_l2["finger1_h2"]), MovieClip(port1_l2["hand2"]));
					// HAND 3
					l2p2.addHand( new Array(
						new Point( 265.1, 107.8),
						new Point( 115.55, 256.35),
						new Point( 40.8, 256.35)
					), MovieClip(port1_l2["hand3"]));

					levelText=GameConfig.INTRO_TEXT_PRE+2+GameConfig.INTRO_TEXT_SUF;
					break;
				case 3:
					container.addChild(bg=new Bg_l3() as Sprite);
					container.addChild(port0_l3=new Port0_l3() as Sprite);
					container.addChild(port1_l3=new Port1_l3() as Sprite);
					container.addChild(port2_l3=new Port2_l3() as Sprite);
					port0_l3.x = 302.8;
					port0_l3.y = 284.85;
					port1_l3.x = 388.1;
					port1_l3.y = 108.1;
					port2_l3.x = 281.5;
					port2_l3.y = 18.5;
					virusAwardsWindow.x = 109.8;
					virusAwardsWindow.y = 66;
					ClipUtils.stopChildren(port0_l3);
					ClipUtils.stopChildren(port1_l3);
					ClipUtils.stopChildren(port2_l3);
					var l3p1:NetworkPort=new NetworkPort(port0_l3,MovieClip(port0_l3["body"]));
					var l3p2:NetworkPort=new NetworkPort(port1_l3,MovieClip(port1_l3["body"]));
					var l3p3:NetworkPort=new NetworkPort(port2_l3,MovieClip(port2_l3["body"]));
					registerPort(l3p1,port0_l3,0);
					registerPort(l3p2,port1_l3,1);
					registerPort(l3p3,port2_l3,2);

					// PORT 1
					// HAND 0
					l3p1.addHand( new Array(
						new Point( 149.25, 71.95),
						new Point( 206.25, 71.95)
					), MovieClip(port0_l3["hand0"]));
					l3p1.addFinger( new Array(
						new Point( 248.55, 88.15),
						new Point( 252.45, 92.05)

					), MovieClip(port0_l3["finger0_h0"]), MovieClip(port0_l3["hand0"]));
					l3p1.addFinger( new Array(
						new Point( 255.55, 71.95),
						new Point( 278.65, 71.95),
						new Point( 336.7, 14.4),
						new Point( 381.4, 14.4)
					), MovieClip(port0_l3["finger1_h0"]), MovieClip(port0_l3["hand0"]));
					// HAND 1
					l3p1.addHand( new Array(
						new Point( 128.7, 107.6),
						new Point( 99.1, 137.55),
						new Point( 36.4, 137.55)
					), MovieClip(port0_l3["hand1"]));

					// PORT 2
					// HAND 0
					l3p2.addHand( new Array(
						new Point( 172.75, 161.2),
						new Point( 187.8, 161.2),
						new Point( 193.5, 143.2)
					), MovieClip(port1_l3["hand0"]));
					l3p2.addFinger( new Array(
						new Point( 224, 120.1),
						new Point( 286.4, 120.1),
						new Point( 330, 77.45)
					), MovieClip(port1_l3["finger0_h0"]), MovieClip(port1_l3["hand0"]));
					l3p2.addFinger( new Array(
						new Point( 207.85, 95.15),
						new Point( 231.65, 13.9),
						new Point( 242.15, 13.9)
					), MovieClip(port1_l3["finger1_h0"]), MovieClip(port1_l3["hand0"]));
					// HAND 1
					l3p2.addHand( new Array(
						new Point( 105.6, 162.45),
						new Point( 91.2, 162.45),
						new Point( 47.95, 59.4),
						new Point( 36.85, 59.4)
					), MovieClip(port1_l3["hand1"]));
					// HAND 2
					l3p2.addHand( new Array(
						new Point( 160.75, 177.85),
						new Point( 175.3, 193.15),
						new Point( 211.2, 193.15),
						new Point( 255.2, 236.4)
					), MovieClip(port1_l3["hand2"]));

					// PORT 3
					// HAND 0
					l3p3.addHand( new Array(
						new Point( 239.8, 75.3),
						new Point( 274, 75.3),
						new Point( 356.25, 157)
					), MovieClip(port2_l3["hand0"]));
					// HAND 1
					l3p3.addHand( new Array(
						new Point( 239.9, 53.65),
						new Point( 307.1, 53.65),
						new Point( 327.85, 32.7)
					), MovieClip(port2_l3["hand1"]));

					// HAND 2
					l3p3.addHand( new Array(
						new Point( 171.8, 59.85),
						new Point( 96.25, 59.85)
					), MovieClip(port2_l3["hand2"]));
					l3p3.addFinger( new Array(
						new Point( 89.45, 41.6),
						new Point( 100.05, 31.6),
						new Point( 124.45, 31.6)
					), MovieClip(port2_l3["finger0_h2"]), MovieClip(port2_l3["hand2"]));
					l3p3.addFinger( new Array(
						new Point( 53.6, 40.05),
						new Point( 43.65, 30.6)
					), MovieClip(port2_l3["finger1_h2"]), MovieClip(port2_l3["hand2"]));
					// HAND 3
					l3p3.addHand( new Array(
						new Point( 222.65, 92.15),
						new Point( 97.7, 216.85),
						new Point( 36.9, 216.85)
					), MovieClip(port2_l3["hand3"]));

					levelText=GameConfig.INTRO_TEXT_PRE+3+GameConfig.INTRO_TEXT_SUF;
					break;
			}
			virusIndex=container.getChildIndex(bg) + 1;

			quitToMainConfirm = new QuitToMainConfirm();
			Sprite(quitToMainConfirm).visible = false;
			MovieClip(quitToMainConfirm.no).buttonMode=true;
			MovieClip(quitToMainConfirm.yes).buttonMode=true;
			quitConfirmYes= new NativeSignal( MovieClip(quitToMainConfirm.yes), MouseEvent.CLICK, MouseEvent);
			quitConfirmNo= new NativeSignal( MovieClip(quitToMainConfirm.no), MouseEvent.CLICK, MouseEvent);
			container.addChild( menuHit=new MenuHit() as Sprite );
			menuHit.x = .2;
			menuHit.y=459.45;
			menuHit.alpha=0;
			menuHit.buttonMode=true;
			menuClick=new NativeSignal(menuHit,MouseEvent.CLICK,MouseEvent);

			//for collison checking
			stageEdgeN=0;
			stageEdgeE=stage.width;
			stageEdgeS=stage.height;
			stageEdgeW=0;

			container.addChild( flinger = new Flinger() as Sprite );
			flinger.x = 158;
			flinger.y = 361.5;
			flinger.cacheAsBitmap = true;
			container.addChild( gainedVirus = new GainedVirus() as Sprite );
			gainedVirus.visible=false;
			gainedVirus.alpha=0;
			gainedVirus.x=126;
			gainedVirus.y=385;
			container.addChild(virusAwardsWindow);
			virusAwardsWindow.visible=false;
			resetVirusAwardsWindow();
			updateVirusIcons();

			container.addChild(volumeMuteButton=new VolumeMuteButton());
			volumeMuteButton.x=639;
			volumeMuteButton.y=478;
			MovieClip(volumeMuteButton).stop();
			MovieClip(volumeMuteButton).buttonMode=true;
			volumeMuteClicked=new NativeSignal(volumeMuteButton,MouseEvent.CLICK,MouseEvent);
			volumeMuteClicked.add(onVolumeMutePress);

			levelIntroScreen=new LevelIntro() as Sprite;
			TextField(LevelIntro(levelIntroScreen).tf).text=levelText;

			levelIntro();
		}

		private function levelIntro():void
		{
			introTimer=new Timer(GameConfig.INTRO_TIME);
			introTimerComplete=new NativeSignal(introTimer,TimerEvent.TIMER,TimerEvent);
			introTimerComplete.addOnce(function(e:TimerEvent):void {
				if(GameInstance.level == 2)
					NetworkSounds.fadeSound( NetworkSounds.TRANSITION_1, 0, .5);
				else if(GameInstance.level == 3)
					NetworkSounds.fadeSound( NetworkSounds.TRANSITION_2, 0, .5);
				introTimerComplete=null;
				introTimer.stop();
				introTimer=null;
				removeChild(levelIntroScreen);
				levelIntroScreen=null;
				levelBegin();
			});
			addChild(levelIntroScreen);
			introTimer.start();
			if(GameInstance.level == 2)
				NetworkSounds.playSound( NetworkSounds.TRANSITION_1, .5,3);
			else if (GameInstance.level == 3)
				NetworkSounds.playSound( NetworkSounds.TRANSITION_2, .5,3);
		}

		private function levelBegin():void
		{
			NetworkSounds.playSound(NetworkSounds.MAIN_THEME, 0, 999);
			NetworkSounds.fadeSound(NetworkSounds.MAIN_THEME, .3, 3, false);
			addChild(container);
			addChild(quitToMainConfirm);
			configurePorts();
			createVirus();
			for(var k:String in ports)
			{
				NetworkPort(ports[k]).activate();
			}

			//points
			pointsTimer = new Timer(60000);
			pointsTimerInterval = new NativeSignal(pointsTimer, TimerEvent.TIMER,TimerEvent);
			pointsTimerInterval.add(onPointsTimerInterval);
			pointsTimerMinutes = 0;

		}

		private var pointsTimer:Timer;
		private var pointsTimerInterval:NativeSignal;
		private var pointsTimerMinutes:uint;
		private var pointsLivesGained:uint;
		private var pointsNodesCleaned:uint;
		private var pointsPortsInfected:uint;
		private function onPointsTimerInterval(e:TimerEvent):void
		{
			pointsTimerMinutes++;
		}

		private function registerPort(port:NetworkPort,portClip:Sprite,index:uint):void
		{
			if(ports==null)
				ports=new Dictionary(true);
			if(portIDs==null)
				portIDs=new Dictionary(true);
			if(portClips==null)
				portClips=new Dictionary(true);
			if(virusInfections==null)
				virusInfections=new Dictionary(true);
			if(infectedNodeIDs==null)
				infectedNodeIDs=new Dictionary(true);
			if(ports[index]==null)
				numPorts++;
			ports[index]=port;
			portIDs[port]=index;
			portClips[index]=portClip;
			infectedNodeIDs[port]=new Dictionary(true);
			virusInfections[index]=new Dictionary(true);
		}

		private function configurePorts():void
		{
			var port:NetworkPort;
			for(var k:String in ports)
			{
				port=NetworkPort(ports[k]);
				port.nodeInfected.add(onPortNodeInfected);
				port.nodeCleaned.add(onPortNodeCleaned);
				port.portCompletelyInfected.addOnce( function():void
				{
					onPortCompletelyInfected(port);
				});
			}
		}

		private function onPortNodeInfected(port:NetworkPort,segmentID:String):void
		{
			var portID:uint = portIDs[port as NetworkPort];
			var infectedNodes:Dictionary = Dictionary(infectedNodeIDs[port]);
			if (infectedNodes==null)
				return;
			infectedNodes[segmentID]=segmentID;
			numActiveViruses++;
			updateVirusAwards();
		}

		private function onPortNodeCleaned(port:NetworkPort,segmentID:String):void
		{
			var portID:uint = portIDs[port as NetworkPort];
			container.removeChild(Sprite(Dictionary(virusInfections[portID])[segmentID]));
			var infectedNodes:Dictionary = Dictionary(infectedNodeIDs[port]);
			if (infectedNodes==null)
				return;
			delete infectedNodes[segmentID];
			numActiveViruses--;
			updateVirusAwards();
			if (playerOutOfFlings)
				checkFlingsLeft();
		}

		private function removePortVirusAwards(port:NetworkPort):void
		{
			var infectedNodes:Dictionary = Dictionary(infectedNodeIDs[port]);
			if (infectedNodes==null)
				return;
			for(var k:String in infectedNodes)
				delete infectedNodes[k];
			numActiveViruses-=port.numNodes;
			updateVirusAwards();
		}


		private function updateVirusAwards():void
		{
			if(numActiveViruses>0) {
				if(!virusAwardsWindow.visible)
				{
					virusAwardsWindow.visible=true;
					startVirusAwards();
				} else {
					//cancel any current transition out
					if(popupOut || popupIn)
					{
						TweenLite.killTweensOf(virusAwardsWindow);
						virusAwardsWindow.alpha=1;
						popupOut=popupIn=false;
						startVirusAwards();
					}
				}
			}
			else
			{
				if(!popupOut)
				{
					if(popupIn)
					{
						TweenLite.killTweensOf(virusAwardsWindow);
						popupIn=false;
					}
					if(virusAwardsWindow.visible)
						endVirusAwards();
				}
			}

			function startVirusAwards():void
			{
				resetVirusAwardsWindow();
				popupIn=true;
				if(virusAwardsWindow.alpha!=1)
					TweenLite.to(virusAwardsWindow,POPUP_TRANSITION_TIME,{alpha:1, onComplete:activateVirusAwardsWindow});
				else
					activateVirusAwardsWindow();
			}

			function endVirusAwards():void
			{
				deactivateVirusAwardsWindow();
				popupOut=true;
				TweenLite.to(virusAwardsWindow,POPUP_TRANSITION_TIME,{alpha:0, onComplete:onVirusAwardsHidden});
			}

			function onVirusAwardsHidden():void {
				popupOut=false;
				virusAwardsWindow.visible=false;
			}

			/**
			 * Start gaining viruses
			 */
			function activateVirusAwardsWindow():void
			{
				popupIn=false;
				virusAwardsEnterFrame.add(onVirusAwardsEnterFrame);
			}

			/**
			 * Stop gaining viruses
			 */
			function deactivateVirusAwardsWindow():void
			{
				virusAwardsEnterFrame.remove(onVirusAwardsEnterFrame);
			}
		}

		/**
		 * Reset virus downloading bar
		 */
		private function resetVirusAwardsWindow():void
		{
			if(popupDelay==null)
				popupDelay=new Timer(POPUP_VISIBLE_TIME);
			if(popupDelayed==null)
				popupDelayed=new NativeSignal(popupDelay, TimerEvent.TIMER, TimerEvent);
			if(virusAwardsEnterFrame==null)
				virusAwardsEnterFrame=new NativeSignal(virusAwardsWindow,Event.ENTER_FRAME,Event);
			var maskRect:Sprite = Sprite(virusAwardsWindow["maskRect"]);
			maskRect.x=GameConfig.VIRUS_AWARDS_BAR_OFFSET+maskRect.width*.1;
			virusAwardsProgress=0;
		}

		private function onVirusAwardsEnterFrame(e:Event):void
		{
			var maskRect:Sprite = Sprite(virusAwardsWindow["maskRect"]);
			//update progress
			virusAwardsProgress+=.01*(numActiveViruses*GameInstance.virusAwardsTimeConstant);

			if (virusAwardsProgress>=1)
			{
				awardVirus();
				resetVirusAwardsWindow();
			} else if(virusAwardsProgress>.1)
			{
				maskRect.x=GameConfig.VIRUS_AWARDS_BAR_OFFSET+maskRect.width*virusAwardsProgress;
			}
		}

		private function awardVirus():void
		{
			NetworkSounds.playSound(NetworkSounds.GAIN_LIFE, .5);
			GameInstance.lives++;
			pointsLivesGained++;
			updateVirusIcons();
			if(playerOutOfFlings)
				checkFlingsLeft();

			if(!gainedVirus.visible)
			{
				awardVirusIn=true;
				gainedVirus.alpha=0;
				gainedVirus.visible=true;
				TweenLite.to(gainedVirus,POPUP_TRANSITION_TIME,{alpha:1, onComplete:delayPopOut});
			} else {
				//cancel transition of gained Virus window
				if(awardVirusIn || awardVirusOut)
				{
					TweenLite.killTweensOf(gainedVirus);
					gainedVirus.alpha=1;
					awardVirusIn=false;
				} else {
					delayPopOut();
				}
			}

			function delayPopOut():void
			{
				awardVirusIn=false;
				if(popupDelay.running)
				{
					popupDelayed.remove(onPopupDelayed);
					popupDelay.reset();
				}
				popupDelayed.addOnce(onPopupDelayed);
				popupDelay.start();
			}

			function onPopupDelayed(e:TimerEvent):void
			{
				awardVirusOut=true;
				TweenLite.to(gainedVirus,POPUP_TRANSITION_TIME,{alpha:0, onComplete:onPopOut});
			}

			function onPopOut():void
			{
				gainedVirus.visible=false;
				awardVirusOut=false;
			}
		}

		private function onPortCompletelyInfected(port:NetworkPort):void {

			if(numInfectedPorts==numPorts)
			{
				levelComplete(); // do nextLevel.dispatch instead of gameOver.dispatch
			} else {
				checkFlingsLeft();
			}
		}

		private function createVirus():void
		{
			virus = new Virus();
			container.addChild(virusLoading=new VirusLoading() as MovieClip);
			virus.x=virusLoading.x=vStartX;
			virus.y=virusLoading.y=vStartY;
			virus.scaleX=virus.scaleY=virusLoading.scaleX=virusLoading.scaleY=virusScale;
			virus.cacheAsBitmap = true;
			virus.buttonMode = true;
			virus.visible=false;
			virusLoadedEndFrame=virusLoading.totalFrames-1;
			virusLoading.addFrameScript(virusLoadedEndFrame, function():void {
				virusLoading.stop();
				virusLoading.dispatchEvent(new Event("VirusLoaded"));
			});
			virusLoaded=new NativeSignal(virusLoading, "VirusLoaded", Event);
			virusLoaded.addOnce(onVirusLoaded);
			container.addChild(virus);

			//for collision checking
			virusOffset=virus.width*.5;
		}

		/**
		 * Create the signals that will be listened to for dragging functionality
		 *
		 */
		private function onVirusLoaded(e:Event):void
		{
			virus.visible=true;
			container.removeChild(virusLoading);
			virusLoading = null;
			virusLoaded = null;
			virusDown = new NativeSignal(virus, MouseEvent.MOUSE_DOWN, MouseEvent);
			virusUp = new NativeSignal(virus, MouseEvent.MOUSE_UP, MouseEvent);
			stageUp = new NativeSignal(this.stage, MouseEvent.MOUSE_UP, MouseEvent);
			virusMoved = new NativeSignal(this.stage, MouseEvent.MOUSE_MOVE, Event);
			initControls();
		}

		private function initControls():void
		{
			menuClick.addOnce(onMenuButtonClicked);
			virusDown.addOnce(onVirusDown);
		}

		private function onVirusDown(e:MouseEvent):void
		{
			menuClick.remove(onMenuButtonClicked);
			virusMoved.add(onVirusMoved);
			virusUp.addOnce(onVirusUp);
			stageUp.addOnce(onStageUp);
		}

		private function onStageUp(e:MouseEvent):void { virusUp.dispatch(new MouseEvent(MouseEvent.MOUSE_UP)); }

		/**
		 * Draw lines to the virus and limit the distance player can drag the virus
		 *
		 */
		private function onVirusMoved(e:Event):void
		{
			virus.x = mouseX;
			virus.y = mouseY;
			var distanceX:Number = virus.x - vStartX;
			var distanceY:Number = virus.y - vStartY;
			if ( distanceX * distanceX + distanceY * distanceY > 10000 ) {
				var virusAngle:Number = Math.atan2( distanceY, distanceX );
				virus.x = vStartX + ( 100 * Math.cos(virusAngle) );
				virus.y = vStartY + ( 100 * Math.sin(virusAngle) );
			}
		}

		/**
		 * Stops drag and stops lines from being drawn
		 */
		private function onVirusUp(e:MouseEvent):void
		{
			virus.buttonMode=false;
			virusMoved.remove(onVirusMoved);
			stageUp.removeAll();
			stageUp = null;
			virusUp = null;

			var distanceX:Number = virus.x - vStartX;
			var distanceY:Number = virus.y - vStartY;
			var r:Number = Math.sqrt( distanceX * distanceX + distanceY * distanceY );
			//trace( "r=" + r);
			var radians:Number = Math.atan2( distanceY, distanceX );
			dx = -(r * Math.cos( radians ) ) / speedReductionConstant;
			dy = -(r * Math.sin( radians ) ) / speedReductionConstant;

			this.enterFrame = new NativeSignal(this.stage, Event.ENTER_FRAME, Event);
			this.enterFrame.add( updateVirusPosition );
		}

		private function updateVirusPosition(e:Event):void
		{
			if(!checkCollisions())
			{
				dy += gravity;
				virus.x += dx;
				virus.y += dy;
			} else {

				if(collisionNode)
				{
					//trace("collision with node: " + nodeID + ", of port: " + portID);
					var clonedVirus:Sprite = cloneVirus();
					Dictionary(virusInfections[tempPortID])[tempNodeID]=clonedVirus;
					clonedVirusAdded=new NativeSignal(clonedVirus,Event.ADDED_TO_STAGE,Event);
					clonedVirusAdded.addOnce(function(e:Event):void {
						var virusTarget:Sprite=Sprite(e.target);
						var port:NetworkPort = NetworkPort(ports[tempPortID]);
						var segment:NodeSegment = NodeSegment(port.segments[tempNodeID]);
						var point:Point = new Point(
							Sprite(portClips[tempPortID]).x + nodeHitSp.x + segment.segmentGraphic.x,
							Sprite(portClips[tempPortID]).y + nodeHitSp.y + segment.segmentGraphic.y
						);
						TweenLite.to( virusTarget,.25,{x:point.x,y:point.y,onComplete:function():void {
							container.addChildAt(virusTarget,virusIndex);
							onClonedVirusSnapped(new Event("clonedVirusSnapped"));
						}} );
					});
					container.addChild(clonedVirus);
					removeVirus();
				} else {
					//trace("collision with wall");
					removeVirus();
					showVirusDestroyed();
				}
			}
		}

		private function checkCollisions():Boolean
		{
			var collision:Boolean=false;

			//check stage edges
			if( (virus.y - virusOffset) <= stageEdgeN )
				collision=true;
			else if( (virus.x + virusOffset) >= stageEdgeE )
				collision=true;
			else if( (virus.y + virusOffset) >= stageEdgeS )
				collision=true;
			else if( (virus.x - virusOffset) <= stageEdgeW )
				collision=true;

			if(!collision)
			{
				var nodeHitSprite:Sprite;
				for ( var pK:String in ports)
				{
					var port:NetworkPort = NetworkPort(ports[pK]);
					var segments:Dictionary = port.segments;
					for ( var aK:String in segments)
					{
						nodeHitSprite=Sprite(NodeSegment(segments[aK]).nodeHit);
						if(!port.nodeIsInfected(nodeHitSprite))
						{
							if(virus.hitTestObject(nodeHitSprite))
							{
								collision=true;
								tempNodeID=aK;
								tempPortID=portIDs[port];
								nodeHitSp = nodeHitSprite;
							}
						}
					}
				}
				if(collision)
					collisionNode=true;
			}

			return collision;
		}

		private function removeVirus():void
		{
			this.enterFrame.remove(updateVirusPosition);
			this.container.removeChild(virus);
		}

		private function showVirusDestroyed():void
		{
			container.addChild(virusDestroyed=new VirusDestroyed() as MovieClip);
			virusDestroyed.scaleX=virusDestroyed.scaleY=virusScale;
			virusDestroyed.x=virus.x;
			virusDestroyed.y=virus.y;
			virusDestroyedEndFrame=virusDestroyed.totalFrames;
			virusDestroyed.addFrameScript(virusDestroyedEndFrame-1, function():void {
				virusDestroyed.stop();
				virusDestroyed.dispatchEvent(new Event("VirusDestroyed"));
			});
			onVirusDestroyedComplete=new NativeSignal(virusDestroyed, "VirusDestroyed", Event);
			onVirusDestroyedComplete.addOnce(onVirusDestroyed);
		}

		private function onVirusDestroyed(e:Event):void
		{
			if(virusDestroyed!=null)
			{
				container.removeChild(virusDestroyed);
				onVirusDestroyedComplete=null;
				virusDestroyed=null;
			}
			GameInstance.lives--;
			pointsNodesCleaned++;
			updateVirusIcons();
			virus=null;
			checkFlingsLeft();
		}

		private function cloneVirus():Sprite
		{
			var newVirus:Sprite = new Virus() as Sprite;
			newVirus.x=virus.x;
			newVirus.y=virus.y;
			newVirus.scaleX=newVirus.scaleY=virusScale;
			return newVirus;
		}

		private function onClonedVirusSnapped(e:Event):void
		{
			var port:NetworkPort = NetworkPort(ports[tempPortID]);
			if( !port.isActivated )
				return;
			var segment:NodeSegment = NodeSegment(port.segments[tempNodeID]);
			var children:Dictionary = segment.children;
			port.infectNode(tempNodeID);
			var clonedVirus:Sprite;
			var childSegment:NodeSegment;
			if(segment.isHub)
			{
				for(var k:String in children)
				{
					if ( port.infectedNodes[k] == null )
					{
						clonedVirus = cloneVirus();
						Dictionary(virusInfections[tempPortID])[k]=clonedVirus;
						childSegment = NodeSegment(port.segments[k]);
						var point:Point = new Point(
							Sprite(portClips[tempPortID]).x + childSegment.nodeHit.x + childSegment.segmentGraphic.x,
							Sprite(portClips[tempPortID]).y + childSegment.nodeHit.y + childSegment.segmentGraphic.y
						);
						clonedVirus.x = point.x;
						clonedVirus.y = point.y;
						clonedVirus.alpha = 0;
						container.addChild(clonedVirus);
						TweenLite.to( clonedVirus,.25,{alpha:1});
						port.infectNode(k);
					}
				}
				NetworkSounds.playSound(NetworkSounds.HUB_HIT, 1);
			} else
			{
				NetworkSounds.playSound(NetworkSounds.NODE_HIT, 1);
			}

			collisionNode=false;
			tempNodeID="";
			tempPortID=0;
			nodeHitSp=null;
			virus=null;

			if( !port.isActivated )
				return;
			if(port.numInfectedNodes == port.numNodes)
			{
				//trace("all nodes infected");
				GameInstance.lives++;
				GameInstance.lives++;
				pointsPortsInfected++;
				updateVirusIcons();
				removePortVirusAwards(port);
				numInfectedPorts++;
				port.completelyInfectPort();
			} else {
				GameInstance.lives--;
				updateVirusIcons();
				checkFlingsLeft();
			}
		}

		private function checkFlingsLeft():void
		{
			if(GameInstance.lives<0)
			{
				if(numActiveViruses<=0)
					playerOutOfLives();
				else
					playerOutOfFlings=true;
			} else
			{
				if(playerOutOfFlings)
					playerOutOfFlings=false;
				createVirus();
			}
		}

		private function playerOutOfLives():void
		{
			addChild(tweenHolder=new Sprite());
			tweenHolder.addChild(container);
			stopGame();
			TweenUtils.bitmapTelevisionTubeTween( container, tweenHolder, 1, 0, .5, 1, onTelevisionTweenFinished );
		}

		private function levelComplete():void
		{
			//play victory music
			nextLevel();
		}

		private function nextLevel():void
		{
			GameInstance.lives=3;
			addChild(tweenHolder=new Sprite());
			tweenHolder.addChild(container);
			stopGame();
			goToNextLevel=true;
			TweenUtils.bitmapTelevisionTubeTween( container, tweenHolder, 1, 0, .5, 1, onTelevisionTweenFinished );
		}

		private function onTelevisionTweenFinished():void
		{
			this.destroy();

			/* Calculate Points */
			/*
			Gain Life = +100
			Node Cleaned = -200
			Under a minute = + 1000
			Completely Infect Port = +400
			Each minute after 1 = -500
			*/
			var points:int = 1000;
			if(pointsTimerMinutes == 0)
				points += 1000;
			else
				points -= (500 * pointsTimerMinutes);
			points += (100 * pointsLivesGained);
			points -= (200 * pointsNodesCleaned);
			points += (400 * pointsPortsInfected);
			GameInstance.points += points;

			if(goToNextLevel)
				beatLevel.dispatch();
			else
				gameOver.dispatch();
		}

		/* Menu */

		private function updateVirusIcons():void
		{
			if(livesHolder==null)
				livesHolder=new Sprite();
			if(!this.container.contains(livesHolder))
			{
				this.container.addChild(livesHolder);
				livesHolder.y=this.stage.height-22.5;
				livesHolder.x=135.5;
			}
			//cap lives
			if(GameInstance.lives > 3)
				GameInstance.lives=3;
			if(GameInstance.lives!=livesHolder.numChildren && GameInstance.lives>=0)
			{
				while(GameInstance.lives<livesHolder.numChildren && livesHolder.numChildren>0)
				{
					livesHolder.removeChildAt(livesHolder.numChildren-1);
				}
				var virusIcon:Sprite;
				while(GameInstance.lives>livesHolder.numChildren)
				{
					livesHolder.addChild(virusIcon=new Virus_Icon() as Sprite);
					virusIcon.scaleX=virusIcon.scaleY=.225;
					virusIcon.x = (virusIcon.width + 26.2) * (livesHolder.numChildren - 1);
				}
			}
		}

		private function onVolumeMutePress(e:MouseEvent):void
		{
			if(MovieClip(volumeMuteButton).currentFrame==1) {
				MovieClip(volumeMuteButton).gotoAndStop(2);
				NetworkSounds.muteAllSounds();
			} else {
				MovieClip(volumeMuteButton).gotoAndStop(1);
				NetworkSounds.unmuteAllSounds();
			}
		}

		private function onMenuButtonClicked(e:MouseEvent):void
		{
			quitToMainConfirm.visible=true;
			quitConfirmYes.addOnce( function(e:MouseEvent):void { backToMain(); } );
			quitConfirmNo.addOnce( function(e:MouseEvent):void {
				closeMenu();
				menuClick.addOnce(onMenuButtonClicked);
			} );
		}

		private function backToMain():void
		{
			closeMenu();
			addChild(tweenHolder=new Sprite());
			tweenHolder.addChild(container);
			stopGame();
			TweenUtils.bitmapTelevisionTubeTween( container, tweenHolder, 1, 0, .5, .2, onTelevisionTweenFinishedMenu );
		}

		private function closeMenu():void
		{
			quitConfirmYes.removeAll();
			quitConfirmNo.removeAll();
			quitToMainConfirm.visible=false;
		}

		private function onTelevisionTweenFinishedMenu():void
		{
			destroy();
			quitToMenu.dispatch();
		}

		private function stopGame():void
		{
			NetworkSounds.fadeSound(NetworkSounds.MAIN_THEME, 0, .8);

			//virus awards
			TweenLite.killTweensOf(virusAwardsWindow);
			TweenLite.killTweensOf(gainedVirus);
			virusAwardsEnterFrame.remove(onVirusAwardsEnterFrame);
			popupDelayed.removeAll();
			popupDelay.stop();

			//points
			pointsTimerInterval.remove(onPointsTimerInterval);
			pointsTimer.stop();

			//menu & ui
			virusDown.removeAll();
			quitConfirmYes.removeAll();
			quitConfirmNo.removeAll();
			menuClick.removeAll();
			volumeMuteClicked.removeAll();

			for ( var pK:String in ports)
			{
				var port:NetworkPort = NetworkPort(ports[pK]);
				port.deactivate();
			}
		}

		private function destroy():void
		{
			virusDown=virusUp=stageUp=virusMoved=menuClick=quitConfirmYes=quitConfirmNo=pointsTimerInterval=null;
			pointsTimer = null;
			DisplayObjectUtil.removeAllChildren(tweenHolder,false,true);
			this.removeChild(tweenHolder);
			container=flinger=tweenHolder=livesHolder=menuHit=gainedVirus=virusAwardsWindow=null;
			quitToMainConfirm=null;
			volumeMuteButton=null;
			bg=null;
			for (var k:String in ports)
				NetworkPort(ports[k]).destroy();
			DictionaryUtils.emptyDictionary(portIDs);
			DictionaryUtils.emptyDictionary(portClips);
			DictionaryUtils.emptyDictionary(infectedNodeIDs,false,true);
			DictionaryUtils.emptyDictionary(virusInfections,false,true);
			DictionaryUtils.emptyDictionary(ports,true,false);
			switch(GameInstance.level)
			{
				case 1:
					port0_l1=null;
					break;
				case 2:
					port0_l2=port1_l2=null;
					break;
				case 3:
					port0_l3=port1_l3=port2_l3=null;
					break;
			}
		}
	}
}