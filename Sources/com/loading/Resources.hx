package com.loading;

class Resources
{
	public var keepData:Bool;
	var resources:Array<Resource>;
	var loadedCount:Int;
	var onFinish:Void->Void;
	
	public function new() 
	{
		resources = new Array();
	}
	public function add(resource:Resource) {
		resources.push(resource);
	}
	public function load(onFinish:Void->Void) {
		loadedCount=0;
		this.onFinish = onFinish;
		if(resources.length==0){
			onFinish();
			return;
		}
		for(resource in resources){
			resource.load(onLoad);	
		}
	}
	function onLoad() 
	{
		++loadedCount;
		if (loadedCount == resources.length)
		{
			onFinish();
		}
	}
	
	public function unload() {
		for (resource in resources) 
		{
			resource.unload();
		}
		resources.splice(0, resources.length);
	}
}