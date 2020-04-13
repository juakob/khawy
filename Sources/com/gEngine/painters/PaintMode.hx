package com.gEngine.painters;

import com.gEngine.display.Camera;
import kha.math.FastMatrix4;
import kha.arrays.Float32Array;
import com.helpers.MinMax;
import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureFilter;
import com.gEngine.display.BlendMode;

class PaintMode {
	public var currentPainter(default, null):IPainter;

	var paintInfo:PaintInfo;
	var renderArea:Array<MinMax>;
	var renderAreaUnion:MinMax;

	public var camera:Camera;

	public var mulR:Float = 1;
	public var mulG:Float = 1;
	public var mulB:Float = 1;
	public var mulA:Float = 1;

	public var addR:Float = 0;
	public var addG:Float = 0;
	public var addB:Float = 0;
	public var addA:Float = 0;

	public var colorTransform:Bool;

	public function new() {
		renderArea = new Array();
		renderAreaUnion = new MinMax();
	}

	public function render(clear:Bool = false):Void {
		if (currentPainter != null) {
			currentPainter.setProjection(camera.projection);
			if (renderArea.length > 0) {
				currentPainter.render(clear, renderAreaUnion);
			} else {
				currentPainter.render(clear);
			}
		}
	}

	public function changePainter(painter:IPainter, paintInfo:PaintInfo) {
		currentPainter = painter;
		currentPainter.textureID = paintInfo.texture;
		currentPainter.mipMapFilter = paintInfo.mipMapFilter;
		currentPainter.filter = paintInfo.textureFilter;
		this.paintInfo = paintInfo;
	}

	public function canBatch(info:PaintInfo, size:Int, painter:IPainter):Bool {
		return currentPainter == painter && currentPainter.canBatch(info, size);
	}

	public function adjustRenderArea(area:MinMax) {
		var length = renderArea.push(area);
		if (length == 1) {
			renderAreaUnion.setFrom(area);
		} else {
			renderAreaUnion.intersection(area);
		}
	}

	public function resetRenderArea() {
		renderArea.pop();
		renderAreaUnion.reset();
		for (area in renderArea) {
			renderAreaUnion.intersection(area);
		}
	}

	public function getRenderArea():MinMax {
		return renderAreaUnion;
	}

	public function hasRenderArea():Bool {
		return renderArea.length > 0;
	}

	public function vertexCount() {
		if (currentPainter != null) {
			return currentPainter.vertexCount();
		}
		return 0;
	}

	public function isVisible(area:MinMax):Bool {
		return renderAreaUnion.contains(area);
	}
}
