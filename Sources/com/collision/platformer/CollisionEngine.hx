package com.collision.platformer;

/**
 * ...
 * @author Joaquin
 */
class CollisionEngine {
	public function new() {}

	public static function collide(A:ICollider, B:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		return A.collide(B,aCallBack);
	}
	public static function overlap(A:ICollider, B:ICollider, aCallBack:ICollider->ICollider->Void = null):Bool {
		return A.overlap(B,aCallBack);
	}
}
