package com.collision.box2d;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;

class SimplePlayerCollision {
	public var body:B2Body;
	public var shape:B2Fixture;
	public var dragX:Float = 1;
	public var dragY:Float = 1;

	var moving:Bool = false;

	public var velocityX(get, set):Float;
	public var velocityY(get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;

	public function new(x:Float, y:Float, width:Float, height:Float, world:B2World) {
		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.DYNAMIC_BODY;
		body = world.createBody(bodyDef);
		var box = new B2PolygonShape();
		box.setAsBox(width * Const.invWorldScale, height * Const.invWorldScale);
		var fixture = new B2FixtureDef();
		fixture.friction = 0;
		fixture.shape = box;
		fixture.density = 1;
		shape = body.createFixture(fixture);
		body.setPosition(new B2Vec2(x * Const.invWorldScale, y * Const.invWorldScale));
		body.setFixedRotation(true);
	}

	public function set_velocityX(velX:Float):Float {
		moving = true;
		body.setAwake(true);
		body.getLinearVelocity().x = velX * Const.invWorldScale;
		return velX;
	}

	public function get_velocityX():Float {
		return body.getLinearVelocity().x * Const.worldScale;
	}

	public function set_velocityY(velY:Float):Float {
		moving = true;
		body.setAwake(true);
		body.getLinearVelocity().y = velY * Const.invWorldScale;
		return velY;
	}

	public function get_velocityY():Float {
		return body.getLinearVelocity().y * Const.worldScale;
	}

	public function set_x(x:Float):Float {
		body.getPosition().x = x * Const.invWorldScale;
		return x;
	}

	public function get_x():Float {
		return body.getPosition().x * Const.worldScale;
	}

	public function set_y(y:Float):Float {
		body.getPosition().y = y * Const.invWorldScale;
		return y;
	}

	public function get_y():Float {
		return body.getPosition().y * Const.worldScale;
	}

	public function update(dt:Float) {
		if (!moving) {
			body.getLinearVelocity().x *= dragX;
			body.getLinearVelocity().y *= dragY;
		}
		moving = false;
	}
}
