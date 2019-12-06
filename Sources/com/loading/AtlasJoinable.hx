package com.loading;

import com.imageAtlas.Bitmap;

interface AtlasJoinable extends Resource {
	function getBitmaps():Array<Bitmap>;
	function update(atlasId:Int):Void;
}
