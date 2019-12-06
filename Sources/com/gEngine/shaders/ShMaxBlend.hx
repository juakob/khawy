package com.gEngine.shaders;

import com.gEngine.GEngine;
import com.gEngine.display.Blend;
import com.gEngine.shaders.CacheTexture;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;

class ShMaxBlend extends Painter {
	public var textureMask:CacheTexture;

	var maskTextureID:TextureUnit;

	public function new(mask:CacheTexture) {
		textureMask = mask;
		textureMask.addReference();
		super();
	}

	override private function setBlends(pipeline:PipelineState, blend:Blend) {
		pipeline.blendSource = BlendingFactor.BlendOne;
		pipeline.blendDestination = BlendingFactor.BlendZero;
		pipeline.alphaBlendSource = BlendingFactor.InverseDestinationAlpha;
		pipeline.alphaBlendDestination = BlendingFactor.InverseDestinationAlpha;
	}

	override public function start() {}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.shMask_vert;
		pipeline.fragmentShader = Shaders.shMaxBlend_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		maskTextureID = pipeline.getTextureUnit("mask");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setTexture(maskTextureID, GEngine.i.textures[textureMask.textureID]);
		textureMask.referenceUseFinish();
	}
}
