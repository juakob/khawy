package com.loading.basicResources;

import com.loading.Resource;
import com.soundLib.SoundManager.SM;
import kha.Assets;
import kha.Sound;

class SoundLoader implements Resource {
	var name:String;
	var onLoad:Void->Void;
	var uncompress:Bool = true;

	public function new(soundName:String, uncompress:Bool = true) {
		name = soundName;
		this.uncompress = uncompress;
	}

	public function load(callback:Void->Void):Void {
		onLoad = callback;
		Assets.loadSound(name, onSoundLoad);
	}

	public function loadLocal(callback:Void->Void):Void {
		onLoad = callback;
		onSoundLoad(Reflect.field(Assets.sounds, name));
	}

	function onSoundLoad(sound:Sound) {
		SM.addSound(name, sound);
		if (uncompress && sound.compressedData != null) {
			sound.uncompress(onLoad);
		} else {
			onLoad();
		}
		onLoad = null;
	}

	public function unload():Void {
		Assets.sounds.get(name).unload();
		Reflect.setField(Assets.sounds, name, null);
	}

	public function unloadLocal():Void {}
}
