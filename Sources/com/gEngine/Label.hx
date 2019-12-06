package com.gEngine;

class Label {
	public var text(default, null):String;
	public var frame(default, null):Int;

	public function new(text:String, frame:Int) {
		this.text = text;
		this.frame = frame;
	}

	public function clone():Label {
		var cl:Label = new Label(text, frame);
		return cl;
	}
}
