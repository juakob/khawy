package com.imageAtlas;
import com.helpers.Point;
import kha.Image;


class Bitmap
{
	public var name:String;
	public var image:Image;
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int = 0;
	public var height:Int = 0;
	public var extrude:Int = 0;
	public var minUV:Point = new Point(0, 0);
	public var maxUV:Point = new Point(1, 1);
	public function new() 
	{
		
	}
	
}