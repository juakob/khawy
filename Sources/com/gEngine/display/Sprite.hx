package com.gEngine.display;

import com.gEngine.helper.Timeline;
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
	public var mipMapFilter:MipMapFilter = MipMapFilter.NoMipFilter;

	var transform:FastMatrix4;

	public var filter:Filter;
	public var timeline(default, null):Timeline;

	var paintInfo:PaintInfo;

	public function new(name:String = null) {
		if (name != null) {
			animationData = com.basicDisplay.SpriteSheetDB.i.getData(name);
		}
		transform = FastMatrix4.identity();

		paintInfo = new PaintInfo();
		timeline = new Timeline(1 / 30, animationData.frames.length, animationData.labels);
		scaleX = 1;
		scaleY = 1;
		rotation = 0;
		cosAng = Math.cos(rotation);
		sinAng = Math.sin(rotation);

		textureId = animationData.texturesID;
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
		// x = aX;
		// y = aY;
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

	public function makeUnique() {
		animationData = animationData.clone();
		dataUnique = true;
	}

	public function getAnimationData():AnimationData {
		if (!dataUnique)
			makeUnique();
		return animationData;
	}

	inline function calculateTransform() {
		this.transform._00 = cosAng * scaleX;
		this.transform._10 = -sinAng * scaleY;
		this.transform._30 = x + pivotX ;
		this.transform._01 = sinAng * scaleX;
		this.transform._11 = cosAng * scaleY;
		this.transform._31 = y + pivotY ;
		this.transform._32 = z;
	}

	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		if (!visible) {
			return;
		}
		if (filter != null)
			filter.filterStart(this, paintMode, transform);

		calculateTransform();

		var model = transform.multmat(this.transform);

		// var model=paintMode.projection.multmat(a);
		// var model=paintMode.projection;
		var vertexX:FastFloat;
		var vertexY:FastFloat;

		var frame = animationData.frames[timeline.currentFrame];
		var vertexs:Array<FastFloat> = frame.vertexs;

		var uvs = frame.UVs;
		paintInfo.blend = blend;
		paintInfo.mipMapFilter = mipMapFilter;
		paintInfo.textureFilter = textureFilter;
		paintInfo.texture = textureId;

		if (colorTransform||paintMode.colorTransform) {
			var painter = GEngine.i.getColorTransformPainter(blend);
			checkBatch(paintMode, paintInfo, Std.int(frame.vertexs.length / 2), painter);
			var redMul, blueMul, greenMul, alphaMul:Float;
			var redAdd, blueAdd, greenAdd, alphaAdd:Float;
			var buffer = painter.getVertexBuffer();
			var vertexBufferCounter = painter.getVertexDataCounter();

			redMul = this.mulRed*paintMode.mulR;
			greenMul = this.mulGreen*paintMode.mulG;
			blueMul = this.mulBlue*paintMode.mulB;
			alphaMul = this.alpha*paintMode.mulA;
			

			redAdd = this.addRed;
			greenAdd = this.addGreen;
			blueAdd = this.addBlue;
			alphaAdd = this.addAlpha;
			var vertexIndex:Int = 0;
			var uvIndex:Int = 0;
			for (k in 0...4) {
				vertexX = vertexs[vertexIndex++] - pivotX ;
				vertexY = vertexs[vertexIndex++] - pivotY ;
				var pos = model.multvec(new FastVector4(vertexX, vertexY, 0));
				writeColorVertex(pos.x+ offsetX, pos.y+ offsetY, pos.z, uvs[uvIndex++], uvs[uvIndex++], redMul, greenMul, blueMul, alphaMul, redAdd, greenAdd, blueAdd, alphaAdd,
					buffer, vertexBufferCounter);
				vertexBufferCounter += 13;
			}

			painter.setVertexDataCounter(vertexBufferCounter);
		} else if (alpha != 1) {
			var painter = GEngine.i.getAlphaPainter(blend);
			checkBatch(paintMode, paintInfo, Std.int(frame.vertexs.length / 2), painter);
			var buffer = painter.getVertexBuffer();
			var vertexBufferCounter = painter.getVertexDataCounter();
			var vertexIndex:Int = 0;
			var uvIndex:Int = 0;
			for (i in 0...4) {
				vertexX = vertexs[vertexIndex++] - pivotX ;
				vertexY = vertexs[vertexIndex++] - pivotY ;
				var pos = model.multvec(new FastVector4(vertexX, vertexY, 0));
				buffer.set(vertexBufferCounter++, pos.x+ offsetX);
				buffer.set(vertexBufferCounter++, pos.y+ offsetY);
				buffer.set(vertexBufferCounter++, pos.z);
				buffer.set(vertexBufferCounter++, uvs[uvIndex++]);
				buffer.set(vertexBufferCounter++, uvs[uvIndex++]);
				buffer.set(vertexBufferCounter++, alpha);
			}

			painter.setVertexDataCounter(vertexBufferCounter);
		} else {
			var painter = GEngine.i.getSimplePainter(blend);
			checkBatch(paintMode, paintInfo, Std.int(frame.vertexs.length / 2), painter);
			var buffer = painter.getVertexBuffer();
			var vertexBufferCounter = painter.getVertexDataCounter();
			var vertexIndex:Int = 0;
			var uvIndex:Int = 0;
			for (i in 0...4) {
				vertexX = vertexs[vertexIndex++] - pivotX ;
				vertexY = vertexs[vertexIndex++] - pivotY ;
				var pos = model.multvec(new FastVector4(vertexX, vertexY, 0));
				buffer.set(vertexBufferCounter++, pos.x+ offsetX);
				buffer.set(vertexBufferCounter++, pos.y+ offsetY);
				buffer.set(vertexBufferCounter++, pos.z);
				buffer.set(vertexBufferCounter++, uvs[uvIndex++]);
				buffer.set(vertexBufferCounter++, uvs[uvIndex++]);
			}

			painter.setVertexDataCounter(vertexBufferCounter);
		}

		if (filter != null)
			filter.filterEnd(paintMode);
	}

	static function checkBatch(paintMode:PaintMode, paintInfo:PaintInfo, count:Int, painter:IPainter) {
		if (!paintMode.canBatch(paintInfo, count, painter)) {
			paintMode.render();
			paintMode.changePainter(painter, paintInfo);
		}
	}

	private static inline function writeColorVertex(x:Float, y:Float, z:Float, u:Float, v:Float, redMul:Float, greenMul:Float, blueMul:Float,
			alphaMul:Float, redAdd:Float, greenAdd:Float, blueAdd:Float, alphaAdd:Float, buffer:Float32Array, offsetPos:Int) {
		buffer.set(offsetPos++, x);
		buffer.set(offsetPos++, y);
		buffer.set(offsetPos++, z);
		buffer.set(offsetPos++, u);
		buffer.set(offsetPos++, v);
		buffer.set(offsetPos++, redMul);
		buffer.set(offsetPos++, greenMul);
		buffer.set(offsetPos++, blueMul);
		buffer.set(offsetPos++, alphaMul);
		buffer.set(offsetPos++, redAdd);
		buffer.set(offsetPos++, greenAdd);
		buffer.set(offsetPos++, blueAdd);
		buffer.set(offsetPos++, alphaAdd);
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
		return mulRed == 1 && mulGreen == 1 && mulBlue == 1 && alpha == 1 && addRed == 0 && addGreen == 0 && addBlue == 0 && addAlpha == 0;
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
		calculateTransform();
		var model = transform.multmat(this.transform);
		var drawArea = animationData.frames[timeline.currentFrame].drawArea;
		if (drawArea.maxX != 16) {
			drawArea.minX = drawArea.minX;
		}
		area.mergeVec4(model.multvec(new FastVector4(drawArea.minX - pivotX + offsetX, drawArea.minY - pivotY + offsetY, 0)));
		area.mergeVec4(model.multvec(new FastVector4(drawArea.maxX - pivotX + offsetX, drawArea.minY - pivotY + offsetY, 0)));
		area.mergeVec4(model.multvec(new FastVector4(drawArea.minX - pivotX + offsetX, drawArea.maxY - pivotY + offsetY, 0)));
		area.mergeVec4(model.multvec(new FastVector4(drawArea.maxX - pivotX + offsetX, drawArea.maxY - pivotY + offsetY, 0)));
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
		} else {
			textureFilter = LinearFilter;
		}
		return value;
	}
}
