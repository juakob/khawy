package com.soundLib;

import kha.Assets;
import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;
#if kha_html5
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Surface;
#end

typedef SM = SoundManager;

class SoundManager {
	private static var map:Map<String, Sound>;
	private static var music:AudioChannel;
	private static var musicName:String;
	private static var musicPosition:Float = 0;
	#if kha_html5
	private static var audioUnlocked:Bool = false;
	private static var pendingMusicName:String;
	private static var pendingMusicLoop:Bool = true;
	private static var hasPendingMusic:Bool = false;
	#end
	//
	public static var soundMuted(default, null):Bool = false;
	public static var musicMuted(default, null):Bool = false;
	public static var initied:Bool;

	public static function init():Void {
		map = new Map();
		initied = true;
		#if kha_html5
		audioUnlocked = false;
		hasPendingMusic = false;
		pendingMusicName = null;
		pendingMusicLoop = true;
		subscribeUnlockInput();
		#end
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
			#if kha_html5
			if (!audioUnlocked) {
				return null;
			}
			#end
			return Audio.play(map.get(sound), loop);
		}
		return null;
	}

	public static function playMusic(soundName:String, loop:Bool = true):Void {
		#if debug
		if (!map.exists(soundName)) {
			throw "Sound not found " + soundName;
		}
		#end
		if (music != null) {
			music.stop();
		}
		musicName = soundName;
		if (!musicMuted) {
			#if kha_html5
			if (!audioUnlocked) {
				pendingMusicName = soundName;
				pendingMusicLoop = loop;
				hasPendingMusic = true;
				return;
			}
			#end
			startMusic(soundName, loop);
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
		
		if (music != null && !musicMuted) {
			musicPosition = music.position;
			music.pause();
		}
		musicMuted = true;
	}

	public static function musicVolume(vol:Float):Void {
		if (music != null) {
			music.volume = vol;
		}
	}

	public static function stopMusic():Void {
		#if kha_html5
		hasPendingMusic = false;
		pendingMusicName = null;
		#end
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
		
		if (music != null && musicMuted) {
			music.play();
		}
		musicMuted = false;
	}

	static public function reset() {
		map = new Map();
	}

	private static function startMusic(soundName:String, loop:Bool):Void {
		var sound = map.get(soundName);
		if (sound.compressedData != null) {
			music = Audio.stream(sound, loop);
		} else {
			music = Audio.play(sound, loop);
		}
	}

	#if kha_html5
	private static function subscribeUnlockInput():Void {
		Keyboard.get().notify(onUnlockKeyDown, null);
		Mouse.get().notify(onUnlockMouseDown, null, null, null);
		var surface = Surface.get();
		if (surface != null) {
			surface.notify(onUnlockTouchStart, null, null);
		}
	}

	private static function unsubscribeUnlockInput():Void {
		Keyboard.get().remove(onUnlockKeyDown, null, null);
		Mouse.get().remove(onUnlockMouseDown, null, null, null);
		var surface = Surface.get();
		if (surface != null) {
			surface.remove(onUnlockTouchStart, null, null);
		}
	}

	private static function unlockAudio():Void {
		if (audioUnlocked) {
			return;
		}
		audioUnlocked = true;
		unsubscribeUnlockInput();
		if (hasPendingMusic && pendingMusicName != null && !musicMuted) {
			hasPendingMusic = false;
			playMusic(pendingMusicName, pendingMusicLoop);
		}
	}

	private static function onUnlockKeyDown(_:KeyCode):Void {
		unlockAudio();
	}

	private static function onUnlockMouseDown(_:Int, _:Int, _:Int):Void {
		unlockAudio();
	}

	private static function onUnlockTouchStart(_:Int, _:Int, _:Int):Void {
		unlockAudio();
	}
	#end
}
