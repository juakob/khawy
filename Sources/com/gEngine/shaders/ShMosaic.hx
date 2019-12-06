package com.gEngine.shaders;

import com.TimeManager;
import com.gEngine.GEngine;
import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShMosaic extends Painter {
	var resolutionID:ConstantLocation;

	public var tilesCount:Int = 500;

	public function new(blend:Blend) {
		super(true, blend);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.mosaic_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		resolutionID = pipeline.getConstantLocation("tiles");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat(resolutionID, tilesCount);
	}
}
