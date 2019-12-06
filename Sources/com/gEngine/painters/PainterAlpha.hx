package com.gEngine.painters;

import com.gEngine.display.Blend;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;

class PainterAlpha extends Painter {
	public function new(autoDestroy:Bool = true, blend:Blend) {
		super(autoDestroy, blend);
		dataPerVertex = 6;
	}

	override function defineVertexStructure(structure:VertexStructure) {
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float3);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simpleAlpha_vert;
		pipeline.fragmentShader = Shaders.simpleAlpha_frag;
	}
}
