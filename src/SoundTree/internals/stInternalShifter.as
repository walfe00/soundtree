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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import SoundTree.events.stSoundEvent;
	import SoundTree.st_friend;
	import SoundTree.stFlashSound;
	import SoundTree.stSoundObject;
	use namespace st_friend;
	
	public class stInternalShifter
	{
		st_friend static const SHIFT_VOLUME:uint = 1;
		st_friend static const SHIFT_PAN:uint    = 2;
		
		private var _hostObject:stSoundObject;
		private var _shiftTime:Number = 0;
		private var _type:uint = 0;
		private var _interval:Number = 0;
		private var _target:Number = 0;
		
		private var _vector:Number = 0;
		
		private var _timer:Timer = null;
		
		st_friend function init(hostObject:stSoundObject, shiftTime:Number, type:uint, interval:Number, target:Number):void
		{
			_hostObject = hostObject;
			_shiftTime   = shiftTime;
			_interval = interval;
			_target = target;
			_type = type;
			
			if ( _type == SHIFT_PAN )
				_vector = _target - _hostObject.pan;
			else if ( _type == SHIFT_VOLUME )
				_vector = _target - _hostObject.volume;
			else
				return;
				
			if ( _vector == 0 )  return;
			
			var numIntervalsToTarget:Number = _shiftTime / _interval;
			_vector /= numIntervalsToTarget;
			
			_timer = new Timer(interval*1000, int.MAX_VALUE);
			_timer.addEventListener(TimerEvent.TIMER, timerEvent, false, 0, true );
			_timer.start();
		}
		
		private function timerEvent(evt:TimerEvent):void
		{
			var currValue:Number = 0;
			if ( _type == SHIFT_PAN )
			{
				_hostObject.pan += _vector;
				currValue = _hostObject.pan;
			}
			else if ( _type == SHIFT_VOLUME )
			{
				_hostObject.volume += _vector;
				currValue = _hostObject.volume;
			}
			
			if ( _vector < 0 && currValue <= _target || _vector > 0 && currValue >= _target)
			{
				//--- Just make sure property exactly matches to target, and doesn't miss slightly due to floating point error.
				if ( _type == SHIFT_PAN )
				{
					_hostObject.pan = _target;
				}
				else if ( _type == SHIFT_VOLUME )
				{
					_hostObject.volume = _target;
				}
				
				stop();
				
				var soundEvent:stSoundEvent = new stSoundEvent(stSoundEvent.SOUND_SHIFT_COMPLETE);
				soundEvent._soundObject = _hostObject;
				_hostObject.dispatchEvent(soundEvent);
			}
		}
		
		st_friend function stop():void
		{
			stopTimer();
			
			if ( _type == SHIFT_PAN )
				_hostObject._panShifter = null;
			else if ( _type == SHIFT_VOLUME )
				_hostObject._volumeShifter = null;
		}
		
		private function stopTimer():void
		{
			if ( !_timer )  return;
			
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, timerEvent);
			_timer = null;
		}
	}
}