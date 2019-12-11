package com.g3d;

import kha.math.FastMatrix4;

class Bone {
	public var bindTransform:FastMatrix4;
	public var finalTransform:FastMatrix4;
	public var children:Array<Bone>;
	public var animations:Array<Float>;
	public var id:String;
	public var animated:Bool;

	public function new() {
		children = new Array();
		finalTransform = FastMatrix4.identity();
	}

	public function clone():Bone {
		var cl = new Bone();
		cl.id = id;

		for (child in children) {
			cl.children.push(child.clone());
		}
		if (animated) {
			cl.animations = new Array();
			for (animation in animations) {
				cl.animations.push(animation);
			}
		}
		cl.bindTransform = bindTransform;
		cl.animated = animated;
		return cl;
	}

	public function addChild(bone:Bone) {
		children.push(bone);
	}

	public function setFrame(frame:Int, transform:FastMatrix4) {
		if (!animated) {
			finalTransform = bindTransform;
		} else {
			matrixFromArray(animations, frame * 16, finalTransform);
		}
		var toPass:FastMatrix4 = transform.multmat(finalTransform);
		finalTransform = toPass.multmat(bindTransform.inverse());

		for (child in children) {
			child.setFrame(frame, toPass);
		}
	}

	public function getBone(id:String):Bone {
		for (child in children) {
			if (child.id == id)
				return child;
			var result = child.getBone(id);
			if (result != null)
				return result;
		}
		return null;
	}

	public static function matrixFromArray(values:Array<Float>, offset:Int, matrix:FastMatrix4):Void {
		matrix._00 = values[offset++];
		matrix._01 = values[offset++];
		matrix._02 = values[offset++];
		matrix._03 = values[offset++];

		matrix._10 = values[offset++];
		matrix._11 = values[offset++];
		matrix._12 = values[offset++];
		matrix._13 = values[offset++];

		matrix._20 = values[offset++];
		matrix._21 = values[offset++];
		matrix._22 = values[offset++];
		matrix._23 = values[offset++];

		matrix._30 = values[offset++];
		matrix._31 = values[offset++];
		matrix._32 = values[offset++];
		matrix._33 = values[offset++];
		matrix.inverse();
	}
}
