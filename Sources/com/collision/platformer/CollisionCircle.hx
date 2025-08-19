package com.collision.platformer;

class CollisionCircle extends Body implements ICollider {
	public var radio:Float = 0;

	public function new(radio) {
		super();
		this.radio = radio;
	}

	public function collide(aCollider:ICollider, ?NotifyCallback:ICollider->ICollider->Void):Bool {
		if (aCollider.collisionType() == CollisionType.Circle) {}
		return false;
	}

	public function overlap(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool {
		if (collider.collisionType() == CollisionType.Circle) {
			var circle:CollisionCircle = cast collider;
			var deltaDistanceX = circle.x - x;
			var deltaDistanceY = circle.y - y;
			if ((deltaDistanceX * deltaDistanceX + deltaDistanceY * deltaDistanceY) < (circle.radio + radio) * (circle.radio + radio)) {
				if (notifyCallback != null) {
					notifyCallback(this, collider);
				}
				return true;
			}
			return false;
		} else if (collider.collisionType() == CollisionType.Group) {
			return collider.overlap(this, notifyCallback);
		} else if (collider.collisionType() == CollisionType.Box) {
			var box:CollisionBox = cast collider;
			return this.x>box.x && this.x< box.x+box.width && this.x>box.y && this.y< box.y+box.height; //temp calculation
		}
		return false;
	}

	public function collisionType():CollisionType {
		return CollisionType.Circle;
	}

	public var userData:Dynamic;
	public var parent:CollisionGroup;

	public function removeFromParent():Void {
		if (parent != null) {
			parent.remove(this);
		}
	}

	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void {
		var g2 = canvas.g2;
		var iterations = Std.int(radio);
		var angle = Math.PI * 2 / iterations;

		for (i in 0...iterations) {
			g2.drawLine(x + Math.cos(angle * i) * radio, y + Math.sin(angle * i) * radio, x + Math.cos(angle * (i + 1)) * radio, y + Math.sin(angle * (i +
				1)) * radio);
		}
	}
	#end
}
