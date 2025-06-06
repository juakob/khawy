package com.collision.platformer;

/**
 * ...
 * @author Joaquin
 */
class CollisionBox extends Body implements ICollider {
	public var width:Float = 10;
	public var height:Float = 10;
	public var collisionAllow:Int = Sides.BOTTOM | Sides.LEFT | Sides.RIGHT | Sides.TOP;
	public var userData:Dynamic;
	public var parent:CollisionGroup;

	public var middleX(get,null):Float;
	public var middleY(get,null):Float;

	public function removeFromParent() {
		if (parent != null) {
			parent.remove(this);
		}
	}
	public function get_middleX() {
		return x+width*0.5;
	}
	public function get_middleY() {
		return y+height*0.5;
	}

	public function new() {
		super();
	}

	/* INTERFACE ICollider */
	public function collisionType():CollisionType {
		return CollisionType.Box;
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
				var overlapX:Float = width * 0.5 + boxCollider.width * 0.5 - Math.abs((x + width * 0.5) -(boxCollider.x + boxCollider.width * 0.5));
				var overlapY:Float = height * 0.5 + boxCollider.height * 0.5 - Math.abs((y + height * 0.5) -(boxCollider.y + boxCollider.height * 0.5));
				var overlapXSmaller:Bool = overlapX < overlapY;
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

				if(collisionAllow!=Sides.ALL||boxCollider.collisionAllow!=Sides.ALL){					
					
					var currentX=x;
					var currentY=y;
					x=lastX;
					y=lastY;
					var colliderX=boxCollider.x;
					var colliderY=boxCollider.y;
					boxCollider.x=boxCollider.lastX;
					boxCollider.y=boxCollider.lastY;

					var colliding=overlapVsBox(boxCollider);

					x=currentX;
					y=currentY;
					boxCollider.x=colliderX;
					boxCollider.y=colliderY;

					if(colliding){
						return false;
					}

				}
				if (overlapXSmaller && (collisionAllow & myCollisionNeededX > 0) && (boxCollider.collisionAllow & colliderNeededX > 0)) {
					
					if (velocityX * overlapX <= 0 && !staticObject) { // dot product to see direction
						velocityX *= -bounce;
						x += overlapX * myPonderation;
					}
					if (boxCollider.velocityX * overlapX >= 0 && !boxCollider.staticObject) { // dot product to see direction
						boxCollider.velocityX *= -boxCollider.bounce;
						boxCollider.x -= overlapX * colliderPonderation;
					}
					touching |= myCollisionNeededX;
					boxCollider.touching |= colliderNeededX;
					if (notifyCallback != null) {
						notifyCallback(this, collider);
					}
					return true;
				} else if ((collisionAllow & myCollisionNeededY > 0) && (boxCollider.collisionAllow & colliderNeededY > 0)) {
					if (velocityY * overlapY <= 0 && !staticObject) { // dot product to see direction
						velocityY *= -bounce;
						y += overlapY * myPonderation;
					}
					if (boxCollider.velocityY * overlapY >= 0 && !boxCollider.staticObject) { // dot product to see direction
						boxCollider.velocityY *= -boxCollider.bounce;
						boxCollider.y -= overlapY * colliderPonderation;
					}

					touching |= myCollisionNeededY;
					boxCollider.touching |= colliderNeededY;
					if (notifyCallback != null) {
						notifyCallback(this, collider);
					}
					return true;
				}
			}
			return false;
		} else if (collider.collisionType() == CollisionType.TileMap) {
			return collider.collide(this, notifyCallback);
		} else if (collider.collisionType() == CollisionType.Group) {
			var collision:CollisionGroup=cast collider;
			var result:Bool=false;
			for(col in collision.colliders){
				result = collide(col,notifyCallback) || result;
			}
			return result;
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
			var group:CollisionGroup = cast collider;
			return group.overlapInverted(this, NotifyCallback); 
		} else if (collider.collisionType() == CollisionType.Circle) {
			var circle:CollisionCircle = cast collider;
			if(circle.x>x && circle.x< x+width && circle.y>y && circle.y< y+height) //temp calculation
			{
				if (NotifyCallback != null)
					NotifyCallback(this, collider);
				return true;
			}

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

	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void {
		var g2 = canvas.g2;
		g2.drawLine(x, y, x + width, y);
		g2.drawLine(x + width, y, x + width, y + height);
		g2.drawLine(x + width, y + height, x, y + height);
		g2.drawLine(x, y + height, x, y);
	}
	#end
}
