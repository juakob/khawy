package com.collision.platformer;

/**
 * ...
 * @author Joaquin
 */
class CollisionBox extends Body implements ICollider {

	public var width:Float = 0;
	public var height:Float = 0;
	

	public var collisionAllow:Int = Sides.BOTTOM | Sides.LEFT | Sides.RIGHT | Sides.TOP;
	public var userData:Dynamic;
	public var parent:CollisionGroup;

	public function removeFromParent() {
		if (parent != null)
			parent.remove(this);
	}

	public function new() {
		super();
	}

	/* INTERFACE ICollider */
	public function collisionType():CollisionType {
		return CollisionType.Box;
	}

	public function isTouching(side:Int):Bool {
		return side & touching > 0;
	}

	public function collide(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool {
		if (collider == this)
			return false;
		if (collider.collisionType() == CollisionType.Box) {
			var boxCollider:CollisionBox = cast collider;
			var myPonderation:Float = 0.5;
			var colliderPonderation:Float = 0.5;
			if (staticObject) {
				myPonderation = 0;
				colliderPonderation = 1;
			} else if (boxCollider.staticObject) {
				myPonderation = 1;
				colliderPonderation = 0;
			}
			if (overlapVsBox(boxCollider)) {
				var overlapX:Float = width * 0.5 + boxCollider.width * 0.5 - Math.abs((x + width * 0.5) - (boxCollider.x + boxCollider.width * 0.5));
				var overlapY:Float = height * 0.5 + boxCollider.height * 0.5 - Math.abs((y + height * 0.5) - (boxCollider.y + boxCollider.height * 0.5));
				var overlapXSmaller:Bool=overlapX<overlapY;
				var myCollisionNeededX:Int = Sides.LEFT;
				var colliderNeededX:Int = Sides.RIGHT;
				var myCollisionNeededY:Int = Sides.TOP;
				var colliderNeededY:Int = Sides.BOTTOM;

				if ((x + width * 0.5) < (boxCollider.x + boxCollider.width * 0.5)) {
					myCollisionNeededX = Sides.RIGHT;
					colliderNeededX = Sides.LEFT;
					overlapX *= -1;
				} 
				
				if ((y + height * 0.5) < (boxCollider.y + boxCollider.height * 0.5)) {
					myCollisionNeededY = Sides.BOTTOM;
					colliderNeededY = Sides.TOP;
					overlapY *= -1;
					
				}
				if (overlapXSmaller
					&& (collisionAllow & myCollisionNeededX > 0)
					&& (boxCollider.collisionAllow & colliderNeededX > 0)) {
					x += overlapX * myPonderation;
					boxCollider.x -= overlapX * colliderPonderation;
					boxCollider.velocityX=0;
					velocityX=0;
					touching |= myCollisionNeededX;
					boxCollider.touching |= colliderNeededX;
					return true;
				} else if ((collisionAllow & myCollisionNeededY > 0) && (boxCollider.collisionAllow & colliderNeededY > 0)) {
					if(velocityY*overlapY>0){ //dot product to se direction
						y += overlapY * myPonderation;
						velocityY=0;
					}
					if(boxCollider.velocityY*overlapY>0){ //dot product to se direction
					boxCollider.y -= overlapY * colliderPonderation;
					boxCollider.velocityY=0;
					}
					
					touching |= myCollisionNeededY;
					boxCollider.touching |= colliderNeededY;
					if(notifyCallback!=null){
						notifyCallback(this,collider);
					}
					return true;
				}
			}
			return false;
		} else if (collider.collisionType() == CollisionType.TileMap) {
			return collider.collide(this, notifyCallback);
		} else if (collider.collisionType() == CollisionType.Group) {
			return collider.collide(this, notifyCallback);
		}
		return false;
	}

	/* INTERFACE ICollider */
	public function overlap(collider:ICollider, ?NotifyCallback:ICollider->ICollider->Void):Bool {
		if (collider.collisionType() == CollisionType.Box) {
			if (inline overlapVsBox(cast collider)) {
				if (NotifyCallback != null)
					NotifyCallback(this, collider);
				return true;
			}
		} else if (collider.collisionType() == CollisionType.TileMap) {
			return collider.overlap(this, NotifyCallback);
		} else if (collider.collisionType() == CollisionType.Group) {
			collider.overlap(this, NotifyCallback); // TODO: Fix order
		}
		return false;
	}

	public function bottom():Float {
		return y + height;
	}

	public function right():Float {
		return x + width;
	}

	public function topMiddle():Float {
		return x + width / 2;
	}

	public function bottomMiddle():Float {
		return y + height / 2;
	}

	function overlapVsBox(box:CollisionBox):Bool {
		return (box.x < x + width && box.x + box.width > x && box.y < y + height && box.y + box.height > y);
	}
}
