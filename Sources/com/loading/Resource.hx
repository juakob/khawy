package com.loading;


interface Resource 
{
	function load(callback:Void->Void):Void;
	function unload():Void;
}