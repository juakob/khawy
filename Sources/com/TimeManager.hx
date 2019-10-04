package com;


class TimeManager
{

	public static var delta(default, null):Float;
	public static var time(default, null):Float = 0;
	public static var realDelta(default, null):Float;
	public static var multiplier:Float=1;
	
	public static function setDelta(delta:Float,realTime:Float):Void
	{
		TimeManager.delta = delta;
		time = realTime;
		realDelta = delta;
	}
	
}