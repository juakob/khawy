package com.loading.basicResources;

import kha.graphics4.PipelineState;
import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureAddressing;
import kha.graphics4.Graphics2;
import kha.Font;
import com.basicDisplay.SpriteSheetDB;
import com.imageAtlas.Bitmap;
import kha.Assets;
import com.gEngine.AnimationData;
import com.gEngine.Label;
import com.gEngine.Frame;
import kha.Blob;
import kha.Image;
import haxe.xml.Access;

class FontLoader extends TilesheetLoader {
	var size:Int;

	public function new(imageName:String, size:Int) {
		super(imageName, 0, 0, 0);
		this.size = size;
	}

	override function load(callback:Void->Void):Void {
		Assets.loadFont(imageName, function(font:Font) {
			fromKhaFont();
			callback();
		});
	}

	override function loadLocal(callback:() -> Void) {
		fromKhaFont();
		callback();
	}
	var tex:Image;
	static var pipeline:PipelineState;
	private function fromKhaFont() {
		var font:Font = Reflect.field(kha.Assets.fonts, imageName);
		var kravurImage = font._get(size);
		tex = kravurImage.getTexture();
		animation = new com.gEngine.FontData(size);
		var frames:Array<Frame> = new Array();
		var labels:Array<Label> = new Array();
		bitmaps = new Array();
		var bakedQuadCache = new kha.Kravur.AlignedQuad();
		var counter:Int = 0;
		if(pipeline==null) {
			pipeline = Graphics2.createTextPipeline(Graphics2.createTextVertexStructure());
			pipeline.compile();
		}
		while (true) {
			var q = kravurImage.getBakedQuad(bakedQuadCache, counter, 0, 0);
			if (q != null) {
				++counter;
				// framebuffer.g2.drawSubImage(tex,q.x0,q.y0,q.s0*tex.realWidth,q.t0*tex.realHeight,q.x1-q.x0,q.y1-q.y0);
				var x:Int = Std.int(q.s0 * tex.realWidth);
				var y:Int = Std.int(q.t0 * tex.realHeight);
				var width:Int = Std.int((q.s1 - q.s0) * tex.realWidth);
				var height:Int = Std.int((q.t1 - q.t0) * tex.realHeight);

				frames.push(TilesheetLoader.createFrame(Std.int(q.x0), Std.int(q.y0), width, height, false));
				// var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));
				var bitmap:Bitmap = new Bitmap();
				bitmap.x = x;
				bitmap.y = y;
				bitmap.width = width;
				bitmap.height = height;
				bitmap.specialPipeline = pipeline;
				// bitmap.name = i+"";
				bitmap.image = tex;
				bitmaps.push(bitmap);
			} else {
				break;
			}
		}
		animation.frames = frames;
		animation.name = imageName;
		animation.labels = labels;
		SpriteSheetDB.i.add(animation);
	}
	override function update(atlasId:Int) {
		super.update(atlasId);
	}

	override function unload() {}

	override function unloadLocal() {}
}
