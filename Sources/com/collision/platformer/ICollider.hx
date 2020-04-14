package com.collision.platformer;

/**
 * @author Joaquin
 */
interface ICollider {
	public function collide(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool;
	public function overlap(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool;
	public function collisionType():CollisionType;
	public var userData:Dynamic;
	public var parent:CollisionGroup; // TODO create ICollisionContainer
	public function removeFromParent():Void;
	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void;
	#end
}
