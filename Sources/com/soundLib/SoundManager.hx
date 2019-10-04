package com.soundLib;
import kha.Assets;
import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;



typedef SM = SoundManager;
class SoundManager
{
	
	private static var map:Map<String,Sound>;
	private static var music:AudioChannel;
	private static var musicName:String;
	private static var musicPosition:Float=0;
	//
	private static var soundMuted(default,null):Bool = false;
	private static var musicMuted(default,null):Bool = false;
	
	public static var initied:Bool;
	public static function init():Void
	{
		map = new Map();
		initied = true;
	}
	public static function addSound(sound:String):Void
	{
		
		//#if debug
		////if (!Assets.exists(location + aSound + ".mp3"))
		////{
			////throw new Error("sound file not found " + aSound);
		////}
		//#end
		map.set(sound,  Reflect.field(kha.Assets.sounds, sound));
		//#else
		//map.set(aSound, Assets.getSound(location + aSound+".ogg"));
		//#end
	}
	public static function playFx(sound:String,loop:Bool=false):AudioChannel
	{
		#if debug
		if (!map.exists(sound)) {
			throw "Sound not found";
		}
		#end
		if (!soundMuted)
		{
			return Audio.play(map.get(sound),loop);
		}
		return null;
	}
	public static function playMusic(sound:String,loop:Bool=true):Void
	{
		//#if debug
		if (!map.exists(sound)) {
			throw "Sound not found " +sound;
		}
		//#end
		if (music != null)
		{
			music.stop();
		}
		musicName = sound;
		if (!musicMuted)
		{
			music = Audio.stream(map.get(sound), loop);
			//music.position = aPosition;
		}
	}
	public static function switchSound():Void
	{
		if (soundMuted)
		{
			unMuteSound();
		}else {
			muteSound();
		}
	}
	public static function switchMusic():Void
	{
		if (musicMuted)
		{
			unMuteMusic();
		}else {
			SoundManager.muteMusic();
		}
	}
	public static function muteSound():Void
	{
		soundMuted = true;
	}
	public static function muteMusic():Void
	{
		musicMuted = true;
		if (music != null)
		{
			musicPosition = music.position;
			music.pause();
		}
	}
	public static function musicVolume(vol:Float):Void{
		if(music!=null){
			music.volume=vol;
		}
	}
	public static function stopMusic():Void
	{
		if (music != null)
		{
			musicPosition = music.position;
			music.stop();
			music=null;
		}
	}
	public static function unMuteSound():Void
	{
		soundMuted = false;
	}
	public static function unMuteMusic():Void
	{
		musicMuted = false;
		if (music != null)
		{
			music.play();
		}
	}
	
	static public function reset() 
	{
		map = new Map();
	}
	
}