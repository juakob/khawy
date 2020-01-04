package com.gEngine.shaders;

import com.gEngine.painters.Painter;

@:keep
class ShRender extends Painter {
	public var directDraw:Bool;

	public function new(directDraw:Bool = true) {
		this.directDraw = directDraw;
		super(true);
	}
}
