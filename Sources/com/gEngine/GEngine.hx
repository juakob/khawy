package com.gEngine;

import com.gEngine.display.BlendMode;
import com.gEngine.painters.PainterColorTransform;
import com.gEngine.painters.PainterAlpha;
import kha.graphics4.Graphics;
import com.framework.utils.Input;
import com.gEngine.display.Blend;
import com.gEngine.display.IDraw;
import com.gEngine.display.Stage;
import com.gEngine.helper.RectangleDisplay;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.Painter;
import com.helpers.RenderTargetPool;
import kha.Assets;
import kha.Canvas;
import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.Window;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFilter;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;

@:allow(com.gEngine.painters.Painter)
class GEngine {
	public static var i(get, null):GEngine;

	private static function get_i():GEngine {
		return i;
	}

	public var width(default, null):Int;
	public var height(default, null):Int;
	public var realWidth(default, null):Int;
	public var realHeight(default, null):Int;
	public var directRender(default, default):Bool = true;
	public var realU:Float;
	public var realV:Float;

	private var textures:Array<Image>;
	private var stage:Stage;
	var modelViewMatrix:FastMatrix4;
	var tempToTempBuffMatrix:FastMatrix4;
	var tempToTempBuffMatrixMirrorY:FastMatrix4;
	private var painter:Painter;

	inline static var initialIndex:Int = 2;

	public var oversample:Float = 1;

	var renderTargetPool:RenderTargetPool;
	var currentRenderTargetId:Int = -1;
	var identity4x4 = FastMatrix4.identity();
	#if debugInfo
	private var deltaTime:Float = 0.0;
	private var totalFrames:Int = 0;
	private var elapsedTime:Float = 0.0;
	private var previousTime:Float = 0.0;
	private var fps:Int = 0;

	public static var drawCount:Int = 0;

	public var font:kha.Font;

	public static var extraInfo:String = "";

	var fontLoaded:Bool;
	var identity3x3 = FastMatrix3.identity();
	#end

	private function new(oversample:Float, antiAlias:Int) {
		clearColor = Color.fromFloats(0, 0, 0, 1);

		antiAliasing = antiAlias;
		this.oversample = oversample;

		Window.get(0).notifyOnResize(resize);

		PainterGarbage.init();

		renderTargetPool = new RenderTargetPool();

		textures = new Array();

		createPainters();

		// createBuffer(Screen.getWidth(), Screen.getHeight());
		trace(com.gEngine.helper.Screen.getWidth() + "x" + com.gEngine.helper.Screen.getHeight());
		createBuffer(com.gEngine.helper.Screen.getWidth(), com.gEngine.helper.Screen.getHeight());

		var recTexture = Image.createRenderTarget(1, 1);
		recTexture.g2.begin(true, Color.White);
		recTexture.g2.end();
		textures.push(recTexture);
		RectangleDisplay.init(1);
	}

	public function getSimplePainter(blend:BlendMode) {
		return simplePainters[cast blend];
	}

	public function getAlphaPainter(blend:BlendMode) {
		return alphaPainters[cast blend];
	}

	public function getColorTransformPainter(blend:BlendMode) {
		return colorPainters[cast blend];
	}

	function createBuffer(targetWidth:Int, targetHeight:Int):Bool {
		if (this.width == targetWidth && this.height == targetHeight)
			return false;
		this.width = Std.int(targetWidth * oversample);
		this.height = Std.int(targetHeight * oversample);
		if (mTempBuffer != null)
			mTempBuffer.unload();
		mTempBuffer = Image.createRenderTarget(width, height, null, DepthStencilFormat.DepthOnly, antiAliasing);
		if (textures.length == 0) {
			currentRenderTargetId = mTempBufferID = textures.push(mTempBuffer) - 1;
		} else {
			textures[mTempBufferID] = mTempBuffer;
		}

		realWidth = mTempBuffer.realWidth;
		realHeight = mTempBuffer.realHeight;

		var renderScale:Float = 1;
		realU = width / realWidth;
		realV = height / realHeight;

		scaleWidth = (width / realWidth);
		scaleHeigth = (height / realHeight);

		modelViewMatrix=FastMatrix4.orthogonalProjection(0,virtualWidth / scaleWidth / ( renderScale),
		virtualHeight / scaleHeigth / ( renderScale),0,0,5000);
		return true;
	}

