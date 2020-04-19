package com.collision.platformer;

class Body {
	public var lastX:Float=0;
	public var lastY:Float=0;
    public var x:Float = 0;
	public var y:Float = 0;
	public var velocityX:Float = 0;
	public var velocityY:Float = 0;
	public var bounce:Float=0;
	public var accelerationX:Float = 0;
	public var accelerationY:Float = 0;
	public var dragX:Float = 1;
	public var dragY:Float = 1;
	public var staticObject:Bool = false;
	public var maxVelocityX:Float = Math.POSITIVE_INFINITY;
	public var maxVelocityY:Float = Math.POSITIVE_INFINITY;
    public var touching:Int = Sides.NONE;
    public function new() {
        
    }
    
    public function update(dt:Float):Void {
		touching = Sides.NONE;
		lastX=x;
		lastY=y;
		velocityX += accelerationX * dt;
		velocityY += accelerationY * dt;
		if (Math.abs(velocityX) > maxVelocityX) {
			if (velocityX > 0) {
				velocityX = maxVelocityX;
			} else {
				velocityX = -maxVelocityX;
			}
		}
		if (Math.abs(velocityY) > maxVelocityY) {
			if (velocityY > 0) {
				velocityY = maxVelocityY;
			} else {
				velocityY = -maxVelocityY;
			}
		}
		x += velocityX * dt;
		y += velocityY * dt;

		if (accelerationX == 0) {
			velocityX *= dragX;
			if (Math.abs(velocityX) < 70) {
				velocityX = 0;
			}
		}
		if (accelerationY == 0) {
			velocityY *= dragY;
			if (Math.abs(velocityY) < 70) {
				velocityY = 0;
			}
		}
	}
}