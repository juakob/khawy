package com.gEngine.display;

import kha.Image;
import kha.math.FastVector2;
import kha.math.FastVector4;
import com.framework.utils.Perlin;
import kha.graphics4.TextureFilter;
import com.gEngine.painters.Painter;
import kha.math.FastVector3;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;
import com.helpers.MinMax;
import com.helpers.FastPoint;

class Camera {
	private var targetPos:FastPoint;
	static inline var zMapDistance:Float=869.1168; //distance where x,y are map to the screen if z=0;
	public var min:FastPoint;
	public var max:FastPoint;

	public var width(default, null):Int;
	public var height(default, null):Int;
	public var scale:Float = 1;
	public var angle(default,set):Float = 1;

	var time:Float=0;
	var maxShakeX:Float;
	var maxShakeY:Float;
	var shakeRotation:Float;
	var totalTime:Float;
	var shakeInterval:Float = 0;
	var lastShake:Float = 0;

	public var scaleX:Float=0;
	public var scaleY:Float=0;
	var x:Float=0;
	var y:Float=0;
	var z:Float=0;

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

	var shakeX:Float=0;
	var shakeY:Float=0;
	var perlin:Perlin;

	var drawArea:MinMax;

	var textureFilter:TextureFilter = TextureFilter.LinearFilter;

	public var blend:BlendMode = BlendMode.Default;

	public var world:Layer;

	public var camera2d:Bool=true;

	public function new() {
		
		width = GEngine.virtualWidth;
		height = GEngine.virtualHeight;
		eye = new FastVector3(0, 0, zMapDistance);
		at = new FastVector3(0, 0, 0);
		up = new FastVector3(0, 1, 0);
		view = FastMatrix4.identity();
		updateView();
		targetPos = new FastPoint(0,0);

		
		setDrawArea(0, 0, width, height);
		renderTarget = GEngine.i.getRenderTarget(width, height);
		setOrthogonalProjection(width, height);
		setProjection(FastMatrix4.perspectiveProjection(45,width/height,0.1,5000));
		perlin=new Perlin(1);
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

	public function set_angle(value:Float):Float {
		
		up.x=Math.sin(value);
		up.y=Math.cos(value);
		return value;
	}


	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
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

		world.render(paintMode, view);
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
		min = new FastPoint(x - this.width , y - this.height );
		max = new FastPoint(x + width - this.width , y + height - this.height );
	}

	public function setTarget(x:Float, y:Float):Void {
		targetPos.setTo(x  , y);
	}
	public function move(deltaX:Float, deltaY:Float):Void {
		targetPos.x += deltaX;
		targetPos.y += deltaY ;
	}

	public function goTo(x:Float, y:Float):Void {
		this.x = x - width * 0.5;
		this.y = y - height * 0.5 ;
	}

	public  function worldToScreen(x:Float,y:Float,z:Float):FastVector2 {
		var transform=projection.multmat(view);
		var screen=transform.multvec(new FastVector4(x,y,z));
		screen.mult(screen.w);
		return new FastVector2(width*0.5 + screen.x, height*0.5 + screen.y);
	}

	public  function screenToWorld(targetX:Float,targetY:Float,targetZ:Float=0):FastVector2 {
		targetX=(targetX/width)*2-1;
		targetY=Image.renderTargetsInvertedY()?(targetY/height)*2-1:1-(targetY/height)*2;
		var transform=(projection.multmat(view)).inverse();
		var farRaw:FastVector4=transform.multvec(new FastVector4(targetX,targetY,-1,1));
		var nearRaw:FastVector4=transform.multvec(new FastVector4(targetX,targetY,1,1));
		var far = farRaw.mult(1/farRaw.w);
		var near = nearRaw.mult(1/nearRaw.w);
		var dir=far.sub(near);

		return new FastVector2(near.x+dir.x*((targetZ-near.z)/dir.z),near.y+dir.y*((targetZ-near.z)/dir.z));
	}

	public function destroy() {
		GEngine.i.releaseRenderTarget(renderTarget);
	
	}

	public var maxSeparationFromTarget:Float = 100 * 100;

	public function update(dt:Float):Void {
		//var deltaX:Float = this.x - targetPos.x;
		//var deltaY:Float = this.y - targetPos.y;
		if(camera2d){
			this.x = targetPos.x;
			this.y = targetPos.y;
			this.z=zMapDistance*1/scale;

			shakeX = 0;
			shakeY = 0;
			adjustToLimits();
			if (time > 0) {
				time -= dt;
			
					var s=time/totalTime;
					shakeX = maxShakeX-perlin.OctavePerlin(time*s,time,time, 8, s,shakeInterval)* maxShakeX*2  ;
					shakeY = maxShakeY-perlin.OctavePerlin(-time,-time,-time, 8, s, shakeInterval)* maxShakeY*2 ;
					//this.rotation=shakeRotation-2*shakeRotation*perlin.OctavePerlin(time,time,time, 8, s, shakeInterval);
					
				
			}
			eye.setFrom(new FastVector3(this.x,this.y,this.z));
			at.setFrom(new FastVector3(this.x,this.y,0));
		}
		
		//this.pivotX=targetPos.x+(width*0.5-targetPos.x)*2;
		//this.pivotY=targetPos.y+(height*0.5-targetPos.y)*2;
		/*if (deltaX * deltaX + deltaY * deltaY > maxSeparationFromTarget * maxSeparationFromTarget) {
			var length:Float = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
			this.x = targetPos.x + (deltaX / length) * maxSeparationFromTarget;
			this.y = targetPos.y + (deltaY / length) * maxSeparationFromTarget;
		}*/
		/*
		
		this.x+=shakeX;
		this.y+=shakeY;*/
		updateView();
	}

	
	public inline function screenHeight():Float {
		return height;
	}

	public inline function screenWidth():Float {
		return width;
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

	public function shake(time:Float = -1, maxX:Float = 10, maxY:Float = 10, rotation:Float=0, shakeInterval:Float = 0.1):Void {
		this.time = totalTime = time;
		if (time < 0) {
			this.time = 100000;
			totalTime =1;
		}
		
		shakeRotation = rotation;
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
