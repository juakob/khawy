package com.collision.platformer;

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
	var tmxData:String;
	var scale:Float;
	var tileWidth:Int;
	var tileHeight:Int;

	public var display:Layer;
	public var collision:CollisionGroup;
	public var widthIntTiles(default, null):Int = 0;
	public var heightInTiles(default, null):Int = 0;

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
	public function createDisplay(tileMap:TmxTileLayer,display:IAnimation):TileMapDisplay {
		var tiles:Array<TmxTile> = cast tileMap.data.tiles;
		var tileMapDisplay:TileMapDisplay = new TileMapDisplay(display, tileMap.width, tileMap.height, tileWidth, tileHeight);
		tileMapDisplay.scaleX = tileMapDisplay.scaleY = scale;
		var counter:Int = 0;
		for (tile in tiles) {
			tileMapDisplay.setTile2(counter++, tile.gid - 1);
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
	public function createAdvanceDisplay(tileMap:TmxTileLayer,displayConstructor:Int->IAnimation):TileMapAdvanceDisplay {
		var tiles:Array<TmxTile> = cast tileMap.data.tiles;
		var tileMapDisplay:TileMapAdvanceDisplay = new TileMapAdvanceDisplay(displayConstructor, tileMap.width, tileMap.height, tileWidth, tileHeight);
		tileMapDisplay.scaleX = tileMapDisplay.scaleY = scale;
		var counter:Int = 0;
		for (tile in tiles) {
			tileMapDisplay.setTile2(counter++, tile.gid - 1);
		}
		this.display.addChild(tileMapDisplay);
		return tileMapDisplay;
	}

	public function init(processTileMap:Tilemap->TmxTileLayer->Void = null, processObject:Tilemap->TmxObject->Void = null):CollisionTileMap {
		var r:format.tmx.Reader = new format.tmx.Reader();
		var t:TmxMap = r.read(Xml.parse(Assets.blobs.get(tmxData).toString()));
		tileWidth = t.tileWidth;
		tileHeight = t.tileHeight;
		widthIntTiles = t.width;
		heightInTiles = t.height;
		var collision:CollisionTileMap = null;
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
