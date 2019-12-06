package com.g3d;

import kha.math.FastMatrix4;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.Image;

class Object3dData {
	public var vertexBuffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;
	public var skin:Skinning;
	public var animated:Bool;
	public var texture:Image;
	public var modelTransform:FastMatrix4;

	public function new() {}

	public function unload() {
		vertexBuffer.delete();
		indexBuffer.delete();
	}
}
