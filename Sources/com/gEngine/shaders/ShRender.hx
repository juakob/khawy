package com.gEngine.shaders;

import com.gEngine.painters.Painter;

class ShRender extends Painter {
	public var directDraw:Bool = false;

	public function new(directDraw:Bool = true) {
		this.directDraw = directDraw;
		super(true);
	}
}
