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

package SoundTree.internals 
{
	import flash.events.*;
	import flash.media.*;
	import SoundTree.*;
	import SoundTree.objects.stFlashSound;
	use namespace st_friend;
	
	public class stInternalFlashSoundInstance
	{
		st_friend var pausePosition:Number = 0;
		st_friend var channel:SoundChannel;
		st_friend var parentSound:stFlashSound;
		st_friend var playCount:uint = 0;
		
		st_friend function init(sound:stFlashSound):void
		{
			parentSound = sound;
			
			actuallyPlaySound(parentSound._startTime*1000);
		}
		
		private function soundComplete(evt:Event):void
		{
			var channel:SoundChannel = evt.currentTarget as SoundChannel;
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			channel = null;
			playCount++;
			
			if ( playCount >= parentSound._numLoops+1 )
			{
				parentSound.incProps(0, 0, -1);
				parentSound._instances.splice(parentSound._instances.indexOf(this), 1);
				
				if ( parentSound._instanceCount == 0 )
				{
					parentSound._playing = parentSound._paused = false;
				}
				
				parentSound = null;
			}
			else
			{
				actuallyPlaySound(parentSound._startTime);
			}
		}
		
		st_friend function get position():Number
			{  return channel ? channel.position : pausePosition;  }
		
		st_friend function get leftPeak():Number
			{  return channel ? channel.leftPeak : 0;  }
			
		st_friend function get rightPeak():Number
			{  return channel ? channel.rightPeak : 0;  }
		
		st_friend function pause():void
		{
			if ( !channel )  return;
			
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			pausePosition = channel.position;
			channel.stop();
			channel = null;
		}
		
		st_friend function play():void
		{
			if ( channel )  return;
			
			actuallyPlaySound(pausePosition);
		}
		
		st_friend function stop():void
		{
			if ( channel )
			{
				channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				channel.stop();
			}
			
			pausePosition = 0;
			channel = null;
		}
		
		private function actuallyPlaySound(position:Number):void
		{
			var transform:SoundTransform = new SoundTransform(parentSound.actualVolume, parentSound._pan);
			channel = parentSound._sound.play(position, 1, transform);
			channel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
			pausePosition = 0;
		}
	}
}