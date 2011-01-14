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
	import flash.events.EventDispatcher;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import SoundTree.internals.stInternalShifter;
	
	import SoundTree.st_friend;
	use namespace st_friend;
	
	public class stSoundObject extends EventDispatcher
	{
		public function stSoundObject()
		{
			if ( (this as Object).constructor == stSoundObject )  throw new Error("This class acts as an abstract base class, and therefore cannot be instantiated directly.");
		}
		
		public function get name():String
			{  return _name;  }
		public function set name(value:String):void
			{  _name = value;  }
		st_friend var _name:String;
		
		public function get parent():stSoundGroup
			{  return _parent;  }
		st_friend var _parent:stSoundGroup;
		
		public function removeFromParent():void
			{  this._parent.removeObject(this);  }
		
		public function get actualVolume():Number
		{
			var currParent:stSoundObject = this;
			var currVolume:Number = 1.0;
			
			while ( currParent )
			{
				if ( currParent.muted )
					return 0;
					
				currVolume *= currParent.volume;
				currParent = currParent.parent;
			}
			
			return currVolume;
		}
		
		public function get actuallyMuted():Boolean
		{
			var currParent:stSoundObject = this;
			
			while ( currParent )
			{
				if ( currParent.muted )
					return true;
					
				currParent = currParent.parent;
			}
			
			return false;
		}
		
		st_friend var _volumeShifter:stInternalShifter = null;
		st_friend var _panShifter:stInternalShifter = null;
		
		public function shiftVolumeTo(targetVolume:Number, timeInSeconds:Number, intervalInSeconds:Number = .01):void
		{
			if( _volumeShifter )  _volumeShifter.stop();
			
			_volumeShifter = new stInternalShifter();
			_volumeShifter.init(this, timeInSeconds, stInternalShifter.SHIFT_VOLUME, intervalInSeconds, targetVolume);
		}
		
		public function shiftPanTo(targetPan:Number, timeInSeconds:Number, intervalInSeconds:Number = 10):void
		{
			if ( _panShifter )  _panShifter.stop();
			
			_panShifter = new stInternalShifter();
			_panShifter.init(this, timeInSeconds, stInternalShifter.SHIFT_PAN, intervalInSeconds, targetPan);
		}
		
		
		
		public virtual function play():void  { }
		public virtual function pause():void { }
		public virtual function stop():void  { }
		
		public virtual function get leftPeak():Number  { return 0; }
		public virtual function get rightPeak():Number { return 0; }
		
		public virtual function get playing():Boolean { return false; }
		public virtual function get paused():Boolean  { return false; }
		
		
		
		st_friend static function collectAncestorProperties(object:stSoundObject):Object
		{
			var dict:Object = null;
			var currParent:stSoundGroup = object._parent;
			while ( currParent )
			{
				for ( var propName:String in PROP_TO_MASK_DICT )
				{
					if ( currParent.propsSetFlags & PROP_TO_MASK_DICT[propName] )
					{
						if ( !dict )  dict = new Object();
						
						if ( dict[propName] )  continue;
						
						dict[propName] = [currParent[PUBLIC_TO_PRIVATE_DICT[propName]]]; // Add an array with one element for this property name key.
					}
				}
				currParent = currParent._parent;
			}
			
			return dict;
		}
		
		st_friend static function cascadeAncestorProperties(object:stSoundObject, propStacks:Object):void
		{
			if ( !propStacks )  return; // No ancestor objects have any properties explicitly defined.
		
			var redundantProps:Vector.<String> = null;
			var nonRedundantPropertyFound:Boolean = false;
			for ( var propName:String in propStacks )
			{
				var propStack:Array = propStacks[propName];
				
				if ( object.propsSetFlags & PROP_TO_MASK_DICT[propName] )
				{
					if ( !redundantProps )  redundantProps = new Vector.<String>();
					propStack.push(object[PUBLIC_TO_PRIVATE_DICT[propName]]);
				}
				else
				{
					object.setPropertyImplicitly(propName, propStack[propStack.length - 1]);
					nonRedundantPropertyFound = true;
				}
			}
			
			//--- Only continue further down the tree if a property is set by an ancestor that isn't set by 'object'.
			if ( nonRedundantPropertyFound && (object is stSoundGroup) )
			{
				var asGroup:stSoundGroup = object as stSoundGroup;
				for (var i:int = 0; i < asGroup.numObjects; i++) 
				{
					cascadeAncestorProperties(asGroup.getObjectAt(i), propStacks);
				}
			}
			
			//--- Have to clear any properties pushed onto the stack, cause we don't want them bleeding into peers' properties.
			if ( redundantProps )
			{
				for ( i = 0; i < redundantProps.length; i++ )
				{
					propStack = propStacks[redundantProps[i]];
					propStack.pop();
				}
			}
		}
		
		private static function cascadeProperty(rootObject:stSoundObject, propName:String, value:*):void
		{
			rootObject.propsSetFlags |= PROP_TO_MASK_DICT[propName];
			
			var queue:Vector.<stSoundObject> = new Vector.<stSoundObject>();
			queue.unshift(rootObject);
			
			while ( queue.length )
			{
				var subObject:stSoundObject = queue.shift();
				if ( subObject != rootObject )
				{
					subObject.propsSetFlags &= ~PROP_TO_MASK_DICT[propName]; // this object loses the right to say that it has this property explicitly defined...it is now considered "inherited" from the root tangible.
				}
				
				subObject.setPropertyImplicitly(propName, value);
				
				if ( subObject is stSoundGroup )
				{
					var asGroup:stSoundGroup = subObject as stSoundGroup;
					
					for ( var i:int = 0; i < asGroup.numObjects; i++) 
					{
						var ithObject:stSoundObject = asGroup.getObjectAt(i);
						queue.unshift(ithObject as stSoundObject);
					}
				}
			}
		}
		
		protected function setPropertyImplicitly(propName:String, value:*):void
		{
			this[PUBLIC_TO_PRIVATE_DICT[propName]] = value;
		}
		
		private static const PROP_TO_MASK_DICT:Object =
		{
			//volume:    0x00000000,
			//muted:     0x00000000,
			pan:       0x00000004,
			numLoops:  0x00000008,
			startTime: 0x00000010
		}
		
		private static const PUBLIC_TO_PRIVATE_DICT:Object =
		{
			volume:    "_volume",
			muted:     "_muted",
			pan:       "_pan",
			numLoops:  "_numLoops",
			startTime: "_startTime"
		}
		
		public function get volume():Number
			{  return _volume;  }
		public function set volume(value:Number):void
		{
			_volume = value;
			updateInstanceVolumes();
		}
		st_friend var _volume:Number = 1;
		
		public function get muted():Boolean
			{  return _muted;  }
		public function set muted(bool:Boolean):void
		{
			_muted = bool;
			updateInstanceVolumes();
		}
		st_friend var _muted:Boolean = false;
		
		public function get pan():Number
			{  return _pan;   }
		public function set pan(value:Number):void
			{  cascadeProperty(this, "pan", value);  }
		st_friend var _pan:Number = 0;

		public function get numLoops():uint
			{  return _numLoops;  }
		public function set numLoops(value:uint):void
			{  cascadeProperty(this, "numLoops", value);  }
		st_friend var _numLoops:uint = 0;
		
		public function get startTime():Number
			{  return _startTime;   }
		public function set startTime(value:Number):void
			{  cascadeProperty(this, "startTime", value);  }
		st_friend var _startTime:Number = 0;
		
		st_friend var propsSetFlags:uint = 0;
		
		st_friend virtual function updateInstanceVolumes():void { };
		
		
		
		
		
		
		
		st_friend var eventFlags:uint = 0;
		
		
		
		
		
		
		
		
		public function get length():Number
			{  return _length;  }
		st_friend var _length:Number = 0;
		
		public function get numBytes():uint
			{  return _numBytes;  }
		st_friend var _numBytes:uint = 0;

		public function get instanceCount():uint
			{  return _instanceCount;  }
		st_friend var _instanceCount:uint = 0;
		
		st_friend function incProps(bytesChange:int, lengthChange:Number, numInstancesChange:int):void
		{
			var currParent:stSoundObject = this;
			
			while ( currParent )
			{
				if ( currParent.propsFrozen )  return;
				
				currParent._numBytes      += bytesChange;
				currParent._length        += lengthChange;
				currParent._instanceCount += numInstancesChange;
				
				currParent = currParent._parent;
			}
		}
		
		private var propFreezeStack:Vector.<Boolean>;
		
		st_friend function pushPropFreeze():void
		{
			if ( !propFreezeStack )
				propFreezeStack = new Vector.<Boolean>();
			propFreezeStack.push(true);
		}
		
		st_friend function popPropFreeze():void
		{
			if ( propFreezeStack )
			{
				propFreezeStack.pop();
				if ( propFreezeStack.length == 0 )
					propFreezeStack = null;
			}
		}
		
		private function get propsFrozen():Boolean
			{  return propFreezeStack ? true : false;  }
	}
}