package com.gEngine.display.extra;

import com.basicDisplay.SpriteSheetDB;
import com.gEngine.display.Sprite;
import com.gEngine.display.Layer;
import kha.graphics4.TextureFilter;

/**
 * ...
 * @author Joaquin
 */
class TileMapDisplay extends Layer {
	public var widthInTiles:Int;
	public var heightInTiles:Int;

	public function new(tileType:String, widthInTiles:Int, heightInTiles:Int, tileWidth:Int, tileHeight:Int) {
		super();
		// stop();
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		for (i in 0...widthInTiles * heightInTiles) {
			var sprite = new Sprite(tileType);
			sprite.textureFilter = TextureFilter.PointFilter;
			sprite.x = (i % widthInTiles) * tileWidth;
			sprite.y = Std.int(i / widthInTiles) * tileHeight;
			sprite.visible = false;
			sprite.timeline.stop();
			addChild(sprite);
		}
	}

	public function getTile(indexX:Int, indexY:Int):Int {
		return (cast children[indexX + widthInTiles * indexY]).timeline.currentFrame;
	}
	public function setTile(indexX:Int, indexY:Int, value:Int) {
		setTile2(indexX + widthInTiles * indexY, value);
	}

	public function setTile2(index:Int, value:Int) {
		var sprite:Sprite = cast children[index];
		if (value < 0) {
			sprite.visible = false;
		} else {
			sprite.timeline.gotoAndStop(value);
			sprite.visible = true;
		}
	}
}
