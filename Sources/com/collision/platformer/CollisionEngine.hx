package com.collision.platformer;

/**
 * ...
 * @author Joaquin
 */
class CollisionEngine {
	public function new() {}
	#if DEBUGDRAW
		private static var colliders:Array<ICollider>=new Array();
		public static function renderDebug(canvas:kha.Canvas) {
			canvas.g2.begin(false);
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
