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

package SoundTree.events 
{
	import flash.events.Event;
	import SoundTree.st_friend;
	import SoundTree.stSoundObject;
	use namespace st_friend;
	
	public class stAddRemoveEvent extends Event 
	{
		
		st_friend var _soundObject:stSoundObject;
		
		public function stAddRemoveEvent(type:String)
		{ 
			super(type);
		} 
		
		public override function clone():Event 
		{
			var clone:stAddRemoveEvent = new stAddRemoveEvent(type);
			clone._soundObject = this._soundObject;
			return clone;
		}
		
		public function get soundObject():stSoundObject
			{	return _soundObject;  }
	}
}