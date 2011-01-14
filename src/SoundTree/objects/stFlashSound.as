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
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	import SoundTree.*;
	import SoundTree.internals.*;
	
	use namespace st_friend;
	
	public class stFlashSound extends stSoundObject
	{
		private static const LOAD_ERROR:String = "Sound could not be loaded.";
		
		st_friend var   _sound:Sound
		st_friend const _instances:Vector.<stInternalFlashSoundInstance> = new Vector.<stInternalFlashSoundInstance>();
		st_friend var   _source:*;
		
		st_friend var _playing:Boolean = false;
		st_friend var _paused:Boolean  = false;
		
		public var allowMultipleInstances:Boolean = true;
		
		st_friend var _readyToPlay:Boolean = false;
	
		public function stFlashSound(source:*, name:String = null):void
		{
			_source = source;
			_name = name;
			
			if ( _source is Class )
			{
				_sound = new _source;
				setSoundData();
			}
			else if ( _source is String )
			{
				var asString:String = _source as String;
				
				if ( asString.indexOf(".mp3") >= 0 )
				{
					_sound = new Sound(new URLRequest( _source as String));
					_sound.addEventListener(Event.COMPLETE,        completionEvent, false, 0, true);
					_sound.addEventListener(IOErrorEvent.IO_ERROR, completionEvent, false, 0, true);
				}
				else
				{
					_sound = new (getDefinitionByName(asString) as Class);
					setSoundData();
				}
			}
			else
			{
				_sound = new Sound();
			}
		}
		
		private function completionEvent(evt:Event):void
		{
			if ( evt.type == IOErrorEvent.IO_ERROR )
			{
				//throw new Error(LOAD_ERROR);
			}
			else
			{
				setSoundData();
			}
			
			_sound.removeEventListener(Event.COMPLETE,        completionEvent);
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, completionEvent);
		}
		
		private function setSoundData():void
		{
			incProps(_sound.bytesTotal, _sound.length/1000.0, 0)
			
			_readyToPlay = true;
		}
		
		public function get readyToPlay():Boolean
			{  return _readyToPlay;  }
		
		public function get source():*
			{  return _source;  }
			
		public function get id3():ID3Info
			{  return _sound.id3;  }			
		
		public function get position():Number
			{  return _instances.length ? _instances[_instances.length - 1].position : 0;  }
			
		public override function play():void
		{
			for (var i:int = 0; i < _instances.length; i++) 
			{
				_instances[i].play();
			}
			
			_playing = true;
			_paused  = false;
			
			if ( _instanceCount && !allowMultipleInstances )  return;

			incProps(0, 0, 1);
			
			var instance:stInternalFlashSoundInstance = new stInternalFlashSoundInstance();
			instance.init(this);
			_instances.push(instance);
		}
		
		public override function pause():void
		{
			for (var i:int = 0; i < _instances.length; i++) 
			{
				_instances[i].pause();
			}
			
			_playing = false;
			_paused  = true;
		}
		
		public override function stop():void
		{
			for (var i:int = 0; i < _instances.length; i++) 
			{
				_instances[i].stop();
			}
			
			incProps(0, 0, -_instances.length);
			_instances.length = 0;
			_playing = _paused = false;
		}
		
		public override function get leftPeak():Number
		{
			var highestPeak:Number = 0;
			for (var i:int = 0; i < _instances.length; i++) 
			{
				if ( _instances[i].leftPeak > highestPeak )
					highestPeak = _instances[i].leftPeak;
			}
			return highestPeak;
		}
		
		public override function get rightPeak():Number
		{
			var highestPeak:Number = 0;
			for (var i:int = 0; i < _instances.length; i++) 
			{
				if ( _instances[i].rightPeak > highestPeak )
					highestPeak = _instances[i].rightPeak;
			}
			return highestPeak;
		}
		
		public override function get playing():Boolean
			{  return _playing;  }
		
		public override function get paused():Boolean
			{  return _paused;  }
			
		st_friend override function updateInstanceVolumes():void
		{
			updateInstances();
		}
		
		private function updateInstances():void
		{
			for (var i:int = 0; i < _instances.length; i++)
			{
				var instance:stInternalFlashSoundInstance = _instances[i];
				var channel:SoundChannel = instance.channel;
				if ( channel )
				{
					var transform:SoundTransform = channel.soundTransform;
					transform.volume = this.actualVolume;
					transform.pan    = _pan;
					channel.soundTransform = transform; // have to assign it back for changes to take effect.
				}
			}
		}
			
		protected override function setPropertyImplicitly(propName:String, value:*):void
		{
			super.setPropertyImplicitly(propName, value);
			
			if ( propName == "volume" || propName == "muted" || propName == "pan" )
			{
				updateInstances();
			}
		}
	}
}