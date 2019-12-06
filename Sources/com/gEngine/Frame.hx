package com.gEngine;

import kha.FastFloat;

class Frame {
	public var vertexs:Array<FastFloat>;
	public var UVs:Array<FastFloat>;
	public var drawArea:DrawArea;

	public function new() {}

	public function clone():Frame {
		var cl = new Frame();
		cl.vertexs = new Array();
		cl.UVs = new Array();
		cl.drawArea = drawArea.clone();

		copyData(vertexs, cl.vertexs);
		copyData(UVs, cl.UVs);

		return cl;
	}

	public inline static function copyData(from:Array<FastFloat>, to:Array<FastFloat>) {
		for (data in from) {
			to.push(data);
		}
	}
}
