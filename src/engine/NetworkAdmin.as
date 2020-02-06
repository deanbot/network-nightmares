package engine
{
	import com.meekgeek.statemachines.finite.manager.StateManager;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.casalib.util.DisplayObjectUtil;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	/**
	 * Network Admin is extention of Network Port. Port controlls admin. Admin acts and issues signals once finished. 
	 * @author Dean
	 * 
	 */
	public class NetworkAdmin extends Sprite
	{
		private var _activated:Boolean;
		private var _route:Array;
		private var _currentArmIndex:int;
		private var _currentFingerIndex:int;
		private var _currentSegmentID:String;
		private var _rememberFingerIndex:int;
		private var _fromPointIndex:uint;
		private var _destPointIndex:uint;
		private var _goingToStart:Boolean;
		private var _between:Boolean;
		private var _healingSegmentID:String;
		private var _alerted:Boolean;
		private var _healing:Boolean;
		private var _portHealed:Signal;
		private var _alertFinished:Signal;
		private var _sm:StateManager;
		private var _deathFinished:Signal;
		
		private var _healingTimer:Timer;
		private var _healingTimerComplete:NativeSignal;
		private var _bg:Sprite;
		public function NetworkAdmin()
		{
			super();
			this.addChild(_bg=new NetworkAdminSp() as Sprite);
			_bg.cacheAsBitmap=true;
			_route=new Array();
			_fromPointIndex=_currentArmIndex=_destPointIndex=0;
			_healing=_alerted=_between=_goingToStart=false;
			_portHealed=new Signal();
			_alertFinished=new Signal();
			_deathFinished=new Signal();
			_healingTimer=new Timer(GameInstance.adminHealingTime);
			_healingTimerComplete=new NativeSignal(_healingTimer,TimerEvent.TIMER,TimerEvent);
			_sm=new StateManager(this);
			_sm.addState(NetworkAdminState.WANDER,new AdminWander(),true);
			_sm.addState(NetworkAdminState.ALERT,new AdminAlert());
			_sm.addState(NetworkAdminState.HEALING,new AdminHealing());
			_sm.addState(NetworkAdminState.DEAD,new AdminDead());
			_currentArmIndex = _currentFingerIndex = _rememberFingerIndex = -1;
			_healingSegmentID = "";
			_activated = false;
		}
		
		public function get healingSegmentID():String
		{
			return _healingSegmentID;
		}

		public function set healingSegmentID(value:String):void
		{
			_healingSegmentID = value;
		}

		public function get goingToStart():Boolean
		{
			return _goingToStart;
		}

		public function set goingToStart(value:Boolean):void
		{
			_goingToStart = value;
		}

		public function get rememberFingerIndex():int
		{
			return _rememberFingerIndex;
		}

		public function set rememberFingerIndex(value:int):void
		{
			_rememberFingerIndex = value;
		}

		public function get currentFingerIndex():int
		{
			return _currentFingerIndex;
		}
		
		public function set currentFingerIndex(value:int):void
		{
			_currentFingerIndex = value;
		}

		public function get deathFinished():Signal
		{
			return _deathFinished;
		}

		public function get route():Array
		{
			return _route;
		}
		
		public function set route(value:Array):void
		{
			_route=value;
		}
		
		public function get currentArmIndex():int
		{
			return _currentArmIndex;
		}
		
		public function set currentArmIndex(value:int):void
		{
			_currentArmIndex = value;
		}
		
		public function get currentSegmentID():String
		{
			return _currentSegmentID;
		}
		
		public function set currentSegmentID(ID:String):void
		{
			_currentSegmentID = ID;
		}
		
		public function get fromPointIndex():uint
		{
			return _fromPointIndex;
		}
		
		public function set fromPointIndex(value:uint):void
		{
			_fromPointIndex = value;
		}
				
		public function get destPointIndex():uint
		{
			return _destPointIndex;
		}
		
		public function set destPointIndex(value:uint):void
		{
			_destPointIndex = value;
		}
		
		public function get between():Boolean
		{
			return _between;
		}
		
		public function set between(value:Boolean):void
		{
			_between=value;
		}
		
		public function get alerted():Boolean
		{
			return _alerted;
		}
		
		public function set alerted(value:Boolean):void
		{
			_alerted = value;
		}
		
		public function get alertFinished():Signal
		{
			return _alertFinished;
		}
		
		public function get healing():Boolean
		{
			return _healing;
		}
		
		public function set healing(value:Boolean):void
		{
			_healing = value;
		}
		
		public function get portHealed():Signal
		{
			return _portHealed;
		}
		
		public function get status():String
		{
			return _sm.currentKey;
		}
		
		public function set activated(value:Boolean):void
		{
			_activated = value;
		}
		
		public function get activated():Boolean
		{
			return _activated;
		}
		
		public function setState(stateKey:String)
		{
			_sm.setState(stateKey);
		}
		
		public function beginHealing()
		{
			if(!_activated)
				return;
			_healing=true;
			_healingTimerComplete.addOnce(onHealingTimerComplete);
			_healingTimer.start();
		}
		
		public function stopHealing()
		{
			if(!_activated)
				return;
			if(!_healing)
				return;
			_healing=false;
			if(_healingTimer.running)
				_healingTimer.stop();
		}
		
		public function destroy()
		{
			DisplayObjectUtil.removeAllChildren(this,false,true);
			_bg=null;
			stopHealing();
			_healingTimerComplete.removeAll();
			_healingTimerComplete=null;
			_healingTimer=null;
			_portHealed.removeAll();
			_portHealed=null;
			_activated = false;
		}
		
		private function onHealingTimerComplete(e:TimerEvent):void
		{
			stopHealing();
			_portHealed.dispatch();
		}
	}
}
import com.greensock.TweenLite;
import com.meekgeek.statemachines.finite.states.State;

