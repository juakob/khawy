package com.g3d;

import com.gEngine.GEngine;
import com.framework.Simulation;
import com.loading.ResourceHandler;

class Object3dDB implements ResourceHandler {
	var objects:Map<String, Array<Object3dData>>;
	var skeletons:Map<String, SkeletonD>;

	public static var i(get, null):Object3dDB;

	public static function get_i() {
		if (i == null) {
			i = new Object3dDB();
		}
		return i;
	}

	private function new() {
		objects = new Map();
		skeletons = new Map();
		Simulation.i.addResourceHandler(this);
	}

	public function add(name:String, data:Array<Object3dData>) {
		for (parts in data) {
			GEngine.i.addTexture(parts.texture);
		}
		objects.set(name, data);
	}

	public function addSkeleton(name:String, skeleton:SkeletonD) {
		skeletons.set(name, skeleton);
	}

	public function getData(name:String):Array<Object3dData> {
		#if debug
		if (!objects.exists(name))
			throw "object3d with name " + name + " not found. Make sure it's loaded";
		#end
		return objects.get(name);
	}

	public function getSkeleton(name:String):SkeletonD {
		if (!skeletons.exists(name))
			return null;
		return skeletons.get(name);
	}

	public function clear():Void {
		for (object in objects) {
			for (part in object) {
				part.unload();
			}
		}
		objects = new Map();
	}
}
