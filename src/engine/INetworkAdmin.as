package engine
{

	import org.osflash.signals.Signal;

	public interface INetworkAdmin
	{
		function get route():Array;
		function set route(value:Array):void;
		function get currentArmIndex():uint;
		function set currentArmIndex(value:uint):void;
		function get currentSegmentIndex():String;
		function set currentSegmentIndex():String;
		function get fromPointIndex():uint;
		function set fromPointIndex(value:uint):void;
		function get destPointIndex():uint;
		function set destPointIndex(value:uint):void;
		function get between():Boolean;
		function set between(value:Boolean):void;
		function get alerted():Boolean;
		function set alerted(value:Boolean):void;
		function get alertFinished():Signal;
		function get deathFinished():Signal;
		function get healing():Boolean;
		function set healing(value:Boolean):void;
		function get portHealed():Signal;
		function get status():String;
		function setState(stateKey:String);
		function beginHealing(); //activates timer that will issue portHealed
		function stopHealing(); //stops timer
		function destroy();
	}
}