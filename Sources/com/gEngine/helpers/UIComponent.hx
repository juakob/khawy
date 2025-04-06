package com.gEngine.helpers;

import com.gEngine.display.DisplayObject;

enum HorizontalAlign {
    Right;
    Left;
    Center;
    Free;
    OutLeft;
    OutRight;
}
enum VerticalAlign {
    Top;
    Bottom;
    Center;
    Free;
}
class UIComponent {
    public var display:DisplayObject;
    public var horizontalAlign:HorizontalAlign = HorizontalAlign.Free;
    public var verticalAlign:VerticalAlign = VerticalAlign.Free;
	public var offsetX:Float;
	public var offsetY:Float;
    public function new() {
        
    }
    
}