package com.gEngine.shaders;

import com.gEngine.painters.Painter;

class CacheTexture extends Painter {
	public function new(autoDestroy:Bool = true) {
		super(autoDestroy);
	}

	var totalReferences:Int = 0;
	var currentReferences:Int = 0;

	override public function releaseTexture():Bool {
		if (totalReferences == currentReferences) {
			currentReferences = 0;
			return true;
		}
		return false;
	}

	public function addReference() {
		++totalReferences;
	}

	public function referenceUseFinish() {
		++currentReferences;
		if (releaseTexture()) {
			GEngine.i.releaseRenderTarget(textureID);
		}
	}
}
