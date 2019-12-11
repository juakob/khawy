package com.g3d;

import com.g3d.OgexData.BoneNode;
import com.g3d.OgexData.Node;
import kha.graphics4.Usage;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;
import com.g3d.OgexData.GeometryNode;
import kha.Image;
import kha.Assets;

class MeshExtractor {
	public static function extract(data:OgexData, skeletons:Array<SkeletonD>):Array<Object3dData> {
		var structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv', VertexData.Float2);
		if (skeletons != null && skeletons.length != 0) {
			structure.add('weights', VertexData.Float4);
			structure.add('boneIndex', VertexData.Float4);
		}
		var result = new Array<Object3dData>();
		for (node in data.children) {
			if (Std.is(node, GeometryNode)) {} else if (Std.is(node, BoneNode)) {}
		}
		var geometries = data.geometryObjects;
		for (geomtry in geometries) {
			var vertices = geomtry.mesh.vertexArrays[0].values;
			var normals = geomtry.mesh.vertexArrays[1].values;
			var uv = geomtry.mesh.vertexArrays[2].values;
			var indices = geomtry.mesh.indexArray.values;
			var skin = geomtry.mesh.skin;
			var textureName = null;
			for (child in data.children) {
				textureName = getTextureName(child, data, geomtry.ref);
				if (textureName != null)
					break;
			}
			if (textureName == null || textureName == "") {
				continue;
			}
			var texture:Image = cast Reflect.field(Assets.images, textureName);
			if (texture != null)
				texture.generateMipmaps(3);

			var boneIndexs = new Array<Int>();
			var boneWeight = new Array<Float>();
			if (skeletons != null && skeletons.length != 0) {
				var counter:Int = 0;
				for (numAffectingBones in skin.boneCountArray.values) {
					for (i in 0...numAffectingBones) {
						boneIndexs.push(skin.boneIndexArray.values[counter + i]);
						boneWeight.push(skin.boneWeightArray.values[counter + i]);
					}
					counter += numAffectingBones;
					if (numAffectingBones > 4)
						throw "implementation limited to 4 bones per vertex";
					for (i in numAffectingBones...4) // fill up to 4 bones per vertex
					{
						boneIndexs.push(0);
						boneWeight.push(0);
					}
				}
			}

			var vertexBuffer = new VertexBuffer(vertices.length, structure, Usage.StaticUsage);
			var buffer = vertexBuffer.lock();
			if (skeletons != null && skeletons.length != 0) {
				for (i in 0...Std.int(vertices.length / 3)) {
					buffer.set(i * 16 + 0, vertices[i * 3 + 0]);
					buffer.set(i * 16 + 1, vertices[i * 3 + 1]);
					buffer.set(i * 16 + 2, vertices[i * 3 + 2]);
					buffer.set(i * 16 + 3, normals[i * 3 + 0]);
					buffer.set(i * 16 + 4, normals[i * 3 + 1]);
					buffer.set(i * 16 + 5, normals[i * 3 + 2]);
					buffer.set(i * 16 + 6, uv[i * 2 + 0]);
					buffer.set(i * 16 + 7, 1 - uv[i * 2 + 1]);
					buffer.set(i * 16 + 8, boneWeight[i * 4 + 0]);
					buffer.set(i * 16 + 9, boneWeight[i * 4 + 1]);
					buffer.set(i * 16 + 10, boneWeight[i * 4 + 2]);
					buffer.set(i * 16 + 11, boneWeight[i * 4 + 3]);
					buffer.set(i * 16 + 12, boneIndexs[i * 4 + 0]);
					buffer.set(i * 16 + 13, boneIndexs[i * 4 + 1]);
					buffer.set(i * 16 + 14, boneIndexs[i * 4 + 2]);
					buffer.set(i * 16 + 15, boneIndexs[i * 4 + 3]);
				}
			} else {
				for (i in 0...Std.int(vertices.length / 3)) {
					buffer.set(i * 8 + 0, vertices[i * 3 + 0]);
					buffer.set(i * 8 + 1, vertices[i * 3 + 1]);
					buffer.set(i * 8 + 2, vertices[i * 3 + 2]);
					buffer.set(i * 8 + 3, normals[i * 3 + 0]);
					buffer.set(i * 8 + 4, normals[i * 3 + 1]);
					buffer.set(i * 8 + 5, normals[i * 3 + 2]);
					buffer.set(i * 8 + 6, uv[i * 2 + 0]);
					buffer.set(i * 8 + 7, 1 - uv[i * 2 + 1]);
				}
			}
			vertexBuffer.unlock();

			var indexBuffer = new IndexBuffer(indices.length, Usage.StaticUsage);
			var ibuffer = indexBuffer.lock();
			for (i in 0...indices.length) {
				ibuffer[i] = indices[i];
			}
			indexBuffer.unlock();
			var object3dData = new Object3dData();

			if (skeletons != null && skeletons.length != 0) {
				var bones:Array<Bone> = new Array();
				var skeleton = skin.skeleton;
				var bonesNames = skeleton.boneRefArray.refs;
				for (name in bonesNames) {
					for (sk in skeletons) {
						var bone = sk.getBone(name);
						if (bone != null) {
							bones.push(bone);
							break;
						}
					}
				}

				if (bones.length != bonesNames.length)
					throw "some skined bones not found `v('~')v´";
				for (i in 0...skeleton.transforms.length) {
					bones[i].bindTransform = FastMatrix4.empty();
					Bone.matrixFromArray(skeleton.transforms[i].values, 0, bones[i].bindTransform);
				}
				var skining:Skinning = new Skinning(bones);
				object3dData.skin = skining;
			}

			object3dData.vertexBuffer = vertexBuffer;
			object3dData.indexBuffer = indexBuffer;

			object3dData.animated = (skeletons != null && skeletons.length != 0);
			object3dData.texture = texture;
			result.push(object3dData);
		}
		return result;
	}

	static function getTextureName(node:Node, data:OgexData, ref:String):String {
		if (Std.is(node, GeometryNode)) {
			var gNode:GeometryNode = cast node;
			if (ref == gNode.objectRefs[0]) {
				var material = data.getMaterial(gNode.materialRefs[0]);
				if (material.texture.length == 0)
					return "";
				var path = material.texture[0].path;
				var parts = path.split("/");
				var ss = parts[parts.length - 1];
				ss = StringTools.replace(ss, "-", "_");
				ss = StringTools.replace(ss, " ", "_");
				return ss.split(".")[0];
			}
		}
		for (node in node.children) {
			var name = getTextureName(node, data, ref);
			if (name != null)
				return name;
		}
		return null;
	}
}
