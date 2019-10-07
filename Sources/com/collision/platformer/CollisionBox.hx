package com.collision.platformer;

/**
 * ...
 * @author Joaquin
 */
class CollisionBox  implements ICollider
{
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Float = 0;
	public var height:Float = 0;
	public var velocityX:Float = 0;
	public var velocityY:Float = 0;
	public var accelerationX:Float = 0;
	public var accelerationY:Float = 0;
	public var dragX:Float = 1;
	public var dragY:Float = 1;
	public var Static:Bool = false;
	public var maxVelocityX:Float = Math.POSITIVE_INFINITY;
	public var maxVelocityY:Float = Math.POSITIVE_INFINITY;
	public var touching:Int = Sides.NONE;
	public var collisionAllow:Int = Sides.BOTTOM|Sides.LEFT|Sides.RIGHT|Sides.TOP;
	public var userData:Dynamic;
	public var parent:CollisionGroup;
	
	public function removeFromParent() 
	{
		if (parent != null) parent.remove(this);
	}
	public function new() 
	{
	}
	
	/* INTERFACE ICollider */
	
	public function collisionType():CollisionType 
	{
		return CollisionType.Box;
	}
	public function isTouching(aSide:Int):Bool
	{
		return aSide & touching>0;
	}
	public function update(aDt:Float):Void 
	{
		touching = Sides.NONE;
		velocityX += accelerationX * aDt;
		velocityY += accelerationY * aDt;
		if (Math.abs(velocityX) > maxVelocityX)
		{
			if (velocityX > 0)
			{
				velocityX = maxVelocityX;
			}else {
				velocityX = -maxVelocityX;
			}
		}
		if (Math.abs(velocityY) > maxVelocityY)
		{
			if (velocityY > 0)
			{
				velocityY = maxVelocityY;
			}else {
				velocityY =-maxVelocityY;	
			}
		}
		x += velocityX * aDt;
		y += velocityY * aDt;
		
		if (accelerationX == 0)
		{
			velocityX *= dragX;
			if (Math.abs(velocityX) < 70)
			{
				velocityX = 0;
			}
		}
		if (accelerationY == 0)
		{
			velocityY *= dragY;
			if (Math.abs(velocityY) < 70)
			{
				velocityY = 0;
			}
		}
	}
	
	
	
