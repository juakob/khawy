package com.gEngine.shaders;

import com.gEngine.GEngine;
import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;

class ShHighLight extends Painter {
	private var textureLigthID:TextureUnit;

	public var textureLightID:Int = 0;

	public function new() {
		super();
		// alpha = 1;
		// red = green = blue = 1;
	}

	override private function setBlends(pipeline:PipelineState, blend:Blend) {
		super.setBlends(pipeline, Blend.blendMultipass());
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.HighPassFilter_frag;
	}
	// override function getConstantLocations(aPipeline:PipelineState)
	// {
	// super.getConstantLocations(aPipeline);
	// mTextureLigthID = aPipeline.getTextureUnit("tex2");
	// }
	// override function setParameter(g:Graphics):Void
	// {
	// super.setParameter(g);
	// g.setTexture(mTextureLigthID, GEngine.i.mTextures[textureLightID]);
	// }
}
