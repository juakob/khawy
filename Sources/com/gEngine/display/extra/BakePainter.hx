package com.gEngine.display.extra;

import kha.math.FastMatrix4;
import kha.arrays.Float32Array;
import com.gEngine.painters.PaintInfo;
import kha.graphics5_.MipMapFilter;
import kha.graphics5_.TextureFilter;
import com.helpers.MinMax;
import com.gEngine.painters.IPainter;

class BakePainter implements IPainter {
    public var textureID:Int;
	public var resolution:Float;
	public var filter:TextureFilter;
    public var mipMapFilter:MipMapFilter;
    public var vertexBuffer:Float32Array;
    var counter:Int=0;

    public function new(vertexBuffer:Float32Array) {
        this.vertexBuffer=vertexBuffer;
    }
    
    public function write(value:Float):Void{
        vertexBuffer.set(counter++, value);
    }
	public function start():Void{}
	public function finish():Void{}
	public function render(clear:Bool = false, area:MinMax = null):Void{}
	public function canBatch(info:PaintInfo, size:Int):Bool{
        return true;
    }
	public function vertexCount():Int{
        return 0;
    }
	public function releaseTexture():Bool{
        return true;
    }
	public function adjustRenderArea(area:MinMax):Void{}
	public function getVertexBuffer():Float32Array{
        return vertexBuffer;
    }
	public function getVertexDataCounter():Int{
        return counter;
    }
	public function setVertexDataCounter(data:Int):Void{
        counter=data;
    }
	public function destroy():Void{}
	public function setProjection(proj:FastMatrix4):Void{}
}