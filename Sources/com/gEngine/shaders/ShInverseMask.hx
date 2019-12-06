package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.shaders.CacheTexture;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.PipelineState;

class ShInverseMask extends ShMask {
	public function new(mask:CacheTexture, blend:Blend) {
		super(mask, blend);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.shMask_vert;
		pipeline.fragmentShader = Shaders.shInverseMask_frag;
	}
}
