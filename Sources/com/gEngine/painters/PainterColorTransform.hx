package com.gEngine.painters;

import com.gEngine.display.Blend;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;

class PainterColorTransform extends Painter {
	public function new(autoDestroy:Bool = true, blend:Blend) {
		super(autoDestroy, blend);
		dataPerVertex = 13;
	}

	override function defineVertexStructure(structure:VertexStructure) {
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("colorMul", VertexData.Float4);
		structure.add("colorAdd", VertexData.Float4);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simpleColorTransformation_vert;
		pipeline.fragmentShader = Shaders.simpleColorTransformation_frag;
	}
}
