package com.gEngine.shaders;

import com.TimeManager;
import com.gEngine.GEngine;
import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShRgbSplit extends Painter {
	var resolutionID:ConstantLocation;

	public var spreadX:Float = 2;
	public var spreadY:Float = 2;

	public function new(blend:Blend) {
		super(true, blend);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.simpleRgbSplit_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		resolutionID = pipeline.getConstantLocation("resolution");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat2(resolutionID, spreadX / canvasWidth, spreadY / canvasHeight);
	}
}
