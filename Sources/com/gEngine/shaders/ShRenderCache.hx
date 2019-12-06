package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.shaders.CacheTexture;
import com.gEngine.painters.Painter;
import kha.graphics4.Graphics;

class ShRenderCache extends Painter {
	public var texture:CacheTexture;

	public function new(texture:CacheTexture, autoDestroy:Bool = true, blend:Blend = null) {
		super(autoDestroy, blend);
		this.texture = texture;
		texture.addReference();
	}

	override function setParameter(g:Graphics):Void {
		g.setMatrix(mvpID, GEngine.i.getMatrix());
		g.setTexture(textureConstantID, GEngine.i.textures[texture.textureID]);
		texture.referenceUseFinish();
	}
}
