package com.gEngine.display;

import com.MyList;
import kha.arrays.Float32Array;

class BatchProxy {
	private var pool:MyList<Batch>;
	private var inUse:Int = 0;
	private var current:Batch;

	public var toDraw(get, null):Float32Array;
	public var counter(get, set):Int;
	public var texture(get, set):Int;
	public var blendMode(get, set):Int;

	public function new() {
		current = new Batch();
		pool = new MyList();
		pool.push(current);
	}

	public function reset():Void {
		inUse = 0;
		change();
	}

	public function change():Void {
		if (pool.length <= inUse) {
			pool.push(new Batch());
		}
		current = pool[inUse];
		current.reset();
		++inUse;
	}

	// getters
	public function get_toDraw():Float32Array {
		return current.toDraw;
	}

	public function get_counter():Int {
		return current.counter;
	}

	public function get_texture():Int {
		return current.texture;
	}

	public function get_blendMode():Int {
		return current.blendMode;
	}

	public function set_counter(value:Int):Int {
		current.counter = value;
		return current.counter;
	}

	public function set_texture(value:Int):Int {
		current.texture = value;
		return current.texture;
	}

	public function set_blendMode(value:Int):Int {
		current.blendMode = value;
		return current.blendMode;
	}
}
