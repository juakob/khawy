package com.collision.platformer;

import kha.math.FastVector2;
import com.helpers.MinMax;

/**
 * ...
 * @author Joaquin
 */
class CollisionTileMap implements ICollider {
	var tiles:Array<Int>;

	public var tileWidth(default, null):Float;
	public var tileHeight(default, null):Float;
	public var widthIntTiles(default, null):Int;
	public var heightInTiles(default, null):Int;

	public var startingCollisionIndex:Int = 1;
	var edges:Array<Int>;

	public var userData:Dynamic;

	var helperTile:CollisionBox;

	public var parent:CollisionGroup;

	public var x:Float = 0;
	public var y:Float = 0;

	/**
	 Creates an empty CollisionTileMap with all tiles set to 0.
	 */
	public static function createEmpty(aTileWidth:Float, aTileHeight:Float, aWidthInTiles:Int, aHeightInTiles:Int, ?startCollisionIndex:Int = 1):CollisionTileMap {
		var total = aWidthInTiles * aHeightInTiles;
		var aTiles = [for (i in 0...total) 0];
		return new CollisionTileMap(aTiles, aTileWidth, aTileHeight, aWidthInTiles, aHeightInTiles, startCollisionIndex);
	}

	public function new(aTiles:Array<Int>, aTileWidth:Float, aTileHeight:Float, aWidthInTiles:Int, aHeightInTiles:Int, ?startCollisionIndex:Int = 1) {
		tiles = aTiles;
		tileWidth = aTileWidth;
		tileHeight = aTileHeight;
		widthIntTiles = aWidthInTiles;
		heightInTiles = aHeightInTiles;
		helperTile = new CollisionBox();
		helperTile.width = aTileWidth;
		helperTile.height = aTileHeight;
		helperTile.staticObject = true;
		this.startingCollisionIndex = startCollisionIndex;
		edges = new Array();
		for (i in 0...tiles.length) {
			edges.push(0);
		}
		calculateEdges(0, 0, aWidthInTiles, aHeightInTiles);
	}

	public function removeFromParent() {
		if (parent != null)
			parent.remove(this);
	}

	function calculateEdges(minX:Int, minY:Int, maxX:Int, maxY:Int) {
		for (tileY in minY...maxY) {
			for (tileX in minX...maxX) {
				if (getTileId(tileX, tileY) >= startingCollisionIndex) {
					var edge:Int = Sides.NONE;
					if (getTileId(tileX, tileY - 1) < startingCollisionIndex)
						edge |= Sides.TOP;
					if (getTileId(tileX - 1, tileY) < startingCollisionIndex)
						edge |= Sides.LEFT;
					if (getTileId(tileX + 1, tileY) < startingCollisionIndex)
						edge |= Sides.RIGHT;
					if (getTileId(tileX, tileY + 1) < startingCollisionIndex)
						edge |= Sides.BOTTOM;
					edges[tileX + tileY * widthIntTiles] = edge;
				}
			}
		}
	}

	/* INTERFACE ICollider */
	public function collide(aCollider:ICollider, ?NotifyCallback:ICollider->ICollider->Void):Bool {
		if (aCollider.collisionType() == CollisionType.Box) {
			// TODO calculate more points if the box is much larger than tiles
			var box:CollisionBox = cast aCollider;
			var minX:Int = Std.int(( box.x-this.x) / tileWidth);
			var minY:Int = Std.int(( box.y-this.y) / tileHeight);
			var maxX:Int = Std.int(( box.x-this.x + box.width) / tileWidth) + 1;
			var maxY:Int = Std.int(( box.y-this.y + box.height) / tileHeight) + 1;

			var toReturn:Bool = false;
			for (tileY in minY...maxY) {
				for (tileX in minX...maxX) {
					if (getTileId(tileX, tileY) >= startingCollisionIndex) {
						helperTile.collisionAllow = edges[tileX + tileY * widthIntTiles];
						helperTile.x = this.x + tileX * tileWidth;
						helperTile.y = this.y + tileY * tileHeight;
						toReturn = helperTile.collide(box, NotifyCallback) || toReturn;
					}
				}
			}
			return toReturn;
		} else if (aCollider.collisionType() == CollisionType.Group) {
			return aCollider.collide(this, NotifyCallback);
		}
		return false;
	}

	public function getTileId(aX:Int, aY:Int):Int {
		if (aX >= 0 && aY >= 0 && aX < widthIntTiles && aY < heightInTiles) {
			return tiles[aX + aY * widthIntTiles];
		}
		return 0;
	}

	public function getTileId2(aX:Float, aY:Float):Int {
		return getTileId(Std.int(aX / tileWidth), Std.int(aY / tileHeight));
	}

	public function overlap(aCollider:ICollider, ?NotifyCallback:ICollider->ICollider->Void):Bool {
		var toReturn:Bool = false;
		if (aCollider.collisionType() == CollisionType.Box) {
			// TODO calculate more points if the box is larger than tiles
			var box:CollisionBox = cast aCollider;
			var minX:Int = Std.int(box.x / tileWidth);
			var minY:Int = Std.int(box.y / tileHeight);
			var maxX:Int = Std.int((box.x + box.width) / tileWidth) + 1;
			var maxY:Int = Std.int((box.y + box.height) / tileHeight) + 1;

			for (tileY in minY...maxY) {
				for (tileX in minX...maxX) {
					if (getTileId(tileX, tileY) >= startingCollisionIndex) {
						helperTile.collisionAllow = edges[tileX + tileY * widthIntTiles];
						helperTile.x = this.x + tileX * tileWidth;
						helperTile.y = this.y + tileY * tileHeight;
						toReturn = helperTile.overlap(box, NotifyCallback) || toReturn;
					}
				}
			}
		}
		return toReturn;
	}

