package com.gEngine.display;

import com.gEngine.painters.PolyPainter;
import kha.math.FastVector3;
import kha.arrays.Float32Array;
import kha.Color;
import com.gEngine.display.Blend;
import kha.math.FastMatrix3;
import com.helpers.MinMax;
import com.gEngine.display.IContainer;
import kha.FastFloat;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;
import com.gEngine.display.DisplayObject;
import js.lib.intl.Collator.Usage;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics5_.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;


class Polygon implements DisplayObject {

    public var x:FastFloat;
	public var y:FastFloat;
	public var z:FastFloat;
	public var offsetX:FastFloat;
	public var offsetY:FastFloat;
	public var rotation(default, set):Float;
	public var scaleX:FastFloat;
	public var scaleY:FastFloat;
	public var scaleZ:FastFloat;
	public var parent:IContainer;
	public var visible:Bool;

    var vertexBuffer:VertexBuffer;
    var indexBuffer:IndexBuffer;

    var vertex:Float32Array;
    var counter:Int=0;
    public var color:Color=Color.Red;

    static var painter:PolyPainter;

    public function new() {
        var vertexStructure:VertexStructure=new VertexStructure();
        vertexStructure.add("pos",VertexData.Float3);
        vertexBuffer= new VertexBuffer(1000,vertexStructure,Usage.DynamicUsage);
        indexBuffer=new IndexBuffer(1000*3,Usage.StaticUsage);
        var index=indexBuffer.lock();
        for(i in 0...1000*3){
            index.set(i,i);
        }
        indexBuffer.unlock();
        if(painter==null){
            painter=new PolyPainter(Blend.blendDefault());
        }
    }
    public function start() {
        counter=0;
        vertex=vertexBuffer.lock();
    }
    inline public function addTriangle(a:FastVector3,b:FastVector3,c:FastVector3) {
        vertex.set(counter++,a.x);
        vertex.set(counter++,a.y);
        vertex.set(counter++,a.z);
        
        vertex.set(counter++,b.x);
        vertex.set(counter++,b.y);
        vertex.set(counter++,b.z);

        vertex.set(counter++,c.x);
        vertex.set(counter++,c.y);
        vertex.set(counter++,c.z);
    }
    public function end() {
        vertexBuffer.unlock(counter); 
    }
    public function set_rotation(angle:Float):Float {
        return angle;
    }
    public function render(paintMode:PaintMode, transform:FastMatrix4):Void{
        paintMode.render();
        painter.setRenderInfo(paintMode.camera.projection.multmat(transform),vertexBuffer,indexBuffer,color,Std.int(counter/3));
        painter.render();
    }
	public function update(elapsedTime:Float):Void{}
	public function removeFromParent():Void{}
	public function getDrawArea(value:MinMax, transform:FastMatrix4):Void{}
	public function getTransformation():FastMatrix3{return null;}
	public function getFinalTransformation():FastMatrix3{return null;}
}