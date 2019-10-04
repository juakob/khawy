package com.collision.platformer;

/**
 * ...
 * @author Joaquin
 */
class CollisionEngine
{

	public function new() 
	{
		
	}
	public static function collide(A:ICollider, B:ICollider,aCallBack:ICollider->ICollider->Void=null):Bool
	{
		if (A.collide(B)) {
			if (aCallBack != null)
			{
				aCallBack(A, B);
				return true;
			}
		}
		return false;
	}
}