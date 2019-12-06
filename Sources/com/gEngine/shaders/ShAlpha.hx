package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShAlpha extends Painter {
	var alphaValue:Float = 1;
	var alphaID:ConstantLocation;

	public function new(blend:Blend, alpha:Float = 1, autoDestroy:Bool = true) {
		super(autoDestroy, blend);
		this.alphaValue = alpha;
	}

	override function getConstantLocations(aPipeline:PipelineState) {
		super.getConstantLocations(aPipeline);
		alphaID = aPipeline.getConstantLocation("alpha");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat(alphaID, alphaValue);
	}

	override function setShaders(aPipeline:PipelineState):Void {
		aPipeline.vertexShader = Shaders.alpha_vert;
		aPipeline.fragmentShader = Shaders.simpleAlpha_frag;
	}
}
