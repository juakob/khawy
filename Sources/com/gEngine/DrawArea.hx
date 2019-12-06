package com.gEngine;

class DrawArea {
	public var minX:Float;
	public var minY:Float;
	public var maxY:Float;
	public var maxX:Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;

	public function new(minX:Float, minY:Float, maxX:Float, maxY:Float) {
		this.minX = minX;
		this.minY = minY;
		this.maxY = maxY;
		this.maxX = maxX;
	}

	public function clone():DrawArea {
		return new DrawArea(minX, minY, maxX, maxY);
	}

	public function get_x():Float {
		return minX;
	}

	public function set_x(value:Float):Float {
		var delta = value - minX;
		minX = value;
		maxX = maxX + delta;
		return minX;
	}

	public function get_y():Float {
		return minY;
	}

	public function set_y(value:Float):Float {
		var delta = value - minY;
		minY = value;
		maxY = maxY + delta;
		return minY;
	}

	public function get_width():Float {
		return maxX - minX;
	}

	public function set_width(value:Float):Float {
		maxX = minX + value;
		return maxX;
	}

	public function get_height():Float {
		return maxY - minY;
	}

	public function set_height(value:Float):Float {
		maxY = minY + value;
		return maxY;
	}
}
