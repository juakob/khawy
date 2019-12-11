package com.g3d;

import kha.math.FastMatrix4;
import kha.arrays.Float32Array;

class Skinning {
	private var bones:Array<Bone>;
	private var matrices:Float32Array;

	public function new(bones:Array<Bone>) {
		this.bones = bones;
		matrices = new Float32Array(bones.length * 16);
	}

	public function getBonesTransformations():Float32Array {
		var offset:Int = 0;
		for (bone in bones) {
			appendMatrix(matrices, bone.finalTransform, offset);
			offset += 16;
		}
		return matrices;
	}

	function appendMatrix(list:Float32Array, matrix:FastMatrix4, offset:Int):Void {
		list.set(offset + 0, matrix._00);
		list.set(offset + 1, matrix._01);
		list.set(offset + 2, matrix._02);
		list.set(offset + 3, matrix._03);
		list.set(offset + 4, matrix._10);
		list.set(offset + 5, matrix._11);
		list.set(offset + 6, matrix._12);
		list.set(offset + 7, matrix._13);
		list.set(offset + 8, matrix._20);
		list.set(offset + 9, matrix._21);
		list.set(offset + 10, matrix._22);
		list.set(offset + 11, matrix._23);
		list.set(offset + 12, matrix._30);
		list.set(offset + 13, matrix._31);
		list.set(offset + 14, matrix._32);
		list.set(offset + 15, matrix._33);
	}
}
