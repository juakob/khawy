package com.helpers;

class Rectangle {
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function clone():Rectangle {
		return new Rectangle(x, y, width, height);
	}

	public function contains(mouseX:Float, mouseY:Float):Bool {
		return mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height;
	}
}
