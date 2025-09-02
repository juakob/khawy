package com.gEngine.display.extra;

import kha.math.FastVector2;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;
import com.basicDisplay.SpriteSheetDB;
import com.gEngine.display.Sprite;
import com.gEngine.display.Layer;
import kha.graphics4.TextureFilter;

enum abstract Orientation(Int) {
	var None = 0;
	var FlipX = 0x01;
	var FlipY = 0x02;
	var Rotate = 0x04;
}

class TileMapDisplay extends Layer {
	public var widthInTiles:Int;
	public var heightInTiles:Int;

	var tileWidth:Int;
	var tileHeight:Int;
	var tiles:Array<Int>;
	var orientation:Array<Int>;
	var tile:Sprite;

	public function new(tileType:Sprite, widthInTiles:Int, heightInTiles:Int, tileWidth:Int, tileHeight:Int) {
		super();
		// stop();
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		tiles = new Array();
		orientation = new Array();
		tile = tileType;
		tile.pivotX = tileWidth * 0.5;
		tile.pivotY = tileHeight * 0.5;
		for (i in 0...widthInTiles * heightInTiles) {
			tiles.push(-1);
			orientation.push(cast Orientation.None);
		}
	}

	public function getTile(indexX:Int, indexY:Int):Int {
		return tiles[indexX + widthInTiles * indexY];
	}

	public function setTile(indexX:Int, indexY:Int, value:Int, flipX:Bool = false, flipY:Bool = false, rotate:Bool = false) {
		setTile2(indexX + widthInTiles * indexY, value, flipX, flipY);
	}

	public function setTile2(index:Int, value:Int, flipX:Bool = false, flipY:Bool = false, rotate:Bool = false) {
		tiles[index] = value;
		var tileOrientation = 0;
		if (flipX)
			tileOrientation |= cast Orientation.FlipX;
		if (flipY)
			tileOrientation |= cast Orientation.FlipY;
		if (rotate)
			tileOrientation |= cast Orientation.Rotate;
		orientation[index] = tileOrientation;
	}

	override function render(paintMode:PaintMode, transform:FastMatrix4) {
		super.render(paintMode, transform);
		var min:FastVector2 = paintMode.camera.screenToWorld(0, 0);
		var max:FastVector2 = new FastVector2(min.x, min.y);
		mergeMinMax(paintMode.camera.screenToWorld(paintMode.camera.width, 0), min, max);
		mergeMinMax(paintMode.camera.screenToWorld(paintMode.camera.width, paintMode.camera.height), min, max);
		mergeMinMax(paintMode.camera.screenToWorld(0, paintMode.camera.height), min, max);
		var startInTilesX = Std.int(min.x / tileWidth) ;
		var endInTilesX = Std.int(max.x / tileWidth) + 2;
		var startInTilesY = Std.int(min.y / tileHeight) ;
		var endInTilesY = Std.int(max.y / tileHeight) + 2;
		if (startInTilesX < 0)
			startInTilesX = 0;
		if (startInTilesY < 0)
			startInTilesY = 0;
		if (endInTilesX > widthInTiles)
			endInTilesX = widthInTiles;
		if (endInTilesY > heightInTiles)
			endInTilesY = heightInTiles;
		for (y in startInTilesY...endInTilesY) {
			for (x in startInTilesX...endInTilesX) {
				var index = x + widthInTiles * y;
				if (index >= 0 && index < tiles.length) {
					var frame = tiles[index];
					var orientation = orientation[index];
					if (frame >= 0) {
						tile.timeline.gotoAndStop(frame);
						tile.x = x * tileWidth;
						tile.y = y * tileHeight;
						if (orientation & (cast Orientation.Rotate) != 0) {
							tile.rotation = Math.PI * 0.5;
							tile.scaleX = orientation & (cast Orientation.FlipY) != 0 ? -1 : 1;
							tile.scaleY = orientation & (cast Orientation.FlipX) != 0 ? 1 : -1;
						} else {
							tile.rotation = 0;
							tile.scaleX = orientation & (cast Orientation.FlipX) != 0 ? -1 : 1;
							tile.scaleY = orientation & (cast Orientation.FlipY) != 0 ? -1 : 1;
						}
						tile.render(paintMode, transform);
					}
				}
			}
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
