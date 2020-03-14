package com.gEngine.helper;

import com.gEngine.AnimationData;
import com.gEngine.DrawArea;
import com.gEngine.Frame;
import com.gEngine.display.Sprite;

class RectangleDisplay extends Sprite {
	public static var data:AnimationData;

	public static function init(textureID:Int):Void {
		data = new AnimationData();
		data.name = "rec?";
		var frame:Frame = new Frame();
		frame.drawArea = new DrawArea(0, 0, 1, 1);
		frame.vertexs = [0, 0, 1, 0, 0, 1, 1, 1];
		frame.UVs = [0, 0, 1, 0, 0, 1, 1, 1];
		data.frames = [frame];
		data.texturesID = textureID;
	}

	public function new() {
		animationData = data;
		super();
	}

	public function setColor(r:Int, g:Int, b:Int) {
		colorMultiplication(r / 255, g / 255, b / 255, 1);
	}
}
