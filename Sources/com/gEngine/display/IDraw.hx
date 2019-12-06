package com.gEngine.display;

import com.gEngine.painters.PaintMode;
import com.helpers.MinMax;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;

interface IDraw {
	public var x:FastFloat;
	public var y:FastFloat;
	public var z:FastFloat;
	public var offsetX:FastFloat;
	public var offsetY:FastFloat;
	// public var rotation(default, set):Float;
	public var scaleX:FastFloat;
	public var scaleY:FastFloat;
	public var scaleZ:FastFloat;
	public var parent:IContainer;
	public var visible:Bool;
	function render(paintMode:PaintMode, transform:FastMatrix4):Void;
	function update(elapsedTime:Float):Void;
	function removeFromParent():Void;
	function getDrawArea(value:MinMax, transform:FastMatrix4):Void;
	function getTransformation():FastMatrix3;
	function getFinalTransformation():FastMatrix3;
}
