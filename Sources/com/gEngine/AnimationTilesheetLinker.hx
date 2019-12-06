package com.gEngine;

import com.helpers.Rectangle;
import com.MyList;

class AnimationTilesheetLinker {
	public var image:String;
	public var UVs:MyList<Float>;

	public function new(image:String, rectangle:Rectangle, width:Int, height:Float) {
		this.image = image;
		UVs = new MyList();
		//	a-- -c
		//	|   /|
		//	|  / |
		//	| /	 |
		//	b----d

		// a
		UVs.push(rectangle.x / width);
		UVs.push(rectangle.y / height);

		// b
		UVs.push(rectangle.x / width);
		UVs.push((rectangle.y + rectangle.height) / height);

		// c
		UVs.push((rectangle.x + rectangle.width) / width);
		UVs.push(rectangle.y / height);

		// d
		UVs.push((rectangle.x + rectangle.width) / width);
		UVs.push((rectangle.y + rectangle.height) / height);
	}

	public inline function getUWidth():Float {
		return UVs[4] - UVs[0];
	}

	public inline function getVHeight():Float {
		return UVs[3] - UVs[1];
	}

	public inline function getUStart():Float {
		return UVs[0];
	}

	public function getVStart():Float {
		return UVs[1];
	}
}
