package com.collision.platformer;

/**
 * @author Joaquin
 */
class Sides
{
	public static var ALL:Int=LEFT|RIGHT|TOP|BOTTOM;
	public static var NONE:Int = 0x00000;
	public static var LEFT:Int = 0x00001;
	public static var RIGHT:Int = 0x00002;
	public static var TOP:Int = 0x00004;
	public static var BOTTOM:Int = 0x00008;
}