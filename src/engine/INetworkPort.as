package engine
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public interface INetworkPort
	{
		function get nodeInfected():Signal; // Signal(NetworkPort, uint - the port ID );
		function get nodeCleaned():Signal; // Signal(NetworkPort, uint - the port ID );
		function get hubInfected():Signal; // Signal(NetworkPort, uint - the port ID, Array - finger IDs);
		function get portCompletelyInfected():Signal;
		function get portDeactivated():Signal;
		function get nodes():Dictionary; // return collision shapes
		function get infectedNodes():Dictionary;
		function get numInfectedNodes():uint;
		function nodeIsInfected(node_hit_sp:Sprite):Boolean;
		function infectNode(nodeArmIndex:uint):void; //updates arm_mc and alerts network admin
		function addHand(points:Array, hand_mc:MovieClip, node_hit_sp:Sprite):void; //array of point, arm_mc, node_hit_mc
		function addFinger(points:Array, finger_mc:MovieClip, hand_mc:MovieClip, node_hit_sp:Sprite):void;
		function completelyInfectPort():void; //updates port_mc, kills admin
		function activate():void; //initializes admin
		function deactivate():void;
		function destroy():void; //cleans up
	}
}