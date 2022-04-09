package com.imageAtlas;

import kha.graphics4.VertexData;
import kha.graphics4.PipelineState;
import kha.graphics4.MipMapFilter;
import kha.math.FastVector2;
import kha.graphics4.TextureFilter;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.arrays.Float32Array;
import kha.Image;
import kha.graphics4.Graphics;
import kha.math.FastMatrix4;
import kha.graphics4.VertexBuffer;
import kha.graphics4.Graphics2;
import kha.graphics4.IndexBuffer;
import kha.graphics4.TextureAddressing;
import kha.Color;
import kha.FastFloat;

class SingleImagePainter {
	var projectionMatrix: FastMatrix4;
	static var standardImagePipeline: PipelineCache = null;
	static var structure: VertexStructure = null;
	static inline var bufferSize: Int = 1;
	static inline var vertexSize: Int = 9;
	static var bufferStart: Int;
	static var bufferIndex: Int;
	static var rectVertexBuffer: VertexBuffer;
	static var rectVertices: Float32Array;
	static var indexBuffer: IndexBuffer;
	static var lastTexture: Image;
	var bilinear: Bool = false;
	var bilinearMipmaps: Bool = false;
	var g: Graphics;
	var myPipeline: PipelineCache = null;
	public var pipeline(get, set): PipelineCache;
	public var color:Color=Color.White;
	public var opacity:Float=1;
	var lastPipeline:PipelineState;

	public function new(g4: Graphics) {
		this.g = g4;
		bufferStart = 0;
		bufferIndex = 0;
		initShaders();
		myPipeline = standardImagePipeline;
		initBuffers();
	}

	private function get_pipeline(): PipelineCache {
		return myPipeline;
	}

	private function set_pipeline(pipe: PipelineCache): PipelineCache {
		myPipeline = pipe != null ? pipe : standardImagePipeline;
		return myPipeline;
	}

	public function setPipeline(pipeline: PipelineState): Void {
		if (pipeline == lastPipeline) {
			return;
		}
		lastPipeline = pipeline;
		drawBuffer(false);
		if (pipeline == null) {
			pipeline = null;
		}
		else {
			this.pipeline = new SimplePipelineCache(pipeline, true);
		}
	}

	public function setProjection(width:Float,height:Float): Void {
		if (Image.renderTargetsInvertedY()) {
			projectionMatrix = FastMatrix4.orthogonalProjection(0, width, 0, height, 0.1, 1000);
		}
		else {
			projectionMatrix = FastMatrix4.orthogonalProjection(0, width, height, 0, 0.1, 1000);
		}
	}

	private static function initShaders(): Void {
		if (structure == null) {
			structure = new VertexStructure();
			structure.add("vertexPosition", VertexData.Float32_3X);
			structure.add("vertexUV", VertexData.Float32_2X);
			structure.add("vertexColor", VertexData.Float4);
		}
		if (standardImagePipeline == null) {
			var pipeline = Graphics2.createImagePipeline(structure);
			standardImagePipeline = new PerFramebufferPipelineCache(pipeline, true);
		}
	}

	function initBuffers(): Void {
		if (rectVertexBuffer == null) {
			rectVertexBuffer = new VertexBuffer(bufferSize * 4, structure, Usage.DynamicUsage);
			rectVertices = rectVertexBuffer.lock();

			indexBuffer = new IndexBuffer(bufferSize * 3 * 2, Usage.StaticUsage);
			var indices = indexBuffer.lock();
			for (i in 0...bufferSize) {
				indices[i * 3 * 2 + 0] = i * 4 + 0;
				indices[i * 3 * 2 + 1] = i * 4 + 1;
				indices[i * 3 * 2 + 2] = i * 4 + 2;
				indices[i * 3 * 2 + 3] = i * 4 + 0;
				indices[i * 3 * 2 + 4] = i * 4 + 2;
				indices[i * 3 * 2 + 5] = i * 4 + 3;
			}
			indexBuffer.unlock();
		}
	}

	private inline function setRectVertices(
		bottomleftx: FastFloat, bottomlefty: FastFloat,
		topleftx: FastFloat, toplefty: FastFloat,
		toprightx: FastFloat, toprighty: FastFloat,
		bottomrightx: FastFloat, bottomrighty: FastFloat): Void {
		var baseIndex: Int = (bufferIndex - bufferStart) * vertexSize * 4;
		rectVertices.set(baseIndex +  0, bottomleftx);
		rectVertices.set(baseIndex +  1, bottomlefty);
		rectVertices.set(baseIndex +  2, -5.0);

		rectVertices.set(baseIndex +  9, topleftx);
		rectVertices.set(baseIndex + 10, toplefty);
		rectVertices.set(baseIndex + 11, -5.0);

		rectVertices.set(baseIndex + 18, toprightx);
		rectVertices.set(baseIndex + 19, toprighty);
		rectVertices.set(baseIndex + 20, -5.0);

		rectVertices.set(baseIndex + 27, bottomrightx);
		rectVertices.set(baseIndex + 28, bottomrighty);
		rectVertices.set(baseIndex + 29, -5.0);
	}

