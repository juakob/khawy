package com.collision.platformer;

/**
 * @author Joaquin
 */

interface ICollider 
{
	public function collide(aCollider:ICollider,?NotifyCallback:ICollider->ICollider->Void):Bool;
	public function overlap(aCollider:ICollider,?NotifyCallback:ICollider->ICollider->Void):Bool;
	public function collisionType():CollisionType;
	public var userData:Dynamic;
	public var parent:CollisionGroup;//TODO create ICollisionContainer
	public function removeFromParent():Void;
	
}