import engine.NetworkAdmin;
import engine.NetworkSounds;

import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.osflash.signals.natives.NativeSignal;

class AdminWander extends State {
	private var graphic:Sprite;
	public function AdminWander():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		//NetworkSounds.playSound(NetworkSounds.
		NetworkAdmin(this.context).addChild(graphic=new AdminWanderSp() as Sprite);
		graphic.cacheAsBitmap=true;
		NetworkAdmin(this.context).alerted=false;
		this.signalIntroComplete();
	}
	
	override public function action():void
	{
		
	}
	
	override public function doOutro():void
	{
		NetworkAdmin(this.context).removeChild(graphic);
		graphic=null;
		this.signalOutroComplete();
	}
}

class AdminAlert extends State {
	private static const ALERT_TIME:uint=1000;
	private var graphic:Sprite;
	private var alertTimer:Timer;
	private var alertTimerComplete:NativeSignal;
	public function AdminAlert():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		NetworkAdmin(this.context).addChild(graphic=new AdminAlertSp() as Sprite);
		graphic.cacheAsBitmap=true;
		if(!NetworkAdmin(context).alerted)
		{
			NetworkSounds.playSound(NetworkSounds.ADMIN_ALERT,1);
			alertTimer=new Timer(ALERT_TIME);
			alertTimerComplete=new NativeSignal(alertTimer,TimerEvent.TIMER,TimerEvent);
			alertTimerComplete.addOnce(function(e:TimerEvent):void { 
				NetworkAdmin(context).alerted=true;
				NetworkAdmin(context).alertFinished.dispatch();
				signalIntroComplete(); 
			});
			alertTimer.start();
		} else {
			signalIntroComplete();
			NetworkAdmin(context).alertFinished.dispatch();
		}
	}
	
	override public function action():void
	{
		
	}
	
	override public function doOutro():void
	{
		NetworkAdmin(this.context).removeChild(graphic);
		if(alertTimer!=null) 
		{
			alertTimer.stop();
			alertTimerComplete.removeAll();
			alertTimerComplete=null;
			alertTimer=null;
		}
		graphic=null;
		this.signalOutroComplete();
	}
}

class AdminHealing extends State {
	private var graphic:Sprite;
	public function AdminHealing():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		NetworkAdmin(this.context).addChild(graphic=new AdminHealingSp() as Sprite);
		graphic.cacheAsBitmap=true;
		NetworkAdmin(this.context).beginHealing();
		this.signalIntroComplete();
	}
	
	override public function action():void
	{
		
	}
	
	override public function doOutro():void
	{
		if(NetworkAdmin(this.context).contains(graphic))
			NetworkAdmin(this.context).removeChild(graphic);
		graphic=null;
		this.signalOutroComplete();
	}
}

class AdminDead extends State {
	private static const BLINK_IN_TIME:uint=300;
	private static const BLINK_OUT_TIME:uint=150;
	private static const FADE_DURATION:Number=.5
	private var blinkCounter:uint=0;
	private var graphic:Sprite;
	private var blinkOutTimer:Timer;
	private var blinkInTimer:Timer;
	private var blinkInTimerLoop:NativeSignal;
	private var blinkOutTimerLoop:NativeSignal;
	
	public function AdminDead():void
	{
		super();
	}
	
	override public function doIntro():void
	{
		NetworkAdmin(this.context).addChild(graphic=new AdminDeadSp() as Sprite);
		blinkOutTimer=new Timer(BLINK_OUT_TIME);
		blinkOutTimerLoop=new NativeSignal(blinkOutTimer,TimerEvent.TIMER,TimerEvent);
		blinkOutTimerLoop.add(blinkIn);
		blinkInTimer=new Timer(BLINK_IN_TIME);
		blinkInTimerLoop=new NativeSignal(blinkInTimer,TimerEvent.TIMER,TimerEvent);
		blinkInTimerLoop.add(blinkOut);
		blinkInTimer.start();
	}
	
	private function blinkOut(e:TimerEvent):void
	{
		blinkInTimer.stop();
		graphic.visible=false;
		blinkOutTimer.start();
	}
	
	private function blinkIn(e:TimerEvent):void
	{
		blinkCounter++;
		blinkOutTimer.stop();
		graphic.visible=true;
		if(blinkCounter<3)
			blinkInTimer.start();
		else
			fadeOut();
	}
	
	private function fadeOut():void
	{
		TweenLite.to(NetworkAdmin(context),FADE_DURATION,{scaleX:0, scaleY:0, onComplete:onFadeOut});
	}
	
	private function onFadeOut():void
	{
		this.signalIntroComplete();
		NetworkAdmin(context).deathFinished.dispatch();
	}
	
	override public function action():void
	{
		
	}
	
	override public function doOutro():void
	{
		NetworkAdmin(this.context).removeChild(graphic);
		graphic=null;
		this.signalOutroComplete();
	}
}