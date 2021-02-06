package com.gEngine.painters;

import kha.Color;
import kha.graphics4.CompareMode;
import kha.graphics4.CullMode;
import com.gEngine.display.Blend;
import com.gEngine.GEngine;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureFilter;
import kha.arrays.Float32Array;
import com.helpers.MinMax;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.PaintInfo;

class PolyPainter implements IPainter {
	private var pipeline:PipelineState;
    var mMvpID:ConstantLocation;
    var colorID:ConstantLocation;
	var matrix:FastMatrix4;
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var counter:Int = 0;

	public var textureID:Int;
	public var resolution:Float;
	public var filter:TextureFilter;
    public var mipMapFilter:MipMapFilter;
    public var color:Color;

	var projection:FastMatrix4;

	public function new(blend:Blend) {
		pipeline = new PipelineState();
		setPrograms(pipeline);
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		pipeline.blendSource = blend.blendSource;
		pipeline.blendDestination = blend.blendDestination;
		pipeline.alphaBlendSource = blend.alphaBlendSource;
		pipeline.alphaBlendDestination = blend.alphaBlendDestination;
		pipeline.inputLayout = [structure];
		pipeline.cullMode = CullMode.None;
		pipeline.depthWrite = false;
		pipeline.depthMode = CompareMode.LessEqual;
		pipeline.compile();
		getConstantLocation(pipeline);
	}

	function setPrograms(pipeline:PipelineState) {
		pipeline.vertexShader = Shaders.poly_vert;
		pipeline.fragmentShader = Shaders.poly_frag;
	}

	function getConstantLocation(pipeline:PipelineState) {
        mMvpID = pipeline.getConstantLocation("projectionMatrix");
        colorID=pipeline.getConstantLocation("color");
	}

	public function write(aValue:Float):Void {}

	public function start():Void {}

	public function finish():Void {}

	public function setRenderInfo(matrix:FastMatrix4, vertexBuffer:VertexBuffer, indexBuffer:IndexBuffer,color:Color,counter:Int) {
		this.matrix = matrix;
		this.vertexBuffer = vertexBuffer;
        this.indexBuffer = indexBuffer;
        this.color=color;
		this.counter=counter;
	}

	public function render(clear:Bool = false, cropArea:MinMax = null):Void {
		var g4:Graphics = GEngine.i.currentCanvas().g4;
		g4.setIndexBuffer(indexBuffer);
		g4.setVertexBuffer(vertexBuffer);
		g4.setPipeline(pipeline);
		setParameters(g4);
		g4.drawIndexedVertices(0,counter);
		#if debugInfo
		++ GEngine.drawCount;
		#end
	}

	function setParameters(g4:Graphics) {
        g4.setMatrix(mMvpID, matrix);
        g4.setFloat4(colorID,color.R,color.B,color.G,color.A);
	}

	public function canBatch(info:PaintInfo, size:Int):Bool {
		return false;
	}

	public function vertexCount():Int {
		return 0;
	}

	public function releaseTexture():Bool {
		return true;
	}

	public function adjustRenderArea(aArea:MinMax):Void {}

	public function resetRenderArea():Void {}

	public function getVertexBuffer():Float32Array {
		return null;
	}

	public function getVertexDataCounter():Int {
		return 0;
	}

	public function setProjection(proj:FastMatrix4) {
		projection = proj;
	}

	public function setVertexDataCounter(aData:Int):Void {}

	public function destroy():Void {
		pipeline.delete();
	}
}
