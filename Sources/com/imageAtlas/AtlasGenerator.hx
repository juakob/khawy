package com.imageAtlas;

import kha.graphics4.Graphics2;
import kha.graphics4.BlendingFactor;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics2.ImageScaleQuality;
import kha.Color;
import com.helpers.Rectangle;
import kha.Image;
import kha.graphics2.Graphics;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import com.imageAtlas.Bitmap;

class AtlasGenerator {
	static var clearPipeline:PipelineState;
	public static function generate(width:Int, height:Int, bitmaps:Array<Bitmap>, separation:Int = 2):Image {
		if(clearPipeline==null)clearPipeline=createClearPipeline();
		bitmaps.sort(sortArea);
		var atlasImage = Image.createRenderTarget(width, height, TextureFormat.RGBA32, DepthStencilFormat.NoDepthAndStencil, 0);
		var realWidth:Int = atlasImage.realWidth;
		var realHeight:Int = atlasImage.realWidth;
		var atlasMap = new ImageTree(width, height, separation);

		var g:Graphics = atlasImage.g2;
		g.begin(true, Color.fromFloats(0, 0, 0, 0));
		for (bitmap in bitmaps) {
			var rectangle:Rectangle = atlasMap.insertImage(bitmap);
			#if debug
			if (rectangle == null) {
				throw "not enough space on the atlas texture , atlas id " + bitmap.name + ", create another atlas";
			}
			#end
			if(bitmap.hasPreRender){
				g.end();
				bitmap.preRender();
				g.begin(false);
			}
			if(bitmap.specialPipeline!=null){
				g.pipeline = bitmap.specialPipeline;
			}else{
				g.pipeline = clearPipeline;
			}
			
			g.imageScaleQuality = ImageScaleQuality.High;
			if(bitmap.hasMipMap){ 
				g.mipmapScaleQuality = ImageScaleQuality.High;
			}else{
				g.mipmapScaleQuality = ImageScaleQuality.Low;
			}
			g.imageScaleQuality=ImageScaleQuality.Low;
			
			g.drawScaledSubImage(bitmap.image,bitmap.x*bitmap.scaleX, bitmap.y*bitmap.scaleY,bitmap.width*bitmap.scaleX, bitmap.height*bitmap.scaleY,rectangle.x-1, rectangle.y-1, bitmap.width+2, bitmap.height+2);
			g.color=Color.fromFloats(1,1,1,1);
			g.imageScaleQuality=ImageScaleQuality.High;
			g.drawScaledSubImage(bitmap.image,bitmap.x*bitmap.scaleX, bitmap.y*bitmap.scaleY,bitmap.width*bitmap.scaleX, bitmap.height*bitmap.scaleY,rectangle.x, rectangle.y, bitmap.width, bitmap.height);
			rectangle.x += bitmap.extrude;
			rectangle.y += bitmap.extrude;
			//
			rectangle.width += -separation * 2 - bitmap.extrude * 2;
			rectangle.height += -separation * 2 - bitmap.extrude * 2;

			// set UVs
			bitmap.minUV.setTo(rectangle.x / realWidth, rectangle.y / realHeight);
			bitmap.maxUV.setTo((rectangle.x + rectangle.width) / realWidth, (rectangle.y + rectangle.height) / realHeight);
		}
		g.end();
		// hack for electron bug
		var img = Image.createRenderTarget(1, 1);
		img.unload();

		atlasImage.generateMipmaps(4);
		return atlasImage;
	}

	private static function sortArea(b1:Bitmap, b2:Bitmap):Int {
		return Std.int((b2.width * b2.height) -(b1.width * b1.height));
	}

	public static function createClearPipeline(): PipelineState {
		var shaderPipeline = Graphics2.createImagePipeline(Graphics2.createImageVertexStructure());
		shaderPipeline.blendSource = BlendingFactor.BlendOne;
		shaderPipeline.blendDestination = BlendingFactor.BlendZero;
		shaderPipeline.alphaBlendSource = BlendingFactor.BlendOne;
		shaderPipeline.alphaBlendDestination = BlendingFactor.BlendZero;
		shaderPipeline.compile();
		return shaderPipeline;
	}
}
