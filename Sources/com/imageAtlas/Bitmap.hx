package com.imageAtlas;

import kha.graphics4.PipelineState;
import com.helpers.Point;
import kha.Image;

class Bitmap {
	public var name:String;
	public var image:Image;
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Int = 0;
	public var height:Int = 0;
	public var extrude:Int = 0;
	public var scaleX:Float=1;
	public var scaleY:Float=1;
	public var minUV:Point = new Point(0, 0);
	public var maxUV:Point = new Point(1, 1);
	public var specialPipeline:PipelineState = null;
	public var hasMipMap:Bool=false;

	public function new() {}
}
