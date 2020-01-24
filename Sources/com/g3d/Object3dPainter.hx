package com.g3d;

import kha.graphics4.CullMode;
import kha.graphics4.TextureAddressing;
import kha.graphics4.CompareMode;
import kha.Image;
import kha.graphics4.TextureUnit;
import com.gEngine.display.Blend;
import com.gEngine.GEngine;
import kha.Shaders;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureFilter;
import kha.arrays.Float32Array;
import com.helpers.MinMax;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.PaintInfo;

class Object3dPainter implements IPainter {
	private var pipeline:PipelineState;
	var modelLocation:ConstantLocation;
	var mvpLocation:ConstantLocation;
	var textureLocation:TextureUnit;
	var model:FastMatrix4;
	var mvp:FastMatrix4;
	var texture:Image;
	var bonesTransforms:Float32Array;
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var counter:Int = 0;

	public var textureID:Int;
	public var resolution:Float;
	public var filter:TextureFilter;
	public var mipMapFilter:MipMapFilter;

	var projection:FastMatrix4;

	public function new(blend:Blend) {
		pipeline = new PipelineState();

		var structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv', VertexData.Float2);

		pipeline.inputLayout = [structure];
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		if (kha.Image.renderTargetsInvertedY()) {
			pipeline.cullMode = CullMode.CounterClockwise;
		} else {
			pipeline.cullMode = CullMode.Clockwise;
		}
		pipeline.blendSource = blend.blendSource;
		pipeline.blendDestination = blend.blendDestination;
		pipeline.alphaBlendSource = blend.alphaBlendSource;
		pipeline.alphaBlendDestination = blend.alphaBlendDestination;
		setPrograms(pipeline);
		pipeline.compile();
		getConstantLocation(pipeline);
	}

	function setPrograms(pipeline:PipelineState) {
		pipeline.vertexShader = Shaders.mesh_vert;
		pipeline.fragmentShader = Shaders.meshNoShade_frag;
	}

	function getConstantLocation(pipeline:PipelineState) {
		//	modelLocation = pipeline.getConstantLocation("model");
		mvpLocation = pipeline.getConstantLocation("mvp");
		textureLocation = pipeline.getTextureUnit("tex");
	}

	/* INTERFACE com.gEngine.painters.IPainter */
	public function write(aValue:Float):Void {}

	public function start():Void {}

	public function finish():Void {}

	public function setRenderInfo(model:FastMatrix4, view:FastMatrix4, projection:FastMatrix4, texture:Image, vertexBuffer:VertexBuffer,
			indexBuffer:IndexBuffer) {
		this.model = model;
		this.mvp = projection.multmat(view.multmat(model));
		this.texture = texture;
		this.indexBuffer = indexBuffer;
		this.vertexBuffer = vertexBuffer;
		++counter;
	}

	public function render(clear:Bool = false, cropArea:MinMax = null):Void {
		if (counter == 0)
			return;
		counter = 0;

		var g4:Graphics = GEngine.i.currentCanvas().g4;
		if (cropArea != null)
			g4.scissor(Std.int(cropArea.min.x), Std.int(cropArea.min.y), Std.int(cropArea.max.x), Std.int(cropArea.max.y));
		g4.setIndexBuffer(indexBuffer);
		g4.setVertexBuffer(vertexBuffer);
		g4.setPipeline(pipeline);
		setParameters(g4);
		g4.drawIndexedVertices();
		if (cropArea != null)
			g4.disableScissor();
		#if debugInfo
		++GEngine.drawCount;
		#end
	}

	function setParameters(g4:Graphics) {
		g4.setMatrix(mvpLocation, mvp);
		//	g4.setMatrix(modelLocation, model);
		g4.setTexture(textureLocation, texture);
		//	g4.setTextureParameters(textureLocation,TextureAddressing.Repeat,TextureAddressing.Repeat,TextureFilter.LinearFilter,TextureFilter.LinearFilter,MipMapFilter.LinearMipFilter);
	}

	public function canBatch(info:PaintInfo, size:Int):Bool {
		return false;
	}

	public function setProjection(proj:FastMatrix4):Void {
		projection = proj;
	}

	public function vertexCount():Int {
		return 0;
	}

	public function releaseTexture():Bool {
		return true;
	}

	public function adjustRenderArea(aArea:MinMax):Void {}

	public function resetRenderArea():Void {}

	public function getVertexBuffer():Float32Array {
		return null;
	}

	public function getVertexDataCounter():Int {
		return 0;
	}

	public function setVertexDataCounter(aData:Int):Void {}

	public function destroy():Void {
		pipeline.delete();
	}
}
