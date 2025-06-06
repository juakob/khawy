package com.gEngine.display;

import kha.math.FastVector3;
import com.helpers.SIMDOperations;
import com.gEngine.helpers.Timeline;
import kha.math.FastVector4;
import kha.math.FastMatrix4;
import com.gEngine.AnimationData;
import com.gEngine.DrawArea;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.PaintInfo;
import com.gEngine.painters.PaintMode;
import com.gEngine.painters.Painter;
import com.gEngine.display.IAnimation;
import com.gEngine.painters.PainterAlpha;
import com.gEngine.painters.PainterColorTransform;
import com.helpers.MinMax;
import kha.FastFloat;
import kha.arrays.Float32Array;
import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureFilter;
import kha.math.FastMatrix3;

class Sprite implements IAnimation implements IRotation {
	public var x:FastFloat = 0;
	public var y:FastFloat = 0;
	public var z:FastFloat = 0;
	public var scaleX:FastFloat = 1;
	public var scaleY:FastFloat = 1;
	public var scaleZ:FastFloat = 1;
	public var rotation(default, set):Float;
	public var blend:BlendMode = BlendMode.Default;

	private var cosAng:FastFloat;
	private var sinAng:FastFloat;

	public var pivotX:FastFloat = 0;
	public var pivotY:FastFloat = 0;
	public var offsetX:FastFloat = 0;
	public var offsetY:FastFloat = 0;
	public var offsetZ:FastFloat = 0;

	private var animationData:AnimationData;
	private var mTileSheetId:Int;

	public var parent:IContainer;
	public var visible:Bool = true;
	public var alpha:FastFloat = 1;
	public var skewX(default, set):FastFloat = 0;
	public var skewY(default, set):FastFloat = 0;

	private var tanSkewX:FastFloat = 0;
	private var tanSkewY:FastFloat = 0;
	private var colorTransform:Bool = false;
	private var addRed:FastFloat = 0;
	private var addGreen:FastFloat = 0;
	private var addBlue:FastFloat = 0;
	private var addAlpha:FastFloat = 0;
	private var mulRed:FastFloat = 1;
	private var mulGreen:FastFloat = 1;
	private var mulBlue:FastFloat = 1;
	private var textureId:Int = -1;
	private var dataUnique:Bool = false;

	public var smooth(get, set):Bool;
	public var textureFilter:TextureFilter = TextureFilter.LinearFilter;
	public var mipMapFilter:MipMapFilter = MipMapFilter.LinearMipFilter;

	var transform:FastMatrix4;
	var rotation3d:FastMatrix4;

	public var billboard:Bool;
	public var customPainter:Painter;
	public var filter:Filter;
	public var timeline(default, null):Timeline;

	var alphaPainters:Array<PainterAlpha>;
	var colorPainters:Array<PainterColorTransform>;

	var paintInfo:PaintInfo;

	public function new(name:String = null) {
		if (name != null) {
			animationData = com.basicDisplay.SpriteSheetDB.i.getData(name);
		}
		transform = FastMatrix4.identity();
		#if PIXEL_GAME
		smooth = false;
		#end

		paintInfo = new PaintInfo();
		timeline = new Timeline(1 / 30, animationData.frames.length, animationData.labels);
		scaleX = 1;
		scaleY = 1;
		rotation = 0;
		cosAng = Math.cos(rotation);
		sinAng = Math.sin(rotation);

		textureId = animationData.texturesID;

		alphaPainters = GEngine.i.getAlphaPainters();
		colorPainters = GEngine.i.getColorTransformPainters();
	}

	public function clone():Sprite {
		var cl = new Sprite();
		cl.animationData = animationData;
		return cl;
	}

	public function recenter():Void {
		var rec = localDrawArea();
		pivotX = rec.x + rec.width / 2;
		pivotY = rec.y + rec.height / 2;
	}

	public function rotation3D(yaw:FastFloat, pitch:FastFloat, roll:FastFloat) {
		var rotation = FastMatrix4.rotation(yaw, pitch, roll);
		if (rotation3d == null) {
			rotation3d = rotation;
		} else {
			rotation3d.setFrom(rotation);
		}
	}

