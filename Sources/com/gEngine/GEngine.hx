package com.gEngine;

import com.debug.Profiler;
import kha.math.FastVector2;
import com.gEngine.display.BlendMode;
import com.gEngine.painters.PainterColorTransform;
import com.gEngine.painters.PainterAlpha;
import kha.graphics4.Graphics;
import com.framework.utils.Input;
import com.gEngine.display.Blend;
import com.gEngine.display.DisplayObject;
import com.gEngine.display.Stage;
import com.gEngine.helpers.RectangleDisplay;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.Painter;
import com.gEngine.helpers.RenderTargetPool;
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

	private var textures:Array<Image>;
	public var stage:Stage;
	var modelViewMatrix:FastMatrix4;

	inline static var initialIndex:Int = 2;

	public var oversample:Float = 1;

	var renderTargetPool:RenderTargetPool;
	var currentRenderTargetId:Int = -1;
	var resizeRequire:Bool;
	var newSize:FastVector2=new FastVector2();
	
	#if (debugInfo || profile || profile_light || profile_deep)
	private var deltaTime:Float = 0.0;
	private var totalFrames:Int = 0;
	private var elapsedTime:Float = 0.0;
	private var previousTime:Float = 0.0;
	private var fps:Int = 0;

	public static var drawCount:Int = 0;
	public static var maxDrawCount:Int = 99999999;

	public var font:kha.Font;

	public static var extraInfo:String = "";

	var fontLoaded:Bool;
	var identity3x3 = FastMatrix3.identity();
	#end

	private function new(oversample:Float, antiAlias:Int) {
		clearColor = Color.fromFloats(0, 0, 0, 1);

		antiAliasing = antiAlias;
		this.oversample = oversample;

		Window.get(0).notifyOnResize(resizeInput);

		PainterGarbage.init();

		renderTargetPool = new RenderTargetPool();

		textures = new Array();

		createPainters();

		// createBuffer(Screen.getWidth(), Screen.getHeight());
		trace(com.gEngine.helpers.Screen.getWidth() + "x" + com.gEngine.helpers.Screen.getHeight());
		calculateModelViewMatrix(com.gEngine.helpers.Screen.getWidth(), com.gEngine.helpers.Screen.getHeight());

		var recTexture = Image.createRenderTarget(1, 1);
		recTexture.g2.begin(true, Color.White);
		recTexture.g2.end();
		var id=textures.push(recTexture)-1;
		RectangleDisplay.init(id);
	}

	public inline function getSimplePainter(blend:BlendMode) {
		return simplePainters[0];
	}
	public inline function getSimplePainters() {
		return simplePainters;
	}

	public inline function getAlphaPainter(blend:BlendMode) {
		return alphaPainters[0];
	}
	public inline function getAlphaPainters() {
		return alphaPainters;
	}

	public inline function getColorTransformPainter(blend:BlendMode) {
		return colorPainters[0];
	}

	public inline function getColorTransformPainters() {
		return colorPainters;
	}

	function calculateModelViewMatrix(targetWidth:Int, targetHeight:Int):Void {
		if (this.width == targetWidth && this.height == targetHeight)
			return;
		this.width = Std.int(targetWidth * oversample);
		this.height = Std.int(targetHeight * oversample);

		modelViewMatrix = FastMatrix4.orthogonalProjection(0, this.width, this.height, 0, 0, 5000);
		if (Image.renderTargetsInvertedY()) {
			modelViewMatrix.setFrom(FastMatrix4.scale(1, -1, 1).multmat(modelViewMatrix));
		}
	}

	public function resize(width:Int,height:Int) {
		resizeRequire = true;
		newSize.x = width;
		newSize.y = height;
	}

	public function createDefaultPainters():Void {
		stage = new Stage();
	}

	public static function init(virtualWidth:Int, virtualHeight:Int, oversample:Float, antiAlias:Int):Void {
		GEngine.virtualWidth = virtualWidth;
		GEngine.virtualHeight = virtualHeight;
		i = new GEngine(oversample, antiAlias);
		#if (debugInfo || profile || profile_light || profile_deep)
		Assets.loadFont("mainfont", setFont);
		#end
	}

	#if (debugInfo || profile || profile_light || profile_deep)
	static private function setFont(aFont:kha.Font) {
		i.font = aFont;
		i.fontLoaded = true;
	}
	#end

	public function resizeInput(availWidth:Int, availHeight:Int) {
		if (availWidth == 0 || availWidth == 0)
			return;
		Input.i.screenScale.setTo(virtualWidth / availWidth, virtualHeight / availHeight);
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

	private var frameBuffer:Framebuffer;

	static inline var frameBufferID:Int = -1;

	private var renderCustomBuffer:Bool;
	private var customBuffer:Image;
	private var antiAliasing:Int = 0;

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

	public function setFrameBufferAsCanvas() {
		renderCustomBuffer = false;
	}

	public function setCanvas(id:Int):Void {
		currentRenderTargetId = id;
		if (currentRenderTargetId != frameBufferID) {
			renderCustomBuffer = true;
			customBuffer = textures[id];
		} else {
			setFrameBufferAsCanvas();
		}
	}

	public function setCanvasFromImage(image:Image):Void {
		renderCustomBuffer = true;
		customBuffer = image;
	}

	function createPainters() {
		var blends:Array<Blend> = [
			Blend.blendDefault(),
		];
		simplePainters = new Array();
		alphaPainters = new Array();
		colorPainters = new Array();
		for (blend in blends) {
			simplePainters.push(new Painter(false, blend));
			alphaPainters.push(new PainterAlpha(false, blend));
			colorPainters.push(new PainterColorTransform(false, blend));
		}
	}

	public function endCanvas() {
		#if debug
		if (!currentCanvasActive) {
			throw ("Warning :start buffer before you end it");
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
			throw ("Warning :end buffer before you start ");
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
		return frameBuffer;
	}

	public function getMatrix():FastMatrix4 {
		return modelViewMatrix;
	}

	public function renderToFrameBuffer(source:Int, painter:IPainter, x:Float, y:Float, width:Float, height:Float, sourceScale:Float, clear:Bool,
			outScale:Float = 1,matrixSize:Bool=false) {
		painter.textureID = source;
		if (!matrixSize) {
			painter.setProjection(getMatrix());
		}else{
			var mvp = FastMatrix4.orthogonalProjection(0, currentCanvas().width, currentCanvas().height, 0, 0, 5000);
			if (Image.renderTargetsInvertedY()) {
				mvp.setFrom(FastMatrix4.scale(1, -1, 1).multmat(mvp));
			}
			painter.setProjection(mvp);
		}
		
		var text = getTexture(source);
		writeVertexFull(painter, x, y, 0, 0, 0, outScale);

		writeVertexFull(painter, (x + width) * scaleWidth, y * scaleHeigth, 0, width * oversample / (text.realWidth), 0, outScale);

		writeVertexFull(painter, x * scaleWidth, (y + height) * scaleHeigth, 0, 0, height * oversample / (text.realHeight), outScale);

		writeVertexFull(painter, (x + width) * scaleWidth, (y + height) * scaleHeigth, 0, width * oversample / (text.realWidth),
			height * oversample / (text.realHeight), outScale);

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

	public function draw(frameBuffer:Framebuffer, clear:Bool = true, needRefresh:Bool):Void {
		if(resizeRequire){
			resizeRequire = false;
			var width = Math.round(newSize.x);
			var height = Math.round(newSize.y);
			calculateModelViewMatrix(width, height);
			stage.defaultCamera().resize(width,height);
			releaseUnuseRenderTargets();
		}
		if (frameBuffer.width * oversample != width || frameBuffer.height * oversample != height)
			resizeInput(frameBuffer.width, frameBuffer.height);

		calculateFPS();
		this.frameBuffer = frameBuffer;
		var g:Graphics = frameBuffer.g4;
		g.begin();
		if (clear)
			g.clear(clearColor, 1);
		g.end();
		stage.render(needRefresh);
		drawDebugInfo(frameBuffer);
	}

	function calculateFPS() {
		#if (debugInfo || profile || profile_light || profile_deep)
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
	}

	function drawDebugInfo(frameBuffer:Framebuffer) {
		#if (debugInfo || profile || profile_light || profile_deep)
		// frameBuffer.g2.transformation = FastMatrix3.identity();
		#if (profile || profile_light || profile_deep)
		Profiler.beginFrame();
		if (Input.i != null) {
			if (Input.i.isKeyCodePressed(kha.input.KeyCode.F6)) {
				Profiler.toggleOverlay();
			}
			if (Input.i.isKeyCodePressed(kha.input.KeyCode.F7)) {
				Profiler.clear();
			}
			if (Input.i.isKeyCodePressed(kha.input.KeyCode.F8)) {
				Profiler.toggleCompact();
			}
			if (Input.i.isKeyCodePressed(kha.input.KeyCode.F9)) {
				Profiler.toggleGraph();
			}
			if (Input.i.isKeyCodePressed(kha.input.KeyCode.F10)) {
				Profiler.toggleFreeze();
			}
		}
		#end
		if (fontLoaded) {
			var g2 = frameBuffer.g2;
			g2.begin(false);
			g2.transformation = identity3x3;
			g2.font = font;
			g2.fontSize = 16;
			var yOffset:Int = 0;
			#if debugInfo
			g2.color = 0xD0000000;
			g2.fillRect(0, yOffset, 340, 20);
			g2.color = 0xFFFFFFFF;
			g2.drawString("drawCount: " + drawCount + "         fps: " + fps + " " + extraInfo, 10, yOffset + 2);
			yOffset += 22;
			#end
			#if (profile || profile_light || profile_deep)
			var profileLines = Profiler.getOverlayLines(10, 18);
			if (profileLines.length > 0) {
				var maxChars:Int = 0;
				for (line in profileLines) {
					if (line.length > maxChars) {
						maxChars = line.length;
					}
				}
				var panelWidth = Std.int(Math.min(frameBuffer.width, maxChars * 8 + 20));
				var panelHeight = profileLines.length * 16 + 8;
				g2.color = 0xB0000000;
				g2.fillRect(0, yOffset, panelWidth, panelHeight);
				g2.color = 0xFFFFFFFF;
				var lineY:Int = yOffset + 2;
				for (line in profileLines) {
					g2.drawString(line, 10, lineY);
					lineY += 16;
				}
				if (Profiler.isGraphVisible()) {
					yOffset += panelHeight + 4;
					drawProfileGraph(g2, frameBuffer, 0, yOffset, Std.int(Math.max(panelWidth, 420)));
				}
			}
			#end
			g2.end();
		}
		#if debugInfo
		drawCount = 0;
		#end
		#end
	}

	#if (profile || profile_light || profile_deep)
	function drawProfileGraph(g2:kha.graphics2.Graphics, frameBuffer:Framebuffer, x:Int, y:Int, width:Int):Void {
		var frames = Profiler.getFrameHistory();
		if (frames.length == 0) {
			return;
		}

		var updates = Profiler.getUpdateHistory();
		var renders = Profiler.getRenderHistory();
		var idles = Profiler.getIdleHistory();
		var budget60 = Profiler.getBudget60Ms();
		var budget30 = Profiler.getBudget30Ms();
		var breakdownCount = Profiler.getRenderBreakdownCount();
		var breakdownRows = Std.int(Math.min(6, breakdownCount));
		var breakdownHeight = 26 + (breakdownRows == 0 ? 14 : breakdownRows * 16);

		var panelWidth = Std.int(Math.min(frameBuffer.width - x, width));
		if (panelWidth < 120) {
			return;
		}
		var panelHeight = 132 + breakdownHeight;
		var plotX = x + 8;
		var plotY = y + 22;
		var plotWidth = panelWidth - 16;
		var plotHeight = 90;

		g2.color = 0xB0000000;
		g2.fillRect(x, y, panelWidth, panelHeight);

		var maxMs = budget30;
		for (value in frames) {
			if (value > maxMs) {
				maxMs = value;
			}
		}
		if (maxMs < budget30) {
			maxMs = budget30;
		}
		maxMs *= 1.1;

		var scaleY = plotHeight / maxMs;
		var y60 = plotY + plotHeight - Std.int(budget60 * scaleY);
		var y30 = plotY + plotHeight - Std.int(budget30 * scaleY);

		g2.color = 0x50FFFFFF;
		g2.fillRect(plotX, y60, plotWidth, 1);
		g2.fillRect(plotX, y30, plotWidth, 1);
		g2.color = 0xFFFFFFFF;
		g2.drawString("60fps", plotX + 2, y60 - 12);
		g2.drawString("30fps", plotX + 2, y30 - 12);

		var sampleCount = frames.length;
		var maxBars = plotWidth;
		var start = sampleCount > maxBars ? sampleCount - maxBars : 0;
		var visible = sampleCount - start;
		var barWidth = Std.int(Math.max(1, Math.floor(plotWidth / visible)));
		var xCursor = plotX;
		var baseY = plotY + plotHeight;

		for (i in start...sampleCount) {
			var frameMs = frames[i];
			var updateMs = i < updates.length ? updates[i] : 0;
			var renderMs = i < renders.length ? renders[i] : 0;
			var idleMs = i < idles.length ? idles[i] : 0;

			var frameH = Std.int(Math.min(plotHeight, frameMs * scaleY));
			var updateH = Std.int(updateMs * scaleY);
			var renderH = Std.int(renderMs * scaleY);
			var idleH = Std.int(idleMs * scaleY);
			var stack = updateH + renderH + idleH;
			if (stack > frameH && stack > 0) {
				var f = frameH / stack;
				updateH = Std.int(updateH * f);
				renderH = Std.int(renderH * f);
				idleH = frameH - updateH - renderH;
			}

			var yCursor = baseY;
			if (idleH > 0) {
				yCursor -= idleH;
				g2.color = 0xFF606060;
				g2.fillRect(xCursor, yCursor, barWidth, idleH);
			}
			if (renderH > 0) {
				yCursor -= renderH;
				g2.color = 0xFF4DD17C;
				g2.fillRect(xCursor, yCursor, barWidth, renderH);
			}
			if (updateH > 0) {
				yCursor -= updateH;
				g2.color = 0xFF4FA3FF;
				g2.fillRect(xCursor, yCursor, barWidth, updateH);
			}
			if (frameMs > budget60) {
				var overMs = frameMs - budget60;
				var overH = Std.int(overMs * scaleY);
				if (overH > 0) {
					g2.color = frameMs > budget30 ? 0xE0FF3B30 : 0xE0FF9F0A;
					g2.fillRect(xCursor, baseY - frameH, barWidth, overH);
				}
			}
			g2.color = 0xCCFFFFFF;
			g2.fillRect(xCursor, baseY - frameH, barWidth, 1);

			xCursor += barWidth;
			if (xCursor >= plotX + plotWidth) {
				break;
			}
		}

		var last = frames[frames.length - 1];
		var percent60 = budget60 > 0 ? (last / budget60) * 100 : 0;
		var percent30 = budget30 > 0 ? (last / budget30) * 100 : 0;
		g2.color = 0xFFFFFFFF;
		g2.drawString("last " + Std.int(last * 100) / 100 + "ms  60fps:" + Std.int(percent60 * 10) / 10 + "%  30fps:" + Std.int(percent30 * 10) / 10 + "%", plotX, y + 4);
		g2.drawString("bars: update(blue) render(green) idle(gray)", plotX, y + 104);

		var detailY = y + 120;
		var renderTotal = Profiler.getRenderTotalMs();
		g2.color = 0x70FFFFFF;
		g2.fillRect(plotX, detailY - 6, plotWidth, 1);
		g2.color = 0xFFFFFFFF;
		g2.drawString("render breakdown (" + Std.int(renderTotal * 100) / 100 + "ms total)", plotX, detailY);

		if (breakdownRows == 0) {
			g2.drawString("no render samples", plotX, detailY + 14);
			return;
		}

		var barAreaX = plotX + 170;
		var barAreaW = Std.int(Math.max(40, plotWidth - 170));
		for (row in 0...breakdownRows) {
			var name = Profiler.getRenderBreakdownName(row);
			var ms = Profiler.getRenderBreakdownMs(row);
			var pct = Profiler.getRenderBreakdownPercent(row);
			var rowY = detailY + 14 + row * 16;
			if (name.length > 22) {
				name = name.substr(0, 22) + "..";
			}
			g2.color = 0xFFFFFFFF;
			g2.drawString(name + " " + Std.int(ms * 100) / 100 + "ms", plotX, rowY);
			g2.color = 0x40404040;
			g2.fillRect(barAreaX, rowY + 3, barAreaW, 8);
			var fillW = Std.int(barAreaW * Math.min(1.0, pct / 100));
			if (fillW > 0) {
				g2.color = 0xFFFC9F2A;
				g2.fillRect(barAreaX, rowY + 3, fillW, 8);
			}
			g2.color = 0xFFFFFFFF;
			g2.drawString(Std.int(pct * 10) / 10 + "%", barAreaX + barAreaW + 4, rowY);
		}
	}
	#end

	public function addChild(draw:DisplayObject):Void {
		stage.addChild(draw);
	}

	public function getRenderTarget(width:Int, height:Int):Int {
		var id:Int = renderTargetPool.getFreeImageId(width, height);
		if (id == -1) {
			var target:Image = Image.createRenderTarget(Std.int(width * oversample), Std.int(height * oversample),null,NoDepthAndStencil,8);
			id = textures.push(target) - 1;
			renderTargetPool.addRenderTarget(id, width, height);
		}
		return id;
	}

	public function releaseRenderTarget(id:Int) {
		renderTargetPool.release(id);
	}
	public function releaseUnuseRenderTargets():Void {
		for (proxy in renderTargetPool.targets) {
			if(!proxy.inUse){
				textures[proxy.textureId].unload();
			}
		}
		renderTargetPool.removeUnused();
	}

	public function adjustRenderTargets():Void {
		for (proxy in renderTargetPool.targets) {
			textures[proxy.textureId].unload();
			textures[proxy.textureId] = Image.createRenderTarget(width, height, null, DepthStencilFormat.NoDepthAndStencil, antiAliasing);
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
