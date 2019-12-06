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
		Reflect.callMethod(Assets.fonts, Reflect.field(Assets.fonts, name + "Unload"), []);
	}

	public function unloadLocal():Void {}
}
