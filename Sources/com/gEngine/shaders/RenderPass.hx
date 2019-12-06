package com.gEngine.shaders;

import com.gEngine.painters.IPainter;

class RenderPass {
	public var renderAtEnd:Bool;
	public var filters:Array<IPainter>;

	public function new(filters:Array<IPainter>, renderAtEnd:Bool) {
		this.filters = filters;
		this.renderAtEnd = renderAtEnd;
	}
}
