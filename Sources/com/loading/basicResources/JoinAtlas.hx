package com.loading.basicResources;

import kha.Assets;
import com.imageAtlas.Bitmap;
import com.gEngine.GEngine;
import com.imageAtlas.AtlasGenerator;
import com.loading.Resource;


class JoinAtlas implements Resource
{
	var width:Int;
	var height:Int;
	var resources:Array<AtlasJoinable>;
	var onFinish:Void->Void;
	var loadedCounter:Int = 0;
	var separation:Int;
	public function new(width:Int, height:Int, separation:Int = 2 ) 
	{
		this.width = width;
		this.height = height;
		this.separation = separation;
		resources = new Array();
	}
	
	public function add(resource:AtlasJoinable) {
		resources.push(resource);
	}
	
	public function load(callback:Void->Void):Void 
	{
		onFinish = callback;
		for (resource in resources) 
		{
			resource.load(onLoad);
		}
	}
	
	function onLoad() 
	{
		++loadedCounter;
		if (loadedCounter == resources.length)
		{
			createAtlas();
		}
	}
	
	function createAtlas() 
	{
		var bitmaps:Array<Bitmap> = new Array();
		for (resource in resources) 
		{
			bitmaps = bitmaps.concat(resource.getBitmaps());
		}
		var img = AtlasGenerator.generate(width, height, bitmaps, separation);
		for(bitmap in bitmaps){
			bitmap.image.unload();
			Reflect.setField(Assets.images,bitmap.name,null);
		}
		var textureId:Int = GEngine.i.addTexture(img);
		for (resource in resources) 
		{
			resource.update(textureId);
		}
		onFinish();
	}
	
	public function unload():Void 
	{
		for (resource in resources) 
		{
			resource.unload();
		}
	}
	
}