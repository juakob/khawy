package com.framework.utils;

#if INPUT_REC
import com.framework.utils.SaveFile.StreamReader;
#end
import kha.input.Gamepad;
import com.helpers.FastPoint;
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Surface;

#if INPUT_REC
enum InputRecordType {
	KeyDown(key:KeyCode);
	KeyUp(key:KeyCode);
	MouseDown(button:Int,x:Int,y:Int);
	MouseMove(x:Int,y:Int,deltaX:Int,deltaY:Int);
	MouseUp(button:Int,x:Int,y:Int);
}
class InputRecord {
	public var time:Float;
	public var type:InputRecordType;
	public function new(type:InputRecordType) {
		this.type=type;
		time=TimeManager.time;
	}
	public function serialize(stream:BytesBuffer) {
		stream.addFloat(time);
		switch type{
			case KeyDown(key):
				stream.addInt32(1);
				stream.addInt32(cast key);
			case KeyUp(key):
				stream.addInt32(2);
				stream.addInt32(cast key);
			case MouseDown(button, x, y):
				stream.addInt32(3);
				stream.addInt32(button);
				stream.addInt32(x);
				stream.addInt32(y);
			case MouseMove(x, y, deltaX, deltaY):
				stream.addInt32(4);
				stream.addInt32(x);
				stream.addInt32(y);
				stream.addInt32(deltaX);
				stream.addInt32(deltaY);
			case MouseUp(button, x, y):
				stream.addInt32(5);
				stream.addInt32(button);
				stream.addInt32(x);
				stream.addInt32(y);
		}
	}
	public static function fromStream(stream:StreamReader):InputRecord {
		var timeStamp=stream.readFloat();
		var id:Int=stream.readInt32();
		var type:InputRecordType=
		switch (id){
			case 1:
				KeyDown(cast stream.readInt32());
			case 2:
				KeyUp(cast stream.readInt32());
			case 3:
				MouseDown(stream.readInt32(), stream.readInt32(), stream.readInt32());
			case 4:
				MouseMove(stream.readInt32(), stream.readInt32(), stream.readInt32(), stream.readInt32());
			case 5:
				MouseUp(stream.readInt32(), stream.readInt32(), stream.readInt32());
			default:
				throw "input id error";
		}
		var record=new InputRecord(type);
		record.time=timeStamp;
		return record;
	}
}
#end

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
	private var mouseLeftIsDown:Bool;
	private var mouseLeftPressed:Bool;
	private var mouseLeftReleased:Bool;
	private var keysDown:Array<Int>;
	private var keysPressed:Array<Int>;
	private var keysReleased:Array<Int>;
	private var touchPos:Array<Int>;
	private var touchActive:Array<Int>;
	public var mouseDeltaX:Float = 0;
	public var mouseDeltaY:Float = 0;
	public var mouseWheelDelta:Int = 0;
	private var mousePosition:FastPoint;

	private var t_mouseIsDown:Bool;
	private var t_mousePressed:Bool;
	private var t_mouseReleased:Bool;
	private var t_mouseLeftIsDown:Bool;
	private var t_mouseLeftPressed:Bool;
	private var t_mouseLeftReleased:Bool;
	private var t_keysDown:Array<Int>;
	private var t_keysPressed:Array<Int>;
	private var t_keysReleased:Array<Int>;
	private var t_touchPos:Array<Int>;
	private var t_touchActive:Array<Int>;
	public var t_mouseDeltaX:Float = 0;
	public var t_mouseDeltaY:Float = 0;
	public var t_mouseWheelDelta:Int = 0;
	private var t_mousePosition:FastPoint;

	public var activeTouchSpots(default, null):Int;

	public var uiCapture:Bool;

	var joysticks:Array<JoystickProxy>;
	

	static public inline var TOUCH_MAX:Int = 6;

	public var screenScale(default, null):FastPoint;

	private var onKeyDownSubscribers:Array<KeyCode->Void>;
	private var onKeyUpSubscribers:Array<KeyCode->Void>;
	
	#if INPUT_REC
	var records:Array<InputRecord>=new Array();
	var record:Bool=false;
	var playback:Bool=false;
	var playbackIndex:Int=0;
	#end

	public function new() {
		screenScale = new FastPoint(1, 1);

		mouseIsDown = false;
		mousePressed = false;
		mouseReleased = false;

		mouseLeftIsDown = false;
		mouseLeftPressed = false;
		mouseLeftReleased = false;

		keysDown = new Array();
		keysPressed = new Array();
		keysReleased = new Array();

		t_keysDown = new Array();
		t_keysPressed = new Array();
		t_keysReleased = new Array();

		onKeyDownSubscribers = new Array();
		onKeyUpSubscribers = new Array();

		activeTouchSpots = 0;

		touchActive = new Array();
		touchPos = new Array();
		t_touchActive = new Array();
		t_touchPos = new Array();

		for (i in 0...TOUCH_MAX) {
			touchPos.push(0);
			touchPos.push(0);
			t_touchPos.push(0);
			t_touchPos.push(0);
		}

		mousePosition = new FastPoint();
		t_mousePosition = new FastPoint();

		joysticks = new Array();
	}

	public function getGamepad(index:Int):JoystickProxy {
		return joysticks[index];
	}

	private function subscibeInput() {
		Keyboard.get().notify(onKeyDown, onKeyUp);
		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
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
		if (id == 0) {
			t_mousePosition.setTo(x, y);
		}
	}

	function onTouchEnd(id:Int, x:Int, y:Int) {
		t_touchActive.remove(id);
		t_touchPos[id * 2] = x;
		t_touchPos[id * 2 + 1] = y;
		--activeTouchSpots;
		t_mousePosition.setTo(x, y);
		if (id == 0) {
			t_mouseIsDown = false;
			t_mouseReleased = true;
		}else
		if (id == 1) {
			t_mouseLeftIsDown = false;
			t_mouseLeftReleased = true;
		}
	}

	function onTouchStart(id:Int, x:Int, y:Int) {
		++activeTouchSpots;
		t_touchActive.push(id);
		t_touchPos[id * 2] = x;
		t_touchPos[id * 2 + 1] = y;
		t_mousePosition.setTo(x, y);
		if (id == 0) {
			t_mouseIsDown = true;
			t_mousePressed = true;
		}else
		if (id == 1) {
			t_mouseLeftIsDown = true;
			t_mouseLeftPressed = true;
		}
	}

	function onMouseMove(x:Int, y:Int, moveX:Int, moveY:Int):Void {
		t_touchPos[0] = x;
		t_touchPos[1] = y;
		t_mousePosition.x = x;
		t_mousePosition.y = y;
		t_mouseDeltaX = moveX;
		t_mouseDeltaY = moveY;
		#if INPUT_REC
		if(record) records.push(new InputRecord(MouseMove(x,y,moveX,moveY)));
		#end
	}

	function onMouseWheel(delta:Int):Void {
		t_mouseWheelDelta += delta;
	}

	function onMouseUp(button:Int, x:Int, y:Int):Void {
		t_touchActive.remove(0);
		--activeTouchSpots;
		t_mousePosition.x = x;
		t_mousePosition.y = y;
		if(button ==0 ){
			t_mouseReleased = true;
			t_mouseIsDown = false;
		}else
		if(button==1){
			t_mouseLeftReleased = true;
			t_mouseLeftIsDown = false;
		}
		
		#if INPUT_REC
		if(record) records.push(new InputRecord(MouseUp(button,x,y)));
		#end
	}

	function onMouseDown(button:Int, x:Int, y:Int):Void {
		++activeTouchSpots;
		t_touchActive.push(0);
		t_touchPos[0] = x;
		t_touchPos[1] = y;
		t_mousePosition.x = x;
		t_mousePosition.y = y;
		if(button ==0 ){
			t_mousePressed = t_mouseIsDown = true;
		}else
		if(button==1){
			t_mouseLeftPressed = t_mouseLeftIsDown = true;
		}
		#if INPUT_REC
		if(record) records.push(new InputRecord(MouseDown(button,x,y)));
		#end
	}

	function onKeyDown(key:KeyCode):Void {
		if (t_keysDown.indexOf(cast key) == -1) {
			t_keysDown.push(cast key);
			t_keysPressed.push(cast key);
		}
		for(listener in onKeyDownSubscribers){
			listener(key);
		}
		#if INPUT_REC
		if(record) records.push(new InputRecord(KeyDown(key)));
		#end
	}

	function onKeyUp(key:KeyCode):Void {
		var vIndex:Int = t_keysDown.indexOf(cast key);
		if (vIndex != -1) {
			t_keysDown.splice(vIndex, 1);
		}
		t_keysReleased.push(cast key);
		
		for(listener in onKeyUpSubscribers){
			listener(key);
		}
		#if INPUT_REC
		if(record) records.push(new InputRecord(KeyUp(key)));
		#end
	}

	public function lockMouse() {
		Mouse.get().lock();
	}

	public function unlockMouse() {
		Mouse.get().unlock();
	}

	public function isMouseLock():Bool {
		return Mouse.get().isLocked();
	}

	public function update():Void {
		mousePressed = t_mousePressed;
		mouseReleased = t_mouseReleased;
		mouseIsDown = t_mouseIsDown;

		mouseLeftPressed = t_mouseLeftPressed;
		mouseLeftReleased = t_mouseLeftReleased;
		mouseLeftIsDown = t_mouseLeftIsDown;

		t_mousePressed = false;
		t_mouseReleased = false;

		t_mouseLeftPressed = false;
		t_mouseLeftReleased = false;

		keysPressed.splice(0, keysPressed.length);
		keysReleased.splice(0, keysReleased.length);
		for (i in 0...t_keysPressed.length){
			keysPressed.push(t_keysPressed[i]);
		}
		for (i in 0...t_keysReleased.length){
			keysReleased.push(t_keysReleased[i]);
		}

		t_keysPressed.splice(0, keysPressed.length);
		t_keysReleased.splice(0, keysReleased.length);

		for (joystick in joysticks) {
			joystick.update();
		}

		mouseDeltaX = t_mouseDeltaX;
		mouseDeltaY = t_mouseDeltaY;
		mouseWheelDelta = t_mouseWheelDelta;
		
		t_mouseDeltaX = 0;
		t_mouseDeltaY = 0;
		t_mouseWheelDelta = 0;
		mousePosition.setTo(t_mousePosition.x,t_mousePosition.y);
	}
	#if INPUT_REC
	public function updatePlayeback() {
		if(playback){
			while(playbackIndex<records.length && TimeManager.time>=records[playbackIndex].time)
			{
				switch (records[playbackIndex].type){
					case KeyDown(key):
						onKeyDown(key);
					case KeyUp(key):
						onKeyUp(key);
					case MouseMove(x, y, deltaX, deltaY):
						onMouseMove(x,y,deltaX,deltaY);
					case MouseDown(button,x, y):
						onMouseDown(button,x,y);
					case MouseUp(button,x, y):
						onMouseUp(button,x,y);
				}
					++playbackIndex;
			}
		}
	}
	
	public function serializeInputRecord() {
		var data:BytesBuffer=new BytesBuffer();
		data.addInt32(records.length);
		for(record in records){
			record.serialize(data);
		}
		return data;
	}
	public function loadRecord(stream:StreamReader) {
		records.splice(0,records.length);
		var recordCount=stream.readInt32();
		for(i in 0...recordCount){
			records.push(InputRecord.fromStream(stream));
		}
	}

	public function startRecord() {
		records.splice(0,records.length);
		record=true;
		playback=false;
	}
	public function stopRecord() {
		record=false;
	}
	public function playRecord() {
		playback=true;
		playbackIndex=0;
		record=false;
	}
	#end

	public function clearInput() {
		mousePressed = false;
		mouseReleased = false;
		mouseWheelDelta = 0;
		t_mouseWheelDelta = 0;
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

	public function isMouseLeftDown():Bool {
		return mouseLeftIsDown;
	}

	public function isMouseLeftPressed():Bool {
		return mouseLeftPressed;
	}

	public function isMouseLeftReleased():Bool {
		return mouseLeftReleased;
	}

	public inline function getMouseX():Float {
		return mousePosition.x ;
	}

	public inline function getMouseY():Float {
		return mousePosition.y ;
	}

	public inline function getMouseWheelDelta():Int {
		return mouseWheelDelta;
	}

	public inline function touchX(id:Int):Float {
		return touchPos[id * 2] ;
	}

	public inline function touchY(id:Int):Float {
		return touchPos[id * 2 + 1] ;
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

	public function subscribeKeyboard(onKeyDown:KeyCode->Void,onKeyUp:KeyCode->Void) {
		onKeyDownSubscribers.push(onKeyDown);
		onKeyUpSubscribers.push(onKeyUp);
	}
	public function unsubscribeKeyboard(onKeyDown:KeyCode->Void,onKeyUp:KeyCode->Void) {
		onKeyDownSubscribers.remove(onKeyDown);
		onKeyUpSubscribers.remove(onKeyUp);
	}
}

