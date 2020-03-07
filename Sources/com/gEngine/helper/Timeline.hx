package com.gEngine.helper;

import com.gEngine.Label;

class Timeline {
	public var frameRate:Float;
	public var frameSkiped:Int = 0;
	public var totalFrames:Int;
	public var currentFrame(default, null):Int = 0;
	public var playing:Bool = true;
	public var frameChange:Bool;
	public var loop:Bool = true;
	public var frameJump:Bool;
	public var currentAnimation(default, null):String;

	var firstFrame:Int = 0;
	var lastFrame:Int = 0;
	private var labels:Array<Label>;
	public var currentTime:Float = 0;

	public function new(frameRate:Float, totalFrames:Int, ?labels:Array<Label>) {
		this.frameRate = frameRate;
		this.totalFrames = totalFrames;
		if (totalFrames == 1)
			playing = false;
		this.labels = labels;
		frameJump = true;
	}

	public function update(dt:Float) {
		frameChange = false;
		frameSkiped = 0;
		frameJump = false;
		if (!playing)
			return;
		currentTime += dt;
		if (currentTime < frameRate)
			return;

		frameChange = true;

		frameSkiped = Math.floor(currentTime / frameRate);
		currentTime -= frameRate * frameSkiped;
		currentFrame += frameSkiped;
		if (currentFrame >= totalFrames) {
			if (loop) {
				if (currentFrame != firstFrame) {
					frameJump = true;
				}
				currentFrame = firstFrame;
			} else {
				currentFrame = totalFrames - 1;
				playing = false;
			}
		}
		if (currentFrame <= lastFrame && currentFrame >= firstFrame)
			return;
		if (currentAnimation != null) {
			if (loop) {
				gotoAndPlay(firstFrame);
			} else {
				gotoAndStop(lastFrame);
			}
		}
	}

	public function gotoAndPlay(frame:Int) {
		currentFrame = frame;
		currentTime = 0;
		playing = true;
		frameJump = true;
	}

	public function gotoAndStop(frame:Int) {
		currentFrame = frame;
		currentTime = 0;
		playing = false;
		frameJump = true;
	}

	public function labelFrame(text:String):Label {
		for (label in labels) {
			if (label.text == text) {
				return label;
			}
		}
		throw "label " + text + "not found";
	}

	public function currentLabel():String {
		var frame:Int;

		for (label in labels) {
			frame = label.frame;
			if (frame == currentFrame || (frame > currentFrame - frameSkiped && frame <= currentFrame)) {
				return label.text;
			}
			if (frame > currentFrame) {
				return null;
			}
		}
		return null;
	}

	public function labelEnd(text:String):Int {
		var counter:Int = 0;
		for (label in labels) {
			if (label.text == text) {
				if (labels.length == counter + 1)
					return totalFrames - 1;
				return labels[counter + 1].frame - 1;
			}
			++counter;
		}
		throw "label " + text + "not found";
	}

	public function labelEndEvent(text:String, indexStart:Int = 0, prefixIgnore:String):Int {
		for (i in indexStart...labels.length) {
			var label = labels[i];
			if (label.text == text) {
				if (labels.length == i + 1)
					return totalFrames - 1;
				if (labels[i + 1].text.indexOf(prefixIgnore) == 0) {
					return labelEndEvent(labels[i + 1].text, i + 1, prefixIgnore);
				}
				return labels[i + 1].frame - 1;
			}
		}
		throw "label " + text + "not found";
	}

	public function play() {
		playing = true;
	}

	public function localFrame():Int {
		return currentFrame - firstFrame;
	}

	public function playAnimation(animation:String, loop:Bool = true, force:Bool = false, prefixCharIgnore:String = null):Void {
		var firstAnimationFrame:Int = labelFrame(animation).frame;
		this.loop = loop;
		if ((currentAnimation != animation || force || !playing) && firstAnimationFrame != -1) {
			currentAnimation = animation;
			firstFrame = firstAnimationFrame;
			lastFrame = prefixCharIgnore == null ? labelEnd(currentAnimation) : labelEndEvent(animation, prefixCharIgnore);
			gotoAndPlay(firstFrame);
		}
	}

	public function labelFrameAt(frame:Int):String {
		for (label in labels) {
			if (label.frame == frame) {
				return label.text;
			}
			if (label.frame > frame) {
				return null;
			}
		}
		return null;
	}

	public function hasLabel(labelText:String):Bool {
		for (label in labels) {
			if (label.text == labelText) {
				return true;
			}
		}
		return false;
	}

	public inline function interchange(animation:String):Void {
		if (currentAnimation != animation) {
			var delta = currentFrame - firstFrame;
			currentAnimation = animation;
			firstFrame = labelFrame(currentAnimation).frame;
			gotoAndPlay(firstFrame + delta);
		}
	}

	public inline function stop():Void {
		playing = false;
	}

	public inline function isComplete():Bool {
		return !playing && !loop;
	}
}
