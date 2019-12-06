package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import com.helpers.MinMax;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShBlurH extends Painter {
	var resolutionID:ConstantLocation;

	public var factor:Float;

	public function new(delete:Bool, factor:Float = 1, blend:Blend) {
		super(delete, blend);
		this.factor = factor;
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.hBlurVertexShader_vert;
		pipeline.fragmentShader = Shaders.blurFragmentShader_frag;
	}

	override public function adjustRenderArea(area:MinMax):Void {
		area.addBorderHeight(2 * factor);
		// height = aArea.height();
	}

	public var height:Float = 1280;

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		resolutionID = pipeline.getConstantLocation("resolution");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat2(resolutionID, 1 / height * factor, 0);
	}
}
