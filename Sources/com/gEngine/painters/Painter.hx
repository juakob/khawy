package com.gEngine.painters;

import kha.graphics5_.TextureFilter;
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
	public static inline var MAX_BATCH_TEXTURES:Int = 4;

	var vertexBuffer:VertexBuffer;
	var vertexBuffer1:VertexBuffer;
	var vertexBuffer2:VertexBuffer;
	var usingBuff1:Bool = true;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;
	

	public var red:FastFloat = 0.;
	public var green:FastFloat = 0.;
	public var blue:FastFloat = 0.;
	public var alpha:FastFloat = 0.;

	var MAX_VERTEX_PER_BUFFER:Int ;

	var dataPerVertex:Int = 5;
	var mvpID:ConstantLocation;
	var textureConstantID:TextureUnit;
	var textureConstantIDs:Array<TextureUnit>;
	var activeTextureIDs:Array<Int>;
	var canvasWidth:Int = 0;
	var canvasHeight:Int = 0;
	var projection:FastMatrix4;

	public var resolution:Float = 1;

	static inline var ratioIndexVertex:Float = 6 / 4;

	public var counter:Int = 0;

	var buffer:Float32Array;

	public var textureID:Int = -1;
	public var filter:TextureFilter = TextureFilter.LinearFilter;
	public var mipMapFilter:MipMapFilter = MipMapFilter.NoMipFilter;
	public var paintInfo:PaintInfo;

	var structure:VertexStructure;
	var depthWrite:Bool;
	var clockWise:CullMode;

	public function new(autoDestroy:Bool = true, blend:Blend = null, depthWrite:Bool = false, clockWise:CullMode = CullMode.None,maxV:Int =12,dataV:Int=5) {
		if (blend == null)
			blend = Blend.blendDefault();
		if (autoDestroy)
			PainterGarbage.i.add(this);
		this.depthWrite = depthWrite;
		this.clockWise = clockWise;
		this.MAX_VERTEX_PER_BUFFER = maxV;
		this.dataPerVertex = dataV;
		initShaders(blend);
		createBuffers();
		activeTextureIDs = new Array();
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
		#if debugInfo
		if(GEngine.drawCount> GEngine.maxDrawCount){
			counter =0;
			return;
		}
		#end
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
		setTextureParameters(g);

		g.drawIndexedVertices(0, Std.int(vertexCount * ratioIndexVertex));

		unsetTextures(g);
		// End rendering
		if (usingBuff1) {
			vertexBuffer = vertexBuffer1;
			usingBuff1 = false;
		}else{
			vertexBuffer = vertexBuffer1;
			usingBuff1 = true;
		}
		buffer = downloadVertexBuffer();
		

		#if debugInfo
		++ GEngine.drawCount;
		#end
		counter = 0;
		activeTextureIDs.splice(0, activeTextureIDs.length);
	}

	public inline function vertexCount():Int {
		return Std.int(counter / dataPerVertex);
	}

	function initShaders(blend:Blend):Void {
		pipeline = new PipelineState();
		structure = new VertexStructure();
		defineVertexStructure(structure);
		pipeline.inputLayout = [structure];
		pipeline.cullMode = clockWise;
		pipeline.depthWrite = false;
		if (false){
			pipeline.depthMode = CompareMode.Less;
		}
		setShaders(pipeline);
		setBlends(pipeline, blend);
		// pipeline.colorWriteMaskAlpha = false;
		pipeline.compile();

		getConstantLocations(pipeline);
	}

	function getConstantLocations(pipeline:PipelineState) {
		mvpID = pipeline.getConstantLocation("projectionMatrix");
		textureConstantIDs = new Array();
		var tex = pipeline.getTextureUnit("tex");
		var tex2 = pipeline.getTextureUnit("tex2");
		var tex3 = pipeline.getTextureUnit("tex3");
		var tex4 = pipeline.getTextureUnit("tex4");
		if (tex != null && (tex2 != null || tex3 != null || tex4 != null)) {
			textureConstantIDs.push(tex);
			if (tex2 != null) textureConstantIDs.push(tex2);
			if (tex3 != null) textureConstantIDs.push(tex3);
			if (tex4 != null) textureConstantIDs.push(tex4);
		} else {
			for (i in 0...MAX_BATCH_TEXTURES) {
				var unit = pipeline.getTextureUnit("tex" + i);
				if (unit != null) {
					textureConstantIDs.push(unit);
				}
			}
			if (textureConstantIDs.length == 0 && tex != null) {
				textureConstantIDs.push(tex);
			}
		}
		if (textureConstantIDs.length > 0) {
			textureConstantID = textureConstantIDs[0];
		} else {
			textureConstantID = null;
		}
	}

	function createBuffers():Void {
		vertexBuffer1 = new VertexBuffer(MAX_VERTEX_PER_BUFFER, structure, Usage.DynamicUsage);
		vertexBuffer2 = new VertexBuffer(MAX_VERTEX_PER_BUFFER, structure, Usage.DynamicUsage);
		vertexBuffer = vertexBuffer1;
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
		if (textureConstantIDs == null || textureConstantIDs.length == 0) {
			return;
		}
		var fallbackTexture = textureID;
		if (activeTextureIDs.length > 0) {
			fallbackTexture = activeTextureIDs[0];
		}
		if (fallbackTexture < 0 && GEngine.i.textures.length > 0) {
			fallbackTexture = 0;
		}
		if (textureConstantIDs.length == 1) {
			var onlyTexture = fallbackTexture;
			g.setTexture(textureConstantIDs[0], onlyTexture >= 0 ? GEngine.i.textures[onlyTexture] : null);
			return;
		}
		for (i in 0...textureConstantIDs.length) {
			var texID = i < activeTextureIDs.length ? activeTextureIDs[i] : fallbackTexture;
			g.setTexture(textureConstantIDs[i], texID >= 0 ? GEngine.i.textures[texID] : null);
		}
	}

	private function setTextureParameters(g:Graphics):Void {
		if (textureConstantIDs == null) {
			return;
		}
		for (unit in textureConstantIDs) {
			if (unit != null) {
				g.setTextureParameters(unit, TextureAddressing.Clamp, TextureAddressing.Clamp, filter, filter, mipMapFilter);
			}
		}
	}

	private function unsetTextures(g:Graphics):Void {
		if (textureConstantIDs == null) {
			return;
		}
		for (unit in textureConstantIDs) {
			if (unit != null) {
				g.setTexture(unit, null);
			}
		}
	}

	function downloadVertexBuffer():Float32Array {
		return vertexBuffer.lock();
	}

	function uploadVertexBuffer(count:Int):Void {
		vertexBuffer.unlock(count);
	}

	public function destroy():Void {
		vertexBuffer.delete();
		indexBuffer.delete();
		pipeline.delete();
	}

	public function adjustRenderArea(area:MinMax):Void {}

	public function canBatch(info:PaintInfo, size:Int):Bool {
		//return info.texture == textureID && info.mipMapFilter == mipMapFilter && info.textureFilter == this.filter && ((counter +
		//	size * dataPerVertex) <= MAX_VERTEX_PER_BUFFER * dataPerVertex);
		return info.texture == textureID&& info.mipMapFilter == mipMapFilter && info.textureFilter == this.filter &&((counter +	size * dataPerVertex) <= (MAX_VERTEX_PER_BUFFER * dataPerVertex));
	}

	public function canBatchWithTextureArray(info:PaintInfo, size:Int):Bool {
		if (info.mipMapFilter != mipMapFilter || info.textureFilter != this.filter) {
			return false;
		}
		if ((counter + size * dataPerVertex) > (MAX_VERTEX_PER_BUFFER * dataPerVertex)) {
			return false;
		}
		if (info.texture == textureID || activeTextureIDs.indexOf(info.texture) != -1) {
			return true;
		}
		return textureConstantIDs != null
			&& textureConstantIDs.length > 1
			&& activeTextureIDs.length < textureConstantIDs.length;
	}

	public function resetTextureBatch(texture:Int):Void {
		activeTextureIDs.splice(0, activeTextureIDs.length);
		textureID = texture;
		if (texture >= 0) {
			activeTextureIDs.push(texture);
		}
	}

	public function getTextureSlot(texture:Int):Float {
		if (texture < 0) {
			return 0;
		}
		var slot = activeTextureIDs.indexOf(texture);
		if (slot != -1) {
			return slot;
		}
		if (activeTextureIDs.length == 0) {
			activeTextureIDs.push(texture);
			textureID = texture;
			return 0;
		}
		var maxTextures = textureConstantIDs != null ? textureConstantIDs.length : 1;
		if (maxTextures > 1 && activeTextureIDs.length < maxTextures) {
			activeTextureIDs.push(texture);
			return activeTextureIDs.length - 1;
		}
		return -1;
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