	public function createDefaultPainters():Void {
		stage = new Stage();
		painter = new Painter(false, Blend.blendNone());
		painter.setProjection(FastMatrix4.identity());
		painter.filter = TextureFilter.LinearFilter;
	}

	public static function init(virtualWidth:Int, virtualHeight:Int, oversample:Float, antiAlias:Int):Void {
		GEngine.virtualWidth = virtualWidth;
		GEngine.virtualHeight = virtualHeight;
		i = new GEngine(oversample, antiAlias);
		#if debugInfo
		Assets.loadFont("mainfont", setFont);
		#end
	}

	#if debugInfo
	static private function setFont(aFont:kha.Font) {
		i.font = aFont;
		i.fontLoaded = true;
	}
	#end

	public function resize(availWidth:Int, availHeight:Int) {
		if (availWidth == 0 || availWidth == 0)
			return;
		Input.i.screenScale.setTo(virtualWidth / availWidth, virtualHeight / availHeight);
		if (false && createBuffer(availWidth, availHeight)) {
			adjustRenderTargets();
			trace("resize " + availWidth + " , " + availHeight);
		}
	}

	public function getNewRectangle(width:Float, height:Float):RectangleDisplay {
		var rectangle:RectangleDisplay = new RectangleDisplay();
		rectangle.scaleX = width;
		rectangle.scaleY = height;
		return rectangle;
	}

	public function addTexture(texture:Image):Int {
		return textures.push(texture) - 1;
	}

	private var mFrameBuffer:Framebuffer;
	private var mTempBuffer:Image;

	public var mTempBufferID:Int;
	public var renderFinal:Bool;

	private var renderCustomBuffer:Bool;
	private var customBuffer:Image;
	private var antiAliasing:Int = 4;

	public static var virtualWidth:Int;
	public static var virtualHeight:Int;
	static inline public var backBufferId = 0;

	public var scaleWidth:Float = 1;
	public var scaleHeigth:Float = 1;
	public var clearColor:Color;

	var currentCanvasActive:Bool = false;
	var simplePainters:Array<Painter>;
	var alphaPainters:Array<PainterAlpha>;
	var colorPainters:Array<PainterColorTransform>;

	public function changeToBuffer() {
		#if debug
		if (currentCanvasActive)
			throw "end buffer before releasing it";
		#end
		currentRenderTargetId = mTempBufferID;
		renderCustomBuffer = false;
	}

	public function setCanvas(id:Int):Void {
		currentRenderTargetId = id;
		if (currentRenderTargetId != mTempBufferID) {
			renderCustomBuffer = true;
			customBuffer = textures[id];
		} else {
			changeToBuffer();
		}
	}

	public function setCanvasFromImage(image:Image):Void {
		renderCustomBuffer = true;
		customBuffer = image;
	}

	function createPainters() {
		var defaultBlend:Blend = Blend.blendDefault();
		var multipassBlend:Blend = Blend.blendMultipass();
		var addBlend:Blend = Blend.blendAdd();
		var multiplyBlend:Blend = Blend.blendMultiply();
		var screenBlend:Blend = Blend.blendScreen();
		simplePainters = [
			new Painter(false, defaultBlend),
			new Painter(false, multipassBlend),
			new Painter(false, addBlend),
			new Painter(false, multiplyBlend),
			new Painter(false, screenBlend)
		];

		alphaPainters = [
			new PainterAlpha(false, defaultBlend),
			new PainterAlpha(false, multipassBlend),
			new PainterAlpha(false, addBlend),
			new PainterAlpha(false, multiplyBlend),
			new PainterAlpha(false, screenBlend)
		];

		colorPainters = [
			new PainterColorTransform(false, defaultBlend),
			new PainterColorTransform(false, multipassBlend),
			new PainterColorTransform(false, addBlend),
			new PainterColorTransform(false, multiplyBlend),
			new PainterColorTransform(false, screenBlend)
		];
	}

