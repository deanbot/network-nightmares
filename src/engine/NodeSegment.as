package engine
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import net.deanverleger.utils.DictionaryUtils;

	/* A hand or a finger */

	public class NodeSegment {

		private var _ID:String;
		private var _children:Dictionary;
		private var _childrenNum:uint;
		private var _parentID:String;
		private var _points:Array;
		private var _segmentGraphic:MovieClip;
		private var _nodeHit:Sprite;
		private var _segmentType:String;

		public function NodeSegment() {
			// constructor code
			_children = new Dictionary(true);
		}

		public function get childrenNum():uint
		{
			return _childrenNum;
		}

		public function get nodeHit():Sprite
		{
			return _nodeHit;
		}

		public function get segmentGraphic():MovieClip
		{
			return _segmentGraphic;
		}

		public function get parentID():String
		{
			return _parentID;
		}

		public function set parentID(ID:String):void
		{
			_parentID = ID;
		}

		public function get children():Dictionary
		{
			return _children;
		}

		public function get segmentType():String
		{
			return _segmentType;
		}

		public function get ID():String
		{
			return _ID;
		}

		public function get points():Array
		{
			return _points;
		}

		public function get isHub():Boolean
		{
			return ( _childrenNum > 0 );
		}

		public function setData(ID:String, points:Array, graphic:MovieClip, hit:Sprite, type:String):void
		{
			_ID = ID;
			_points = points;
			_segmentGraphic = graphic;
			_nodeHit = hit;
			_segmentType = type;
		}

		public function getPoint(pointIndex:uint):Point
		{
			return Point(_points[pointIndex]);
		}

		public function addSegmentChild( ID:String ):void
		{
			_children[ID] = ID;
			_childrenNum++;
		}

		public function hasChild(ID:String):Boolean
		{
			return ( _children[ID] != null );
		}

		public function destroy():void
		{
			DictionaryUtils.emptyDictionary(_children);
			_segmentGraphic = null;
			_nodeHit = null;
		}
	}
}