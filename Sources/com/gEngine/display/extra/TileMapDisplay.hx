package com.gEngine.display.extra;

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
class TileMapDisplay extends Layer {
	public var widthInTiles:Int;
	public var heightInTiles:Int;
	var tileWidth:Int;
	var tileHeight:Int;
	var tiles:Array<Int>;
	var tile:Sprite;
	public var smooth(get,set):Bool;

	public function new(tileType:String, widthInTiles:Int, heightInTiles:Int, tileWidth:Int, tileHeight:Int) {
		super();
		// stop();
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		tiles=new Array();
		tile=new Sprite(tileType);
		for (i in 0...widthInTiles * heightInTiles) {
			tiles.push(-1);
			/*var sprite = ;
			sprite.textureFilter = TextureFilter.PointFilter;
			sprite.x = (i % widthInTiles) * tileWidth;
			sprite.y = Std.int(i / widthInTiles) * tileHeight;
			sprite.visible = false;
			sprite.timeline.stop();
			addChild(sprite);*/
		}
	}

	public function getTile(indexX:Int, indexY:Int):Int {
		return tiles[indexX + widthInTiles * indexY];
	}
	public function setTile(indexX:Int, indexY:Int, value:Int) {
		setTile2(indexX + widthInTiles * indexY, value);
	}

	public function setTile2(index:Int, value:Int) {
		tiles[index]=value;
	}
	override function render(paintMode:PaintMode, transform:FastMatrix4) {
		super.render(paintMode, transform);
		var initialPos=paintMode.camera.screenToWorld(0,0);
		var endPos=paintMode.camera.screenToWorld(paintMode.camera.width,paintMode.camera.height);
		var startInTilesX=Std.int(initialPos.x/tileWidth)-1;
		var endInTilesX=Std.int(endPos.x/tileWidth)+1;
		var startInTilesY=Std.int(initialPos.y/tileHeight)-1;
		var endInTilesY=Std.int(endPos.y/tileHeight)+1;
		for(y in startInTilesY...endInTilesY){
			for(x in startInTilesX...endInTilesX){
				var index=x + widthInTiles * y;
				if(index<0||index>tiles.length) continue;
				var frame=tiles[index];
				if(frame>=0){
					tile.timeline.gotoAndStop(frame);
					tile.x=x*tileWidth;
					tile.y=y*tileHeight;
					tile.render(paintMode,transform);
				}
			}
		}
	}
	public function get_smooth():Bool{
		return tile.smooth;
	}
	public function set_smooth(value:Bool):Bool{
		tile.smooth=value;
		return tile.smooth;
	}
}
