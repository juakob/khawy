package com.framework.utils;

import kha.Framebuffer;

class Entity {
	private var parent:Entity = null;
	private var children:Array<Entity> = new Array<Entity>();
	private var dead:Bool = false;

	public var pool(default, default):Bool;

	private var limbo:Bool = false;
	private var childrenInLimbo:Int = 0;
	private var toDelete:Array<Int> = new Array();

	public function new() {}

	public function update(dt:Float):Void {
		var counter:Int = 0;
		for (child in children) {
			if (child.limbo) {
				++counter;
				continue;
			}
			child.update(dt);
			if (child.isDead()) {
				if (pool) {
					child.limbo = true;
					child.limboStart();
					++childrenInLimbo;
				} else {
					child.destroy();
					toDelete.push(counter);
				}
			}
			++counter;
		}
		var offset = 0;
		for (index in toDelete) {
			children.splice(index - offset, 1);
			++offset;
		}
		toDelete.splice(0, toDelete.length);
	}

	public function render():Void {
		for (child in children) {
			child.render();
		}
	}

	public function destroy():Void {
		for (child in children) {
			child.destroy();
		}
		parent = null;
	}

	public function revive() {
		this.limbo = false;
		this.dead = false;
	}

	private function limboStart():Void {
		throw "override this function recycle object";
	}

	public function recycle(type:Class<Entity>, arg:Array<Dynamic> = null):Entity {
		if (childrenInLimbo > 0) {
			for (child in children) {
				if (!child.limbo)
					continue;

				child.limbo = false;
				child.dead = false;
				--childrenInLimbo;
				return child;
			}
		}

		var obj:Dynamic = Type.createInstance(type, arg == null ? [] : arg);
		addChild(obj);
		return obj;
	}

	public function die():Void {
		dead = true;
	}

	public function isDead():Bool {
		return dead;
	}

	public function addChild(entity:Entity):Void {
		children.push(entity);
		entity.parent = this;
	}

	public static function notify(entity:Entity, id:String, args:Dynamic):Void {
		var res:Bool = entity.onNotify(id, args);
		if (!res) {
			trace("Unhandled message: " + id + ", args: " + args);
		}
	}

	private function onNotify(id:String, args:Dynamic):Bool {
		return false;
	}

	public function numAliveChildren():Int {
		return children.length - childrenInLimbo;
	}

	public function currentCapacity():Int {
		return children.length;
	}

	public function clear():Void {
		for (child in children) {
			child.limboStart();
			child.limbo = true;
			child.dead = true;
		}
		childrenInLimbo = currentCapacity();
	}
}
