package com.collision.platformer;

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
		private static var colliders:Array<ICollider>=new Array();
		public static function renderDebug(canvas:kha.Canvas,camera:Camera) {
			
			canvas.g2.begin(false);
			canvas.g2.color=Color.Yellow;
			var cV=camera.view;

			canvas.g2.transformation=new FastMatrix3(cV._00,cV._10,cV._30+camera.width*0.5,cV._01,cV._11,cV._31+camera.height*0.5,cV._03,cV._13,cV._33);
			for(collider in colliders){
				collider.debugDraw(canvas);
			}
			canvas.g2.end();
			colliders.splice(0,colliders.length);
		}
	#end
	
	public static function collide(A:ICollider, B:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		#if DEBUGDRAW
		colliders.push(A);
		colliders.push(B);
		#end
		return A.collide(B,aCallBack);
	}
	public static function overlap(A:ICollider, B:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		#if DEBUGDRAW
		colliders.push(A);
		colliders.push(B);
		#end
		return A.overlap(B,aCallBack);
	}
}
