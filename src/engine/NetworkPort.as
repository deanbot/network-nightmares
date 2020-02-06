package engine
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import net.deanverleger.utils.IDestroyable;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	public class NetworkPort implements IDestroyable
	{
	// constants:
	// private properties:
		private var _container:Sprite;
		private var _port_mc:MovieClip;
		private var _admin:NetworkAdmin;
		
		private var _segments:Dictionary;
		private var _segmentHitIndex:Dictionary;
		private var _segmentHandMCIndex:Dictionary;
		private var _hands:Array;
		private var _fingers:Array;

		private var _infectedNodes:Dictionary;
		private var _infectedArms:Array;
		private var _numInfectedNodes:uint;
		
		private var _portInfectTimer:Timer;
		private var _adminRemoved:NativeSignal;
		private var _portInfectDelay:NativeSignal;
		
		private var _nodeInfected:Signal;
		private var _nodeCleaned:Signal;
		private var _portCompletelyInfected:Signal;
		private var _portDeactivated:Signal;
		private var _portDestroyed:Signal;
		
	// public properties:
	// constructor:
		public function NetworkPort(container:Sprite, port_mc:MovieClip)
		{
			_container=container;
			_port_mc=port_mc;
			_admin=new NetworkAdmin();
			_segments = new Dictionary(true);
			_segmentHitIndex = new Dictionary(true);
			_segmentHandMCIndex = new Dictionary(true);
			_hands = new Array();
			_fingers = new Array();
			_infectedArms = new Array();
			_infectedNodes = new Dictionary(true);
			_nodeInfected = new Signal(NetworkPort, String);
			_nodeCleaned = new Signal(NetworkPort, String);
			_portCompletelyInfected = new Signal();
			_portDestroyed=new Signal();
		}
		
	// public getter/setters:

		public function get segments():Dictionary
		{
			return _segments;
		}

		public function get nodeInfected():Signal
		{
			return _nodeInfected;
		}
		
		public function get nodeCleaned():Signal
		{
			return _nodeCleaned;
		}
		
		public function get portCompletelyInfected():Signal
		{
			return _portCompletelyInfected;
		}
		
		public function get portDeactivated():Signal
		{
			return _portDeactivated;
		}
		
		public function get portDestroyed():Signal
		{
			return _portDestroyed;
		}
		
		public function get infectedNodes():Dictionary
		{
			return _infectedNodes;
		}
		
		public function get numNodes():uint
		{
			return _hands.length + _fingers.length;
		}
		
		public function get numInfectedNodes():uint
		{
			return _numInfectedNodes;
		}
		
	// public methods:
		public function addHand(points:Array, hand_mc:MovieClip):void
		{
			var handIndex:uint = _hands.length;
			var key:String = "h" + handIndex;
			var segment:NodeSegment = new NodeSegment();
			var node_hit_sp:Sprite = hand_mc["hit"] as Sprite;
			segment.setData(key, points, hand_mc, node_hit_sp, NodeSegmentType.HAND);
			_segments[key] = segment; 
			_segmentHitIndex[node_hit_sp] = key;
			_segmentHandMCIndex[hand_mc] = key;
			_hands.push(key);
			node_hit_sp.visible=false;
		}
		
		public function addFinger(points:Array, finger_mc:MovieClip, hand_mc:MovieClip):void
		{
			var handKey:String = _segmentHandMCIndex[hand_mc];
			var handSegment:NodeSegment = _segments[handKey];
			var fingerIndex:uint = handSegment.childrenNum;
			var key:String = handKey + "_f" + fingerIndex;
			var segment:NodeSegment = new NodeSegment();
			var node_hit_sp:Sprite = finger_mc["hit"] as Sprite;
			segment.setData(key, points, finger_mc, node_hit_sp, NodeSegmentType.FINGER);
			segment.parentID = handKey;
			_segments[key] = segment;
			_segmentHitIndex[node_hit_sp] = key;
			_fingers.push(key);
			handSegment.addSegmentChild(key);
			node_hit_sp.visible=false;
		}
		
		public function activate():void
		{
			if(_hands.length==0)
			{
				//trace("No arms are set. Can't activate port.");
				return;
			}
			_container.addChild(_admin);
			_admin.activated = true;
			setAtSegment("h0",true);
			_admin.currentArmIndex = 0;
			pickRoute();
			moveTo(nextPoint());
		}
		
		public function infectNode(segmentID:String):void
		{
			if(_segments[segmentID] == null)
			{
				trace("Segment " + segmentID + " not set")
				return;
			}
			if(_infectedNodes[segmentID]!=null)
			{
				trace("Segment " + segmentID + " already infected");
				return;
			}
			var segment_mc:MovieClip=MovieClip(NodeSegment(_segments[segmentID]).segmentGraphic);
			if(segment_mc!=null)
			{
				segment_mc.gotoAndStop(2);
				if(_admin.status!=NetworkAdminState.ALERT)
				{
					//trace("admin do alert please");
					TweenLite.killTweensOf(_admin);
					_admin.route=new Array();
					_admin.alertFinished.addOnce(adminUpdate);
					_admin.setState(NetworkAdminState.ALERT);
					_admin.goingToStart = false;
				}
				_infectedNodes[segmentID]=segmentID;
				var i:int = armIndex(segmentID);
				if(_infectedArms.indexOf( i ) == -1)
					_infectedArms.push( i );
				_numInfectedNodes++;
				_nodeInfected.dispatch(this, segmentID);
			}
		}
		
		public function nodeIsInfected(node_hit_sp:Sprite):Boolean
		{
			return (_infectedNodes[ _segmentHitIndex[node_hit_sp] ] != null);
		}
		
		public function get isActivated():Boolean
		{
			return (_admin == null) ? false : _admin.activated;
		}
		
		public function completelyInfectPort():void
		{
			if(_numInfectedNodes!=numNodes)
			{
				for( var k:String in _segments)
					if(infectedNodes[k] == null)
						infectNode(k);
			}
			_port_mc.gotoAndStop(2);
			deactivate();
			_admin.deathFinished.addOnce(onAdminDeath);
			_admin.setState(NetworkAdminState.DEAD);
		}
		
		public function deactivate():void
		{
			if(_admin==null)
				return;
			if(_admin.healing)
				_admin.stopHealing();
			_admin.activated = false;
			TweenLite.killTweensOf(_admin);
		}
		
		public function destroy():void
		{
			if(_portDestroyed==null)
				return;
			deactivate();
			_port_mc=null;
			_hands=_fingers=_infectedArms=null;
			for (var k:String in segments)
				NodeSegment(segments[k]).destroy();
			clearDictionary(_segments);
			clearDictionary(_segmentHitIndex);
			clearDictionary(_infectedNodes);
			_segments = _segmentHitIndex = _infectedNodes = null;
			if(_nodeInfected != null)
				_nodeInfected.removeAll();
			if(_portCompletelyInfected != null)
				_portCompletelyInfected.removeAll();
			if(_nodeCleaned != null)
				_nodeCleaned.removeAll();
			_nodeInfected = _portCompletelyInfected = null;
			if(_admin!=null)
			{
				if(_container.contains(_admin)) 
				{
					_adminRemoved=new NativeSignal(_admin, Event.ADDED_TO_STAGE, Event);
					_adminRemoved.addOnce(function(e:Event):void { 
						_adminRemoved=null;
						_admin.destroy(); 
						_admin=null;
						
					});
					_container.removeChild(_admin);
				} else {
					_admin.destroy();
				}
				_admin=null;
			}
			_portDestroyed.dispatch();
			_portDestroyed.removeAll();
			_portDestroyed=null;
		}
		
	// private methods:
		/**
		 * The admin update loop handles the creation of new routes, beginning of node healing, and movement
		 * 
		 */
		private function adminUpdate():void
		{
			var status:String = _admin.status;
			if(status==NetworkAdminState.HEALING)
				return;
			else if(status==NetworkAdminState.DEAD)
				return;	
			trace("admin update");	
			
			if(_admin.route.length==0)
			{				
				// set new route
				if(status==NetworkAdminState.ALERT)
				{
					if(!_admin.between)
					{
						if( _admin.currentArmIndex == getInfectedArm() )
						{
							var healingSegmentID:String = "";
							if( _infectedNodes[_admin.currentSegmentID] != null )
							{
								// current node is infected
								if( atEndOfSegment)
									healingSegmentID = _admin.currentSegmentID;
								else if (_admin.fromPointIndex == 0)
									if( _admin.currentFingerIndex != -1)
										if( _infectedNodes["h"+_admin.currentArmIndex] != null )
											healingSegmentID = "h"+_admin.currentArmIndex;
								
							} else
							{
								// current node is not infected
								if (_admin.fromPointIndex == 0)
									if( _admin.currentFingerIndex != -1)
										if( _infectedNodes["h"+_admin.currentArmIndex] != null )
											healingSegmentID = "h"+_admin.currentArmIndex;
							}
							
							if(healingSegmentID != "")
							{
								trace( "healing segment ID: " + healingSegmentID );
								if(_admin.currentFingerIndex != -1)
									_admin.rememberFingerIndex = _admin.currentFingerIndex;
								_admin.healingSegmentID = healingSegmentID;
								_admin.portHealed.addOnce(onHealingFinished);
								_admin.setState(NetworkAdminState.HEALING);
							}
						}
					}
				}
				pickRoute();
			}
			
			if(_admin.route.length!=0) // movement
				moveTo(nextPoint());
			else
				adminUpdate();
			
		}
		
		/**
		 * based on State of Admin create route
		 * >May go to arm beginning if at arm end (if alert)
		 * >If Wander give forwards-and-back-routes if at arm beginning or back routes if at route end (can only change to wander after healing, at end of arm)
		 */
		private function pickRoute():void
		{
			if(_admin == null)
				return;
			var status:String = _admin.status;
			if(status==NetworkAdminState.HEALING)
				return;
			else if(status==NetworkAdminState.DEAD)
				return;
			trace("pickRoute");
			
			var route:Array = new Array();
			var forwards:Array;
			var backwards:Array;
			var index:uint;
			var nodeSegment:NodeSegment;
			if(status==NetworkAdminState.WANDER)
			{
				if( !_admin.between )
				{
					//admin is at a point either after healing a node or after reaching an end point or beginning a segment
					if(_admin.fromPointIndex==0)
					{
						if(_admin.currentFingerIndex == -1)
						{
							// on arm
							if(_admin.goingToStart)
							{
								_admin.goingToStart = false;
								if(_hands.length - 1 > _admin.currentArmIndex)
									_admin.currentArmIndex++;
								else 
									_admin.currentArmIndex = 0;
								setAtSegment("h" + _admin.currentArmIndex ,true,true);
							} else {
								// forward route to end of arm
								forwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex]).points.concat() );
								forwards.shift();
								route=forwards;
							}
						}
						else
						{
							// on finger
							// if no 'rememberFingerIndex' set finger index to current finger index and forward route to end of finger
							if (_admin.rememberFingerIndex == -1)
							{
								_admin.rememberFingerIndex = _admin.currentFingerIndex;
								forwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex + "_f" + _admin.currentFingerIndex]).points.concat() );
								forwards.shift();
								route=forwards;
							}
							else if ( _admin.rememberFingerIndex == _admin.currentFingerIndex)
							{
								// else if 'rememeberFignerIndex' == current Finger Index..
								nodeSegment = NodeSegment(_segments["h" + _admin.currentArmIndex]);
								if( nodeSegment.childrenNum - 1 > _admin.currentFingerIndex )
								{
									// if next finger go to next finger
									_admin.currentFingerIndex++
									setAtSegment("h" + _admin.currentArmIndex + "_f" + _admin.currentFingerIndex); 
								}
								else
								{
									_admin.goingToStart = true;
									// go to end of arm
									setAtSegment("h" + _admin.currentArmIndex, false); 
								}
							}
							else
							{
								trace("_admin.rememberFingerIndex not set correctly: " + _admin.rememberFingerIndex);
							}
						}
					} 
					else if(atEndOfSegment)
					{ 
						if(_admin.currentFingerIndex == -1)
						{
							// on arm
							nodeSegment = NodeSegment(_segments["h" + _admin.currentArmIndex]);
							// if 'goingToStart' or no fingers set back route to start of arm
							if ( !nodeSegment.isHub )
								_admin.goingToStart = true;
							if(_admin.goingToStart )
							{
								backwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex]).points.concat() );
								backwards.reverse();
								backwards.shift();
								route=backwards;
							} // else if fingers go to first finger
							else if (nodeSegment.isHub)
							{
								// go to beginning of finger
								setAtSegment("h" + _admin.currentArmIndex + "_f0"); 
							} else 
							{
								_admin.goingToStart = true;
								trace("_admin doesn't know what to do so he's going back");
								backwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex]).points.concat() );
								backwards.reverse();
								backwards.shift();
								route=backwards;
							}
						}
						else
						{
							// on finger
							// back route to beginning of finger
							backwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex + "_f" + _admin.currentFingerIndex]).points.concat() );
							backwards.reverse();
							backwards.shift();
							route=backwards;
						}
					} 
					else 
					{
						// shouldn't be called as with only one admin changing from alert to wander from a point other than the end or beginning of a segment is impossible
					}
				}
				else
				{
					//admin is between points and this shouldn't be called (as the only way pick route would be called would be if changing from alert to wander or an end point was reached)
				}
			} 
			else if(status==NetworkAdminState.ALERT)
			{
				var infectedArm:uint = getInfectedArm();	
				var infected:Boolean = false;
				var i:uint = 0;
				//if current arm is not infected arm
				if( infectedArm != _admin.currentArmIndex )
				{
					if(_admin.fromPointIndex==0 && !_admin.between)
					{
						if(_admin.currentFingerIndex == -1) // on arm
							setAtSegment("h"+infectedArm,true,true);
						else // on finger
							setAtSegment("h"+_admin.currentArmIndex,false);
					} else if(_admin.fromPointIndex==0 && _admin.between)
					{
						route.push(0);
					} else if(_admin.currentFingerIndex == -1) 
					{ 
						// on arm
						backwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex]).points.concat() );
						backwards.reverse();
						if(_admin.between)
							index = backwards.indexOf((_admin.destPointIndex>_admin.fromPointIndex)?_admin.destPointIndex:_admin.fromPointIndex);
						else 
							index = backwards.indexOf(_admin.fromPointIndex);
						route=backwards.splice(index+1,backwards.length-1);
					} else 
					{
						// on finger
						backwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex + "_f" + _admin.currentFingerIndex]).points.concat() );
						backwards.reverse();
						if(_admin.between)
							index = backwards.indexOf((_admin.destPointIndex>_admin.fromPointIndex)?_admin.destPointIndex:_admin.fromPointIndex);
						else 
							index = backwards.indexOf(_admin.fromPointIndex);
						route=backwards.splice(index+1,backwards.length-1);
					}
				}
				else
				{
					//if current arm is infected arm
					if(_admin.currentFingerIndex == -1)
					{
						// on arm
						nodeSegment = NodeSegment(_segments["h" + _admin.currentArmIndex]);
						//go to end
						forwards = indexArray( nodeSegment.points.concat() );
						if(atEndOfSegment && !_admin.between)
						{
							// if current segment is infected
							if(infectedNodes[_admin.currentSegmentID] !=null)
							{
								//shouldn't call this
								trace('should be healing arm. already at end. giving a route containing end anyway');
								route.push(forwards.length-1);
							} else 
							{
								//get first infected child
								infected = false;
								i = 0;
								while(!infected && i < nodeSegment.childrenNum)
								{
									if(_infectedNodes["h" + _admin.currentArmIndex + "_f" + i] != null)
										infected = true;
									if(!infected)
										i++;
								}
								if( !infected)
								{
									//shouldn't call this
									trace("This arm, " + _admin.currentFingerIndex + ", isn't infected? Sending Back.");
									backwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex]).points.concat() );
									backwards.reverse();
									backwards.shift();
									route=backwards;
									
								} else
									setAtSegment("h" + _admin.currentArmIndex + "_f" + i);
							}
						} else if ( atEndOfSegment && _admin.between )
						{
							route.push(forwards.length-1);
						}
						else 
						{
							if(_admin.between)
								index = forwards.indexOf((_admin.destPointIndex>_admin.fromPointIndex)?_admin.fromPointIndex:_admin.destPointIndex);
							else
								index = forwards.indexOf(_admin.fromPointIndex);
							route=forwards.splice(index+1,forwards.length-1);
						}
						
					}
					else
					{
						// on finger
						// if current segment is infected
						if(infectedNodes[_admin.currentSegmentID] != null)
						{
							nodeSegment = NodeSegment(_segments[_admin.currentSegmentID]);
							//go to end
							forwards = indexArray( nodeSegment.points.concat() );
							if(atEndOfSegment && !_admin.between)
							{
								trace('should be healing finger. already at end. giving a route containing end anyway');
								route.push(forwards.length-1);
							} else
							{
								if(_admin.between)
									index = forwards.indexOf((_admin.destPointIndex>_admin.fromPointIndex)?_admin.fromPointIndex:_admin.destPointIndex);
								else
									index = forwards.indexOf(_admin.fromPointIndex);
								route=forwards.splice(index+1,forwards.length-1);
							}
						} 
						else
						{
							//go to arm
							if(_admin.fromPointIndex==0 && !_admin.between)
							{
								//if arm infected
								if(infectedNodes["h" + _admin.currentArmIndex] != null)
								{
									//shouldn't call this
									trace('should be healing arm. already at beginning of finger. giving a route containing beginning of finger');
									route.push(0);
								} else {
									//get first infected child
									nodeSegment = NodeSegment(_segments["h" + _admin.currentArmIndex]);
									infected = false;
									i = 0;
									while(!infected && i < nodeSegment.childrenNum)
									{
										if(_infectedNodes["h" + _admin.currentArmIndex + "_f" + i] != null)
											infected = true;
										if(!infected)
											i++;
									}
									if(!infected)
									{
										//shouldn't call this
										trace("This arm, " + _admin.currentFingerIndex + ", isn't infected? Sending Back to Arm.");
										setAtSegment("h" + _admin.currentArmIndex,false);
									} else
									{
										setAtSegment("h" + _admin.currentArmIndex + "_f" + i);
									}
								}
							} else {
								backwards = indexArray( NodeSegment(_segments["h" + _admin.currentArmIndex + "_f" + _admin.currentFingerIndex]).points.concat() );
								backwards.reverse();
								if(_admin.between)
									index = backwards.indexOf((_admin.destPointIndex>_admin.fromPointIndex)?_admin.destPointIndex:_admin.fromPointIndex);
								else 
									index = backwards.indexOf(_admin.fromPointIndex);
								route=backwards.splice(index+1,backwards.length-1);
							}
						}
					}
				}
			}
			_admin.route=route;
		}
		
		/**
		 * Rotates Admin based on angle between points (doesn't if between)
		 * begins Movement Tween
		 * Sets admin values
		 * @param point
		 * 
		 */
		var hmmCount:uint;
		private function moveTo(pointIndex:uint):void
		{
			if(_admin==null)
				return;
			if(_admin.status==NetworkAdminState.DEAD)
				return;
			if(_admin.currentArmIndex == -1)
			{
				trace("Admin not on arm [Network Port]");
				return;
			}
			_admin.destPointIndex=pointIndex;
			var dest:Point=Point( NodeSegment(_segments[_admin.currentSegmentID]).getPoint(pointIndex) );
			//trace( "moving to: [" + dest.x + "," + dest.y + "]");
			trace("pointIndex: " + pointIndex);
			if(dest.x==_admin.x && dest.y==_admin.y)
			{
				trace("hmm");
				_admin.between = false;
				if(_admin.route.length>0)
					moveTo(nextPoint());
				else
					adminUpdate();
			} else {
				trace("norm");
				_admin.between=true;
				TweenLite.to(_admin,getDuration(_admin.x,dest.x,_admin.y,dest.y),{x:dest.x,y:dest.y,ease:Linear.easeNone,onComplete:moveComplete});
			}
			/*if(!_admin.between) {
				//rotate admin
				var from:Point=_arms[_admin.currentArmIndex][_admin.fromPointIndex] as Point;
			} */
		}
		
		private function moveComplete():void
		{
			if(_admin==null)
				return;
			if(_admin.status==NetworkAdminState.DEAD)
				return;
			//trace("move complete");
			_admin.fromPointIndex=_admin.destPointIndex;
			_admin.between=false;
			adminUpdate();
		}
		
		/**
		 * Positions Admin at first point of segment
		 */
		private function setAtSegment(segmentID:String, beginning:Boolean = true, newArm:Boolean = false):void
		{
			if(_hands==null || _admin==null)
				return;
			if(_segments[segmentID] == null)
				return;
			trace( "setAtSegment: " + segmentID );
			var segment:NodeSegment = _segments[segmentID] as NodeSegment;
			if(segment.segmentType == NodeSegmentType.FINGER)
				if(_fingers == null)
					return;
			var i:int = (beginning==true) ? 0 : segment.points.length - 1 ;
			var point:Point = Point( segment.getPoint( i ) );
			_admin.x=point.x;
			_admin.y=point.y;
			_admin.route=new Array();
			_admin.fromPointIndex=i;
			_admin.rememberFingerIndex=-1;
			_admin.currentSegmentID = segmentID;
			if(segment.segmentType==NodeSegmentType.FINGER)
				_admin.currentFingerIndex = fingerIndex(segmentID);
			else
				_admin.currentFingerIndex = -1;
			if(newArm)
			{
				_admin.currentArmIndex=armIndex(segmentID);
				_admin.goingToStart = false;
			}
		}
		
		/**
		 * @return next movement pointIndex in route (removes from admin's route)
		 */
		private function nextPoint():int
		{
			var pointIndex:int = _admin.route.shift();
			return pointIndex;
		}
		
		/**
		 * @return either the arm the admin is on if that arm is infected or the earliest infected arm
		 */
		private function getInfectedArm():uint
		{
			var arm:uint;
			var nodeSegment:NodeSegment = NodeSegment( _segments["h"+_admin.currentArmIndex] );
			// check if hand of arm that admin is on is infected
			// else check if hand is a hub
				// if so check if any fingers are infected
			// else give first infectedArm;
			
			if(_infectedNodes["h"+_admin.currentArmIndex] != null)
			{
				arm=_admin.currentArmIndex;
			} else if (nodeSegment.isHub)
			{
				var infected:Boolean = false;
				var i:uint = 0;
				while(!infected && i < nodeSegment.childrenNum)
				{
					if(_infectedNodes["h" + _admin.currentArmIndex + "_f" + i] != null)
						infected = true;
					i++;
				}
				if(infected)
					arm=_admin.currentArmIndex;
				else 
					arm=_infectedArms[0];
			} else {
				arm=_infectedArms[0];
			}
			return arm;
		}
		
		private function cleanNode(segmentID:String):void
		{
			if(_admin==null)
				return;
			if(_segments[segmentID] == null)
			{
				trace("Segment " + segmentID + " not set")
				return;
			}
			if(_infectedNodes[segmentID]==null)
			{
				trace("Segment " + segmentID + " not infected");
				return;
			}
			
			var segment_mc:MovieClip=MovieClip(NodeSegment(_segments[segmentID]).segmentGraphic);
			if(segment_mc!=null)
			{
				segment_mc.gotoAndStop(1);
				_infectedNodes[segmentID]=null;
				_numInfectedNodes--;
				delete _infectedNodes[segmentID];
				
				var infected:Boolean = false;
				var nodeSegment:NodeSegment = NodeSegment( _segments["h"+_admin.currentArmIndex] );
				if(_infectedNodes["h"+_admin.currentArmIndex] != null)
				{
					infected = true;
				} else if (nodeSegment.isHub)
				{
					var i:uint = 0;
					while(!infected && i < nodeSegment.childrenNum)
					{
						if(_infectedNodes["h" + _admin.currentArmIndex + "_f" + i] != null)
							infected = true;
						i++;
					}
				}
				if(!infected)
					_infectedArms.splice(_infectedArms.indexOf(_admin.currentArmIndex),1);

				_nodeCleaned.dispatch(this,segmentID);
			}
		}
		
		private function onHealingFinished():void
		{
			if(_admin==null)
				return;
			if(_admin.status==NetworkAdminState.DEAD)
				return;
			cleanNode(_admin.healingSegmentID);
			_admin.healingSegmentID = "";
			if(_infectedArms.length==0)
				_admin.setState(NetworkAdminState.WANDER);
			else
				_admin.setState(NetworkAdminState.ALERT);
			adminUpdate();
		}

		private function onAdminDeath():void
		{
			_portCompletelyInfected.dispatch();
		}
		
		/* Helper Methods */
		
		private function getDuration(x1,x2,y1,y2){
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			var distance:Number = Math.sqrt(dx * dx + dy * dy);
			var pixelsPerSecond:Number;
			if(_admin.status==NetworkAdminState.WANDER)
				pixelsPerSecond=GameInstance.adminWanderSpeed;
			else if(_admin.status==NetworkAdminState.ALERT)
				pixelsPerSecond=GameInstance.adminAlertSpeed;
			var duration:Number = Math.abs(distance / pixelsPerSecond);
			//trace("duration: "+duration);
			return duration;
		}
		
		private function indexArray(sourceArray:Array):Array
		{
			var array:Array=new Array(sourceArray.length);
			for(var i:uint=0; i<array.length; i++)
			{
				array[i]=i;
			}
			return array;
		}
		
		private function armIndex(segmentID:String):uint
		{
			return uint(segmentID.substr(1,1));
		}
		
		private function fingerIndex(segmentID:String):int
		{
			var s:String = segmentID.substr(4,1);
			var i:int = int(s);
			return i;
		}
		
		private function get atEndOfSegment():Boolean
		{
			return (_admin.fromPointIndex == NodeSegment(_segments[_admin.currentSegmentID]).points.length-1);
		}
		
		private function clearDictionary(dict:Dictionary):void
		{
			for (var k:String in dict)
			{
				dict[k] = null;
				delete dict[k];
			}
		}
	}
}