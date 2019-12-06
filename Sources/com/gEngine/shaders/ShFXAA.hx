package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShFXAA extends Painter {
	var resolutionID:ConstantLocation;

	public function new(delete:Bool, blend:Blend) {
		super(delete, blend);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.fxaa_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		resolutionID = pipeline.getConstantLocation("screenSizeInv");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat2(resolutionID, 1 / GEngine.i.width * GEngine.i.scaleWidth, 1 / GEngine.i.height * GEngine.i.scaleHeigth);
	}
}
