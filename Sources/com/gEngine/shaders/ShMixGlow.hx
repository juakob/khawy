package com.gEngine.shaders;

import com.gEngine.shaders.CacheTexture;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShMixGlow extends Painter {
	public var textureBaseColor:CacheTexture;

	var maskTextureID:TextureUnit;
	var amount:Float;
	var amountID:ConstantLocation;

	public function new(baseColor:CacheTexture, amount:Float) {
		textureBaseColor = baseColor;
		textureBaseColor.addReference();
		super();
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.shMixGlow_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		maskTextureID = pipeline.getTextureUnit("baseColor");
		// mAmountID = aPipeline.getConstantLocation("amount");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setTexture(maskTextureID, GEngine.i.textures[textureBaseColor.textureID]);
		// g.setFloat(mAmountID, mAmount);
		textureBaseColor.referenceUseFinish();
	}
}
