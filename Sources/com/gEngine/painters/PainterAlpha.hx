package com.gEngine.painters;

import kha.graphics5_.CullMode;
import com.gEngine.display.Blend;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import com.gEngine.painters.PaintInfo;

class PainterAlpha extends Painter {
	public function new(autoDestroy:Bool = true, blend:Blend) {
		MAX_VERTEX_PER_BUFFER = 500*4;
		dataPerVertex = 7;
		super(autoDestroy, blend,false,CullMode.None,MAX_VERTEX_PER_BUFFER,dataPerVertex);
	}

	override function defineVertexStructure(structure:VertexStructure) {
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float4);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simpleAlpha_vert;
		pipeline.fragmentShader = Shaders.simpleAlpha_frag;
	}

	override public function canBatch(info:PaintInfo, size:Int):Bool {
		return canBatchWithTextureArray(info, size);
	}
}
