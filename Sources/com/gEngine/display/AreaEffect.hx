package com.gEngine.display;

import kha.math.FastMatrix4;
import com.gEngine.painters.PaintMode;
import kha.FastFloat;
import com.gEngine.painters.IPainter;
import com.gEngine.display.IDraw;
import com.helpers.MinMax;
import kha.math.FastMatrix3;

class AreaEffect implements IDraw {
	@:access(com.gEngine.GEngine.painter)
	public function new(snapShotShader:IPainter, printShader:IPainter, swapBuffer:Bool = false) {
		if (snapShotShader == null) {
			this.snapShotShader = GEngine.i.painter;
		} else {
			this.snapShotShader = snapShotShader;
		}
		if (printShader == null && !this.swapBuffer) {
			this.printShader = GEngine.i.painter;
		} else {
			this.printShader = printShader;
		}
	}

	/* INTERFACE com.gEngine.display.IDraw */
	private var snapShotShader:IPainter;
	private var printShader:IPainter;
	private var swapBuffer:Bool;

	public var rotation(default, set):Float;
	public var offsetX:FastFloat;
	public var offsetY:FastFloat;
	public var parent:IContainer;
	public var visible:Bool = true;
	public var resolution:Float = 1;

	private var screenScaleX:Float = 1;
	private var screenScaleY:Float = 1;

	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		if (!visible) {
			return;
		}

		paintMode.render();
		var painter = snapShotShader;

		var lastTarger:Int = paintMode.buffer;

		GEngine.i.endCanvas();
		var renderTarget:Int = GEngine.i.getRenderTarget(paintMode.targetWidth, paintMode.targetHeight);
		GEngine.i.setCanvas(renderTarget);
		GEngine.i.beginCanvas();

		painter.start();

		// GEngine.i.renderBuffer2(paintMode.buffer, painter, x, y, width, height, 1, true,transform,paintMode.projection);

		painter.finish();

		if (!swapBuffer) {
			painter = printShader;
			// painter.setProjection(paintMode.projection);
			GEngine.i.endCanvas();
			GEngine.i.setCanvas(lastTarger);
			GEngine.i.beginCanvas();
			painter.start();

			// GEngine.i.renderBuffer2(renderTarget, painter, x, y, width, height, 1, false,transform,paintMode.projection);

			painter.finish();
		} else {
			GEngine.i.swapBuffer(renderTarget, lastTarger);
		}
		GEngine.i.releaseRenderTarget(renderTarget);
	}

	public function update(elapsedTime:Float):Void {}

	public function texture():Int {
		return -666;
	}

	public function removeFromParent():Void {
		parent.remove(this);
		parent = null;
	}

	public function set_rotation(angle:Float):Float {
		return angle;
	}

	public var scaleX:FastFloat;
	public var scaleY:FastFloat;
	public var scaleZ:FastFloat;

	public function getTransformation():FastMatrix3 {
		throw "not implemented copy code from basicsprite";
	}

	/* INTERFACE com.gEngine.display.IDraw */
	public function getDrawArea(value:MinMax, transform:FastMatrix4):Void {
		value.mergeRec(x, y, width, height);
	}

	public function getFinalTransformation():FastMatrix3 {
		throw "not implemented copy code from basicsprite";
	}

	public var x:FastFloat = 0;
	public var y:FastFloat = 0;
	public var z:FastFloat = 0;
	public var width:Float = 1280;
	public var height:Float = 720;
}
