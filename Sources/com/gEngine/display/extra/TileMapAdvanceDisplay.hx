package com.gEngine.display.extra;

import kha.math.FastVector2;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;
import com.basicDisplay.SpriteSheetDB;
import com.gEngine.display.Sprite;
import com.gEngine.display.Layer;
import kha.graphics4.TextureFilter;

/**
 * ...
 * @author Joaquin
 */
class TileMapAdvanceDisplay extends Layer {
	public var widthInTiles:Int;
	public var heightInTiles:Int;

	var tileWidth:Int;
	var tileHeight:Int;
	var tiles:Array<Tile>;
	var displayConstructor:Int->IAnimation;

	public function new(displayConstructor:Int->IAnimation, widthInTiles:Int, heightInTiles:Int, tileWidth:Int, tileHeight:Int) {
		super();
		this.displayConstructor = displayConstructor;
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		tiles = new Array();
		for (i in 0...widthInTiles * heightInTiles) {
			tiles.push(new Tile());
		}
	}

	public function getTile(indexX:Int, indexY:Int):Tile {
		return tiles[indexX + widthInTiles * indexY];
	}

	public function setTile(indexX:Int, indexY:Int, value:Int) {
		setTile2(indexX + widthInTiles * indexY, value);
	}

	public function setTile2(index:Int, value:Int, flipX:Bool = false, flipY:Bool = false, rotate:Bool = false) {
		if (tiles[index].display == null) {
			var display = displayConstructor(value);
			addChild(display);
			display.x = Std.int(index % widthInTiles) * tileWidth;
			display.y = Std.int(index / widthInTiles) * tileHeight;
			if (rotate) {
				display.rotation = Math.PI * 0.5;
				display.scaleX = flipY ? -1 : 1;
				display.scaleY = flipX ? 1 : -1;
			} else {
				display.scaleX = flipX ? -1 : 1;
				display.scaleY = flipY ? -1 : 1;
			}

			tiles[index].display = display;
		}
		tiles[index].id = value;
		tiles[index].display.timeline.gotoAndStop(value);
	}

	override function render(paintMode:PaintMode, transform:FastMatrix4) {
		var min:FastVector2 = paintMode.camera.screenToWorld(0, 0);
		var max:FastVector2 = new FastVector2(min.x, min.y);
		mergeMinMax(paintMode.camera.screenToWorld(paintMode.camera.width, 0), min, max);
		mergeMinMax(paintMode.camera.screenToWorld(paintMode.camera.width, paintMode.camera.height), min, max);
		mergeMinMax(paintMode.camera.screenToWorld(0, paintMode.camera.height), min, max);
		var startInTilesX = Std.int(min.x / tileWidth) - 1;
		var endInTilesX = Std.int(max.x / tileWidth) + 1;
		var startInTilesY = Std.int(min.y / tileHeight) - 1;
		var endInTilesY = Std.int(max.y / tileHeight) + 1;
		if (startInTilesX < 0)
			startInTilesX = 0;
		if (startInTilesY < 0)
			startInTilesY = 0;
		if (endInTilesX > widthInTiles)
			endInTilesX = widthInTiles;
		if (endInTilesY > heightInTiles)
			endInTilesY = heightInTiles;
		var tileY = endInTilesY - 1;
		while (startInTilesY <= tileY) {
			for (tileX in startInTilesX...endInTilesX) {
				var index = tileX + widthInTiles * tileY;
				if (index >= 0 && index < tiles.length) {
					var frame = tiles[index].id;
					if (frame >= 0) {
						tiles[index].display.render(paintMode, transform);
					}
				}
			}
			--tileY;
		}
	}

	static inline function mergeMinMax(point:FastVector2, min:FastVector2, max:FastVector2) {
		if (point.x < min.x)
			min.x = point.x;
		if (point.y < min.y)
			min.y = point.y;
		if (point.x > max.x)
			max.x = point.x;
		if (point.y > max.y)
			max.y = point.y;
	}
}

class Tile {
	public var id:Int = -1;
	public var display:IAnimation = null;

	public function new() {}
}
