package com.collision.platformer;

import com.gEngine.display.Sprite;
import com.gEngine.display.IAnimation;
import format.tmx.Data.TmxObject;
import format.tmx.Data.TmxTileLayer;
import com.gEngine.display.extra.TileMapDisplay;
import com.gEngine.display.extra.TileMapAdvanceDisplay;
import format.tmx.Data.TmxTile;
import format.tmx.Data.TmxLayer;
import kha.Assets;
import format.tmx.Data.TmxMap;
import com.gEngine.display.Layer;

class Tilemap {
	static inline var FLIPPED_HORIZONTALLY_FLAG = 0x80000000;
	static inline var FLIPPED_VERTICALLY_FLAG = 0x40000000;
	static inline var FLIPPED_DIAGONALLY_FLAG = 0x20000000;

	var tmxData:String;
	var scale:Float;
	var tileWidth:Int;
	var tileHeight:Int;

	public var display:Layer;
	public var collision:CollisionGroup;
	public var widthIntTiles(default, null):Int = 0;
	public var heightInTiles(default, null):Int = 0;

	var tileIdStart:Array<Int>;

	public function new(tmxData:String, scale:Float = 1) {
		this.tmxData = tmxData;
		this.scale = scale;
		collision = new CollisionGroup();
		display = new Layer();
	}

	public function createCollisions(tileMap:TmxTileLayer):CollisionTileMap {
		var tiles = new Array<Int>();
		for (tile in tileMap.data.tiles) {
			tiles.push(tile.gid);
		}
		var collision = new CollisionTileMap(tiles, tileWidth * scale, tileHeight * scale, tileMap.width, tileMap.height);
		this.collision.add(collision);
		return collision;
	}

	/**
	 * [creates and adds a tile map display]
	 * @param tileMap tile layer
	 * @param display tile type to use when render
	 * @return TileMapDisplay
	 */
	public function createDisplay(tileMap:TmxTileLayer, display:Sprite):TileMapDisplay {
		var tiles:Array<TmxTile> = cast tileMap.data.tiles;
		var tileMapDisplay:TileMapDisplay = new TileMapDisplay(display, tileMap.width, tileMap.height, tileWidth, tileHeight);
		tileMapDisplay.scaleX = tileMapDisplay.scaleY = scale;
		var counter:Int = 0;
		for (tile in tiles) {
			var flipped_horizontally = (tile.gid & FLIPPED_HORIZONTALLY_FLAG);
			var flipped_vertically = (tile.gid & FLIPPED_VERTICALLY_FLAG);
			var flipped_diagonally = (tile.gid & FLIPPED_DIAGONALLY_FLAG);
			var id = tile.gid & ~(FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG);
			tileMapDisplay.setTile2(counter++, idToFrame(id), flipped_horizontally != 0, flipped_vertically != 0, flipped_diagonally != 0);
		}
		this.display.addChild(tileMapDisplay);
		return tileMapDisplay;
	}

	/**
	 * [creates and adds an advance tile map display, use when more complex tile needed otherwise use createDisplay]
	 * @param tileMap tile layer
	 * @param displayConstructor callback use to create all the tile displays
	 * @return TileMapAdvanceDisplay
	 */
	public function createAdvanceDisplay(tileMap:TmxTileLayer, displayConstructor:Int->IAnimation):TileMapAdvanceDisplay {
		var tiles:Array<TmxTile> = cast tileMap.data.tiles;
		var tileMapDisplay:TileMapAdvanceDisplay = new TileMapAdvanceDisplay(displayConstructor, tileMap.width, tileMap.height, tileWidth, tileHeight);
		tileMapDisplay.scaleX = tileMapDisplay.scaleY = scale;
		var counter:Int = 0;
		for (tile in tiles) {
			if (tile.gid <= 0) {
				++counter;
				continue;
			}

			var flipped_horizontally = (tile.gid & FLIPPED_HORIZONTALLY_FLAG);
			var flipped_vertically = (tile.gid & FLIPPED_VERTICALLY_FLAG);
			var flipped_diagonally = (tile.gid & FLIPPED_DIAGONALLY_FLAG);
			var id = tile.gid & ~(FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG);
			tileMapDisplay.setTile2(counter++, idToFrame(id), flipped_horizontally != 0, flipped_vertically != 0, flipped_diagonally != 0);
		}
		this.display.addChild(tileMapDisplay);
		return tileMapDisplay;
	}

	function idToFrame(id:Int):Int {
		var length = tileIdStart.length;
		for (i in 0...length) {
			if (i == length - 1 || tileIdStart[(i + 1)] > id) {
				return id - tileIdStart[i];
			}
		}
		throw "tile id can't be map to tilset";
	}

	public function init(processTileMap:Tilemap->TmxTileLayer->Void = null, processObject:Tilemap->TmxObject->Void = null):CollisionTileMap {
		tileIdStart = new Array();
		var r:format.tmx.Reader = new format.tmx.Reader();
		var t:TmxMap = r.read(Xml.parse(Assets.blobs.get(tmxData).toString()));
		tileWidth = t.tileWidth;
		tileHeight = t.tileHeight;
		widthIntTiles = t.width;
		heightInTiles = t.height;
		var collision:CollisionTileMap = null;
		for (tilset in t.tilesets) {
			tileIdStart.push(tilset.firstGID);
		}
		for (layer in t.layers) {
			switch (layer) {
				case TmxLayer.LTileLayer(tileMap):
					if (processTileMap != null) {
						processTileMap(this, tileMap);
					}
				case TmxLayer.LObjectGroup(objectMap):
					if (processObject != null) {
						for (object in objectMap.objects) {
							processObject(this, object);
						}
					}
				default:
			}
		}
		return collision;
	}
}
