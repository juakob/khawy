package com.helpers;

import kha.FastFloat;

class Point {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
	}

	public function clone():Point {
		return new Point(x, y);
	}

	public inline function setTo(x:Float = 0, y:Float = 0):Void {
		this.x = x;
		this.y = y;
	}

	public inline function length():Float {
		return Math.sqrt(x * x + y * y);
	}

	public inline function normalize():Void {
		var length = length();
		x /= length;
		y /= length;
	}

	public static inline function Lerp(A:Float, B:Float, s:Float):Float {
		return A * (1 - s) + B * s;
	}

	public static inline function Length(A:Point, B:Point):Float {
		var deltaX:Float = A.x - B.x;
		var deltaY:Float = A.y - B.y;
		return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
	}
}
