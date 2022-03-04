package com.collision.platformer;

import kha.math.FastVector2;
import com.collision.platformer.CollisionType;

class Track implements ICollider {
	public var dir:FastVector2;
	public var pos:FastVector2;
	public var length:Float;


	public var nextEdge:Track;
	public var nextAngle:Float;

	public var prevEdge:Track;
	public var prevAngle:Float;

	public var isWall:Bool;
	var wallSide:Int;
	public var isDestroy:Bool;
	public var updated:Bool;

	public function new(startX:Float, startY:Float, endX:Float, endY:Float) {
		updatePosition(startX,startY,endX,endY);
	}

	public function updatePosition(startX:Float, startY:Float, endX:Float, endY:Float) {
		pos = new FastVector2(startX, startY);
		var end = new FastVector2(endX, endY);
		var vector = end.sub(pos);
		dir = vector.normalized();
		length = vector.length;
		wallSide=dir.y>0?1:-1;
	}

	public function collide(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool {
		if (collider.collisionType() == CollisionType.Cart) {
			var cart:Cart = cast collider;
			if(isWall){
				if(cart.velocityX*wallSide>=0)
					return false;
				var y = cart.y - pos.y;
				var scaleY = y / dir.y;
				if (scaleY < 0 || scaleY > length)
					return false; // not between the lines
				var x = scaleY * dir.x + pos.x;
				if (x > (cart.x- cart.width) && x < (cart.x + cart.width)) {
					cart.x=x+cart.width*wallSide;
					
					if (notifyCallback != null) {
						notifyCallback(this, collider);
					}
					//cart.touching;
					cart.touching=Sides.LEFT|Sides.RIGHT;
				}
				return false;

			}
			


			if (cart.track != null && cart.track != this) {
				return false;
			}
			if(cart.velocityY<0){
				return false;
			}

			var x = cart.x - pos.x;
			var scale = x / dir.x;
			if (scale < 0 || scale > length)
				return false; // not between the lines
			var y = scale * dir.y + pos.y;
			if (y < cart.y && y > (cart.y - cart.height)) {
				// we are colliding
				cart.track=this;
				cart.stick=true;
				cart.y = y;
				cart.velocityY = 0;
				cart.distanceFromOrigin=cart.x-pos.x;
				if (notifyCallback != null) {
					notifyCallback(this, collider);
				}
				cart.lastStickY=y;
			}
		}
		return false;
	}

	public function overlap(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool {
		return false;
	}

	public function collisionType():CollisionType {
		return CollisionType.Track;
	}

	public var userData:Dynamic;
	public var parent:CollisionGroup;

	public function removeFromParent():Void {
		if (parent != null) {
			parent.remove(this);
		}
	}

	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void {}
	#end
}
