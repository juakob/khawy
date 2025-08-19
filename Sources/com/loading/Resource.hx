package com.loading;

interface Resource {
	function load(callback:Void->Void):Void;
	function loadLocal(callback:Void->Void):Void;
	function postLoad():Void;
	function unload():Void;
	function unloadLocal():Void;
}
