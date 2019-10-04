package com.gEngine.shaders;


import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import com.helpers.MinMax;
import com.helpers.Point;
import kha.Color;
import kha.Shaders;
import kha.graphics4.BlendingFactor;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;


class ShOutline extends Painter
{
	var colorPosition:kha.graphics4.ConstantLocation;
	var stepSizePosition:kha.graphics4.ConstantLocation;
	
	var color:Color;
	var thick:Float;
	
	public function new(blend:Blend,color:Color,thick:Float) 
	{
		super(true,blend);
		this.color = color;
		this.thick = thick;
	}
	override function setShaders(pipeline:PipelineState):Void 
	{
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.fragmentShader = Shaders.outline_frag;
	}
	override public function adjustRenderArea(aArea:MinMax):Void 
	{
		aArea.addBorderWidth(thick);
		aArea.addBorderHeight(thick);
	}
	override function getConstantLocations(aPipeline:PipelineState) 
	{
		super.getConstantLocations(aPipeline);
		colorPosition = aPipeline.getConstantLocation("color");
		stepSizePosition = aPipeline.getConstantLocation("stepSize");
	}
	override function setParameter(g:Graphics):Void 
	{
		super.setParameter(g);
		g.setFloat3(colorPosition, color.R, color.G, color.B);
		g.setFloat2(stepSizePosition, thick/GEngine.i.realWidth, thick/GEngine.i.realHeight);
	}
	
}