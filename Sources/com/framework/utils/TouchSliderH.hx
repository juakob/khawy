package com.framework.utils;
import com.gEngine.display.Layer;
import com.helpers.MinMax;

enum ScrollDirection {
Horizontal; Vertical;	
}
class TouchSliderH extends Entity
{
	public var width:Float;
	public var height:Float;
	public var x:Float;
	public var y:Float;
	public var display:Layer;
	public var scrollLimit:Float =-1;
	public var scrollStart:Float = 0;
	public var slotSize:Float = 1;
	var components:Array<UIComponent>;
	var scrollDirection:ScrollDirection;
	public var cropLayer(default,set):Bool;
	
	public function new(x:Float,y:Float,width:Float,height:Float,scrollDirection:ScrollDirection) 
	{
		super();
		this.width = width;
		this.height = height;
		velocities = new Array();
		for (i in 0...REC_POSITIONS_NUM) 
		{
			velocities.push(0);
		}
		display = new Layer();
		this.x = x;
		this.y = y;
		components = new Array();
		this.scrollDirection = scrollDirection;
	}
	var captureMovement:Bool;
	var velocities:Array<Float>;
	var	posIndex:Int=0;
	static inline var REC_POSITIONS_NUM:Int = 3;
	var offset:Float;
	var velocity:Float=0;
	var friction:Float=0.95;
	var slotVel:Float = 0;
	var lock:Bool;
	public var maxDelta:Float = 20;
	var startTouch:Bool;
	var startX:Float = 0;
	var startY:Float = 0;
	override function onUpdate(dt:Float):Void 
	{
		if (Input.i.isMousePressed())
		{
			var mouseX:Float = Input.i.getMouseX();
			var mouseY:Float = Input.i.getMouseY();
			if (mouseX < right() && mouseX > left() && mouseY > top() && mouseY < bottom())
			{
				startX = Input.i.getMouseX();
				startY = Input.i.getMouseY();
				startTouch = true;
			}
			for (i in 0...REC_POSITIONS_NUM) 
				{
					velocities[i]=0;
				}
		}
		if (startTouch&&Input.i.isMouseDown())
		{
			var mouseX:Float = Input.i.getMouseX();
			var mouseY:Float = Input.i.getMouseY();
			if (mouseX < right() && mouseX > left() && mouseY > top() && mouseY < bottom()&&(Math.abs(startX-mouseX)>maxDelta||Math.abs(startY-mouseY)>maxDelta))
			{
				startTouch = false;
				captureMovement = true;
				if(scrollDirection==ScrollDirection.Horizontal){
					offset = display.x - mouseX;
				}else {
					offset = display.y - mouseY;
				}
				
			}else {
				for (component in components) 
				{
					component.handleInput();
				}	
			}
			
		}
		if (startTouch && Input.i.isMouseReleased()) {
			for (component in components) 
			{
				component.handleInput();
			}	
			startTouch = false;
		}
		
		if (captureMovement)
		{
			var nextPos:Float;
			if(scrollDirection==ScrollDirection.Horizontal){
				 nextPos = Input.i.getMouseX() + offset;
			}else {
				nextPos = Input.i.getMouseY() + offset;
			}	
			posIndex = (++posIndex) % REC_POSITIONS_NUM;
			
			if (scrollDirection == ScrollDirection.Horizontal) {
				velocities[posIndex] = (nextPos - display.x) / dt;
				display.x = nextPos;
			}else {
				velocities[posIndex] = (nextPos - display.y) / dt;
				display.y = nextPos;
			}
			velocity = 0;
			slotVel = 0;
			lock = false;
			
		}else
		if (!lock)
		{
			var delta:Float; 
			if(scrollDirection==ScrollDirection.Horizontal){
				delta=(display.x / slotSize) - Std.int(display.x / slotSize);
			}else {
				delta=(display.y / slotSize) - Std.int(display.y / slotSize);
			}
			var absDelta:Float = Math.abs(delta);
		
			if (Math.abs(velocity)<1000&&(absDelta<0.03||absDelta>0.97))
			{
				slotVel = 0;
				lock = true;
				velocity = 0;
				if (absDelta > 0.5)
				{
					if(scrollDirection==ScrollDirection.Horizontal){
						display.x = Std.int(display.x / slotSize-1) * slotSize ;
					}else {
						display.y = Std.int(display.y / slotSize-1) * slotSize ;
					}
				}else {
					if(scrollDirection==ScrollDirection.Horizontal){
						display.x = Std.int(display.x / slotSize) * slotSize;
					}else {
						display.y = Std.int(display.y / slotSize) * slotSize;
					}
				}
			}else
			if(delta!=0){
				if (absDelta > 0.5)
				{
					slotVel -= 1000*dt ;
				}else {
					slotVel += 1000*dt ;
				}
				
				if (slotVel < -500)
				{
					slotVel = -500;
				}else if (slotVel > 500)
				{
					slotVel = 500;
				}
			
			}
		}
		if(Input.i.isMouseReleased())
		{
			for (delta in velocities) 
			{
				velocity += delta;
			}
			velocity /= REC_POSITIONS_NUM;
			captureMovement = false;
		}
		if(scrollDirection==ScrollDirection.Horizontal){
			display.x += (velocity + slotVel ) * dt;
		}else {
			display.y += (velocity + slotVel ) * dt;
		}
		velocity = velocity * friction;
		
		if(scrollDirection==ScrollDirection.Horizontal){
			if (display.x > scrollStart)
			{
				display.x = scrollStart;
				slotVel=velocity = 0;
			}else
			if (scrollLimit > 0 &&-display.x > scrollLimit)
			{
				display.x =-scrollLimit;
				slotVel=velocity = 0;
			}
		}else {
			if (display.y > scrollStart)
			{
				display.y = scrollStart;
				slotVel=velocity = 0;
			}else
			if (scrollLimit > 0 &&-display.y > scrollLimit)
			{
				display.y =-scrollLimit;
				slotVel=velocity = 0;
			}
		}
	}
	inline function  left():Float
	{
		return x;
	}
	inline function  right():Float
	{
		return x+width;
	}
	inline function  top():Float
	{
		return y;
	}
	inline function  bottom():Float
	{
		return y+height;
	}
	public function scroll():Float
	{
		return -display.x;
	}
	public function index():Int
	{
		return Std.int(-display.x / slotSize);
	}
	public function isPositionLock():Bool
	{
		return (-display.x / slotSize)-index()==0;
	}
	public function addComponent(component:UIComponent)
	{
		components.push(component);
	}
	
	public function goTo() 
	{
		
	}
	
	function set_cropLayer(value:Bool):Bool 
	{
		if(value){
			display.drawArea = MinMax.from(x, y, width, height);
		}else {
			display.drawArea = null;
		}
		return cropLayer = value;
	}
	
}