package com.helpers;

@:allow(com.gEngine.GEngine)
class RenderTargetPool {
	private var targets:Array<ImageProx>;

	public function new() {
		targets = new Array();
	}

	public function getFreeImageId(width:Int, height:Int):Int {
		for (target in targets) {
			if (!target.inUse && target.width == width && target.height == height) {
				target.inUse = true;
				return target.textureId;
			}
		}
		return -1; // need to create a new Target
	}

	public function addRenderTarget(id:Int, width:Int, height:Int) {
		targets.push(new ImageProx(id, width, height));
	}

	public function release(id:Int) {
		for (target in targets) {
			if (target.textureId == id) {
				target.inUse = false;
				return;
			}
		}
		throw "render target " + id + " not found";
	}

	public function releaseAll() {
		for (target in targets) {
			target.inUse = false;
		}
	}

	public function clear() {
		targets.splice(0, targets.length);
	}
}

class ImageProx {
	public var inUse:Bool;
	public var textureId:Int;
	public var width:Int;
	public var height:Int;

	public function new(id:Int, width:Int, height:Int) {
		inUse = true;
		textureId = id;
		this.width = width;
		this.height = height;
	}
}
