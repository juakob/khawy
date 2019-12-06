package com.gEngine.shaders;

import com.gEngine.painters.Painter;
import com.helpers.MinMax;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.PipelineState;

class ShHighPassFilter extends Painter {
	public function new() {
		super();
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.HighPassFilter_frag;
	}
}
