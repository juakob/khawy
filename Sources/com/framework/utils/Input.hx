package com.framework.utils;

import kha.input.Gamepad;
import com.helpers.FastPoint;
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Surface;

class Input {
	public static var i(default, null):Input = null;
	public static var inst(get, null):Input = null;

	public static function get_inst():Input {
		return i;
	}

	public static function init():Void {
		i = new Input();
		i.subscibeInput();
	}

	private var mouseIsDown:Bool;
	private var mousePressed:Bool;
	private var mouseReleased:Bool;
	private var keysDown:Array<Int>;
	private var keysPressed:Array<Int>;
	private var keysReleased:Array<Int>;
	private var touchPos:Array<Int>;
	private var touchActive:Array<Int>;

	public var activeTouchSpots(default, null):Int;

	var joysticks:Array<JoystickProxy>;
	private var mousePosition:FastPoint;

	static public inline var TOUCH_MAX:Int = 6;

	public var screenScale(default, null):FastPoint;

	public function new() {
		screenScale = new FastPoint(1, 1);

		mouseIsDown = false;
		mousePressed = false;
		mouseReleased = false;

		keysDown = new Array();
		keysPressed = new Array();
		keysReleased = new Array();

		activeTouchSpots = 0;
		touchActive = new Array();
		touchPos = new Array();
		for (i in 0...TOUCH_MAX) {
			touchPos.push(0);
			touchPos.push(0);
		}

		mousePosition = new FastPoint();

		joysticks = new Array();
	}

	public function getGamepad(index:Int):JoystickProxy {
		return joysticks[index];
	}

	private function subscibeInput() {
		Keyboard.get().notify(onKeyDown, onKeyUp);
		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		var surface = Surface.get();
		if (surface != null) {
			surface.notify(onTouchStart, onTouchEnd, onTouchMove);
		}
		for (j in 0...4) {
			joysticks.push(new JoystickProxy(j));
		}
		Gamepad.notifyOnConnect(onConnect, onDisconnect);
	}

	function onConnect(aId:Int) {
		trace("gamepad " + aId);
		joysticks[aId].onConnect();
	}

	function onDisconnect(gamePad:Int) {
		joysticks[gamePad].onDisconnect();
	}

	function onTouchMove(id:Int, x:Int, y:Int) {
		touchPos[id * 2] = x;
		touchPos[id * 2 + 1] = y;
		if(id==0){
			mousePosition.setTo(x,y);
		}
	}

	function onTouchEnd(id:Int, x:Int, y:Int) {
		touchActive.remove(id);
		--activeTouchSpots;
		if(id==0){
			mousePosition.setTo(x,y);
			mouseIsDown=false;
		}
	}

	function onTouchStart(id:Int, x:Int, y:Int) {
		++activeTouchSpots;
		touchActive.push(id);
		touchPos[id * 2] = x;
		touchPos[id * 2 + 1] = y;
		if(id==0){
			mousePosition.setTo(x,y);
			mouseIsDown=true;
		}
	}

	function onMouseMove(x:Int, y:Int, speedX:Int, speedY:Int):Void {
		mousePosition.x = x;
		mousePosition.y = y;
	}

	function onMouseUp(button:Int, x:Int, y:Int):Void {
		mousePosition.x = x;
		mousePosition.y = y;
		mouseReleased = (button == 0);
		mouseIsDown = !(button == 0);
	}

	function onMouseDown(button:Int, x:Int, y:Int):Void {
		mousePosition.x = x;
		mousePosition.y = y;
		mousePressed = mouseIsDown = (button == 0);
	}

	function onKeyDown(key:KeyCode):Void {
		if (keysDown.indexOf(cast key) == -1) {
			keysDown.push(cast key);
			keysPressed.push(cast key);
		}
	}

	function onKeyUp(key:KeyCode):Void {
		var vIndex:Int = keysDown.indexOf(cast key);
		if (vIndex != -1) {
			keysDown.splice(vIndex, 1);
		}
		keysReleased.push(cast key);
	}

	public function update():Void {
		mousePressed = false;
		mouseReleased = false;

		keysPressed.splice(0, keysPressed.length);
		keysReleased.splice(0, keysReleased.length);

		for (joystick in joysticks) {
			joystick.update();
		}
	}

	public function clearInput() {
		mousePressed = false;
		mouseReleased = false;
		activeTouchSpots = 0;

		keysPressed.splice(0, keysPressed.length);
		keysReleased.splice(0, keysReleased.length);
		keysDown.splice(0, keysDown.length);

		for (joystick in joysticks) {
			joystick.clearInput();
		}
	}

	public function isKeyCodeDown(keyCode:KeyCode):Bool {
		return keysDown.indexOf(cast keyCode) != -1;
	}

	public function isKeyCodePressed(keyCode:KeyCode):Bool {
		return keysPressed.indexOf(cast keyCode) != -1;
	}

	public function isKeyCodeReleased(keyCode:KeyCode):Bool {
		return keysReleased.indexOf(cast keyCode) != -1;
	}

	public function isMouseDown():Bool {
		return mouseIsDown;
	}

	public function isMousePressed():Bool {
		return mousePressed;
	}

	public function isMouseReleased():Bool {
		return mouseReleased;
	}

	public inline function getMouseX():Float {
		return mousePosition.x * screenScale.x;
	}

	public inline function getMouseY():Float {
		return mousePosition.y * screenScale.y;
	}

	public inline function touchX(id:Int):Float {
		return touchPos[id * 2] * screenScale.x;
	}

	public inline function touchY(id:Int):Float {
		return touchPos[id * 2 + 1] * screenScale.y;
	}

	public inline function isTouchActive(id:Int):Bool {
		return touchActive.indexOf(id) != -1;
	}

	public inline function activeTouches():Array<Int> {
		return touchActive;
	}

	public function buttonDown(joystickId:Int, buttonId:Int):Bool {
		return joysticks[joystickId].buttonDown(buttonId);
	}

	public function buttonPressed(joystickId:Int, buttonId:Int):Bool {
		return joysticks[joystickId].buttonPressed(buttonId);
	}

	public function buttonReleased(joystickId:Int, buttonId:Int):Bool {
		return joysticks[joystickId].buttonReleased(buttonId);
	}

	public function axis(joystickId:Int, buttonId:Int):Float {
		return joysticks[joystickId].axis(buttonId);
	}
}
