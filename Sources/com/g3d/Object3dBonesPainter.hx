package com.g3d;

import kha.graphics4.CullMode;
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

class Object3dBonesPainter implements IPainter {
	private var pipeline:PipelineState;
	var modelLocation:ConstantLocation;
	var viewLocation:ConstantLocation;
	var projectionLocation:ConstantLocation;
	var bonesLoction:ConstantLocation;
	var textureLocation:TextureUnit;
	var model:FastMatrix4;
	var view:FastMatrix4;
	var projection:FastMatrix4;
	var texture:Image;
	var bonesTransforms:Float32Array;
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var counter:Int = 0;

	public var textureID:Int;
	public var resolution:Float;
	public var filter:TextureFilter;
	public var mipMapFilter:MipMapFilter;

	public function new(blend:Blend) {
		pipeline = new PipelineState();
		setPrograms(pipeline);
		var structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv', VertexData.Float2);
		structure.add('weights', VertexData.Float4);
		structure.add('boneIndex', VertexData.Float4);

		pipeline.blendSource = blend.blendSource;
		pipeline.blendDestination = blend.blendDestination;
		pipeline.alphaBlendSource = blend.alphaBlendSource;
		pipeline.alphaBlendDestination = blend.alphaBlendDestination;
		pipeline.inputLayout = [structure];
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		if (kha.Image.renderTargetsInvertedY()) {
			pipeline.cullMode = CullMode.CounterClockwise;
		} else {
			pipeline.cullMode = CullMode.Clockwise;
		}

		pipeline.compile();
		getConstantLocation(pipeline);
	}

	function setPrograms(pipeline:PipelineState) {
		pipeline.vertexShader = Shaders.meshBones_vert;
		pipeline.fragmentShader = Shaders.meshNoShade_frag;
	}

	function getConstantLocation(pipeline:PipelineState) {
		modelLocation = pipeline.getConstantLocation("model");
		viewLocation = pipeline.getConstantLocation("view");
		projectionLocation = pipeline.getConstantLocation("projection");
		bonesLoction = pipeline.getConstantLocation("bones");
		textureLocation = pipeline.getTextureUnit("tex");
	}

	/* INTERFACE com.gEngine.painters.IPainter */
	public function write(aValue:Float):Void {}

	public function start():Void {}

	public function finish():Void {}

	public function setRenderInfo(model:FastMatrix4, view:FastMatrix4, projection:FastMatrix4, texture:Image, vertexBuffer:VertexBuffer,
			indexBuffer:IndexBuffer, bonesTransforms:Float32Array) {
		this.view = view;
		this.model = model;
		this.projection = projection;
		this.texture = texture;
		this.bonesTransforms = bonesTransforms;
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
		// var finalViewMatrix = GEngine.i.getMatrix();
		//	var view = finalViewMatrix.multmat(view);
		g4.setMatrix(projectionLocation, projection);
		g4.setMatrix(viewLocation, view);
		g4.setMatrix(modelLocation, model);

		g4.setTexture(textureLocation, texture);
		g4.setFloats(bonesLoction, bonesTransforms);
	}

	public function canBatch(info:PaintInfo, size:Int):Bool {
		return false;
	}

	public function vertexCount():Int {
		return 0;
	}

	public function releaseTexture():Bool {
		return true;
	}

	public function adjustRenderArea(area:MinMax):Void {}

	public function resetRenderArea():Void {}

	public function getVertexBuffer():Float32Array {
		return null;
	}

	public function getVertexDataCounter():Int {
		return 0;
	}

	public function setVertexDataCounter(data:Int):Void {}

	public function setProjection(proj:FastMatrix4) {
		projection = proj;
	}

	public function destroy():Void {
		pipeline.delete();
	}
}
