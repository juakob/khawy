package com.gEngine.painters;

import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.math.FastMatrix4;
import com.gEngine.display.Blend;
import com.helpers.MinMax;
import kha.Color;
import kha.FastFloat;
import kha.Shaders;
import kha.arrays.Float32Array;
import kha.graphics4.Graphics;
import kha.graphics4.BlendingFactor;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CullMode;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;

class Painter implements IPainter {
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;

	public var red:FastFloat = 0.;
	public var green:FastFloat = 0.;
	public var blue:FastFloat = 0.;
	public var alpha:FastFloat = 0.;

	inline static var MAX_VERTEX_PER_BUFFER:Int = 4000;

	var dataPerVertex:Int = 5;
	var mvpID:ConstantLocation;
	var textureConstantID:TextureUnit;
	var canvasWidth:Int = 0;
	var canvasHeight:Int = 0;
	var projection:FastMatrix4;

	public var resolution:Float = 1;

	static inline var ratioIndexVertex:Float = 6 / 4;

	public var counter:Int = 0;

	var buffer:Float32Array;

	public var textureID:Int = -1;
	public var filter:TextureFilter = TextureFilter.PointFilter;
	public var mipMapFilter:MipMapFilter = MipMapFilter.NoMipFilter;
	public var paintInfo:PaintInfo;

	var depthWrite:Bool;
	var clockWise:CullMode;

	public function new(autoDestroy:Bool = true, blend:Blend = null, depthWrite:Bool = false, clockWise:CullMode = CullMode.None) {
		if (blend == null)
			blend = Blend.blendDefault();
		if (autoDestroy)
			PainterGarbage.i.add(this);
		this.depthWrite = depthWrite;
		this.clockWise = clockWise;
		initShaders(blend);
		buffer = downloadVertexBuffer();
	}

	public inline function write(value:Float):Void {
		buffer.set(counter++, value);
	}

	public function start() {}

	public function finish() {}

	public function render(clear:Bool = false, cropArea:MinMax = null):Void {
		if (counter == 0)
			return;
		var vertexCount:Int = vertexCount();
		var canvas = GEngine.i.currentCanvas();
		canvasWidth = canvas.width;
		canvasHeight = canvas.height;
		var g = canvas.g4;
		// Begin rendering
		uploadVertexBuffer(vertexCount);
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

		g.drawIndexedVertices(0, Std.int(vertexCount * ratioIndexVertex));

		unsetTextures(g);
		// End rendering

		buffer = downloadVertexBuffer();

		#if debugInfo
		++ GEngine.drawCount;
		#end
		counter = 0;
	}

	public inline function vertexCount():Int {
		return Std.int(counter / dataPerVertex);
	}

	public function initShaders(blend:Blend):Void {
		pipeline = new PipelineState();
		setShaders(pipeline);

		var structure = new VertexStructure();
		defineVertexStructure(structure);
		pipeline.inputLayout = [structure];
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = clockWise;
		pipeline.depthWrite = depthWrite;

		setBlends(pipeline, blend);
		// pipeline.colorWriteMaskAlpha = false;
		pipeline.compile();

		getConstantLocations(pipeline);

		vertexBuffer = new VertexBuffer(MAX_VERTEX_PER_BUFFER, structure, Usage.DynamicUsage);

		createIndexBuffer();
	}

	function getConstantLocations(pipeline:PipelineState) {
		mvpID = pipeline.getConstantLocation("projectionMatrix");
		textureConstantID = pipeline.getTextureUnit("tex");
	}

	function createIndexBuffer():Void {
		// Create index buffer
		indexBuffer = new IndexBuffer(Std.int(MAX_VERTEX_PER_BUFFER * ratioIndexVertex), Usage.StaticUsage);

		// Copy indices to index buffer
		var iData = indexBuffer.lock();
		for (i in 0...Std.int((MAX_VERTEX_PER_BUFFER / 4))) {
			iData[i * 6 + 0] = ((i * 4) + 1);
			iData[i * 6 + 1] = ((i * 4) + 0);
			iData[i * 6 + 2] = ((i * 4) + 2);
			iData[i * 6 + 3] = ((i * 4) + 1);
			iData[i * 6 + 4] = ((i * 4) + 2);
			iData[i * 6 + 5] = ((i * 4) + 3);
		}
		indexBuffer.unlock();
	}

	private inline function setBlends(pipeline:PipelineState, blend:Blend) {
		pipeline.blendOperation = blend.blendOperation;
		pipeline.blendSource = blend.blendSource;
		pipeline.blendDestination = blend.blendDestination;
		pipeline.alphaBlendSource = blend.alphaBlendSource;
		pipeline.alphaBlendDestination = blend.alphaBlendDestination;
	}

	private function defineVertexStructure(structure:VertexStructure) {
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
	}

	private function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.simple_frag;
	}

	private function setParameter(g:Graphics):Void {
		g.setMatrix(mvpID, projection);

		g.setTexture(textureConstantID, GEngine.i.textures[textureID]);
	}

	private function unsetTextures(g:Graphics):Void {
		g.setTexture(textureConstantID, null);
	}

	inline function downloadVertexBuffer():Float32Array {
		return vertexBuffer.lock();
	}

	inline function uploadVertexBuffer(count:Int):Void {
		vertexBuffer.unlock(count);
	}

	public function destroy():Void {
			vertexBuffer.delete();
			indexBuffer.delete();
			pipeline.delete();
	}

	public function adjustRenderArea(area:MinMax):Void {}

	public function canBatch(info:PaintInfo, size:Int):Bool {
		return info.texture == textureID && info.mipMapFilter == mipMapFilter && info.textureFilter == this.filter && ((counter +
			size * dataPerVertex) <= MAX_VERTEX_PER_BUFFER * dataPerVertex);
	}

	public function setProjection(proj:FastMatrix4):Void {
		projection = proj;
	}

	public function releaseTexture():Bool {
		return true;
	}

	public function getVertexDataCounter():Int {
		return counter;
	}

	public function setVertexDataCounter(data:Int):Void {
		counter = data;
	}

	public function getVertexBuffer():Float32Array {
		return buffer;
	}
}
