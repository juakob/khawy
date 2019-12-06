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

class ShMask extends Painter {
	public var textureMask:CacheTexture;

	var mMaskTextureID:TextureUnit;

	public function new(mask:CacheTexture, blend:Blend) {
		textureMask = mask;
		textureMask.addReference();
		super(true, blend);
	}

	override public function start() {}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.shMask_vert;
		pipeline.fragmentShader = Shaders.shMask_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		mMaskTextureID = pipeline.getTextureUnit("mask");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setTexture(mMaskTextureID, GEngine.i.textures[textureMask.textureID]);
		textureMask.referenceUseFinish();
	}
}
