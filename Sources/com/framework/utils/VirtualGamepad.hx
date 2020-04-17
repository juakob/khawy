package com.framework.utils;

import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Surface;
import kha.input.Mouse;

class VirtualGamepad {
	private var width:Int;
	private var height:Int;
	private var scaleX:Float = 1;
	private var scaleY:Float = 1;
	var buttonsTouch:Array<VirtualButton>;
	var sticksTouch:Array<VirtualStick>;

	public var globalStick:VirtualStick;

	var keyButton:Map<KeyCode, Int>;
	var onAxisChange:Int->Float->Void;
	var onButtonChange:Int->Float->Void;

	public function new() {
		Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);
		Keyboard.get().notify(onKeyDown, onKeyUp);
		buttonsTouch = new Array();
		sticksTouch = new Array();
		globalStick = new VirtualStick();
		keyButton = new Map();
	}

	public function destroy() {
		Surface.get().remove(onTouchStart, onTouchEnd, onTouchMove);
		Keyboard.get().remove(onKeyDown, onKeyUp, null);
		onAxisChange = null;
		onButtonChange = null;
	}

	public function clear() {
		onAxisChange = null;
		onButtonChange = null;
	}

	public function addButton(id:Int, x:Float, y:Float, radio:Float) {
		var button = new VirtualButton();
		button.id = id;
		button.x = x;
		button.y = y;
		button.radio = radio;
		buttonsTouch.push(button);
	}

	public function addKeyButton(id:Int, key:KeyCode) {
		keyButton.set(key, id);
	}

	public function addStick(idX:Int, idY:Int, x:Float, y:Float, radio:Float) {
		var stick = new VirtualStick();
		stick.idX = idX;
		stick.idY = idY;
		stick.x = x;
		stick.y = y;
		stick.radio = radio;
		sticksTouch.push(stick);
	}

	public function globalStickData(idX:Int, idY:Int, radio:Float) {
		globalStick.idX = idX;
		globalStick.idY = idY;
		globalStick.radio = radio;
	}

	public function notify(onAxis:Int->Float->Void, onButton:Int->Float->Void):Void {
		onAxisChange = onAxis;
		onButtonChange = onButton;
	}

	function onTouchStart(id:Int, x:Int, y:Int) {
		scaleX = Input.i.screenScale.x;
		scaleY = Input.i.screenScale.y;
		for (button in buttonsTouch) {
			if (button.handleInput(x * scaleX, y * scaleY)) {
				button.active = true;
				button.touchId = id;
				onButtonChange(button.id, 1);
				trace("button active " + id);
				
			}
		}
		for (stick in sticksTouch) {
			if (stick.handleInput(x * scaleX, y * scaleY)) {
				onAxisChange(stick.idX, stick.axisX);
				onAxisChange(stick.idY, stick.axisY);
				stick.active = true;
				stick.touchId = id;
				
			}
		}
		if (!globalStick.active) {
			globalStick.active = true;
			globalStick.x = x * scaleX;
			globalStick.y = y * scaleY;
			globalStick.axisX = 0;
			globalStick.axisY = 0;
			globalStick.touchId = id;
			trace("globalStick active " + id);
		}
	}

	function onTouchMove(id:Int, x:Int, y:Int) {
		scaleX = Input.i.screenScale.x;
		scaleY = Input.i.screenScale.y;
		for (stick in sticksTouch) {
			if (stick.touchId == id) {
				stick.handleInput(x * scaleX, y * scaleY);
				onAxisChange(stick.idX, stick.axisX);
				onAxisChange(stick.idY, stick.axisY);
				stick.active = true;
				return;
			}
		}
		if (globalStick.touchId == id) {
			globalStick.handleInputNoBound(x * scaleX, y * scaleY);
			onAxisChange(globalStick.idX, globalStick.axisX);
			onAxisChange(globalStick.idY, globalStick.axisY);
		}
	}

	function onTouchEnd(id:Int, x:Int, y:Int) {
		for (button in buttonsTouch) {
			if (button.touchId == id) {
				button.active = false;
				onButtonChange(button.id, 0);
				button.touchId = -1;
			
			}
		}
		for (stick in sticksTouch) {
			if (stick.touchId == id) {
				onAxisChange(stick.idX, 0);
				onAxisChange(stick.idY, 0);
				stick.active = false;
				stick.touchId = -1;
			
			}
		}
		if (globalStick.touchId == id) {
			onAxisChange(globalStick.idX, 0);
			onAxisChange(globalStick.idY, 0);
			globalStick.active = false;
			globalStick.touchId = -1;
		
		}
	}

	function onKeyDown(key:KeyCode) {
		if(!keyButton.exists(key))return;
		var id = keyButton.get(key);
		onButtonChange(id, 1);
	}

	function onKeyUp(key:KeyCode) {
		if(!keyButton.exists(key))return;
		var id = keyButton.get(key);
		onButtonChange(id, 0);
	}
}

class VirtualButton {
	public var touchId:Int = -1;
	public var id:Int;
	public var x:Float;
	public var y:Float;
	public var radio:Float;
	public var active:Bool;

	public function new() {}

	public function handleInput(x:Float, y:Float):Bool {
		return (x - this.x) * (x - this.x) + (y - this.y) * (y - this.y) < radio * radio;
	}
}

class VirtualStick {
	public var touchId:Int = -1;
	public var idX:Int;
	public var idY:Int;
	public var x:Float;
	public var y:Float;
	public var radio:Float;
	public var axisX:Float;
	public var axisY:Float;
	public var active:Bool;

	public function new() {}

	public function handleInput(x:Float, y:Float):Bool {
		var sqrDistance = (x - this.x) * (x - this.x) + (y - this.y) * (y - this.y);
		if (sqrDistance < radio * radio) {
			var length = Math.sqrt(sqrDistance);
			axisX = ((x - this.x) / length);
			axisY = ((y - this.y) / length);

			return true;
		}
		return false;
	}

	public function handleInputNoBound(x:Float, y:Float):Bool {
		var sqrDistance = (x - this.x) * (x - this.x) + (y - this.y) * (y - this.y);
		var length = Math.sqrt(sqrDistance);

		if (length > 0) {
			axisX = ((x - this.x) / length);
			axisY = ((y - this.y) / length);
		}

		if (length > radio) {
			this.x = x - axisX * radio;
			this.y = y - axisY * radio;
		}

		return true;
	}
}
