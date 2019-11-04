package com.gEngine.display;

import kha.math.FastVector2;
import kha.math.FastMatrix4;
import com.gEngine.DrawArea;
import com.gEngine.Filter;
import com.gEngine.painters.IPainter;
import com.gEngine.painters.PaintMode;
import com.gEngine.painters.Painter;
import com.gEngine.display.IDraw;
import com.gEngine.display.IContainer;
import com.helpers.MinMax;
import kha.FastFloat;
import kha.math.FastMatrix3;


class Layer implements IDraw implements IContainer {
	private var children:Array<IDraw>;
	private var texture:Int;

	public var x:FastFloat = 0;
	public var y:FastFloat = 0;
	public var z:FastFloat = 0;
	public var scaleX:FastFloat = 1;
	public var scaleY:FastFloat = 1;
	public var scaleZ:FastFloat = 1;
	public var pivotX:FastFloat = 0;
	public var pivotY:FastFloat = 0;
	public var paralaxX:Float=1;
	public var paralaxY:Float=1;
	public var parent:IContainer;
	public var visible:Bool = true;
	public var filter:Filter;
	public var drawArea(default, set):MinMax;
	public var length(get, null):Int;

	private var cosAng:FastFloat;
	private var sinAng:FastFloat;
	var scaleArea:MinMax=new MinMax();
	var transform:FastMatrix4;

	public function new() {
		children = new Array();
		rotation = 0;
		cosAng = 1;
		sinAng = 0;
		this.transform=FastMatrix4.identity();
	}
	 function calculateTransform(transform:FastMatrix4){
		var scale = FastMatrix4.scale(scaleX, scaleY, 1).multmat(FastMatrix4.translation( -pivotX,  -pivotY, 0));
		var rotation = new FastMatrix4(cosAng , -sinAng , 0, 0, sinAng , cosAng , 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
		var translation	= FastMatrix4.translation(x , y, z);
		var model = transform.multmat(translation.multmat(scale).multmat(rotation));
		model._30*=paralaxX;
		model._31*=paralaxY;
		this.transform.setFrom(model);
	}
	public function render(paintMode:PaintMode, transform:FastMatrix4):Void {
		calculateTransform(transform);
		if (!visible) {
			return;
		}

		if (drawArea != null) {
			paintMode.render();
			scaleArea.setFrom(drawArea);
			scaleArea.scale( GEngine.i.scaleWidth, GEngine.i.scaleHeigth);
			paintMode.adjustRenderArea(scaleArea);
		}
		if(filter!=null){
			filter.filterStart(this,paintMode,transform);
		}
		for (child in children) {
			child.render(paintMode, this.transform);
		}
		if(filter!=null){
			filter.filterEnd(paintMode);
		}
		if (drawArea != null) {
			paintMode.render();
			paintMode.resetRenderArea(); 
		}
	}

	var drawAreaTemp:MinMax = new MinMax();

	public function getDrawArea(value:MinMax,transform:FastMatrix4):Void {
		calculateTransform(transform);
		drawAreaTemp.reset();
		for (child in children) {
			if(child.visible)child.getDrawArea(drawAreaTemp,this.transform);
		}
	//	drawAreaTemp.transform3(getTransformation());	
		value.merge(drawAreaTemp);
		if(drawArea!=null){
			scaleArea.setFrom(drawArea);
			scaleArea.scale( GEngine.i.scaleWidth, GEngine.i.scaleHeigth);
			value.intersection(scaleArea);
		} 
	}

	public var playing(default, default):Bool = true;

	public function stop():Void {
		playing = false;
	}

	public function play():Void {
		playing = true;
	}

	public function update(passedTime:Float):Void {
		if (playing) {
			for (child in children) {
				child.update(passedTime);
			}
		}
	}

	public function addChild(child:IDraw):Void {
		child.parent = this;
		children.push(cast child);
	}
	public function addChildOrder(child:IDraw,functionOrder:IDraw->IDraw->Int){
		child.parent = this;
		var counter:Int=0;
		for(childIter in children){
			if(functionOrder(childIter,child)>=0){
				children.insert(counter,child);
				return;
			}
			++counter;
		}
		children.push(cast child);
	}

	public function remove(child:IDraw):Void {
		var counter:Int = 0;
		for (childIter in children) {
			if (childIter == child) {
				children.splice(counter, 1);
				return;
			}
			++counter;
		}
	}

	public function destroy():Void {
		children.splice(0, children.length);
	}

	public function removeFromParent():Void {
		if (parent != null) {
			parent.remove(this);
		}
	}

	public function sort(functionSort:IDraw->IDraw->Int):Void {
		children.sort(functionSort);
	}


	public function getTransformation():FastMatrix3 {
		var transform = FastMatrix3.translation(-pivotX, -pivotY);
		transform = transform.multmat(FastMatrix3.scale(scaleX, scaleY));
		transform = transform.multmat(new FastMatrix3(cosAng, -sinAng, 0, sinAng, cosAng, 0, 0, 0, 1));
		transform = transform.multmat(FastMatrix3.translation(x , y ));
		return transform;
	}
	public function getFinalTransformation():FastMatrix3 {
		if(parent!=null){
			return parent.getFinalTransformation().multmat(getTransformation());
		}else{
			return getTransformation();
		}
	}

	public var offsetX:FastFloat;
	public var offsetY:FastFloat;
	public var rotation(default, set):Float;

	public function set_rotation(value:Float):FastFloat {
		if (value != rotation) {
			rotation = value;
			sinAng = Math.sin(value);
			cosAng = Math.cos(value);
		}
		return rotation;
	}

	public static function sortYCompare(a:IDraw, b:IDraw):Int {
		if (a.y < b.y) {
			return -1;
		}
		if (a.y > b.y) {
			return 1;
		}
		return 0;
	}
	public static function sortZCompare(a:IDraw, b:IDraw):Int {
		if (a.z < b.z) {
			return -1;
		}
		if (a.z > b.z) {
			return 1;
		}
		return 0;
	}

	function set_drawArea(value:MinMax):MinMax {
		value.min.x = value.min.x ;
		value.min.y = value.min.y ;
		value.max.x = value.max.x ;
		value.max.y = value.max.y ;
		return drawArea = value;
	}

	function get_length():Int {
		return children.length;
	}
	

}
