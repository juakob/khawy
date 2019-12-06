package com.gEngine.helper;

class Screen {
	public static inline function getWidth():Int {
		return kha.System.windowWidth();
	}

	public static inline function getHeight():Int {
		return kha.System.windowHeight();
	}

	public function new() {}
}
