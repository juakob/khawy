package com.helpers;

import format.tmx.Data.TmxTileset;
import format.tmx.Data.TmxTileLayer;
import com.collision.box2d.Const;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import format.tmx.Data.TmxTile;

class TilesToPolygons {
	public static function process(tilemap:TmxTileLayer, tilesets:Array<TmxTileset>, tileWidth:Float, tileHeight:Float, body:B2Body, collisionStart:Int = 1):Void {
		var tiles:Array<TmxTile> = tilemap.data.tiles;
		var widthInTiles = tilemap.width;
		var heightInTiles = tilemap.height;
		var rectangles:Array<RawTilesRectangel> = mapToRectangles(tiles, widthInTiles, heightInTiles, collisionStart);
		generateShape(rectangles, tileWidth, tileHeight, body);
	}

	static private function generateShape(rectangles:Array<RawTilesRectangel>, tileWidth:Float, tileHeight:Float, body:B2Body):Void {
		for (rectangle in rectangles) {
			var def:B2FixtureDef = new B2FixtureDef();
			var rectShape = new B2PolygonShape();
			rectShape.setAsOrientedBox((rectangle.width * tileWidth) / 2, (rectangle.height * tileHeight) / 2, new B2Vec2(rectangle.x * tileWidth + (rectangle
				.width * tileWidth) / 2, rectangle.y * tileHeight + (rectangle.height * tileHeight) / 2));
			def.shape = rectShape;
			def.density = 0;
			def.friction = 1;

			body.createFixture(def);
		}

		var def:B2FixtureDef = new B2FixtureDef();
		var rectShape = new B2PolygonShape();
		rectShape.setAsVector([
			new B2Vec2(60 * Const.invWorldScale, 120 * Const.invWorldScale),
			new B2Vec2(70 * Const.invWorldScale, 130 * Const.invWorldScale),
			new B2Vec2(60 * Const.invWorldScale, 130 * Const.invWorldScale)
		]);
		def.shape = rectShape;
		def.density = 0;
		def.friction = 1;

		body.createFixture(def);
	}

	static private function mapToRectangles(tiles:Array<TmxTile>, widthInTiles:Int, heightInTiles:Int, collisionStart:Int):Array<RawTilesRectangel> {
		var rectanglesFirstPass:Array<RawTilesRectangel> = new Array();
		for (y in 0...heightInTiles) {
			var currentRectangle:RawTilesRectangel = null;
			for (x in 0...widthInTiles) {
				var index:Int = x + (y * widthInTiles);
				if (tiles[index].gid >= collisionStart && tiles[index].gid != 5) {
					if (currentRectangle == null) {
						currentRectangle = new RawTilesRectangel(x, y);
						rectanglesFirstPass.push(currentRectangle);
					} else {
						++currentRectangle.width;
					}
				} else if (tiles[index].gid == 5) {
					currentRectangle = null;
				} else if (currentRectangle != null) {
					currentRectangle = null;
				}
			}
		}
		var finalRectangles:Array<RawTilesRectangel> = new Array();
		for (rec in rectanglesFirstPass) {
			var found:Bool = false;
			for (finalRec in finalRectangles) {
				if (finalRec.x == rec.x && finalRec.width == rec.width && finalRec.y + finalRec.height == rec.y) {
					found = true;
					++finalRec.height;
					break;
				}
			}
			if (!found) {
				finalRectangles.push(rec);
			}
		}
		return finalRectangles;
	}
}

class RawTilesRectangel {
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;

	public function new(aX:Int, aY:Int) {
		x = aX;
		y = aY;
		width = 1;
		height = 1;
	}
}
