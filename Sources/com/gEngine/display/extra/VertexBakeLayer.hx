package com.gEngine.display.extra;

import kha.graphics4.VertexBuffer;
import kha.graphics4.CullMode;
import kha.graphics4.TextureFilter;
import kha.graphics4.PipelineState;
import kha.Color;
import kha.graphics5_.TextureAddressing;
import com.helpers.MinMax;
import com.gEngine.painters.Painter;
import kha.graphics4.Usage;
import kha.graphics4.IndexBuffer;
import com.gEngine.painters.PainterColorTransform;
import kha.math.FastMatrix4;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.PaintInfo;
import com.gEngine.painters.PaintMode;

class VertexBakeLayer extends Layer {
    public var painter(default,set):VertexBakePainter;
    var baked:Bool=false;

    public function bake() {
        baked=false;
        var vertexCount=countVertexLayer(this);
        painter=new VertexBakePainter(vertexCount);
        
        var bakePainter=new BakePainter(painter.getVertexBuffer());
        var paintMode=new BakePaintMode(bakePainter);
        paintMode.camera=new Camera(1,1);
        render(paintMode,FastMatrix4.identity());
        painter.textureID=paintMode.textureId;
        painter.upload();
        baked=true;
        painter.filter=TextureFilter.PointFilter;
    }
    function set_painter(painter:VertexBakePainter):VertexBakePainter {
        if(this.painter!=null){
            painter.textureID=this.painter.textureID;
            painter.setBuffers(this.painter);
        }
        this.painter=painter;
        return painter;
    }
    function countVertexLayer(layer:Layer):Int {
        var count:Int=0;
        for(child in layer.children){
            if(Std.is(child,Layer)){
                count+=countVertexLayer(cast child);
            }
            count+=4;
        }
        return count;
    }
    override function update(passedTime:Float) {
    }
    override function render(paintMode:PaintMode, transform:FastMatrix4) {
        if(baked){
            paintMode.render();
            this.transform.setFrom(paintMode.camera.projection.multmat(transform));
            painter.setProjection(this.transform);
            painter.render();
        }else{
            super.render(paintMode,transform);
        }
    }
}
class BakePaintMode extends PaintMode {
    public var textureId:Int=-1;
    public function new(painter:IPainter) {
        super();
        currentPainter=painter;
    }
    override function changePainter(painter:IPainter, paintInfo:PaintInfo) {
        
    }
    override function canBatch(info:PaintInfo, size:Int, painter:IPainter):Bool {
        textureId= info.texture;
        return true;
    }
}
class VertexBakePainter extends PainterColorTransform {
    var size:Int=0;
    public function new(size:Int=0) {
        this.size=size;
        super(true,Blend.blendDefault(),true);
        
    }
    public function upload() {
        uploadVertexBuffer(size);
    }
    public function setBuffers(painter:VertexBakePainter) {
        this.vertexBuffer=painter.vertexBuffer;
        this.indexBuffer=painter.indexBuffer;
    }
    override function  setShaders(pipeline:PipelineState) {
        super.setShaders(pipeline);
        pipeline.cullMode=CullMode.Clockwise;
    }
    override function render(clear:Bool = false, cropArea:MinMax = null) {
       
		var canvas = GEngine.i.currentCanvas();
		canvasWidth = canvas.width;
		canvasHeight = canvas.height;
		var g = canvas.g4;
		// Begin rendering
		// Clear screen
		if (clear)
			g.clear(Color.fromFloats(red, green, blue, alpha), 1);
		// Bind data we want to draw
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		// Bind state we want to draw with
		g.setPipeline(pipeline);

		setParameter(g);
		g.setTextureParameters(textureConstantID, TextureAddressing.Clamp, TextureAddressing.Clamp, filter, filter, mipMapFilter);

		g.drawIndexedVertices();

		unsetTextures(g);
		// End rendering

		#if debugInfo
		++ GEngine.drawCount;
		#end

    }
    override function createBuffers():Void {
        if(size==0)return;
        vertexBuffer = new VertexBuffer(size, structure, Usage.StaticUsage);
		// Create index buffer
		indexBuffer = new IndexBuffer(Std.int(size * Painter.ratioIndexVertex), Usage.StaticUsage);

		// Copy indices to index buffer
		var iData = indexBuffer.lock();
		for (i in 0...Std.int((size / 4))) {
			iData[i * 6 + 0] = ((i * 4) + 1);
			iData[i * 6 + 1] = ((i * 4) + 0);
			iData[i * 6 + 2] = ((i * 4) + 2);
			iData[i * 6 + 3] = ((i * 4) + 1);
			iData[i * 6 + 4] = ((i * 4) + 2);
			iData[i * 6 + 5] = ((i * 4) + 3);
		}
		indexBuffer.unlock();
	}
}