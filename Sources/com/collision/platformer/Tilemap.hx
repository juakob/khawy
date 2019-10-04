package com.collision.platformer;

import com.gEngine.display.extra.TileMapDisplay;
import format.tmx.Data.TmxTile;
import format.tmx.Data.TmxLayer;
import kha.Assets;
import format.tmx.Data.TmxMap;
import com.gEngine.display.Layer;

class Tilemap {
    public function new() {
        
    }
    public function init(tmxData:String,tilesImg:String,tileWidth:Int,tileHeight:Int,displayLayer:Layer):CollisionTileMap {
		var r:format.tmx.Reader = new format.tmx.Reader();
		var t:TmxMap = r.read(Xml.parse(Assets.blobs.get(tmxData).toString()));
		var collision:CollisionTileMap=null;
		for (layer in t.layers) {
			switch (layer) {
				case TmxLayer.LTileLayer(tileMap):
					{
						//if (!tileMap.properties.exists("collision")) {
							var tiles=new Array<Int>();
							for(tile in tileMap.data.tiles){
								tiles.push(tile.gid);
							}
							collision=new CollisionTileMap(tiles,tileWidth,tileHeight,tileMap.width, tileMap.height ) ;
					//	}
						var tiles:Array<TmxTile> = cast tileMap.data.tiles;
						//tileMap.data.
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
		return collision;
    }
	
}