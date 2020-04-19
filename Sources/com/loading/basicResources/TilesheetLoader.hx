package com.loading.basicResources;

import com.gEngine.GEngine;
import kha.FastFloat;
import com.basicDisplay.SpriteSheetDB;
import com.gEngine.AnimationData;
import com.gEngine.DrawArea;
import com.gEngine.Frame;
import com.loading.AtlasJoinable;
import com.imageAtlas.Bitmap;
import kha.Assets;
import kha.Image;

class TilesheetLoader implements AtlasJoinable {
	var imageName:String;
	var tileWidth:Int;
	var tileHeight:Int;
	var spacing:Int;
	var bitmaps:Array<Bitmap>;
	var animation:AnimationData;
	var onLoad:Void->Void;

	public function new(imageName:String, tileWidth:Int, tileHeight:Int, spacing:Int) {
		this.imageName = imageName;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.spacing = spacing;
	}

	public function load(callback:Void->Void):Void {
		Assets.loadImage(imageName, function(image:Image) {
			fromSpriteSheet();
			callback();
		});
	}

	public function loadLocal(callback:Void->Void):Void {
		fromSpriteSheet();
		callback();
	}

	public function unload():Void {
		Assets.images.get(imageName).unload();
		Reflect.setField(Assets.images, imageName, null);
	}

	public function unloadLocal():Void {}

	public function fromSpriteSheet():Void {
		var image:Image = Reflect.field(kha.Assets.images, imageName);
		var spritesCount:Int = Std.int(image.width / (tileWidth + spacing * 2)) * Std.int(image.height / (tileHeight + spacing * 2));

		animation = new AnimationData();
		var frames:Array<Frame> = new Array();

		bitmaps = new Array();

		var widthInFrames = Std.int(image.width / (tileWidth + spacing * 2));
		for (counter in 0...spritesCount) {
			var x = (counter % widthInFrames) * (tileWidth + spacing * 2);
			var y = Std.int(counter / widthInFrames) * (tileHeight + spacing * 2);
			frames.push(createFrame(0, 0, tileWidth, tileHeight, false));

			var bitmap:Bitmap = new Bitmap();
			bitmap.x = x;
			bitmap.y = y;
			bitmap.width = tileWidth + spacing * 2;
			bitmap.height = tileHeight + spacing * 2;
			bitmap.name = imageName + counter;
			bitmap.extrude = spacing;
			bitmap.image = image;
			bitmaps.push(bitmap);
		}
		animation.frames = frames;
		animation.name = imageName;
		animation.labels = new Array();
		animation.texturesID = GEngine.i.addTexture(image);
		SpriteSheetDB.i.add(animation);
	}

	/* INTERFACE com.loading.AtlasJoinable */
	public function getBitmaps():Array<Bitmap> {
		return bitmaps;
	}

	public function update(atlasId:Int):Void {
		animation.texturesID = atlasId;
		for (i in 0...bitmaps.length) {
			var frame:Frame = animation.frames[i];
			var bitmap = bitmaps[i];
			var UVs:Array<FastFloat> = new Array();
			// a
			UVs.push(bitmap.minUV.x);
			UVs.push(bitmap.minUV.y);

			// b
			UVs.push(bitmap.minUV.x);
			UVs.push(bitmap.maxUV.y);

			// c
			UVs.push(bitmap.maxUV.x);
			UVs.push(bitmap.minUV.y);

			// d
			UVs.push(bitmap.maxUV.x);
			UVs.push(bitmap.maxUV.y);

			frame.UVs = UVs;
		}
	}

	public static function createFrame(x:Int, y:Int, width:Int, height:Int, rotated:Bool):Frame {
		if (rotated) {
			var temp = width;
			width = height;
			height = temp;
		}
		var frame:Frame = new Frame();
		frame.vertexs = new Array();
		frame.UVs = new Array();
		frame.drawArea = new DrawArea(x, y, x + width, y + height);

		frame.UVs.push(0);
		frame.UVs.push(0);
		frame.UVs.push(0);
		frame.UVs.push(1);
		frame.UVs.push(1);
		frame.UVs.push(0);
		frame.UVs.push(1);
		frame.UVs.push(1);

		if (rotated) {
			frame.vertexs.push(x);
			frame.vertexs.push(y + height);
			frame.vertexs.push(x + width);
			frame.vertexs.push(y + height);
			frame.vertexs.push(x);
			frame.vertexs.push(y);

			frame.vertexs.push(x + width);
			frame.vertexs.push(y);
		} else {
			frame.vertexs.push(x);
			frame.vertexs.push(y);
			frame.vertexs.push(x);
			frame.vertexs.push(y + height);
			frame.vertexs.push(x + width);
			frame.vertexs.push(y);

			frame.vertexs.push(x + width);
			frame.vertexs.push(y + height);
		}

		return frame;
	}
}