	public function endCanvas() {
		#if debug
		if (!currentCanvasActive) {
			trace("Warning :start buffer before you end it");
		}
		#end
		if (currentCanvasActive) {
			currentCanvas().g4.end();
			currentCanvasActive = false;
		}
	}

	public function beginCanvas() {
		#if debug
		if (currentCanvasActive) {
			trace("Warning :end buffer before you start ");
		}
		#end
		if (!currentCanvasActive) {
			currentCanvas().g4.begin();
			currentCanvasActive = true;
		}
	}

	public inline function getStage():Stage {
		return stage;
	}

	public inline function currentCanvasId():Int {
		return currentRenderTargetId;
	}

	public function currentCanvas():Canvas {
		if (renderCustomBuffer) {
			return customBuffer;
		}
		if (renderFinal || directRender) {
			return mFrameBuffer;
		}
		return mTempBuffer;
	}

	public function getMatrix():FastMatrix4 {
		return modelViewMatrix;
	}

	/*
		public function renderBuffer2(source:Int, painter:IPainter, x:Float, y:Float, width:Float, height:Float, sourceScale:Float, clear:Bool, outScale:Float = 1,transform:FastMatrix4,projection:FastMatrix4) {
				painter.textureID = source;
				painter.setProjection(identity4x4);

				var v1=transform.multvec(new FastVector4(x,y,-869.1168,1));
				var v2=transform.multvec(new FastVector4(x+width,y,-869.1168,1));
				var v3=transform.multvec(new FastVector4(x,y+height,-869.1168,1));
				var v4=transform.multvec(new FastVector4(x + width,y + height,-869.1168,1));

				writeVertexProjection(painter, projection.multvec(v1), outScale);
				writeVertexProjection(painter, projection.multvec(v2), outScale);
				writeVertexProjection(painter, projection.multvec(v3), outScale);
				writeVertexProjection(painter, projection.multvec(v4), outScale);

				painter.render(clear);
		}
		public static  function writeVertexProjection(painter:IPainter, vertex:FastVector4, resolution:Float) {
			painter.write(vertex.x/vertex.w * resolution);
			painter.write(vertex.y/vertex.w * resolution);
			painter.write(vertex.z/vertex.w);
			painter.write((vertex.x/vertex.w+1)*0.5);
			painter.write((vertex.y/vertex.w+1)*0.5);
	}*/
	public function renderBufferFull(source:Int, painter:IPainter, x:Float, y:Float, width:Float, height:Float, sourceScale:Float, clear:Bool,
			outScale:Float = 1) {
		painter.textureID = source;
		painter.setProjection(getMatrix());
		var text = getTexture(source);
		writeVertexFull(painter, x, y, 0, 0, 0, outScale);

		writeVertexFull(painter, (x + width) * scaleWidth, y * scaleHeigth, 0, width * oversample / (text.realWidth), 0, outScale);

		writeVertexFull(painter, x * scaleWidth, (y + height) * scaleHeigth, 0, 0, height * oversample / (text.realHeight), outScale);

		writeVertexFull(painter, (x + width) * scaleWidth, (y + height) * scaleHeigth, 0, width * oversample / (text.realWidth), height * oversample / (text
			.realHeight), outScale);

		painter.render(clear);
	}

	inline function writeVertexFull(painter:IPainter, x:Float, y:Float, z:Float, sWidth:Float, sHeight:Float, resolution:Float) {
		painter.write(x * resolution);
		painter.write(y * resolution);
		painter.write(z);
		painter.write(sWidth);
		painter.write(sHeight);
	}

	public function getTexture(id:Int):Image {
		return textures[id];
	}

	public function update():Void {
		stage.update();
	}

