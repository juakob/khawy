package com.gEngine.painters;

import com.gEngine.display.BlendMode;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;

class PaintInfo {
	public var texture:Int;
	public var blend:BlendMode;
	public var textureFilter:TextureFilter;
	public var mipMapFilter:MipMapFilter;

	public function new() {}

	public function equal(info:PaintInfo):Bool {
		return texture == info.texture && blend == info.blend && textureFilter == info.textureFilter && mipMapFilter == info.mipMapFilter;
	}
}
