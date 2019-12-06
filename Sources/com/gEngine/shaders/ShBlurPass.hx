package com.gEngine.shaders;

import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import com.helpers.MinMax;
import kha.Shaders;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;

class ShBlurPass extends Painter {
	var dirInv:kha.graphics4.ConstantLocation;

	public var amountX:Float;
	public var amountY:Float;

	public function new(amountX:Float, amountY:Float, autoDestroy:Bool = true, blend:Blend = null) {
		super(autoDestroy, blend);
		this.amountX = amountX;
		this.amountY = amountY;
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.blur_pass_frag;
	}

	override public function adjustRenderArea(area:MinMax):Void {
		area.addBorderWidth(Math.abs(amountX * 6));
		area.addBorderHeight(Math.abs(amountY * 6));
	}

	override function getConstantLocations(pipeline:PipelineState) {
		super.getConstantLocations(pipeline);
		dirInv = pipeline.getConstantLocation("dirInv");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat2(dirInv, amountX / canvasWidth, amountY / canvasHeight);
	}
}
