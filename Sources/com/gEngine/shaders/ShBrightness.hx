package com.gEngine.shaders;

import kha.graphics4.ConstantLocation;
import com.gEngine.GEngine;
import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;

class ShBrightness extends Painter {
	private var brightnessID:ConstantLocation;

	public var textureLightID:Int = 0;
	public var brightness:Float = 0.5;

	public function new(blend:Blend, brightness:Float) {
		super(blend);
		this.brightness = brightness;
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.ShBrightness_frag;
	}

	override function getConstantLocations(aPipeline:PipelineState) {
		super.getConstantLocations(aPipeline);
		brightnessID = aPipeline.getConstantLocation("brightness");
	}

	override function setParameter(g:Graphics):Void {
		super.setParameter(g);
		g.setFloat(brightnessID, brightness);
	}
}
