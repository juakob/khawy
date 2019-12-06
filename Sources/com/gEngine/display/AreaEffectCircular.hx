package com.gEngine.display;

import kha.math.FastVector4;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;
import kha.FastFloat;
import com.gEngine.painters.IPainter;
import com.gEngine.display.IDraw;
import com.helpers.MinMax;
import com.helpers.FastPoint;
import kha.math.FastMatrix3;
import kha.math.FastVector2;

@:keep
class AreaEffectCircular implements IDraw {
	private var snapShotShader:IPainter;
	private var printShader:IPainter;

	public var rotation(default, set):Float;
	public var offsetX:FastFloat;
	public var offsetY:FastFloat;

	@:access(com.gEngine.GEngine.painter)
	public function new(?aSnapShotShader:IPainter, ?aPrintShader:IPainter) {
		if (aSnapShotShader == null) {
			snapShotShader = GEngine.i.painter;
		} else {
			snapShotShader = aSnapShotShader;
		}
		if (aPrintShader == null) {
			printShader = GEngine.i.painter;
		} else {
			printShader = aPrintShader;
		}
	}

	private function createDrawFinishRectangle(paintMode:PaintMode, painter:IPainter, transform:FastMatrix4, realWidthRatio:Float, realHeightRatio:Float):Void {
		var leftDirection:FastVector2 = new FastVector2();
		var rigthDirection:FastVector2 = new FastVector2();
		var increments = Math.PI * 2 / numSegments;
		var currentAngle:Float = 0;
		var outsideRadio:Float = radio + stroke / 2;
		var insideRadio:Float = radio;
		var centerX:Float = x;
		var centerY:Float = y;
		var projection = paintMode.projection;
		var tp = projection.multmat(transform);

		var invert:Int = kha.Image.renderTargetsInvertedY() ? 1 : -1;

		for (i in 0...numSegments) {
			leftDirection.x = Math.sin(currentAngle);
			leftDirection.y = Math.cos(currentAngle);
			currentAngle += increments;
			rigthDirection.x = Math.sin(currentAngle);
			rigthDirection.y = Math.cos(currentAngle);

			writeVertexProjectionZoom(painter, tp.multvec(new FastVector4(centerX + leftDirection.x * outsideRadio, centerY + leftDirection.y * outsideRadio,
				z, 1)), tp.multvec(new FastVector4(centerX + leftDirection.x * outsideRadio * zoom, centerY + leftDirection.y * outsideRadio * zoom, z, 1)),
				realWidthRatio, realHeightRatio, invert);

			writeVertexProjectionZoom(painter, tp.multvec(new FastVector4(centerX + rigthDirection.x * outsideRadio, centerY + rigthDirection.y * outsideRadio,
				z, 1)), tp.multvec(new FastVector4(centerX + rigthDirection.x * outsideRadio * zoom, centerY + rigthDirection.y * outsideRadio * zoom, z, 1)),
				realWidthRatio, realHeightRatio, invert);

			writeVertexProjection(painter, tp.multvec(new FastVector4(centerX + leftDirection.x * insideRadio, centerY + leftDirection.y * insideRadio, z, 1)),
				realWidthRatio, realHeightRatio, invert);

			writeVertexProjection(painter, tp.multvec(new FastVector4(centerX + rigthDirection.x * insideRadio, centerY + rigthDirection.y * insideRadio, z,
				1)), realWidthRatio, realHeightRatio, invert);

			///
			insideRadio = outsideRadio;
			outsideRadio = radio + stroke;

			writeVertexProjection(painter, tp.multvec(new FastVector4(centerX + leftDirection.x * outsideRadio, centerY + leftDirection.y * outsideRadio, z,
				1)), realWidthRatio, realHeightRatio, invert);

			writeVertexProjection(painter, tp.multvec(new FastVector4(centerX + rigthDirection.x * outsideRadio, centerY + rigthDirection.y * outsideRadio, z,
				1)), realWidthRatio, realHeightRatio, invert);

			writeVertexProjectionZoom(painter, tp.multvec(new FastVector4(centerX + leftDirection.x * insideRadio, centerY + leftDirection.y * insideRadio, z,
				1)), tp.multvec(new FastVector4(centerX + leftDirection.x * insideRadio * zoom, centerY + leftDirection.y * insideRadio * zoom, z, 1)),
				realWidthRatio, realHeightRatio, invert);

			writeVertexProjectionZoom(painter, tp.multvec(new FastVector4(centerX + rigthDirection.x * insideRadio, centerY + rigthDirection.y * insideRadio,
				z, 1)), tp.multvec(new FastVector4(centerX + rigthDirection.x * insideRadio * zoom, centerY + rigthDirection.y * insideRadio * zoom, z, 1)),
				realWidthRatio, realHeightRatio, invert);

			outsideRadio = insideRadio;
			insideRadio = radio;
		}
	}

