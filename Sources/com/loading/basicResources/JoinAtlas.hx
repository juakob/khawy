package com.loading.basicResources;

//import format.png.Writer;
import kha.Image;
import com.framework.Simulation;
import kha.Assets;
import com.imageAtlas.Bitmap;
import com.gEngine.GEngine;
import com.imageAtlas.AtlasGenerator;
import com.loading.Resource;

class JoinAtlas implements Resource {
	var width:Int;
	var height:Int;
	var resources:Array<AtlasJoinable>;
	var onFinish:Void->Void;
	var loadedCounter:Int = 0;
	var separation:Int;
	var image:Image;
	var expand:Bool=true;

	public function new(width:Int, height:Int, separation:Int = 2,expand:Bool = true) {
		this.width = width;
		this.height = height;
		this.separation = separation;
		this.expand = expand;
		resources = new Array();
	}

	public function add(resource:AtlasJoinable) {
		resources.push(resource);
	}

	public function load(callback:Void->Void):Void {
		onFinish = callback;
		for (resource in resources) {
			resource.load(onLoad);
		}
		if (resources.length == 0)
			callback();
	}

	public function loadLocal(callback:Void->Void):Void {
		onFinish = callback;
		for (resource in resources) {
			resource.loadLocal(onLoad);
		}
		if (resources.length == 0)
			callback();
	}

	function onLoad() {
		++loadedCounter;
		if (loadedCounter == resources.length) {
		//	createAtlas();
			onFinish();
		}
	}

	function createAtlas() {
		var bitmaps:Array<Bitmap> = new Array();
		for (resource in resources) {
			bitmaps = bitmaps.concat(resource.getBitmaps());
		}
		image = AtlasGenerator.generate(width, height, bitmaps, separation, expand);

		var textureId:Int = GEngine.i.addTexture(image);
		for (resource in resources) {
			resource.update(textureId);
		}
		
		//var pixels=image.getPixels();
		//writePixels24("test.png",pixels,width,height);
	
	}

	/*function writePixels24(file:String, pixels:haxe.io.Bytes, width:Int, height:Int) {
		var handle = sys.io.File.write(file, true);
		new format.png.Writer(handle)
			.write(format.png.Tools.build32BGRA(width, height, pixels));
		handle.close();
	}*/

	public function unload():Void {
		for (resource in resources) {
			resource.unload();
		}
		if (image != null)
			image.unload();
	}

	public function unloadLocal():Void {
		for (resource in resources) {
			resource.unloadLocal();
		}
		image.unload();
	}

	public function postLoad() {
		createAtlas();
	}
}
