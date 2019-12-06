package com.gEngine.shaders;

import kha.graphics4.TextureUnit;
import com.TimeManager;
import com.gEngine.GEngine;
import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShFOV extends Painter {
	var depthID:TextureUnit;
	var resX:Float;
	var resY:Float;

	public function new(blend:Blend) {
		super(true, blend);
		resX = 2 / GEngine.i.realWidth;
		resY = 2 / GEngine.i.realHeight;
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.fov_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		depthID = pipeline.getTextureUnit("gbufferD");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setTextureDepth(depthID, GEngine.i.textures[textureID]);
	}
}