	private inline function setRectTexCoords(left: FastFloat, top: FastFloat, right: FastFloat, bottom: FastFloat): Void {
		var baseIndex: Int = (bufferIndex - bufferStart) * vertexSize * 4;
		rectVertices.set(baseIndex +  3, left);
		rectVertices.set(baseIndex +  4, bottom);

		rectVertices.set(baseIndex + 12, left);
		rectVertices.set(baseIndex + 13, top);

		rectVertices.set(baseIndex + 21, right);
		rectVertices.set(baseIndex + 22, top);

		rectVertices.set(baseIndex + 30, right);
		rectVertices.set(baseIndex + 31, bottom);
	}

	private inline function setRectColor(r: FastFloat, g: FastFloat, b: FastFloat, a: FastFloat): Void {
		var baseIndex: Int = (bufferIndex - bufferStart) * vertexSize * 4;
		rectVertices.set(baseIndex +  5, r);
		rectVertices.set(baseIndex +  6, g);
		rectVertices.set(baseIndex +  7, b);
		rectVertices.set(baseIndex +  8, a);

		rectVertices.set(baseIndex + 14, r);
		rectVertices.set(baseIndex + 15, g);
		rectVertices.set(baseIndex + 16, b);
		rectVertices.set(baseIndex + 17, a);

		rectVertices.set(baseIndex + 23, r);
		rectVertices.set(baseIndex + 24, g);
		rectVertices.set(baseIndex + 25, b);
		rectVertices.set(baseIndex + 26, a);

		rectVertices.set(baseIndex + 32, r);
		rectVertices.set(baseIndex + 33, g);
		rectVertices.set(baseIndex + 34, b);
		rectVertices.set(baseIndex + 35, a);
	}

	private function drawBuffer(end: Bool): Void {
		if (bufferIndex - bufferStart == 0) {
			return;
		}

		rectVertexBuffer.unlock((bufferIndex - bufferStart) * 4);
		var pipeline = myPipeline.get(null, Depth24Stencil8);
		g.setPipeline(pipeline.pipeline);
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setTexture(pipeline.textureLocation, lastTexture);
		g.setTextureParameters(pipeline.textureLocation, TextureAddressing.Clamp, TextureAddressing.Clamp, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinearMipmaps ? MipMapFilter.LinearMipFilter : MipMapFilter.NoMipFilter);
		g.setMatrix(pipeline.projectionLocation, projectionMatrix);

		g.drawIndexedVertices(bufferStart * 2 * 3, (bufferIndex - bufferStart) * 2 * 3);

		g.setTexture(pipeline.textureLocation, null);

		if (end || (bufferStart + bufferIndex + 1) * 4 >= bufferSize) {
			bufferStart = 0;
			bufferIndex = 0;
			rectVertices = rectVertexBuffer.lock(0);
		}
		else {
			bufferStart = bufferIndex;
			rectVertices = rectVertexBuffer.lock(bufferStart * 4);
		}
	}

	public function setBilinearFilter(bilinear: Bool): Void {
		drawBuffer(false);
		lastTexture = null;
		this.bilinear = bilinear;
	}

	public function setBilinearMipmapFilter(bilinear: Bool): Void {
		drawBuffer(false);
		lastTexture = null;
		this.bilinearMipmaps = bilinear;
	}

	inline function drawImage2(img: kha.Image, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat,
		bottomleftx: FastFloat, bottomlefty: FastFloat,
		topleftx: FastFloat, toplefty: FastFloat,
		toprightx: FastFloat, toprighty: FastFloat,
		bottomrightx: FastFloat, bottomrighty: FastFloat,
		opacity:Float , color: Color): Void {
		var tex = img;
		if (bufferStart + bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer(false);

		setRectTexCoords(sx / tex.realWidth, sy / tex.realHeight, (sx + sw) / tex.realWidth, (sy + sh) / tex.realHeight);
		setRectColor(color.R, color.G, color.B, color.A*opacity );
		setRectVertices(bottomleftx, bottomlefty, topleftx, toplefty, toprightx, toprighty, bottomrightx, bottomrighty);

		++bufferIndex;
		lastTexture = tex;
	}
	public  function drawScaledSubImage(img: kha.Image, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat, dx: FastFloat, dy: FastFloat, dw: FastFloat, dh: FastFloat): Void {
		var p1 = new FastVector2(dx, dy + dh);
		var p2 = new FastVector2(dx, dy);
		var p3 = new FastVector2(dx + dw, dy);
		var p4 = new FastVector2(dx + dw, dy + dh);
		drawImage2(img, sx, sy, sw, sh, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y, opacity, this.color);
	}
	public function begin(clear:Bool=true,color:Color=Color.Transparent):Void {
		g.begin();
		if(clear) g.clear(color);
	}

	public function end(): Void {
		if (bufferIndex > 0) {
			drawBuffer(true);
		}
		lastTexture = null;
		g.end();
	}
}