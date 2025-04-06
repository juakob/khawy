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
	public var distanceFromOrigin:Float=0;
	public var length:Float = 0;

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
		// if (stick) {
		// //	if(track.updated){
		// 		//var pos=track.dir.mult(distanceFromOrigin).add(track.pos);
		// 		var scale = distanceFromOrigin / track.dir.x;
		// 		y = scale * track.dir.y + track.pos.y;
		// 		x=track.pos.x+distanceFromOrigin;
		// 		//y=pos.y;
		// 		lastStickY=y;
		// //	}
		// }
		
		
		if (velocityY < 0 || (stick&& track.isDestroy)) {
			clearTrack();
			return;
		}
		if (stick) {
			//var distance = Math.sqrt(velocityX*velocityX+velocityY*velocityY);
			length += velocityX*dt;
			if (length>0 && length > track.length) {
				if (track.nextEdge != null) {
					length = length - track.length;
					lastStickY=track.pos.y+track.dir.y*track.length;
					lastX=track.pos.x+track.dir.x*track.length;
					track = track.nextEdge;
				} else {
					clearTrack();
					return;
				}
			} else if (length < 0) {
				if (track.prevEdge != null) {
					track = track.prevEdge;
					length = track.length+length;
					lastStickY=track.pos.y;
					lastX=track.pos.x;
				} else {
					clearTrack();
					return;
				}
			}else{
				super.update(dt);
			}
			var finalPos = track.dir.mult(length);
			x = track.pos.x + finalPos.x;
			y = track.pos.y + finalPos.y;
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
