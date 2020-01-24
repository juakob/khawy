package com.gEngine.display;

import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;

class StaticLayer extends Layer {
	var identity:FastMatrix4 = FastMatrix4.identity();

	override function render(paintMode:PaintMode, transform:FastMatrix4) {
		paintMode.render();
		var proj=paintMode.projection;
		paintMode.projection=paintMode.orthogonal;
		super.render(paintMode, identity);
		paintMode.render();
		paintMode.projection=proj;
	}
}
