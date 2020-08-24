package com.gEngine.display;

import kha.Image;
import kha.math.FastVector4;
import kha.math.FastVector3;
import kha.math.FastVector2;
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

	public var x:FastFloat = 0;
	public var y:FastFloat = 0;
	public var z:FastFloat = 0;
	public var width:Float = 1280;
	public var height:Float = 720;
	/**
	 * overscale to avoid discontinue borders
	 */
	public var sourceOverscale:Float=0;

	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		if (!visible) {
			return;
		}

		paintMode.render();
		var painter = snapShotShader;

		var lastTarger:Int = GEngine.i.currentCanvasId();

		GEngine.i.endCanvas();
		var renderTarget:Int = GEngine.i.getRenderTarget(paintMode.camera.width, paintMode.camera.height);
		GEngine.i.setCanvas(renderTarget);
		GEngine.i.beginCanvas();

		painter.start();
		painter.setProjection(paintMode.camera.projection);
		renderBuffer(paintMode.camera.renderTarget, painter, x-10, y-10, width+20, height+20, true,transform,1,1);

		painter.finish();

		if (!swapBuffer) {
			painter = printShader;
			GEngine.i.endCanvas();
			GEngine.i.setCanvas(lastTarger);
			GEngine.i.beginCanvas();
			painter.start();
			painter.setProjection(paintMode.camera.projection);
			renderBuffer(renderTarget, painter, x,y, width, height, false,transform, 1,1);

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

	function renderBuffer(source:Int, painter:IPainter, x:Float, y:Float, width:Float, height:Float, clear:Bool, transform:FastMatrix4,sourceScale:Float,outScale:Float) {
		painter.textureID = source;

		var p1=transform.multvec(new FastVector4(x,y,z));
		var p2=transform.multvec(new FastVector4(x+width,y,z));
		var p3=transform.multvec(new FastVector4(x,y+height,z));
		var p4=transform.multvec(new FastVector4(x+width,y+height,z));
		var tex = GEngine.i.getTexture(source);
		var texWidth = tex.realWidth * sourceScale * 1 / GEngine.i.oversample;
		var texHeight = tex.realHeight * sourceScale * 1 / GEngine.i.oversample;

		writeVertex(painter, p1, texWidth, texHeight, outScale);

		writeVertex(painter, p2, texWidth, texHeight, outScale);

		writeVertex(painter, p3, texWidth, texHeight, outScale);

		writeVertex(painter, p4, texWidth, texHeight, outScale);

		painter.render(clear);
	}

	static  function writeVertex(painter:IPainter, pos:FastVector4, sWidth:Float, sHeight:Float, resolution:Float) {
		painter.write(pos.x * resolution);
		painter.write(pos.y * resolution);
		painter.write(pos.z);
		painter.write((pos.x / sWidth)+0.5);
		var invert=Image.renderTargetsInvertedY()?-1:1;
		painter.write((pos.y / sHeight)*invert+0.5);
	}
}
