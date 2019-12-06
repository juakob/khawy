package com.basicDisplay;

import com.framework.Simulation;
import com.gEngine.AnimationData;
import com.loading.ResourceHandler;

class SpriteSheetDB implements ResourceHandler {
	var animations:Array<AnimationData>;

	public static var i(get, null):SpriteSheetDB;

	public static function get_i() {
		if (i == null) {
			i = new SpriteSheetDB();
		}
		return i;
	}

	private function new() {
		animations = new Array();
		Simulation.i.addResourceHandler(this);
	}

	public function add(data:AnimationData) {
		animations.push(data);
	}

	public function getData(name:String):AnimationData {
		for (animation in animations) {
			if (animation.name == name)
				return animation;
		}
		throw "spriteSheet with name " + name + " not found. Make sure it's loaded";
	}

	public function clear():Void {
		animations.splice(0, animations.length);
	}
}
