package com.framework.utils;

class TouchButtonRound extends Entity {
	public var x(default, default):Float;
	public var y(default, default):Float;
	public var radio(default, set):Float;

	var sqRadio:Float;
	var touchId:Int = -1;

	public var onRelease:TouchButtonRound->Void;
	public var onTouch:TouchButtonRound->Void;
	public var userData:Dynamic;

	public function new(x:Float = 0, y:Float = 0, radio:Float = 0) {
		super();
		this.x = x;
		this.y = y;
		this.radio = radio;
	}

	public function set_radio(radio:Float):Float {
		this.radio = radio;
		sqRadio = radio * radio;
		return radio;
	}

	override public function update(dt:Float):Void {
		super.update(dt);
		if (touchId >= 0) {
			if (!Input.i.touchActive(touchId) || !isTouching(touchId)) {
				if (onRelease != null) {
					onRelease(this);
				}
				touchId = -1;
			}
		} else if (Input.i.activeTouchSpots > 0) {
			for (i in 0...Input.TOUCH_MAX) {
				if (Input.i.touchActive(i)) {
					if (isTouching(i)) {
						touchId = i;
						if (onTouch != null) {
							onTouch(this);
						}
						break;
					}
				}
			}
		}
	}

	private inline function isTouching(id:Int):Bool {
		var deltaX:Float = x - Input.i.touchX(id);
		var deltaY:Float = y - Input.i.touchY(id);
		return deltaX * deltaX + deltaY * deltaY < sqRadio;
	}
}