	public function set_rotation(value:Float):FastFloat {
		if (value != rotation) {
			rotation = value;
			sinAng = Math.sin(value);
			cosAng = Math.cos(value);
		}
		return rotation;
	}

	public function update(dt:Float):Void {
		timeline.update(dt);
	}

	function makeAnimationDataUnique() {
		animationData = animationData.clone();
		dataUnique = true;
	}

	public function getAnimationData():AnimationData {
		if (!dataUnique)
			makeAnimationDataUnique();
		return animationData;
	}

	inline function calculateTransform(transform:FastMatrix4) {
		this.transform.setFrom(FastMatrix4.identity());
		this.transform._00 = cosAng * scaleX;
		this.transform._10 = -sinAng * scaleY;
		this.transform._30 = x ;

		this.transform._01 = sinAng * scaleX;
		this.transform._11 = cosAng * scaleY;
		this.transform._31 = y ;

		this.transform._22 = scaleZ;
		this.transform._32 = z;
		if (billboard) {
			var rotation = transform.inverse();
			rotation._30 = rotation._31 = rotation._32 = 0;
			this.transform.setFrom(this.transform.multmat(rotation));
		}
		if (rotation3d != null) {
			this.transform.setFrom(this.transform.multmat(rotation3d));
		}
	}

	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		if (!visible) {
			return;
		}
		if (filter != null)
			filter.filterStart(this, paintMode, transform);

		calculateTransform(transform);
		var model = transform.multmat(this.transform);
		#if cpp
		SIMDOperations.setMatrix(model);
		#end

		paintInfo.blend = blend;
		if (animationData.hasMipMap) {
			paintInfo.mipMapFilter = mipMapFilter;
		} else {
			paintInfo.mipMapFilter = NoMipFilter;
		}
		paintInfo.textureFilter = textureFilter;
		paintInfo.texture = textureId;

		if (colorTransform || paintMode.colorTransform || customPainter != null) {
			renderWithColorTransform(paintMode, model);
		} else {
			renderWithAlpha(paintMode, model);
		} // else {
		//	renderWithSimplePainter(paintMode,model);
		// }

