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

package SoundTree 
{
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	public class stGlobal 
	{
		public static function get volume():Number
			{  return SoundMixer.soundTransform.volume;  }
		public static function set volume(value:Number):void
		{
			var transform:SoundTransform = SoundMixer.soundTransform;
			transform.volume = value;
			SoundMixer.soundTransform = transform;
		}
		
		public static function get pan():Number
			{  return SoundMixer.soundTransform.pan;  }
		public static function set pan(value:Number):void
		{
			var transform:SoundTransform = SoundMixer.soundTransform;
			transform.pan = value;
			SoundMixer.soundTransform = transform;
		}
	}
}