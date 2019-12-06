package com.gEngine.painters;

import kha.math.FastMatrix4;
import com.gEngine.display.Blend;
import com.gEngine.display.BlendMode;
import com.gEngine.helper.Screen;
import com.helpers.MinMax;
import kha.Color;
import kha.Display;
import kha.FastFloat;
import kha.Shaders;
import kha.System;
import kha.arrays.Float32Array;
import kha.graphics4.BlendingOperation;
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

class Painter2d implements IPainter {
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;

	public var red:FastFloat = 0.;
	public var green:FastFloat = 0.;
	public var blue:FastFloat = 0.;
	public var alpha:FastFloat = 0.;
	public var MAX_VERTEX_PER_BUFFER:Int = 2500;

	var dataPerVertex:Int = 4;
	var mvpID:ConstantLocation;
	var textureConstantID:TextureUnit;

	public var resolution:Float = 1;

	var ratioIndexVertex:Float = 6 / 4;

	public var counter:Int = 0;

	var buffer:Float32Array;

	public var textureID:Int = -1;
	public var filter:TextureFilter = TextureFilter.PointFilter;
	public var mipMapFilter:MipMapFilter = MipMapFilter.NoMipFilter;
	public var paintInfo:PaintInfo;

	public function new(autoDestroy:Bool = true, blend:Blend = null) {
		if (blend == null)
			blend = Blend.blendDefault();
		if (autoDestroy)
			PainterGarbage.i.add(this);
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

		var g = GEngine.i.currentCanvas().g4;
		// Begin rendering
		g.begin();
		if (cropArea != null)
			g.scissor(Std.int(cropArea.min.x), Std.int(cropArea.min.y), Std.int(cropArea.max.x), Std.int(cropArea.max.y));
		uploadVertexBuffer();
		// Clear screen
		if (clear)
			g.clear(Color.fromFloats(red, green, blue, alpha));
		// Bind data we want to draw
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		// Bind state we want to draw with
		g.setPipeline(pipeline);

		setParameter(g);
		g.setTextureParameters(textureConstantID, TextureAddressing.Clamp, TextureAddressing.Clamp, filter, filter, mipMapFilter);

		g.drawIndexedVertices(0, Std.int(vertexCount() * ratioIndexVertex));

		unsetTextures(g);
		// End rendering

		buffer = downloadVertexBuffer();
		if (cropArea != null)
			g.disableScissor();
		g.end();

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

		// pipeline.cullMode = CullMode.None;

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
		indexBuffer = new IndexBuffer(Std.int(MAX_VERTEX_PER_BUFFER * 6 / 4), Usage.StaticUsage);

		// Copy indices to index buffer
		var iData = indexBuffer.lock();
		for (i in 0...Std.int((MAX_VERTEX_PER_BUFFER / 4))) {
			iData[i * 6] = ((i * 4) + 0);
			iData[i * 6 + 1] = ((i * 4) + 1);
			iData[i * 6 + 2] = ((i * 4) + 2);
			iData[i * 6 + 3] = ((i * 4) + 1);
			iData[i * 6 + 4] = ((i * 4) + 2);
			iData[i * 6 + 5] = ((i * 4) + 3);
		}
		indexBuffer.unlock();
	}

	private function setBlends(pipeline:PipelineState, blend:Blend) {
		pipeline.blendSource = blend.blendSource;
		pipeline.blendDestination = blend.blendDestination;
		pipeline.alphaBlendSource = blend.alphaBlendSource;
		pipeline.alphaBlendDestination = blend.alphaBlendDestination;
	}

	private function defineVertexStructure(structure:VertexStructure) {
		structure.add("vertexPosition", VertexData.Float2);
		structure.add("texPosition", VertexData.Float2);
	}

	private function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.simple_frag;
	}

	private function setParameter(g:Graphics):Void {
		g.setMatrix(mvpID, FastMatrix4.identity());

		g.setTexture(textureConstantID, GEngine.i.getTexture(textureID));
	}

	private function unsetTextures(g:Graphics):Void {
		g.setTexture(textureConstantID, null);
	}

	inline function downloadVertexBuffer():Float32Array {
		return vertexBuffer.lock();
	}

	inline function uploadVertexBuffer():Void {
		vertexBuffer.unlock();
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
