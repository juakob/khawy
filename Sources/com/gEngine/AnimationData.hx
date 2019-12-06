package com.gEngine;

class AnimationData {
	public var name:String;
	public var texturesID:Int = -1;
	public var frames:Array<Frame>;
	public var labels:Array<Label>;

	public function new() {}

	public function clone() {
		var cl = new AnimationData();
		cl.name = name;
		cl.texturesID = texturesID;
		cl.frames = new Array();
		for (frame in frames) {
			cl.frames.push(frame.clone());
		}
		cl.labels = new Array();
		for (label in labels) {
			cl.labels.push(label.clone());
		}

		return cl;
	}
}
