package com.collision.box2d;

import com.gEngine.display.extra.TileMapDisplay;
import format.tmx.Data.TmxTile;
import com.helpers.TilesToPolygons;
import format.tmx.Data.TmxLayer;
import box2D.dynamics.B2World;
import kha.Assets;
import format.tmx.Data.TmxMap;
import box2D.dynamics.B2BodyType;
import com.gEngine.display.Layer;
import box2D.dynamics.B2BodyDef;

class Tilemap {
	public function new() {}

	public function init(tmxData:String, tilesImg:String, tileWidth:Int, tileHeight:Int, world:B2World, displayLayer:Layer) {
		var body = new B2BodyDef();
		body.type = B2BodyType.STATIC_BODY;
		var floor = world.createBody(body);
		var r:format.tmx.Reader = new format.tmx.Reader();
		var t:TmxMap = r.read(Xml.parse(Assets.blobs.get(tmxData).toString()));
		for (layer in t.layers) {
			switch (layer) {
				case TmxLayer.LTileLayer(tileMap):
					{
						// if (!tileMap.properties.exists("collision")) {
						TilesToPolygons.process(tileMap, t.tilesets, tileWidth * Const.invWorldScale, tileHeight * Const.invWorldScale, floor, 1);
						//	}
						var tiles:Array<TmxTile> = cast tileMap.data.tiles;
						// tileMap.data.
						var tileMapDisplay:TileMapDisplay = new TileMapDisplay(tilesImg, tileMap.width, tileMap.height, 10, 10);

						displayLayer.addChild(tileMapDisplay);
						var counter:Int = 0;

						for (tile in tiles) {
							tileMapDisplay.setTile2(counter++, tile.gid - 1);
						}
					}
				default:
			}
		}
	}
}
