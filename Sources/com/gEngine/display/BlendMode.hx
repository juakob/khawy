package com.gEngine.display;

@:enum
abstract BlendMode(Int) { // warning dont change the order
	var Default = 0;
	var Multipass = 1;
	var Add = 2;
	var Multiply = 3;
	var Screen = 4;
}
