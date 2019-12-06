package com.framework.utils;

class LERP {
	public static inline function f(aA:Float, aB:Float, aS:Float):Float {
		return aB * aS - aA * (aS - 1);
	}

	public static inline function s(current:Float, total:Float):Float {
		return current / total;
	}
}
