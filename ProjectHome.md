
```
var newSound:stFlashSound = new stFlashSound("sounds/Hello.mp3");
newSound.volume = .5;
newSound.play();
```

The above code says most of it.  SoundTree wraps all the various sound-related classes that you normally have to interact with into one abstracted class that deals with all the annoying stuff behind the scenes.  Further, you can group sounds into hierarchies using an API similar to Flash's DisplayObjectContainer, which makes it a breeze to selectively manipulate music, interface sounds, sound effects, etc. or work with them all at once.  A common abstract base class (stSoundObject) leaves room for future extensions dealing with things like run-time-synthesized sounds.