	public function draw(frameBuffer:Framebuffer, clear:Bool = true):Void {
		if (frameBuffer.width * oversample != width || frameBuffer.height * oversample != height)
			resize(frameBuffer.width, frameBuffer.height);
		#if debugInfo
		var currentTime:Float = kha.Scheduler.realTime();
		deltaTime = (currentTime - previousTime);

		elapsedTime += deltaTime;
		if (elapsedTime >= 1.0) {
			fps = totalFrames;
			totalFrames = 0;
			elapsedTime = 0;
		}
		totalFrames++;
		previousTime = currentTime;
		#end
		mFrameBuffer = frameBuffer;
		if (mTempBuffer == null)
			return;
		var g:Graphics;
		if (directRender) {
			g = mFrameBuffer.g4;
		} else {
			g = mTempBuffer.g4;
		}

		// Begin rendering
		g.begin();
		if (clear)
			g.clear(clearColor, 1);
		g.end();
		stage.render();
		changeToBuffer();

		if (!directRender) {
			painter.textureID = mTempBufferID;
			renderFinal = true;
			beginCanvas();
			if (kha.Image.renderTargetsInvertedY()) {
				painter.write(-1);
				painter.write(-1);
				painter.write(0);
				painter.write(0);
				painter.write(realV);

				painter.write(1);
				painter.write(-1);
				painter.write(0);
				painter.write(realU);
				painter.write(realV);

				painter.write(-1);
				painter.write(1);
				painter.write(0);
				painter.write(0);
				painter.write(0);

				painter.write(1);
				painter.write(1);
				painter.write(0);
				painter.write(realU);
				painter.write(0);
			} else {
				painter.write(-1);
				painter.write(-1);
				painter.write(0);
				painter.write(0);
				painter.write(0);

				painter.write(1);
				painter.write(-1);
				painter.write(0);
				painter.write(realU);
				painter.write(0);

				painter.write(-1);
				painter.write(1);
				painter.write(0);
				painter.write(0);
				painter.write(realV);

				painter.write(1);
				painter.write(1);
				painter.write(0);
				painter.write(realU);
				painter.write(realV);
			}

			painter.render(true);
			endCanvas();
			renderFinal = false;
			#if debugInfo
			-- drawCount; // dont count this
			#end
		}
		#if debugInfo
		// frameBuffer.g2.transformation = FastMatrix3.identity();
		if (fontLoaded) {
			var g2 = frameBuffer.g2;
			g2.begin(false);
			g2.transformation = identity3x3;
			g2.font = font;
			g2.fontSize = 16;
			g2.color = 0xFF000000;
			g2.fillRect(0, 0, 250, 20);
			g2.color = 0xFFFFFFFF;
			g2.drawString("drawCount: " + drawCount + "         fps: " + fps + " " + extraInfo, 10, 2);
			g2.end();
		}
		drawCount = 0;
		#end
	}

	public function addChild(draw:IDraw):Void {
		stage.addChild(draw);
	}

	public function getRenderTarget(width:Int, height:Int):Int {
		var id:Int = renderTargetPool.getFreeImageId(width, height);
		if (id == -1) {
			var target:Image = Image.createRenderTarget(Std.int(width * oversample), Std.int(height * oversample), null, DepthStencilFormat.DepthOnly,
				antiAliasing);
			id = textures.push(target) - 1;
			renderTargetPool.addRenderTarget(id, width, height);
		}
		return id;
	}

	public function releaseRenderTarget(id:Int) {
		renderTargetPool.release(id);
	}

	public function adjustRenderTargets():Void {
		for (proxy in renderTargetPool.targets) {
			textures[proxy.textureId].unload();
			textures[proxy.textureId] = Image.createRenderTarget(width, height, null, DepthStencilFormat.DepthOnly, antiAliasing);
		}
	}

	public function unload():Void {
		var end = textures.length;
		for (proxy in renderTargetPool.targets) {
			textures[proxy.textureId].unload();
		}
		PainterGarbage.i.clear();
		renderTargetPool.clear();
		stage = new Stage();
	}

	public function swapBuffer(a:Int, b:Int) {
		var temp:Image = textures[a];
		textures[a] = textures[b];
		textures[b] = temp;
	}
}
