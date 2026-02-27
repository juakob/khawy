package com.gEngine.painters;

import kha.graphics5_.CullMode;
import com.gEngine.display.Blend;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import com.gEngine.painters.PaintInfo;

class PainterColorTransform extends Painter {
	public function new(autoDestroy:Bool = true, blend:Blend, depthWrite:Bool = false) {
		super(autoDestroy, blend, depthWrite,CullMode.None,100*4,14);
	}

	override function defineVertexStructure(structure:VertexStructure) {
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float3);
		structure.add("colorMul", VertexData.Float4);
		structure.add("colorAdd", VertexData.Float4);
	}

	override function setShaders(pipeline:PipelineState):Void {
		pipeline.vertexShader = Shaders.simpleColorTransformation_vert;
		pipeline.fragmentShader = Shaders.simpleColorTransformation_frag;
	}

	override public function canBatch(info:PaintInfo, size:Int):Bool {
		return canBatchWithTextureArray(info, size);
	}
}
