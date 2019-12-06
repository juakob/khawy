package com.gEngine.painters;

import kha.math.FastMatrix4;
import com.helpers.MinMax;
import kha.arrays.Float32Array;
import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureFilter;

interface IPainter {
	function write(value:Float):Void;
	function start():Void;
	function finish():Void;
	function render(clear:Bool = false, area:MinMax = null):Void;
	function canBatch(info:PaintInfo, size:Int):Bool;
	function vertexCount():Int;
	function releaseTexture():Bool;
	function adjustRenderArea(area:MinMax):Void;
	function getVertexBuffer():Float32Array;
	function getVertexDataCounter():Int;
	function setVertexDataCounter(data:Int):Void;
	function destroy():Void;
	function setProjection(proj:FastMatrix4):Void;
	var textureID:Int;
	var resolution:Float;
	var filter:TextureFilter;
	var mipMapFilter:MipMapFilter;
}
