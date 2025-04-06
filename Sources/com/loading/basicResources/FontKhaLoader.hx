package com.loading.basicResources;

import com.loading.Resource;
import kha.Assets;

class FontKhaLoader implements Resource {
	var name:String;

	public function new(fontName:String) {
		name = fontName;
	}

	public function load(callback:Void->Void):Void {
		Assets.loadFont(name, function(b:kha.Font) {
			callback();
		});
	}

	public function loadLocal(callback:Void->Void):Void {
		callback();
	}

	public function unload():Void {
		Assets.fonts.get(name).unload();
		Reflect.setField(Assets.fonts, name, null);
	}

	public function unloadLocal():Void {}

	public function postLoad() {}
}
