package com.helpers;

import kha.FastFloat;

class FastPoint {
	public var x:FastFloat;
	public var y:FastFloat;

	public function new(x:FastFloat = 0, y:FastFloat = 0) {
		this.x = x;
		this.y = y;
	}

	public function clone():FastPoint {
		return new FastPoint(x, y);
	}

	public inline function setTo(x:FastFloat = 0, y:FastFloat = 0):Void {
		this.x = x;
		this.y = y;
	}
}
