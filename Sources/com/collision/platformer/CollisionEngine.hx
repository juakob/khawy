package com.collision.platformer;

import com.framework.utils.LERP;
import kha.Color;
import kha.math.FastMatrix3;
import com.gEngine.display.Camera;

/**
 * ...
 * @author Joaquin
 */
class CollisionEngine {
	public function new() {}

	#if DEBUGDRAW
	private static var colliders:Array<ICollider> = new Array();

	public static function renderDebug(canvas:kha.Canvas, camera:Camera) {
		canvas.g2.begin(false);
		canvas.g2.color = Color.Yellow;
		var cV = camera.view;
		var scaleX = canvas.width / camera.width;
		var scaleY = canvas.height / camera.height;
		canvas.g2.transformation = FastMatrix3.scale(scaleX, scaleY).multmat(new FastMatrix3(cV._00, cV._10, cV._30 + camera.width * 0.5, cV._01, cV._11, cV
			._31 + camera.height * 0.5, cV._03, cV._13, cV._33));
		for (collider in colliders) {
			collider.debugDraw(canvas);
		}
		canvas.g2.end();
		colliders.splice(0, colliders.length);
	}
	#end

	public static function collide(A:ICollider, B:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		#if DEBUGDRAW
		colliders.push(A);
		colliders.push(B);
		#end
		return A.collide(B, aCallBack);
	}

	// temporal function needs to be more generic
	public static function bulletCollide(A:CollisionBox, B:ICollider, iterations:Int, aCallBack:ICollider->ICollider->Void = null):Bool {
		#if DEBUGDRAW
		colliders.push(A);
		colliders.push(B);
		#end
		var returnValue:Bool=false;
		var AendX:Float = A.x;
		var AendY:Float = A.y;
		for (i in 1...(iterations + 1)) {
			//avoid interpolation if they are the same value, it can add a rounding error
			if(A.x!=A.lastX) A.x = LERP.f(A.lastX, AendX, i / iterations);
			if(A.y!=A.lastY) A.y = LERP.f(A.lastY, AendY, i / iterations);
			returnValue = A.collide(B, aCallBack)||returnValue;
			if(A.y==A.lastY&&A.x==A.lastX)break;
		}

		return returnValue;
	}

	public static function overlap(A:ICollider, B:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		#if DEBUGDRAW
		colliders.push(A);
		colliders.push(B);
		#end
		return A.overlap(B, aCallBack);
	}
}
