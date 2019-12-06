package com.gEngine;

import com.gEngine.painters.IPainter;

class PainterGarbage {
	public static var i(get, null):PainterGarbage;
	#if debug
	private static var initialized:Bool;
	#end

	private static function get_i():PainterGarbage {
		return i;
	}

	public static function init() {
		i = new PainterGarbage();
	}

	var painters:Array<IPainter>;

	public function new() {
		painters = new Array();
	}

	public function add(painter:IPainter) {
		painters.push(painter);
	}

	public function clear() {
		for (painter in painters) {
			painter.destroy();
		}
		painters.splice(0, painters.length);
	}
}
