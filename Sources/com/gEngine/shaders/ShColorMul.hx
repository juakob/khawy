package com.gEngine.shaders;

import com.gEngine.painters.Painter;
import kha.Color;
import kha.Shaders;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.math.FastVector4;

class ShColorMul extends Painter {
	var colorMulID:kha.graphics4.ConstantLocation;
	var color:FastVector4;

	public function new(color:FastVector4, autoDestroy:Bool = true) {
		super(autoDestroy);
		// pre multiply
		color.x *= color.w;
		color.y *= color.w;
		color.z *= color.w;
		this.color = color;
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.multiplyColor_frag;
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		colorMulID = pipeline.getConstantLocation("colorMul");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setVector4(colorMulID, color);
	}
}
