package com.gEngine;

import kha.Image;
import kha.math.FastMatrix4;
import com.gEngine.display.IDraw;
import com.gEngine.display.Layer;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.PaintMode;
import com.gEngine.shaders.RenderPass;
import com.gEngine.shaders.ShDontRender;
import com.gEngine.shaders.ShRender;
import com.helpers.MinMax;
import kha.Color;
import kha.FastFloat;

class Filter {
	private var renderPass:Array<RenderPass>;
	var red:FastFloat = 0;
	var green:FastFloat = 0;
	var blue:FastFloat = 0;
	var alpha:FastFloat = 0;
	var cropScreen:Bool;
	var drawArea:MinMax;
	var finishTarget:Int;
	var workTargetId:Int;
	var scaleRenderArea:MinMax = new MinMax();

	public function new(filters:Array<IPainter> = null, r:FastFloat = 0, g:FastFloat = 0, b:FastFloat = 0, a:FastFloat = 0, cropScreen:Bool = true) {
		red = r;
		green = g;
		blue = b;
		alpha = a;
		this.cropScreen = cropScreen;
		renderPass = new Array();
		drawArea = new MinMax();
		

		if (filters != null) {
			setPasses(filters);
		}
	}

	public function setPasses(filters:Array<IPainter>) {
		var passFilters:Array<IPainter> = new Array();
		renderPass = new Array();
		for (filter in filters) {
			if (Std.is(filter, ShRender)) {
				renderPass.push(new RenderPass(passFilters, true));
				passFilters = new Array();
				continue;
			}
			if (Std.is(filter, ShDontRender)) {
				renderPass.push(new RenderPass(passFilters, false));
				passFilters = new Array();
				continue;
			}
			passFilters.push(filter);
		}
		if (passFilters.length != 0) {
			renderPass.push(new RenderPass(passFilters, true));
		}

		for (renderPass in renderPass) {
			var length:Int = renderPass.filters.length;
			if (renderPass.renderAtEnd) {
				length -= 1;
			}
			// for (i in 0...length)
			// {
			// aFilters[i].multipassBlend();
			// }
		}
	}

	public function filterStart(display:IDraw, paintMode:PaintMode, transform:FastMatrix4):Void {
		if (!this.cropScreen) {
			drawArea.min.setTo(0, 0);
			drawArea.max.setTo(paintMode.camera.width,paintMode.camera.height);
		}
		if (renderPass.length == 0) {
			return;
		}
		paintMode.render();
		finishTarget = GEngine.i.currentCanvasId();
		var finshTargetImage:Image=cast GEngine.i.currentCanvas();
		workTargetId = GEngine.i.getRenderTarget(paintMode.camera.width, paintMode.camera.height);
		GEngine.i.endCanvas();
		GEngine.i.setCanvas(workTargetId);
		var g4 = GEngine.i.currentCanvas().g4;
		// g4.scissor(0, 0, paintMode.targetWidth,paintMode.targetHeight);
		// g4.begin();
		
		var currentWorkingTarget:Image=cast GEngine.i.currentCanvas();
		currentWorkingTarget.setDepthStencilFrom(finshTargetImage);
		GEngine.i.beginCanvas();
		
		g4.clear(Color.fromFloats(red, green, blue, alpha));
		if (cropScreen) {
			drawArea.reset();
			display.getDrawArea(drawArea, transform);

			if (paintMode.hasRenderArea()) {
				drawArea.intersection(paintMode.getRenderArea());
				//	drawArea.scale(1/GEngine.i.scaleWidth,1/GEngine.i.scaleHeigth);
			}
		}
		// paintMode.render();

		if (drawArea.isEmpty) {
			GEngine.i.endCanvas();
			GEngine.i.releaseRenderTarget(workTargetId);
			GEngine.i.setCanvas(finishTarget);
			GEngine.i.beginCanvas();
		}
	}

	public function filterEnd(paintMode:PaintMode):Void {
		if (drawArea.isEmpty) {
			return;
		}
		paintMode.render();
		GEngine.i.endCanvas();
		var counter:Int = renderPass.length;
		for (renderPass in renderPass) {
			--counter;
			var filters:Array<IPainter> = renderPass.filters;
			var resolution:Float = 1;
			var length:Int;
			if (renderPass.renderAtEnd) {
				length = filters.length - 1; // dont iterate over the last one
			} else {
				length = filters.length;
			}
			for (i in 0...length) {
				var sourceImg = workTargetId;
				workTargetId = GEngine.i.getRenderTarget(paintMode.camera.width, paintMode.camera.height);

				GEngine.i.setCanvas(workTargetId);
				GEngine.i.beginCanvas();
				var filter:IPainter = filters[i];
				filter.setProjection(paintMode.camera.screenTransform);
				filter.adjustRenderArea(drawArea);
				renderBuffer(sourceImg, filter, drawArea.min.x, drawArea.min.y, drawArea.width(), drawArea.height(), 1 / resolution, true, resolution * filter
					.resolution);
				resolution *= filter.resolution;
				if (filter.releaseTexture())
					GEngine.i.releaseRenderTarget(sourceImg);
				GEngine.i.endCanvas();
			}
			if (renderPass.renderAtEnd) {
				GEngine.i.setCanvas(finishTarget);
				GEngine.i.beginCanvas();
				var filter:IPainter = filters[filters.length - 1];
				filter.setProjection(paintMode.camera.screenTransform);
				filter.adjustRenderArea(drawArea);
				var scale = 1 / resolution;
				renderBuffer(workTargetId, filter, drawArea.min.x, drawArea.min.y, drawArea.width(), drawArea.height(), scale, false);
				if (filter.releaseTexture() && counter == 0)
					GEngine.i.releaseRenderTarget(workTargetId);
				if (0 != counter) {
					GEngine.i.endCanvas();
				}
			}
		}
	}

	public function renderBuffer(source:Int, painter:IPainter, x:Float, y:Float, width:Float, height:Float, sourceScale:Float, clear:Bool, outScale:Float = 1) {
		painter.textureID = source;
		var tex = GEngine.i.getTexture(source);
		var texWidth = tex.realWidth * sourceScale;
		var texHeight = tex.realHeight * sourceScale;
		outScale *= GEngine.i.oversample;

		writeVertex(painter, x, y, 0, texWidth, texHeight, outScale);

		writeVertex(painter, x + width, y, 0, texWidth, texHeight, outScale);

		writeVertex(painter, x, y + height, 0, texWidth, texHeight, outScale);

		writeVertex(painter, x + width, y + height, 0, texWidth, texHeight, outScale);

		painter.render(clear);
	}

	inline function writeVertex(painter:IPainter, x:Float, y:Float, z:Float, sWidth:Float, sHeight:Float, resolution:Float) {
		painter.write(x * resolution);
		painter.write(y * resolution);
		painter.write(z);
		painter.write(x * resolution / sWidth);
		painter.write(y * resolution / sHeight);
	}
}
