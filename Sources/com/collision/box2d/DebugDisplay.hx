package com.collision.box2d;

import box2D.dynamics.B2DebugDraw;
import com.gEngine.GEngine;
import com.gEngine.display.IDraw;
import com.gEngine.display.IContainer;
import kha.Color;
import com.helpers.MinMax;
import kha.math.FastMatrix4;
import com.gEngine.painters.PaintMode;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.Font;

class DebugDisplay implements IDraw {
	public var x:FastFloat;
	public var y:FastFloat;
	public var z:FastFloat = 0;
	public var offsetX:FastFloat;
	public var offsetY:FastFloat;
	public var rotation(default, set):Float;
	public var scaleX:FastFloat;
	public var scaleY:FastFloat;
	public var scaleZ:FastFloat;
	public var parent:IContainer;
	public var visible:Bool = true;

	var sinAng:Float = 0;
	var cosAng:Float = 0;
	var font:Font;
	var debugDraw:B2DebugDraw;

	public function new(debugDraw:B2DebugDraw) {
		this.debugDraw = debugDraw;
	}

	public function set_rotation(aValue:Float):FastFloat {
		if (aValue != rotation) {
			rotation = aValue;
			sinAng = Math.sin(aValue);
			cosAng = Math.cos(aValue);
		}
		return rotation;
	}

	public function render(paintMode:PaintMode, t:FastMatrix4):Void {
		if (!visible)
			return;
		/*var scaleWidth:Float=GEngine.i.scaleWidth;
			var scaleHeigth:Float=GEngine.i.scaleHeigth;
			paintMode.render();
			GEngine.i.endCanvas();
			var g2=GEngine.i.currentCanvas().g2;
			g2.begin(false);
			if(paintMode.hasRenderArea()){
				var drawArea=paintMode.getRenderArea();
				g2.scissor(cast drawArea.min.x, cast drawArea.min.y, cast drawArea.width(), cast drawArea.height());
			}
			g2.transformation=FastMatrix3.scale(scaleWidth,scaleHeigth).multmat(new FastMatrix3(t._00,t._10,t._30,t._01,t._11,t._31,t._02,t._12,t._22));
			g2.color=color;
			g2.font=font;
			g2.fontSize=fontSize;
			g2.drawString(text,x,y);
			if(paintMode.hasRenderArea()) g2.disableScissor();
			g2.end();
			GEngine.i.beginCanvas(); */

		var scaleWidth:Float = GEngine.i.scaleWidth;
		var scaleHeigth:Float = GEngine.i.scaleHeigth;
		paintMode.render();
		GEngine.i.endCanvas();
		GEngine.i.currentCanvas().g2.transformation = FastMatrix3.scale(scaleWidth, scaleHeigth).multmat(new FastMatrix3(t._00, t._10, t._30, t._01, t._11, t
			._31, t._02, t._12, t._22));
		debugDraw.render(GEngine.i.currentCanvas(), false);
		GEngine.i.beginCanvas();
	}

	public function update(elapsedTime:Float):Void {}

	public function removeFromParent():Void {}

	public function getDrawArea(aValue:MinMax, transform:FastMatrix4):Void {}

	public function getTransformation():FastMatrix3 {
		return FastMatrix3.identity();
	}

	public function getFinalTransformation():FastMatrix3 {
		return FastMatrix3.identity();
	}
}
