package com.gEngine.display;

import kha.Color;
import kha.math.FastMatrix4;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.PaintMode;
import com.gEngine.painters.Painter;
import kha.arrays.Float32Array;

class Stage {
	public var world:Layer;
	public var cameras:Array<Camera>;

	private var matrix:FastMatrix4;

	public var x(get, set):Float;
	public var y(get, set):Float;

	var painterMode:PaintMode;
	var subStages:Array<Stage>;

	public var timeScale:Float = 1;
	public var color(default, set):Color;

	public function new() {
		world = new Layer();
		cameras = [new Camera()];
		cameras[0].world = world;
		matrix = FastMatrix4.identity();
		painterMode = new PaintMode();
		subStages = new Array();
	}

	public function update():Void {
		var dt = TimeManager.delta * timeScale;
		world.update(dt);
		for (camera in cameras) {
			camera.update(dt);
		}
		for (stage in subStages) {
			stage.update();
		}
	}

	public function render():Void {
		for (camera in cameras) {
			camera.render(painterMode, matrix);
			if (painterMode.vertexCount() > 0) {
				painterMode.render();
			}
		}
		for (stage in subStages) {
			stage.render();
		}
	}

	public function addSubStage(stage:Stage) {
		subStages.push(stage);
	}

	public function removeSubStage(stage:Stage) {
		subStages.remove(stage);
	}

	public function addChild(child:IDraw):Void {
		world.addChild(child);
	}

	public inline function defaultCamera():Camera {
		return cameras[0];
	}

	public inline function cameraAt(index:Int) {
		return cameras[index];
	}

	public function addCamera(camera:Camera):Int {
		camera.world=world;
		camera.clearColor = color;
		return cameras.push(camera);
	}

	public function destroy() {
		for (camera in cameras) {
			camera.destroy();
		}
	}

	function get_y():Float {
		return matrix._31;
	}

	function set_y(value:Float):Float {
		return matrix._31 = value;
	}

	function get_x():Float {
		return matrix._30;
	}

	function set_x(value:Float):Float {
		return matrix._30 = value;
	}

	public function set_color(val:Color):Color {
		color = val;
		for (camera in cameras) {
			camera.clearColor = val;
		}
		return val;
	}
}