	//TODO clean
	public function collide(aCollider:ICollider,?NotifyCallback:ICollider->ICollider->Void):Bool 
	{
		
		if (aCollider == this) return false;
		if (aCollider.collisionType() == CollisionType.Box)
		{
			var boxCollider:CollisionBox = cast aCollider;
			var myPonderation:Float = 0.5;
			var colliderPonderation:Float = 0.5;
			if (Static)
			{
				myPonderation = 0;
				colliderPonderation = 1;
			}else
			if (boxCollider.Static)
			{
				myPonderation = 1;
				colliderPonderation = 0;
			}
			if (overlapVsBox(boxCollider)) {
				 var overlapX:Float;
				 var overlapY:Float;
				 if (x < boxCollider.x) {
						overlapX =   boxCollider.x-(x + width); 
						 if (y < boxCollider.y) {
							 overlapY = boxCollider.y -(y + height); 
							 if (overlapY > overlapX)
							 {
								 if((collisionAllow & Sides.BOTTOM)>0 && (boxCollider.collisionAllow& Sides.TOP)>0){
									boxCollider.y -= overlapY *colliderPonderation;
									y += overlapY * myPonderation;
									if(boxCollider.velocityY<0) boxCollider.velocityY = 0;
									if(velocityY>0)velocityY = 0;
									touching |= Sides.BOTTOM;
									boxCollider.touching |= Sides.TOP;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
									}
							 }else {
								if((collisionAllow & Sides.RIGHT)>0 && (boxCollider.collisionAllow& Sides.LEFT)>0){
									boxCollider.x -= overlapX *colliderPonderation;
									x += overlapX * myPonderation;
									if(boxCollider.velocityX<0) boxCollider.velocityX = 0;
									if(velocityX>0)velocityX = 0;
									touching |= Sides.RIGHT;
									boxCollider.touching |= Sides.LEFT;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
									}
							 }
						 }else {
							 overlapY =   y -(boxCollider.y + boxCollider.height) ; 
							  if (overlapY > overlapX)
							 {
								 if((collisionAllow & Sides.TOP)>0 && (boxCollider.collisionAllow& Sides.BOTTOM)>0){
									boxCollider.y += overlapY *colliderPonderation;
									y -= overlapY * myPonderation;
									if(boxCollider.velocityY>0) boxCollider.velocityY = 0;
									if(velocityY<0)velocityY = 0;
									touching |= Sides.TOP;
									boxCollider.touching |= Sides.BOTTOM;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
									}
							 }else {
								 if((collisionAllow & Sides.RIGHT)>0 && (boxCollider.collisionAllow& Sides.LEFT)>0){
									boxCollider.x -= overlapX *colliderPonderation;
									x += overlapX * myPonderation;
									if(boxCollider.velocityX<0) boxCollider.velocityX = 0;
									if(velocityX>0)velocityX = 0;
									touching |= Sides.RIGHT;
									boxCollider.touching |= Sides.LEFT;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
									}
							 }
						 }
					 
				 }else {
					 overlapX =   x -(boxCollider.x + boxCollider.width) ; 
					 if (y < boxCollider.y) {
							 overlapY = boxCollider.y -(y + height); 
							 if (overlapY > overlapX)
							 {
								 if((collisionAllow & Sides.BOTTOM)>0 && (boxCollider.collisionAllow& Sides.TOP)>0){
									boxCollider.y -= overlapY*colliderPonderation;
									y += overlapY * myPonderation;
									if(boxCollider.velocityY<0) boxCollider.velocityY = 0;
									if(velocityY>0)velocityY = 0;
									touching |= Sides.BOTTOM;
									boxCollider.touching |= Sides.TOP;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
									}
							 }else {
								 if((collisionAllow & Sides.LEFT)>0 && (boxCollider.collisionAllow& Sides.RIGHT)>0) {
									boxCollider.x += overlapX *colliderPonderation;
									x -= overlapX * myPonderation; 
									if(boxCollider.velocityX>0) boxCollider.velocityX = 0;
									if(velocityX<0)velocityX = 0;
									touching |= Sides.LEFT;
									boxCollider.touching |= Sides.RIGHT;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
									}
							 }
						 }else {
							 overlapY =   y -(boxCollider.y + boxCollider.height) ; 
							  if (overlapY > overlapX)
							 {
								 if((collisionAllow & Sides.TOP)>0 && (boxCollider.collisionAllow& Sides.BOTTOM)>0){
									boxCollider.y += overlapY *colliderPonderation;
									y -= overlapY * myPonderation;
									if(boxCollider.velocityY>0) boxCollider.velocityY = 0;
									if(velocityY<0)velocityY = 0;
									touching |= Sides.TOP;
									boxCollider.touching |= Sides.BOTTOM;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
								 }
							 }else {
								if((collisionAllow & Sides.LEFT)>0 && (boxCollider.collisionAllow& Sides.RIGHT)>0) {
									boxCollider.x += overlapX *colliderPonderation;
									x -= overlapX * myPonderation; 
									if(boxCollider.velocityX>0) boxCollider.velocityX = 0;
									if(velocityX<0)velocityX = 0;
									touching |= Sides.LEFT;
									boxCollider.touching |= Sides.RIGHT;
									if (NotifyCallback != null) NotifyCallback(this, boxCollider);
									return true;
									}
							 }
						 }
						
					 
				 }
				 
			 }	
			 return false;
		}else
		if (aCollider.collisionType() == CollisionType.TileMap)
		{
			return aCollider.collide(this,NotifyCallback);
		}else if (aCollider.collisionType() == CollisionType.Group) {
			return aCollider.collide(this,NotifyCallback);
		}
		return false;
	}
	
	/* INTERFACE ICollider */
	
	public function overlap(aCollider:ICollider,?NotifyCallback:ICollider->ICollider->Void):Bool 
	{
		if (aCollider.collisionType() == CollisionType.Box)
		{
			if (overlapVsBox(cast aCollider))
			{
				if (NotifyCallback != null) NotifyCallback(this, aCollider);
				return true;
			}
		}
		else if (aCollider.collisionType() == CollisionType.Group) {
			aCollider.overlap(this,NotifyCallback);//TODO: Fix order
		}
		return  false;
	}
	
	public function bottom() :Float
	{
		return y+ height;
	}
	public function right():Float
	{
		return x + width;
	}
	public function topMiddle():Float
	{
		return x + width/2;
	}
	public function bottomMiddle():Float
	{
		return y + height/2;
	}
	function overlapVsBox(aBox:CollisionBox):Bool
	{
		return (aBox.x < x + width && aBox.x + aBox.width > x &&
				aBox.y < y + height && aBox.y + aBox.height > y );
	}
}