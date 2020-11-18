package com.framework.utils;

#if INPUT_REC
import com.framework.utils.SaveFile.StreamReader;
#end
import haxe.io.BytesBuffer;
import com.g3d.OgexData.Key;
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
	private var keysDown:Array<Int>;
	private var keysPressed:Array<Int>;
	private var keysReleased:Array<Int>;
	private var touchPos:Array<Int>;
	private var touchActive:Array<Int>;

	public var mouseDeltaX:Float = 0;
	public var mouseDeltaY:Float = 0;
	public var activeTouchSpots(default, null):Int;

	var joysticks:Array<JoystickProxy>;
	private var mousePosition:FastPoint;

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

		keysDown = new Array();
		keysPressed = new Array();
		keysReleased = new Array();

		onKeyDownSubscribers = new Array();
		onKeyUpSubscribers = new Array();

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
		if (id == 0) {
			mousePosition.setTo(x, y);
		}
	}

	function onTouchEnd(id:Int, x:Int, y:Int) {
		touchActive.remove(id);
		touchPos[id * 2] = x;
		touchPos[id * 2 + 1] = y;
		--activeTouchSpots;
		if (id == 0) {
			mousePosition.setTo(x, y);
			mouseIsDown = false;
			mouseReleased = true;
		}
	}

	function onTouchStart(id:Int, x:Int, y:Int) {
		++activeTouchSpots;
		touchActive.push(id);
		touchPos[id * 2] = x;
		touchPos[id * 2 + 1] = y;
		if (id == 0) {
			mousePosition.setTo(x, y);
			mouseIsDown = true;
			mousePressed = true;
		}
	}

	function onMouseMove(x:Int, y:Int, moveX:Int, moveY:Int):Void {
		touchPos[0] = x;
		touchPos[1] = y;
		mousePosition.x = x;
		mousePosition.y = y;
		mouseDeltaX = moveX;
		mouseDeltaY = moveY;
		#if INPUT_REC
		if(record) records.push(new InputRecord(MouseMove(x,y,moveX,moveY)));
		#end
	}

	function onMouseUp(button:Int, x:Int, y:Int):Void {
		touchActive.remove(0);
		--activeTouchSpots;
		mousePosition.x = x;
		mousePosition.y = y;
		mouseReleased = (button == 0);
		mouseIsDown = !(button == 0);
		#if INPUT_REC
		if(record) records.push(new InputRecord(MouseUp(button,x,y)));
		#end
	}

	function onMouseDown(button:Int, x:Int, y:Int):Void {
		++activeTouchSpots;
		touchActive.push(0);
		touchPos[0] = x;
		touchPos[1] = y;
		mousePosition.x = x;
		mousePosition.y = y;
		mousePressed = mouseIsDown = (button == 0);
		#if INPUT_REC
		if(record) records.push(new InputRecord(MouseDown(button,x,y)));
		#end
	}

	function onKeyDown(key:KeyCode):Void {
		if (keysDown.indexOf(cast key) == -1) {
			keysDown.push(cast key);
			keysPressed.push(cast key);
		}
		for(listener in onKeyDownSubscribers){
			listener(key);
		}
		#if INPUT_REC
		if(record) records.push(new InputRecord(KeyDown(key)));
		#end
	}

	function onKeyUp(key:KeyCode):Void {
		var vIndex:Int = keysDown.indexOf(cast key);
		if (vIndex != -1) {
			keysDown.splice(vIndex, 1);
		}
		keysReleased.push(cast key);
		
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
		mousePressed = false;
		mouseReleased = false;

		keysPressed.splice(0, keysPressed.length);
		keysReleased.splice(0, keysReleased.length);

		for (joystick in joysticks) {
			joystick.update();
		}
		mouseDeltaX = 0;
		mouseDeltaY = 0;
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

	public function subscribeKeyboard(onKeyDown:KeyCode->Void,onKeyUp:KeyCode->Void) {
		onKeyDownSubscribers.push(onKeyDown);
		onKeyUpSubscribers.push(onKeyUp);
	}
	public function unsubscribeKeyboard(onKeyDown:KeyCode->Void,onKeyUp:KeyCode->Void) {
		onKeyDownSubscribers.remove(onKeyDown);
		onKeyUpSubscribers.remove(onKeyUp);
	}
}

