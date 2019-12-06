package com.collision.platformer;

/**
 * @author Joaquin
 */
class Sides {
	public inline static var NONE:Int = 0x00000;
	public inline static var LEFT:Int = 0x00001;
	public inline static var RIGHT:Int = 0x00002;
	public inline static var TOP:Int = 0x00004;
	public inline static var BOTTOM:Int = 0x00008;
	public inline static var ALL:Int = LEFT | RIGHT | TOP | BOTTOM;
}
