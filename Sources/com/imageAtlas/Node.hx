package com.imageAtlas;

import com.helpers.Rectangle;
import com.imageAtlas.Bitmap;

class Node {
	public function new() {}

	public var Left:Node;
	public var Right:Node;
	public var rect:Rectangle;
	public var bitmap:Bitmap;
}
