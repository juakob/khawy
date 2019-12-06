package com.framework.utils;

import kha.input.Gamepad;

class JoystickProxy {
	var buttons:Array<Float>;
	var axes:Array<Float>;
	var pressed:Array<Int>;
	var released:Array<Int>;
	var gamepad:Gamepad;
	var onAxisChange:Int->Float->Void;
	var onButtonChange:Int->Float->Void;
	var id:Int;

	public var active(default, null):Bool;

	public function new(id:Int) {
		this.id = id;
		buttons = new Array();
		axes = new Array();
		pressed = new Array();
		released = new Array();

		onConnect();
		// add more than needed just to be safe
		for (i in 0...20) {
			buttons.push(0);
		}
		for (i in 0...7) {
			axes.push(0);
		}
	}

	public function notify(onAxisChange:Int->Float->Void, onButtonChange:Int->Float->Void) {
		this.onAxisChange = onAxisChange;
		this.onButtonChange = onButtonChange;
	}

	public function onConnect() {
		if (!active) {
			gamepad = Gamepad.get(id);
			if (gamepad != null) {
				gamepad.notify(onAxis, onButton);
				active = true;
			}
		}
	}

	public function onDisconnect() {
		if (active) {
			gamepad = Gamepad.get(id);
			if (gamepad != null) {
				gamepad.remove(onAxis, onButton);
				active = false;
			}
		}
	}

	function onAxis(id:Int, value:Float) {
		axes[id] = value;
		if (onAxisChange != null)
			onAxisChange(id, value);
	}

	function onButton(id:Int, value:Float) {
		buttons[id] = value;
		if (value == 0) {
			released.push(id);
		} else {
			pressed.push(id);
		}
		if (onButtonChange != null)
			onButtonChange(id, value);
	}

	public function update() {
		released.splice(0, released.length);
		pressed.splice(0, pressed.length);
	}

	public function clearInput() {
		released.splice(0, released.length);
		pressed.splice(0, pressed.length);
		for (i in 0...buttons.length) {
			buttons[i] = 0;
		}
		onButtonChange = null;
		onAxisChange = null;
	}

	public function buttonPressed(id:Int):Bool {
		for (i in pressed) {
			if (i == id)
				return true;
		}
		return false;
	}

	public function buttonReleased(id:Int):Bool {
		for (i in released) {
			if (i == id)
				return true;
		}
		return false;
	}

	public function buttonDown(id:Int):Bool {
		return buttons[id] == 1;
	}

	public function axis(id:Int):Float {
		return axes[id];
	}
}