	public inline static function writeVertexProjection(painter:IPainter, vertex:FastVector4, realWidthRatio:Float, realHeigthRatio:Float, invert:Int) {
		painter.write(vertex.x / vertex.w);
		painter.write(vertex.y / vertex.w);
		painter.write(vertex.z / vertex.w);
		painter.write((vertex.x / vertex.w + 1) * 0.5 * realWidthRatio);
		painter.write((vertex.y / vertex.w * invert + 1) * 0.5 * realHeigthRatio);
	}

	public inline static function writeVertexProjectionZoom(painter:IPainter, vertex:FastVector4, uv:FastVector4, realWidthRatio:Float,
			realHeigthRatio:Float, invert:Int) {
		painter.write(vertex.x / vertex.w);
		painter.write(vertex.y / vertex.w);
		painter.write(vertex.z / vertex.w);
		painter.write((uv.x / uv.w + 1) * 0.5 * realWidthRatio);
		painter.write((uv.y / uv.w * invert + 1) * 0.5 * realHeigthRatio);
	}

	public function set_rotation(angle:Float):Float {
		return angle;
	}

	public function getDrawArea(value:MinMax, transform:FastMatrix4):Void {
		var cornerX = x - (radio + stroke);
		var cornerY = y - (radio + stroke);
		var diameter = (radio + stroke) * 2;
		value.mergeVec4(transform.multvec(new FastVector4(cornerX, cornerY, z)));
		value.mergeVec4(transform.multvec(new FastVector4(cornerX, cornerY + diameter, z)));
		value.mergeVec4(transform.multvec(new FastVector4(cornerX + diameter, cornerY, z)));
		value.mergeVec4(transform.multvec(new FastVector4(cornerX + diameter, cornerY + diameter, z)));
	}

	/* INTERFACE com.gEngine.display.IDraw */
	public var parent:IContainer;
	public var visible:Bool = true;

	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		if (!visible) {
			return;
		}
		paintMode.render();
		GEngine.i.endCanvas();

		snapShotShader.setProjection(FastMatrix4.identity());
		printShader.setProjection(FastMatrix4.identity());
		var finalTarget:Int = paintMode.buffer;
		var finalTexture = GEngine.i.getTexture(finalTarget);
		var tempTexture:Int = GEngine.i.getRenderTarget(paintMode.targetWidth, paintMode.targetHeight);
		var texture = GEngine.i.getTexture(tempTexture);
		var realWidthRatio:Float = finalTexture.width / finalTexture.realWidth;
		var realHeightRatio:Float = finalTexture.height / finalTexture.realHeight;
		GEngine.i.setCanvas(tempTexture);
		GEngine.i.beginCanvas();
		var zoomTemp:Float = zoom;
		var strokeTemp:Float = stroke;
		var radioTemp:Float = radio;
		snapShotShader.textureID = paintMode.buffer;
		zoom = 1;
		stroke += 6;
		radio -= 5;
		createDrawFinishRectangle(paintMode, snapShotShader, transform, realWidthRatio, realHeightRatio);
		zoom = zoomTemp;
		stroke = strokeTemp;
		radio = radioTemp;
		snapShotShader.render(true);
		GEngine.i.endCanvas();

		realWidthRatio = texture.width / texture.realWidth;
		realHeightRatio = texture.height / texture.realHeight;
		GEngine.i.setCanvas(finalTarget);
		GEngine.i.beginCanvas();
		printShader.textureID = tempTexture;
		createDrawFinishRectangle(paintMode, printShader, transform, realWidthRatio, realHeightRatio);
		printShader.render();

		GEngine.i.releaseRenderTarget(tempTexture);
	}

	public function update(elapsedTime:Float):Void {}

	public function removeFromParent():Void {
		parent.remove(this);
		parent = null;
	}

	public var x:FastFloat = 0;
	public var y:FastFloat = 0;
	public var z:FastFloat = 0;
	public var scaleX:FastFloat = 1;
	public var scaleY:FastFloat = 1;
	public var scaleZ:FastFloat = 1;

	public function getTransformation():FastMatrix3 {
		throw "not implemented copy code from basicsprite";
	}

	public function getFinalTransformation():FastMatrix3 {
		throw "not implemented copy code from basicsprite";
	}

	public var radio:Float = 100;
	public var stroke:Float = 50;
	public var numSegments:Int = 20;
	public var zoom:Float = .85;
	public var width:Float = 10;
	public var height:Float = 10;
	public var resolution:Float = 1;
}
