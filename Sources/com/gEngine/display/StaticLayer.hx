package com.gEngine.display;

import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;

class StaticLayer extends Layer {
	var offset:FastMatrix4;

	public function new() {
		super();
		offset = FastMatrix4.identity();
	}

	override function render(paintMode:PaintMode, transform:FastMatrix4) {
		paintMode.render();
		var proj = paintMode.camera.projection;
		paintMode.camera.projection = paintMode.camera.orthogonal;
		offset.setFrom(FastMatrix4.translation(-paintMode.camera.width * 0.5, -paintMode.camera.height * 0.5, 0));
		super.render(paintMode, offset);
		paintMode.render();
		paintMode.camera.projection = proj;
	}
}
