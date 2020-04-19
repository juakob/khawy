package com.loading.basicResources;

import com.loading.Resource;
import kha.Assets;
import kha.Blob;

class DataLoader implements Resource {
	var name:String;

	public function new(dataName:String) {
		name = dataName;
	}

	public function load(callback:Void->Void):Void {
		Assets.loadBlob(name, function(b:Blob) {
			callback();
		});
	}

	public function loadLocal(callback:Void->Void):Void {
		callback();
	}

	public function unload():Void {
		Assets.blobs.get(name).unload();
		Reflect.setField(Assets.blobs, name, null);
	}

	public function unloadLocal():Void {}
}
