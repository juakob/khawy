package com.gEngine.display;

import com.gEngine.painters.IPainter;
import com.gEngine.display.IDraw;
import kha.math.FastMatrix3;

class AreaEffectMatrix extends AreaEffect {
	@:access(com.gEngine.GEngine.mPainter)
	public function new(aSnapShotShader:IPainter, aPrintShader:IPainter) {
		super(aSnapShotShader, aPrintShader);
	}

	private override function createDrawFinishRectangle(aPainter):Void {
		var screenWidth = GEngine.i.realWidth * screenScaleX;
		var screenHeight = GEngine.i.realHeight * screenScaleY;
		var faceWidth:Float = width / 10;
		var faceHeigth:Float = height / 10;
		for (sx in 0...10) {
			for (sy in 0...10) {
				aPainter.write(x + faceWidth * sx);
				aPainter.write(y + faceHeigth * sy);
				aPainter.write((x + faceWidth * sx) / screenWidth);
				aPainter.write((y + faceHeigth * sy) / screenHeight);

				aPainter.write((x + (faceWidth) * (sx + 1.5)));
				aPainter.write(y + faceHeigth * sy);
				aPainter.write((x + (faceWidth) * (sx + 1)) / screenWidth);
				aPainter.write((y + faceHeigth * sy) / screenHeight);

				aPainter.write(x + faceWidth * sx);
				aPainter.write(y + (faceHeigth) * (sy + 1));
				aPainter.write((x + faceWidth * sx) / screenWidth);
				aPainter.write((y + (faceHeigth) * (sy + 1)) / screenHeight);

				aPainter.write((x + (faceWidth) * (sx + 1.5)));
				aPainter.write(y + (faceHeigth) * (sy + 1));
				aPainter.write((x + (faceWidth) * (sx + 1)) / screenWidth);
				aPainter.write((y + (faceHeigth) * (sy + 1)) / screenHeight);
			}
		}
	}
}
