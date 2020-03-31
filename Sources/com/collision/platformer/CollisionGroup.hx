package com.collision.platformer;

/**
 * ...
 * @author Joaquin
 */
class CollisionGroup implements ICollider {
	public var colliders:Array<ICollider>;
	public var userData:Dynamic;
	public var parent:CollisionGroup;

	public function removeFromParent():Void {
		if (parent != null)
			parent.remove(this);
	}

	public function new() {
		colliders = new Array();
	}

	public function add(aCollider:ICollider) {
		colliders.push(aCollider);
		aCollider.parent = this;
	}

	public function remove(aCollider:ICollider) {
		colliders.remove(aCollider);
	}

	/* INTERFACE ICollider */
	public function collide(aCollider:ICollider, ?NotifyCallback:ICollider->ICollider->Void):Bool {
		var toReturn:Bool = false;
		if (aCollider.collisionType() == CollisionType.Group) {
			var group:CollisionGroup = cast aCollider;
			for (col1 in colliders) {
				for (col2 in group.colliders) {
					toReturn = col1.collide(col2, NotifyCallback) || toReturn;
				}
			}
		} else {
			for (col in colliders) {
				toReturn = col.collide(aCollider, NotifyCallback) || toReturn;
			}
		}
		return toReturn;
	}

	public function overlap(aCollider:ICollider, ?NotifyCallback:ICollider->ICollider->Void):Bool {
		var toReturn:Bool = false;
		if (aCollider.collisionType() == CollisionType.Group) {
			var group:CollisionGroup = cast aCollider;
			for (col1 in colliders) {
				for (col2 in group.colliders) {
					toReturn = col1.overlap(col2, NotifyCallback) || toReturn;
				}
			}
		} else {
			for (col in colliders) {
				toReturn = col.overlap(aCollider, NotifyCallback) || toReturn;
			}
		}
		return toReturn;
	}

	public function collisionType():CollisionType {
		return CollisionType.Group;
	}
	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void{
		for(col in colliders){
			col.debugDraw(canvas);
		}
	}
	#end
}
