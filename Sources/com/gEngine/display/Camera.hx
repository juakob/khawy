package com.gEngine.display;

import kha.graphics4.TextureFilter;
import kha.graphics1.Graphics4;
import com.g3d.OgexData.Color;
import com.gEngine.painters.Painter;
import kha.math.FastVector4;
import kha.math.FastVector3;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;
import com.helpers.MinMax;
import com.helpers.FastPoint;

class Camera extends Layer {
	private var targetPos:FastPoint;

	public var min:FastPoint;

	private var max:FastPoint;

	public var width(default, null):Int;
	public var height(default, null):Int;
	public var scale:Float = 1;
	public var angle:Float = 1;
	public var angleInverse:Float = 1;

	private var time:Float;
	private var maxShakeX:Float;
	private var maxShakeY:Float;
	private var totalTime:Float;
	private var shakeInterval:Float = 0;
	private var lastShake:Float = 0;

	public var smooth(get, set):Bool;
	public var autoCrop:Bool;
	public var clearColor:kha.Color = kha.Color.fromFloats(0, 0, 0, 0);
	public var projection(default, null):FastMatrix4;
	public var orthogonal:FastMatrix4;

	var finalX:Float = 0;
	var finalY:Float = 0;

	public var eye:FastVector3;
	public var at:FastVector3;
	public var up:FastVector3;
	public var view:FastMatrix4;
	public var onPreRender:Camera->FastMatrix4->Void;
	public var renderTarget:Int = -1;
	public var postProcess:Painter = null;

	var textureFilter:TextureFilter = TextureFilter.LinearFilter;

	public var blend:BlendMode = BlendMode.Default;

	public function new() {
		super();
		targetPos = new FastPoint();
		width = GEngine.virtualWidth;
		height = GEngine.virtualHeight;
		eye = new FastVector3(width / 2, height / 2, 869.1168);
		at = new FastVector3(width / 2, height / 2, 0);
		up = new FastVector3(0, 1, 0);
		view = FastMatrix4.identity();
		updateView();

		pivotX = -(x + width * 0.5);
		pivotY = -(y + height * 0.5);
		setDrawArea(0, 0, width, height);
		renderTarget = GEngine.i.getRenderTarget(width, height);
		setOrthogonalProjection(width, height);
		projection = orthogonal;
	}

	public function updateView() {
		view.setFrom(FastMatrix4.lookAt(eye, at, up));
	}

	public function setArea(x:Int, y:Int, width:Int, height:Int) {
		setDrawArea(x, y, width, height);
		GEngine.i.releaseRenderTarget(renderTarget);
		setOrthogonalProjection(Std.int(width), Std.int(height));
		renderTarget = GEngine.i.getRenderTarget(width, height);
	}

	function setOrthogonalProjection(width:Float, height:Float) {
		if (kha.Image.renderTargetsInvertedY()) {
			orthogonal = FastMatrix4.scale(1, -1, 1).multmat(FastMatrix4.orthogonalProjection(0, width, height, 0, 0, 5000));
		} else {
			orthogonal = FastMatrix4.orthogonalProjection(0, width, height, 0, 0, 5000);
		}
	}

	public function setProjection(mat:FastMatrix4):Void {
		if (!kha.Image.renderTargetsInvertedY()) {
			projection = FastMatrix4.scale(1, -1, 1).multmat(mat);
		} else {
			projection = mat;
		}
	}

	inline function setDrawArea(x:Int, y:Int, width:Int, height:Int) {
		drawArea = MinMax.from(0, 0, width, height);
		finalX = x;
		finalY = y;
		this.width = width;
		this.height = height;
	}

	override public function addChild(child:IDraw):Void {
		children.push(cast child);
	}

	override public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		GEngine.i.setCanvas(renderTarget);
		GEngine.i.beginCanvas();
		var g = GEngine.i.currentCanvas().g4;

		g.clear(clearColor, 1);

		paintMode.projection = projection;
		paintMode.orthogonal = orthogonal;
		paintMode.targetWidth = width;
		paintMode.targetHeight = height;
		paintMode.buffer = renderTarget;

		if (onPreRender != null)
			onPreRender(this, view);

