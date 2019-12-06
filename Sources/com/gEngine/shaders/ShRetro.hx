package com.gEngine.shaders;

import com.TimeManager;
import com.gEngine.GEngine;
import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShRetro extends Painter {
	public function new(blend:Blend) {
		super(true, blend);
	}

	var mTimer:ConstantLocation;

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		mTimer = pipeline.getConstantLocation("time");
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simpleTime_vert;
		pipeline.fragmentShader = Shaders.rgbSplit_frag;
	}

	var time:Float = 0;

	override function setParameter(g:Graphics):Void {
		time += TimeManager.delta * 5;
		super.setParameter(g);
		g.setFloat(mTimer, time);
	}
}