	public function collisionType():CollisionType {
		return CollisionType.TileMap;
	}

	public function changeTileId(aX:Int, aY:Int, aId:Int) {
		if (aX > 0 && aY > 0 && aX < widthIntTiles && aY < heightInTiles) {
			tiles[aX + aY * widthIntTiles] = aId;
			calculateEdges(aX - 1, aY - 1, aX + 1, aY + 1);
		}
	}

	/**
	 Sets all tile IDs inside the given rectangle to aId.
	 The rectangle is provided in world coordinates; it is converted
	 to tile coordinates using this.x/this.y and tileWidth/tileHeight.
	 */
	public function changeTileIdsInRect(rect:MinMax, aId:Int):Void {
		if (rect == null) return;
		// Determine tile-range from world coordinates (exclusive max like Haxe ranges).
		var minX:Int = Std.int(Math.floor((rect.min.x - this.x) / tileWidth));
		var minY:Int = Std.int(Math.floor((rect.min.y - this.y) / tileHeight));
		var maxX:Int = Std.int(Math.ceil((rect.max.x - this.x) / tileWidth));
		var maxY:Int = Std.int(Math.ceil((rect.max.y - this.y) / tileHeight));

		// Clamp to map bounds
		var sx:Int = Std.int(Math.max(0, minX));
		var sy:Int = Std.int(Math.max(0, minY));
		var ex:Int = Std.int(Math.min(widthIntTiles, maxX));
		var ey:Int = Std.int(Math.min(heightInTiles, maxY));

		if (sx >= ex || sy >= ey) return;

		for (ty in sy...ey) {
			var rowBase = ty * widthIntTiles;
			for (tx in sx...ex) {
				tiles[tx + rowBase] = aId;
			}
		}

		// Recalculate edges around the edited area, expanded by 1 tile and clamped.
		var ceMinX = Std.int(Math.max(0, sx - 1));
		var ceMinY = Std.int(Math.max(0, sy - 1));
		var ceMaxX = Std.int(Math.min(widthIntTiles, ex + 1));
		var ceMaxY = Std.int(Math.min(heightInTiles, ey + 1));
		calculateEdges(ceMinX, ceMinY, ceMaxX, ceMaxY);
	}

	

	public function edgeType(tileX:Int, tileY:Int):Int {
		return edges[tileX + tileY * widthIntTiles];
	}

	public function edgeType2(aX:Float, aY:Float):Int {
		return edgeType(Std.int(aX / tileWidth), Std.int(aY / tileHeight));
	}

	public function changeEdgeType(tileX:Int, tileY:Int, edgeType:Int):Void {
		edges[tileX + tileY * widthIntTiles] = edgeType;
	}

	public function raycast(start:FastVector2, dir:FastVector2, length:Float):Int {
		var currentX:Float = Math.floor(start.x / tileWidth);
		var currentY:Float = Math.floor(start.y / tileHeight);

		var endX = Math.floor((start.x + dir.x * length) / tileWidth);
		var endY = Math.floor((start.y + dir.y * length) / tileHeight);

		var stepX:Float = dir.x >= 0 ? 1 : -1;
		var stepY:Float = dir.y >= 0 ? 1 : -1;

		var nextTileEdgeX = (currentX + stepX) * tileWidth;
		var nextTileEdgeY = (currentY + stepY) * tileHeight;

		var tMaxX:Float = (dir.x != 0) ? (nextTileEdgeX - start.x) / dir.x : Math.POSITIVE_INFINITY;
		var tMaxY:Float = (dir.y != 0) ? (nextTileEdgeY - start.y) / dir.y : Math.POSITIVE_INFINITY;

		var tDeltaX = (dir.x != 0) ? tileWidth / dir.x * stepX : Math.POSITIVE_INFINITY;
		var tDeltaY = (dir.y != 0) ? tileHeight / dir.y * stepY : Math.POSITIVE_INFINITY;

		var diff = new FastVector2();
		var neg_ray:Bool = false;
		if (currentX != endX && dir.x < 0) {
			diff.x--;
			neg_ray = true;
		}
		if (currentY != endY && dir.y < 0) {
			diff.y--;
			neg_ray = true;
		}
		if (neg_ray) {
			currentX += diff.x;
			currentY += diff.y;
		}

		while (endX != currentX || endY != currentY) {
			if (tMaxX < tMaxY) {
				tMaxX = tMaxX + tDeltaX;
				currentX = currentX + stepX;
				if (currentX < 0 || currentX > widthIntTiles)
					break;
			} else {
				tMaxY = tMaxY + tDeltaY;
				currentY = currentY + stepY;
				if (currentY < 0 || currentY > heightInTiles)
					break;
			}
			var idx = Std.int(currentX + currentY * widthIntTiles);
			if (tiles[idx] >= startingCollisionIndex) {
				return idx;
			}
		}
		return -1;
	}

	inline public function isWalkableTile(tx:Int, ty:Int):Bool {
		return getTileId(tx, ty) < startingCollisionIndex;
	}

	inline public function isWalkableAt(px:Float, py:Float):Bool {
		return getTileId2(px, py) < startingCollisionIndex;
	}

	public function segmentClear(a:FastVector2, b:FastVector2):Bool {
		var dir = b.sub(a);
		var len = dir.length;
		if (len <= 0) return true;
		return raycast(a, dir.mult(1.0 / len), len) == -1;
	}

	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void {}
	#end
}
