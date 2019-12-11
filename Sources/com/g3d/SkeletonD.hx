package com.g3d;

import kha.math.FastMatrix4;

class SkeletonD {
	public var transformation:FastMatrix4;
	public var bones:Array<Bone>;
	public var ID:String;

	public function new() {
		transformation = FastMatrix4.identity();
		bones = new Array();
	}

	public function setFrame(frame:Int) {
		for (child in bones) {
			child.setFrame(frame, transformation);
		}
	}

	public function totalFrames():Int {
		if (!bones[0].animated)
			return 0;
		return Std.int(bones[0].animations.length / 16);
	}

	public function getBone(id:String):Bone {
		for (child in bones) {
			if (child.id == id)
				return child;
			var result = child.getBone(id);
			if (result != null)
				return result;
		}
		return null;
	}

	public function clone():SkeletonD {
		var cl = new SkeletonD();
		cl.transformation = transformation;
		cl.ID = ID;
		for (bone in bones) {
			cl.bones.push(bone.clone());
		}

		return cl;
	}
}
