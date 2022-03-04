package com.collision.platformer;

import kha.math.FastVector2;

class Cart implements ICollider extends Body {
	var normal:FastVector2;

	public var lastStickY:Float = 0;

	public var stick:Bool;

	public var width:Float;
	public var height:Float;
	public var track:Track;
	public var userData:Dynamic;
	public var parent:CollisionGroup;
	public var distanceFromOrigin:Float;
	

	public function new() {
		super();
	}

	public function collide(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool {
		return false;
	}

	public function overlap(collider:ICollider, ?notifyCallback:ICollider->ICollider->Void):Bool {
		return false;
	}

	public function collisionType():CollisionType {
		return CollisionType.Cart;
	}

	public function removeFromParent():Void {
		if (parent != null) {
			parent.remove(this);
		}
	}

	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void {}
	#end

	override function update(dt:Float) {
		if (stick) {
			if(track.updated){
				//var pos=track.dir.mult(distanceFromOrigin).add(track.pos);
				var scale = distanceFromOrigin / track.dir.x;
				y = scale * track.dir.y + track.pos.y;
				x=track.pos.x+distanceFromOrigin;
				//y=pos.y;
				lastStickY=y;
			}
		}
		super.update(dt);
		if (velocityY < 0 || (stick&& track.isDestroy)) {
			clearTrack();
			return;
		}
		if (stick) {
			var distanceFromOriginX = x - track.pos.x;
			var distance = x - this.lastX;
			if (distanceFromOriginX > track.length) {
				if (track.nextEdge != null) {
					distance = distanceFromOriginX - track.length;
					lastStickY=track.pos.y+track.dir.y*track.length;
					lastX=track.pos.x+track.dir.x*track.length;
					track = track.nextEdge;
				} else {
					clearTrack();
					return;
				}
			} else if (distanceFromOriginX < 0) {
				if (track.prevEdge != null) {
					distance = distanceFromOriginX;
					lastStickY=track.pos.y;
					lastX=track.pos.x;
					track = track.prevEdge;
				} else {
					clearTrack();
					return;
				}
			}
			var finalPos = track.dir.mult(distance);
			x = lastX + finalPos.x;
			y = lastStickY + finalPos.y;
			lastStickY=y;
			velocityY = 0;
			distanceFromOrigin=x-track.pos.x;
		}
	}

	public function clearTrack() {
		stick = false;
		track = null;
		distanceFromOrigin=0;
	}
}
