package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShMirage extends Painter {
	var time:kha.graphics4.ConstantLocation;

	public function new(blend:Blend) {
		super(true, blend);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.mirage_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		time = pipeline.getConstantLocation("time");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat(time, TimeManager.time);
	}
}
