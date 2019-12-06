package com.helpers;

import kha.math.FastVector4;
import kha.math.FastMatrix4;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.FastVector2;

class MinMax {
	public var min:FastPoint;
	public var max:FastPoint;
	public var minZ:FastFloat = -869.1168;
	public var maxZ:FastFloat = -869.1168;

	public static var weak:MinMax = new MinMax();

	public var isEmpty:Bool;

	public function new() {
		min = new FastPoint(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		max = new FastPoint(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
	}

	public inline function reset():Void {
		min.setTo(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		max.setTo(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		minZ = Math.POSITIVE_INFINITY;
		maxZ = Math.NEGATIVE_INFINITY;
		isEmpty = true;
	}

	public function merge(value:MinMax):Void {
		if (min.x > value.min.x) {
			min.x = value.min.x;
		}
		if (min.y > value.min.y) {
			min.y = value.min.y;
		}

		if (max.x < value.max.x) {
			max.x = value.max.x;
		}
		if (max.y < value.max.y) {
			max.y = value.max.y;
		}

		if (minZ > value.minZ) {
			minZ = value.minZ;
		}
		if (maxZ < value.maxZ) {
			maxZ = value.maxZ;
		}
		isEmpty = isEmpty && value.isEmpty;
	}

	public function intersection(value:MinMax):Void {
		if (min.x > value.max.x || max.x < value.min.x || min.y > value.max.y || max.y < value.min.y) {
			isEmpty = true;
			reset();
			return;
		}
		if (min.x < value.min.x) {
			min.x = value.min.x;
		}
		if (min.y < value.min.y) {
			min.y = value.min.y;
		}

		if (max.x > value.max.x) {
			max.x = value.max.x;
		}
		if (max.y > value.max.y) {
			max.y = value.max.y;
		}
	}

	public inline function transform(matrix:FastMatrix4) {
		if (isEmpty)
			return;
		var fMin = new FastVector4(min.x, min.y, minZ);
		var fMax = new FastVector4(max.x, max.y, maxZ);
		reset();
		mergeVec4(matrix.multvec(fMin));
		mergeVec4(matrix.multvec(fMax));
		mergeVec4(matrix.multvec(new FastVector4(fMax.x, fMax.y, fMin.z)));
		mergeVec4(matrix.multvec(new FastVector4(fMin.x, fMin.y, fMax.z)));
		mergeVec4(matrix.multvec(new FastVector4(fMin.x, fMax.y, fMin.z)));
		mergeVec4(matrix.multvec(new FastVector4(fMin.x, fMax.y, fMax.z)));
		mergeVec4(matrix.multvec(new FastVector4(fMax.x, fMin.y, fMin.z)));
		mergeVec4(matrix.multvec(new FastVector4(fMax.x, fMin.y, fMax.z)));
	}

	public function perspective(projection:FastMatrix4, width:Int, height:Int) {
		if (isEmpty)
			return;
		var fMin = new FastVector4(min.x, min.y, minZ);
		var fMax = new FastVector4(max.x, max.y, maxZ);
		reset();
		mergePerspectiveVector(fMin, projection);
		mergePerspectiveVector(fMax, projection);
		mergePerspectiveVector(new FastVector4(fMax.x, fMax.y, fMin.z), projection);
		mergePerspectiveVector(new FastVector4(fMin.x, fMin.y, fMax.z), projection);
		mergePerspectiveVector(new FastVector4(fMin.x, fMax.y, fMin.z), projection);
		mergePerspectiveVector(new FastVector4(fMin.x, fMax.y, fMax.z), projection);
		mergePerspectiveVector(new FastVector4(fMax.x, fMin.y, fMax.z), projection);
		mergePerspectiveVector(new FastVector4(fMax.x, fMin.y, fMin.z), projection);
		min.x *= width * 0.5;
		min.y *= height * 0.5;
		max.x *= width * 0.5;
		max.y *= height * 0.5;
	}

	inline function mergePerspectiveVector(vector:FastVector4, perspective:FastMatrix4) {
		var p = perspective.multvec(vector);
		var hPoint = p.mult(1 / p.w); // in homogeneous space
		mergeVec4(hPoint);
	}

	public function transform3(matrix:FastMatrix3) {
		if (isEmpty)
			return;
		var fMin = new FastVector2(min.x, min.y);
		var fMax = new FastVector2(max.x, max.y);
		reset();
		mergeVec(matrix.multvec(fMin));
		mergeVec(matrix.multvec(fMax));
		mergeVec(matrix.multvec(new FastVector2(fMin.x, fMax.y)));
		mergeVec(matrix.multvec(new FastVector2(fMax.x, fMin.y)));
	}

	public function mergeRec(x:Float, y:Float, width:Float, height:Float):Void {
		if (min.x > x) {
			min.x = x;
		}
		if (min.y > y) {
			min.y = y;
		}

		if (max.x < x + width) {
			max.x = x + width;
		}
		if (max.y < y + height) {
			max.y = y + height;
		}
		isEmpty = (this.width() < 0) || (this.height() < 0);
	}

	public function mergeVec(multvec:FastVector2) {
		if (min.x > multvec.x) {
			min.x = multvec.x;
		}
		if (min.y > multvec.y) {
			min.y = multvec.y;
		}
		if (max.x < multvec.x) {
			max.x = multvec.x;
		}
		if (max.y < multvec.y) {
			max.y = multvec.y;
		}
		isEmpty = width() < 0 || height() < 0;
	}

	public inline function mergeVec4(multvec:FastVector4) {
		if (min.x > multvec.x) {
			min.x = multvec.x;
		}
		if (min.y > multvec.y) {
			min.y = multvec.y;
		}
		if (max.x < multvec.x) {
			max.x = multvec.x;
		}
		if (max.y < multvec.y) {
			max.y = multvec.y;
		}

		if (minZ > multvec.z) {
			minZ = multvec.z;
		}
		if (maxZ < multvec.z) {
			maxZ = multvec.z;
		}
		isEmpty = false;
	}

	public function mergeValue(x:Float, y:Float) {
		if (min.x > x) {
			min.x = x;
		}
		if (min.y > y) {
			min.y = y;
		}
		if (max.x < x) {
			max.x = x;
		}
		if (max.y < y) {
			max.y = y;
		}
		isEmpty = false;
	}

	public function addBorderWidth(value:FastFloat) {
		min.x -= value;
		max.x += value;
	}

	public function addBorderHeight(value:FastFloat) {
		min.y -= value;
		max.y += value;
	}

	public function width():Float {
		return max.x - min.x;
	}

	public function height():Float {
		return max.y - min.y;
	}

	public inline function set(left:FastFloat, top:FastFloat, right:FastFloat, bottom:FastFloat) {
		min.x = left;
		min.y = top;
		max.x = right;
		max.y = bottom;
		isEmpty = width() < 0 || height() < 0;
	}

	public inline function setFrom(minMax:MinMax) {
		max.setTo(minMax.max.x, minMax.max.y);
		min.setTo(minMax.min.x, minMax.min.y);
		minZ = -869.1168;
		maxZ = -869.1168;
		isEmpty = width() < 0 || height() < 0;
	}

	public inline function scale(scaleX:Float, scaleY:Float) {
		min.x *= scaleX;
		min.y *= scaleY;
		max.x *= scaleX;
		max.y *= scaleY;
	}

	public inline function contains(minMax:MinMax):Bool {
		return return min.x <= minMax.max.x && minMax.min.x <= max.x && min.y <= minMax.max.y && minMax.min.y <= max.y;
	}

	public inline function offset(x:Float, y:Float):Void {
		min.x += x;
		min.y += y;
		max.x += x;
		max.y += y;
	}

	public inline function flipY(height:Int) {
		var t = height - min.y;
		min.y = height - max.y;
		max.y = t;
	}

	public function inside(x:Float, y:Float) {
		return x > min.x && x < max.x && y > min.y && y < max.y;
	}

	static public function from(left:FastFloat, top:FastFloat, right:FastFloat, bottom:FastFloat):MinMax {
		var minMax:MinMax = new MinMax();
		minMax.set(left, top, right, bottom);
		return minMax;
	}

	static public function fromRec(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):MinMax {
		var minMax:MinMax = new MinMax();
		minMax.set(x, y, x + width, y + height);
		return minMax;
	}
}
