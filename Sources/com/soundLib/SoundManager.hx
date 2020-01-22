package com.soundLib;

import kha.Assets;
import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;

typedef SM = SoundManager;

class SoundManager {
	private static var map:Map<String, Sound>;
	private static var music:AudioChannel;
	private static var musicName:String;
	private static var musicPosition:Float = 0;
	//
	public static var soundMuted(default, null):Bool = false;
	public static var musicMuted(default, null):Bool = false;
	public static var initied:Bool;

	public static function init():Void {
		map = new Map();
		initied = true;
	}

	public static function addSound(soundName:String, sound:Sound):Void {
		map.set(soundName, sound);
	}

	public static function playFx(sound:String, loop:Bool = false):AudioChannel {
		#if debug
		if (!map.exists(sound)) {
			throw "Sound not found";
		}
		#end
		if (!soundMuted) {
			return Audio.play(map.get(sound), loop);
		}
		return null;
	}

	public static function playMusic(soundName:String, loop:Bool = true):Void {
		// #if debug
		if (!map.exists(soundName)) {
			throw "Sound not found " + soundName;
		}
		// #end
		if (music != null) {
			music.stop();
		}
		musicName = soundName;
		if (!musicMuted) {
			var sound = map.get(soundName);
			if (sound.compressedData != null) {
				music = Audio.stream(sound, loop);
			} else {
				music = Audio.play(sound, loop);
			}
		}
	}

	public static function switchSound():Void {
		if (soundMuted) {
			unMuteSound();
		} else {
			muteSound();
		}
	}

	public static function switchMusic():Void {
		if (musicMuted) {
			unMuteMusic();
		} else {
			SoundManager.muteMusic();
		}
	}

	public static function muteSound():Void {
		soundMuted = true;
	}

	public static function muteMusic():Void {
		musicMuted = true;
		if (music != null) {
			musicPosition = music.position;
			music.pause();
		}
	}

	public static function musicVolume(vol:Float):Void {
		if (music != null) {
			music.volume = vol;
		}
	}

	public static function stopMusic():Void {
		if (music != null) {
			musicPosition = music.position;
			music.stop();
			music = null;
		}
	}

	public static function unMuteSound():Void {
		soundMuted = false;
	}

	public static function unMuteMusic():Void {
		musicMuted = false;
		if (music != null) {
			music.play();
		}
	}

	static public function reset() {
		map = new Map();
	}
}
