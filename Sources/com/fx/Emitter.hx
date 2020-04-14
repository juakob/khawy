package com.fx;

import com.framework.utils.Entity;
import com.gEngine.display.Layer;

class Emitter extends Entity {
	public var minVelocityX:Float = 0;
	public var maxVelocityX:Float = 0;
	public var minVelocityY:Float = 0;
	public var maxVelocityY:Float = 0;
	public var minScale:Float = 1;
	public var maxScale:Float = 1;
	public var maxLife:Float = 0;
	public var minLife:Float = 0;

	private var container:Layer;
	private var playing:Bool;
	private var timePlaying:Bool;
	private var time:Float = 0;

	public var x:Float = 0;
	public var y:Float = 0;
	public var allX(get, set):Float;
	public var allY(get, set):Float;
	public var xRandom:Float = 0;
	public var yRandom:Float = 0;
	public var angularVelocityMax:Float = 0;
	public var angularVelocityMin:Float = 0;
	public var gravity:Float = 0;
	public var accelerationX:Float = 0;

	public function new() {
		super();
		pool = true;
		container = new Layer();
	}

	public function reset(layer:Layer):Void {
		layer.addChild(container);
	}

	override private function limboStart():Void {
		container.removeFromParent();
	}

	public function start(emittTime:Float = 0):Void {
		playing = true;
		if (emittTime > 0) {
			timePlaying = true;
			time = emittTime;
		}
	}

	public function stop():Void {
		playing = false;
		timePlaying = false;
	}

	override function update(dt:Float):Void {
		super.update(dt);
		if (timePlaying) {
			time -= dt;
			if (time < 0) {
				stop();
			}
		}
		if (!playing) {
			if (numAliveChildren() == 0) {
				die();
			}
			return;
		}
		while (numAliveChildren() != currentCapacity()) {
			var particle:Particle = cast(recycle(Particle));
			particle.reset(x + xRandom - xRandom * 2 * Math.random(), y + yRandom - yRandom * 2 * Math.random(), minLife + (maxLife - minLife) * Math.random(),
				minVelocityX + (maxVelocityX - minVelocityX) * Math.random(), minVelocityY + (maxVelocityY - minVelocityY) * Math.random(), container,
				angularVelocityMin + (angularVelocityMax - angularVelocityMin) * Math.random(), minScale + (maxScale - minScale) * Math.random());
			particle.gravity = gravity;
			particle.accelerationX = accelerationX;
		}
	}

	public function get_allX():Float {
		return container.x;
	}

	public function set_allX(value:Float):Float {
		return container.x = value;
	}

	public function get_allY():Float {
		return container.y;
	}

	public function set_allY(value:Float):Float {
		return container.y = value;
	}
}
