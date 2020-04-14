package com.g3d;

import com.gEngine.display.Blend;
import com.g3d.Object3dBonesPainter;
import com.gEngine.painters.PaintMode;
import com.gEngine.display.IContainer;
import com.helpers.MinMax;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import com.gEngine.helper.Timeline;
import com.gEngine.display.IAnimation;

class Object3d implements IAnimation {
	public var x:FastFloat = 0;
	public var y:FastFloat = 0;
	public var z:FastFloat = 0;
	public var offsetX:FastFloat = 1;
	public var offsetY:FastFloat = 1;
	public var rotation(default, set):Float=0;
	public var scaleX:FastFloat = 1;
	public var scaleY:FastFloat = 1;
	public var scaleZ:FastFloat = 1;
	public var parent:IContainer;
	public var visible:Bool;
	public var timeline(default, null):Timeline;
	public var angleZ:Float = 0;

	var cosAngle:Float = 1;
	var sinAngle:Float = 0;
	var parts:Array<Object3dData>;
	var skeleton:SkeletonD;
	var animated:Bool = false;

	static var painterBones:Object3dBonesPainter;
	static var painter:Object3dPainter;

	public function new(name:String) {
		if (painterBones == null) {
			painterBones = new Object3dBonesPainter(Blend.blendDefault());
			painter = new Object3dPainter(Blend.blendDefault());
		}
		parts = Object3dDB.i.getData(name);
		skeleton = Object3dDB.i.getSkeleton(name);
		animated = skeleton != null;
		if (animated) {
			timeline = new Timeline(1 / 30, skeleton.totalFrames());
		} else {
			timeline = new Timeline(0, 0);
		}
	}

	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		var model = FastMatrix4.translation(x, y, z)
			.multmat(FastMatrix4.rotationZ(angleZ))
			.multmat(FastMatrix4.rotationY(rotation))
			.multmat(FastMatrix4.scale(-scaleX, scaleY, scaleZ));
		// var cameraMatrix=FastMatrix4.lookAt(new FastVector3(0, 0, 1), new FastVector3(0, 0, 0), new FastVector3(0, 1, 0));
		var cameraMatrix = transform; // .multmat(cameraMatrix);
		if (animated) {
			skeleton.setFrame(timeline.currentFrame);
		}
		var projection = paintMode.camera.projection;
		paintMode.render();
		for (part in parts) {
			if (part.skin != null) {
				painterBones.setRenderInfo(model, cameraMatrix, projection, part.texture, part.vertexBuffer, part.indexBuffer, part.skin.getBonesTransformations
					());
				painterBones.render();
			} else {
				painter.setRenderInfo(model, cameraMatrix, projection, part.texture, part.vertexBuffer, part.indexBuffer);
				painter.render();
			}
		}
	}

	public function update(elapsedTime:Float):Void {
		timeline.update(elapsedTime);
	}

	public function removeFromParent():Void {
		parent.remove(this);
	}

	public function getDrawArea(value:MinMax, transform:FastMatrix4):Void {}

	public function getTransformation():FastMatrix3 {
		return null;
	}

	public function getFinalTransformation():FastMatrix3 {
		return null;
	}

	function set_rotation(value:Float):Float {
		cosAngle = Math.cos(value);
		sinAngle = Math.sin(value);
		return rotation = value;
	}
}