		if (filter != null)
			filter.filterEnd(paintMode);
	}

	public function renderFastColor(paintMode:PaintMode, transform:FastMatrix4, frame:Int):Void {
		// calculateTransform(transform);
		paintInfo.blend = blend;
		//paintInfo.mipMapFilter = mipMapFilter;
		//
		paintInfo.textureFilter = textureFilter;
		paintInfo.texture = textureId;
		timeline.currentFrame = frame;
		renderWithColorTransform(paintMode, transform);
	}

	public function renderFastAlpha(paintMode:PaintMode, transform:FastMatrix4, frame:Int):Void {
		// calculateTransform(transform);
		paintInfo.blend = blend;
		//paintInfo.mipMapFilter = mipMapFilter;
		paintInfo.textureFilter = textureFilter;
		paintInfo.texture = textureId;
		timeline.currentFrame = frame;
		renderWithAlpha(paintMode, transform);
	}

	function renderWithAlpha(paintMode:PaintMode, model:FastMatrix4) {
		var frame = animationData.frames[timeline.currentFrame];
		var vertexs:Array<FastFloat> = frame.vertexs;
		var cameraScale = paintMode.camera.scale;
		var uvs = frame.UVs;
		var painter:PainterAlpha = alphaPainters[0];
		checkBatchAlpha(paintMode, paintInfo, Std.int(frame.vertexs.length * 0.5), painter);
		var buffer = inline painter.getVertexBuffer();
		var vertexBufferCounter = inline painter.getVertexDataCounter();
		var vertexIndex:Int = 0;
		var uvIndex:Int = 0;
		for (i in 0...4) {
			var vertexX = vertexs[vertexIndex] - pivotX;
			var vertexY = vertexs[vertexIndex + 1] - pivotY;
			var pos = fastMult(model, vertexX, vertexY);

			buffer.set(vertexBufferCounter, pos.x + offsetX * cameraScale);
			buffer.set(vertexBufferCounter + 1, pos.y + offsetY * cameraScale);
			buffer.set(vertexBufferCounter + 2, pos.z);
			buffer.set(vertexBufferCounter + 3, uvs[uvIndex]);
			buffer.set(vertexBufferCounter + 4, uvs[uvIndex + 1]);
			buffer.set(vertexBufferCounter + 5, alpha);
			vertexIndex += 2;
			vertexBufferCounter += 6;
			uvIndex += 2;
		}

		painter.setVertexDataCounter(vertexBufferCounter);
	}

	inline function fastMult(model:FastMatrix4, x:Float, y:Float):FastVector3 {
		return new FastVector3(model._00 * x
			+ model._10 * y
			+ model._30, model._01 * x
			+ model._11 * y
			+ model._31,
			model._02 * x
			+ model._12 * y
			+ model._32);
	}

	function renderWithColorTransform(paintMode:PaintMode, model:FastMatrix4) {
		var frame = animationData.frames[timeline.currentFrame];
		var vertexs:Array<FastFloat> = frame.vertexs;
		var cameraScale = paintMode.camera.scale;
		var uvs = frame.UVs;
		var painter:IPainter = customPainter != null ? customPainter : this.colorPainters[0];
		//var painter:PainterColorTransform = this.colorPainters[cast blend];
		checkBatchColor(paintMode, paintInfo, Std.int(frame.vertexs.length * 0.5), painter);
		var redMul, blueMul, greenMul, alphaMul:Float;
		var redAdd, blueAdd, greenAdd, alphaAdd:Float;
		var buffer =  painter.getVertexBuffer();
		var vertexBufferCounter =  painter.getVertexDataCounter();
		redMul = this.mulRed * paintMode.mulR;
		greenMul = this.mulGreen * paintMode.mulG;
		blueMul = this.mulBlue * paintMode.mulB;
		alphaMul = this.alpha * paintMode.mulA;
		redAdd = this.addRed + paintMode.addR;
		greenAdd = this.addGreen + paintMode.addG;
		blueAdd = this.addBlue + paintMode.addB;
		alphaAdd = this.addAlpha + paintMode.addA;
		var vertexIndex:Int = 0;
		var uvIndex:Int = 0;
		for (k in 0...4) {
			var vertexX = vertexs[vertexIndex] - pivotX;
			var vertexY = vertexs[vertexIndex + 1] - pivotY;
			var pos = fastMult(model, vertexX, vertexY);
			writeColorVertex(pos.x + offsetX * cameraScale, pos.y + offsetY * cameraScale, pos.z + offsetZ, uvs[uvIndex++], uvs[uvIndex++], redMul, greenMul,
				blueMul, alphaMul, redAdd, greenAdd, blueAdd, alphaAdd, buffer, vertexBufferCounter);
			vertexBufferCounter += 13;
			vertexIndex += 2;
		}
		painter.setVertexDataCounter(vertexBufferCounter);
	}

	static inline function checkBatchAlpha(paintMode:PaintMode, paintInfo:PaintInfo, count:Int, painter:PainterAlpha) {
		if (!(paintMode.canBatch(paintInfo, count, painter) && (inline painter.canBatch(paintInfo, count)))) {
			paintMode.render();
			paintMode.changePainter(painter, paintInfo);
		}
	}

	static function checkBatchColor(paintMode:PaintMode, paintInfo:PaintInfo, count:Int, painter:IPainter) {
		if (!(paintMode.canBatch(paintInfo, count, painter) && ( painter.canBatch(paintInfo, count)))) {
			paintMode.render();
			paintMode.changePainter(painter, paintInfo);
		}
	}

	private static inline function writeColorVertex(x:Float, y:Float, z:Float, u:Float, v:Float, redMul:Float, greenMul:Float, blueMul:Float, alphaMul:Float,
			redAdd:Float, greenAdd:Float, blueAdd:Float, alphaAdd:Float, buffer:Float32Array, offsetPos:Int) {
		buffer.set(offsetPos, x);
		buffer.set(offsetPos + 1, y);
		buffer.set(offsetPos + 2, z);
		buffer.set(offsetPos + 3, u);
		buffer.set(offsetPos + 4, v);
		buffer.set(offsetPos + 5, redMul);
		buffer.set(offsetPos + 6, greenMul);
		buffer.set(offsetPos + 7, blueMul);
		buffer.set(offsetPos + 8, alphaMul);
		buffer.set(offsetPos + 9, redAdd);
		buffer.set(offsetPos + 10, greenAdd);
		buffer.set(offsetPos + 11, blueAdd);
		buffer.set(offsetPos + 12, alphaAdd);
	}

	public function set_skewX(value:Float):Float {
		tanSkewX = Math.tan(value);
		return skewX = value;
	}

	public function set_skewY(value:Float):Float {
		tanSkewY = Math.tan(value);
		return skewY = value;
	}

	public function removeFromParent() {
		if (parent != null) {
			parent.remove(this);
			parent = null;
		}
	}

	public function colorAdd(r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0):Void {
		addRed = r;
		addGreen = g;
		addBlue = b;
		addAlpha = a;
		colorTransform = !overrideColorTransform();
	}

	public function colorMultiplication(r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void {
		mulRed = r;
		mulGreen = g;
		mulBlue = b;
		alpha = a;
		colorTransform = !overrideColorTransform();
	}

	public function resetColorTransform() {
		colorAdd();
		colorMultiplication();
	}

	private inline function overrideColorTransform():Bool {
		return mulRed == 1
			&& mulGreen == 1
			&& mulBlue == 1
			&& alpha == 1
			&& addRed == 0
			&& addGreen == 0
			&& addBlue == 0
			&& addAlpha == 0;
	}

	public function getTransformation():FastMatrix3 {
		/*var transform = FastMatrix3.translation(x + pivotX + offsetX, y + pivotY + offsetY);
			transform = transform.multmat(FastMatrix3.scale(scaleX, scaleY));
			transform = transform.multmat(FastMatrix3.rotation(rotation));
			return transform; */
		return null;
	}

	public function getFinalTransformation():FastMatrix3 {
		return null;
		if (parent != null) {
			return parent.getTransformation().multmat(getTransformation());
		} else {
			return getTransformation();
		}
	}

	public function getDrawArea(area:MinMax, transform:FastMatrix4):Void {
		calculateTransform(transform);
		var model = transform.multmat(this.transform);
		var drawArea = animationData.frames[timeline.currentFrame].drawArea;
		if (drawArea.maxX != 16) {
			drawArea.minX = drawArea.minX;
		}
		area.mergeVec4(model.multvec(new FastVector4(drawArea.minX - pivotX, drawArea.minY - pivotY, 0)).add(new FastVector4(offsetX, offsetY)));
		area.mergeVec4(model.multvec(new FastVector4(drawArea.maxX - pivotX, drawArea.minY - pivotY, 0)).add(new FastVector4(offsetX, offsetY)));
		area.mergeVec4(model.multvec(new FastVector4(drawArea.minX - pivotX, drawArea.maxY - pivotY, 0)).add(new FastVector4(offsetX, offsetY)));
		area.mergeVec4(model.multvec(new FastVector4(drawArea.maxX - pivotX, drawArea.maxY - pivotY, 0)).add(new FastVector4(offsetX, offsetY)));
	}

	public function localDrawArea():DrawArea {
		return animationData.frames[timeline.currentFrame].drawArea;
	}

	public function width():Float {
		return animationData.frames[timeline.currentFrame].drawArea.width;
	}

	public function height():Float {
		return animationData.frames[timeline.currentFrame].drawArea.height;
	}

	public function get_smooth():Bool {
		return textureFilter == LinearFilter;
	}

	public function set_smooth(value:Bool):Bool {
		if (!value) {
			textureFilter = PointFilter;
			mipMapFilter = PointMipFilter;
		} else {
			textureFilter = LinearFilter;
			mipMapFilter = LinearMipFilter;
		}
		return value;
	}
}
