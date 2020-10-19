package com.gEngine.shaders;

import kha.math.Vector3;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import com.gEngine.painters.Painter;
import com.helpers.MinMax;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.PipelineState;

class ShHighPassFilter extends Painter {
	var brightIndexConst:ConstantLocation;
	var darkColorConst:ConstantLocation;
	var tintColorConst:ConstantLocation;
	var toleranceConst:ConstantLocation;

	public var brightIndex:Vector3=new Vector3(0.5,0.5,0.5);
	public var darkColor:Vector3=new Vector3(0.5,0.5,0.5);
	public var tintColor:Vector3=new Vector3(0.5,0.5,0.5);
	public var tolerance:Float=1;

	public function new() {
		super();
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.HighPassFilter_frag;
	}
	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		brightIndexConst=pipeline.getConstantLocation("brightIndex");
		darkColorConst=pipeline.getConstantLocation("darkColor");
		tintColorConst=pipeline.getConstantLocation("tintColor");
		toleranceConst=pipeline.getConstantLocation("tolerance");
	}
	override function setParameter(g:Graphics) {
		super.setParameter(g);
		g.setFloat3(brightIndexConst,brightIndex.x,brightIndex.y,brightIndex.z);
		g.setFloat3(darkColorConst,darkColor.x,darkColor.y,darkColor.z);
		g.setFloat3(tintColorConst,tintColor.x,tintColor.y,tintColor.z);
		g.setFloat(toleranceConst,tolerance);
	}
}
