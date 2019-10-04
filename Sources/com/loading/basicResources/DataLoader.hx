package com.loading.basicResources;

import com.loading.Resource;
import kha.Assets;
import kha.Blob;


class DataLoader implements Resource
{
	var name:String;
	public function new(dataName:String) 
	{
		name = dataName;
	}
	
	public function load(callback:Void->Void):Void 
	{
		Assets.loadBlob(name, function(b:Blob) {
			callback();
		});
	}
	
	public function unload():Void 
	{
		Reflect.callMethod(Assets.blobs, Reflect.field(Assets.blobs, name + "Unload"), []);
	}
	
}