		super.render(paintMode, view);
		GEngine.i.endCanvas();
		GEngine.i.changeToBuffer();
		GEngine.i.beginCanvas();
		var painter = postProcess != null ? postProcess : GEngine.i.getSimplePainter(blend);
		painter.setProjection(GEngine.i.getMatrix());
		if (postProcess != null) {}
		GEngine.i.renderBufferFull(renderTarget, painter, finalX, finalY, width, height, 1, false, 1);
		GEngine.i.endCanvas();
	}

	public function limits(x:Float, y:Float, width:Float, height:Float):Void {
		min = new FastPoint(x - this.width * 0.5, y - this.height * 0.5);
		max = new FastPoint(x + width - this.width * 0.5, y + height - this.height * 0.5);
	}

	public function setTarget(x:Float, y:Float):Void {
		targetPos.setTo(-x + width * 0.5, -y + height * 0.5);
	}

	public function goTo(x:Float, y:Float):Void {
		x = x - width * 0.5;
		y = y - height * 0.5 * angleInverse;
	}

	public inline function worldToCameraX(x:Float):Float {
		return ((x - this.x) -width / 2) * scaleX + width / 2;
	}

	public inline function worldToCameraY(y:Float):Float {
		return (((y - this.y) -height) * scaleY + height) * angle;
	}

	public inline function screenToWorldX(x:Float):Float {
		return (x - width / 2) * 1 / scaleX + width / 2 + this.x;
	}

	public inline function screenToWorldY(y:Float):Float {
		return ((y - height / 2) * 1 / scaleY + height / 2) * angleInverse + this.y;
	}

	override function destroy() {
		GEngine.i.releaseRenderTarget(renderTarget);
		super.destroy();
	}

	public var maxSeparationFromTarget:Float = 100 * 100;

	override public function update(dt:Float):Void {
		var deltaX:Float = this.x - targetPos.x;
		var deltaY:Float = this.y - targetPos.y;
		this.x = this.x - deltaX * 0.2;
		this.y = this.y - deltaY * 0.2;
		if (deltaX * deltaX + deltaY * deltaY > maxSeparationFromTarget * maxSeparationFromTarget) {
			var length:Float = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
			this.x = targetPos.x + (deltaX / length) * maxSeparationFromTarget;
			this.y = targetPos.y + (deltaY / length) * maxSeparationFromTarget;
		}

		adjustToLimits();
		if (time > 0) {
			time -= dt;
			lastShake += dt;
			if (lastShake >= shakeInterval) {
				lastShake = 0;
				var s:Float = time / totalTime;

				var shakeX = maxShakeX * s;
				var shakeY = maxShakeY * s;
				this.x += shakeX - Math.random() * shakeX * 2;
				this.y += shakeY - Math.random() * shakeY * 2;
			}
		}
	}

	public function isVisible(x:Float, y:Float, radio:Float = 0):Bool {
		x = worldToCameraX(x);
		y = worldToCameraY(y);
		return !(x + radio < 0 || x - radio > width * scale || y + radio < 0 || y - radio > height * scale * angleInverse);
	}

	public inline function screenHeight():Float {
		return height;
	}

	public inline function screenWidth():Float {
		return width;
	}

	public inline function cameraCenterX():Float {
		return this.x + width * 0.5 * scale;
	}

	public inline function cameraCenterY():Float {
		return this.y + height * 0.5 * scale;
	}

	private function adjustToLimits():Void {
		if (min != null) {
			if (width * 1 / scaleX > max.x - min.x || height * 1 / scaleY > max.y - min.y)
				return;
			if (-this.x - width * 0.5 * 1 / scaleX < min.x) {
				this.x = -(min.x + width * 0.5 * 1 / scaleX);
			} else if (-this.x + width * 0.5 * 1 / scaleX > max.x) {
				this.x = -(max.x - width * 0.5 * 1 / scaleX);
			}

			if (-this.y - height * 0.5 * 1 / scaleY < min.y) {
				this.y = -(min.y + height * 0.5 * 1 / scaleY);
			} else if (-this.y + height * 0.5 * 1 / scaleY > max.y) {
				this.y = -(max.y - height * 0.5 * 1 / scaleY);
			}
		}
	}

	public function shake(time:Float = -1, maxX:Float = 10, maxY:Float = 10, shakeInterval:Float = 0.1):Void {
		this.time = totalTime = time;
		if (this.time < 0) {
			this.time = Math.POSITIVE_INFINITY;
		}
		maxShakeX = maxX;
		maxShakeY = maxY;
		this.shakeInterval = shakeInterval;
	}

	public function get_smooth():Bool {
		return textureFilter == LinearFilter;
	}

	public function set_smooth(value:Bool):Bool {
		if (value) {
			textureFilter = LinearFilter;
		} else {
			textureFilter = PointFilter;
		}
		return value;
	}

	public function stopShake():Void {
		time = totalTime = 0;
	}
}
