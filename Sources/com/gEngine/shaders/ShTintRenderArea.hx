package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.PipelineState;

class ShTintRenderArea extends Painter {
	public function new(autoDestroy:Bool = true, blend:Blend) {
		super(autoDestroy, blend);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.renderAreaTint_frag;
	}
}
