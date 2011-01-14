/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package SoundTree.objects
{
	import SoundTree.st_friend;
	use namespace st_friend;
	
	public class stSoundGroup extends stSoundObject
	{
		private var _objects:Vector.<stSoundObject> = new Vector.<stSoundObject>();
		
		public function stSoundGroup(name:String = null)
		{
			_name = name;
		}
		
		public function playRandom():stSoundObject
		{
			if ( !_objects.length )  return null;
		
			var object:stSoundObject = _objects[ Math.round(Math.random() * _objects.length)];
			object.play();
			return object;
		}
		
		public function playByName(nameOfSound:String):stSoundObject
			{  return operationByName(nameOfSound, OP_PLAY);  }
			
		public function pauseByName(nameOfSound:String):stSoundObject
			{  return operationByName(nameOfSound, OP_PAUSE);  }
		
		public function stopByName(nameOfSound:String):stSoundObject
			{  return operationByName(nameOfSound, OP_STOP);  }
		
		private static const OP_PLAY:uint = 1;
		private static const OP_STOP:uint = 2;
		private static const OP_PAUSE:uint = 3;
		
		private function operationByName(nameOfSound:String, operationType:uint):stSoundObject
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				if ( _objects[i]._name == nameOfSound )
				{
					if( operationType == OP_PLAY )
						_objects[i].play();
					else if( operationType == OP_STOP )
						_objects[i].stop();
					else if( operationType == OP_PAUSE )
						_objects[i].pause();
					
					return _objects[i];
				}
			}
			
			return null;
		}
		
		
		
		
		private function addMultipleObjectsToArray(someObjects:Vector.<stSoundObject>, startIndex:uint):stSoundGroup
		{
			var totalBytes:uint = 0;
			var totalLength:Number = 0;
			var totalInstances:uint = 0;
			
			pushPropFreeze();
			{
				for ( var i:int = 0; i < someObjects.length; i++ )
				{
					var object:stSoundObject = someObjects[i];
					addObjectToArray(object, startIndex);
					
					totalLength    += object._length;
					totalBytes     += object._numBytes;
					totalInstances += object._instanceCount;
					
					startIndex++;
				}
			}
			popPropFreeze();
			
			incProps(totalBytes, totalLength, totalInstances);
			
			return this;
		}
		
		st_friend override function updateInstanceVolumes():void
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				_objects[i].updateInstanceVolumes();
			}
		}
		
		
		private function addObjectToArray(object:stSoundObject, index:uint):void
		{
			if ( object._parent )
				throw new Error("Object already has a parent!");
			
			if ( index == _objects.length )
				_objects.push(object);
			else
				_objects.splice(index, 0, object);
				
			object._parent = this;
			
			cascadeAncestorProperties(object, collectAncestorProperties(object));
			object.updateInstanceVolumes();
			
			// ADD ADD EVENTS OR SOMETHING HERE IN THE FUTURE.
		}
		
		private function removeObjectFromArray(index:uint):stSoundObject
		{			
			var objectRemoved:stSoundObject = _objects.splice(index, 1)[0];
			
			incProps(-objectRemoved._numBytes, -objectRemoved._length, -objectRemoved._instanceCount);
			
			objectRemoved._parent = null;
			
			// ADD REMOVE EVENTS OR SOMETHING HERE IN THE FUTURE.
			
			return objectRemoved;
		}
		
		
		
		
		
		public function containsObject(object:stSoundObject):Boolean
			{  return _objects.indexOf(object) >= 0;  }
		
		public function getObjectAt(index:uint):stSoundObject
			{  return _objects[index];  }

		public function lastObject(minus:uint = 0):stSoundObject
			{  return _objects[_objects.length - 1 - minus];  }
		
		public function get numObjects():uint
			{  return _objects.length;  }
			
		public function getObjectIndex(object:stSoundObject):int
			{	return _objects.indexOf(object);  }
			
		public function getObjectByName(name:String):stSoundObject
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				if ( _objects[i]._name == name )
				{
					return _objects[i];
				}
			}
			
			return null;
		}
		
		public function addObjects(someObjects:Vector.<stSoundObject>):stSoundGroup
			{  return addMultipleObjectsToArray(someObjects, _objects.length);  }
		
		public function addObject(... oneOrMoreObjects):stSoundGroup
			{  return addMultipleObjectsToArray(Vector.<stSoundObject>(oneOrMoreObjects), _objects.length);  }
			
		public function insertObjectAt(index:uint, ... oneOrMoreObjects):stSoundGroup
			{  return addMultipleObjectsToArray(Vector.<stSoundObject>(oneOrMoreObjects), index);  }
		
		public function setObjectAt(index:uint, replacement:stSoundObject):stSoundObject
		{
			var objectRemoved:stSoundObject;
			pushPropFreeze();
			{
				objectRemoved = removeObjectAt(index);
				insertObjectAt(index, replacement);
			}
			popPropFreeze();
			
			var lengthChange:Number = 0, bytesChange:int = 0, instanceChange:int = 0;
			
			lengthChange -= objectRemoved._length;
			bytesChange -= objectRemoved._numBytes;
			instanceChange -= objectRemoved._instanceCount;
			
			lengthChange += replacement._length;
			bytesChange += replacement._numBytes;
			instanceChange += replacement._instanceCount;
		
			incProps(bytesChange, lengthChange, instanceChange);
			
			return objectRemoved;
		}
			
		public function setObjectIndex(object:stSoundObject, index:uint):stSoundGroup
		{
			var origIndex:int = _objects.indexOf(object);
			_objects.splice(origIndex, 1);
			_objects.splice(index, 0, object);
			return this;
		}
	
		public function removeObject(object:stSoundObject):stSoundGroup
		{
			var index:int = _objects.indexOf(object);
			removeObjectAt(index);
			return this;
		}
	
		public function removeObjectAt(index:uint):stSoundObject
			{  return removeObjectFromArray(index);  }
		
		public function removeAllObjects():Vector.<stSoundObject>
		{
			var toReturn:Vector.<stSoundObject>;
			var physObjectFound:Boolean = false;
			
			pushPropFreeze();
			{
				for ( var i:int = 0; i < _objects.length; i++ )
				{
					if ( !toReturn )
						toReturn = new Vector.<stSoundObject>();
					var object:stSoundObject = removeObjectAt(i);
					toReturn.push(object);
				}
			}
			popPropFreeze();
			
			incProps( -_numBytes, -_length, -_instanceCount);
			
			return toReturn;
		}
		
		
		
		
		
		public override function play():void
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				_objects[i].play();
			}
		}
		
		public override function pause():void
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				_objects[i].pause();
			}
		}
		
		public override function stop():void
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				_objects[i].stop();
			}
		}
		
		public override function get leftPeak():Number
		{
			var highestPeak:Number = 0;
			for (var i:int = 0; i < _objects.length; i++) 
			{
				if ( _objects[i].leftPeak > highestPeak )
					highestPeak = _objects[i].leftPeak;
			}
			return highestPeak;
		}
		
		public override function get rightPeak():Number
		{
			var highestPeak:Number = 0;
			for (var i:int = 0; i < _objects.length; i++) 
			{
				if ( _objects[i].rightPeak > highestPeak )
					highestPeak = _objects[i].rightPeak;
			}
			return highestPeak;
		}
		
		public override function get playing():Boolean
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				if ( _objects[i].playing )  return true;
			}
			return false;
		}
		
		public override function get paused():Boolean
		{
			for (var i:int = 0; i < _objects.length; i++) 
			{
				if ( !_objects[i].paused )  return false;
			}
			return true;
		}
	}
}