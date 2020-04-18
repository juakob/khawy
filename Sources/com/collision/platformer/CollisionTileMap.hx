package com.collision.platformer;

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

	var startingCollisionIndex:Int = 1;
	var edges:Array<Int>;

	public var userData:Dynamic;

	var helperTile:CollisionBox;

	public var parent:CollisionGroup;

	public function removeFromParent() {
		if (parent != null)
			parent.remove(this);
	}

	public function new(aTiles:Array<Int>, aTileWidth:Float, aTileHeight:Float, aWidthInTiles:Int, aHeightInTiles:Int) {
		tiles = aTiles;
		tileWidth = aTileWidth;
		tileHeight = aTileHeight;
		widthIntTiles = aWidthInTiles;
		heightInTiles = aHeightInTiles;
		helperTile = new CollisionBox();
		helperTile.width = aTileWidth;
		helperTile.height = aTileHeight;
		helperTile.staticObject = true;
		edges = new Array();
		for (i in 0...tiles.length) {
			edges.push(0);
		}
		calculateEdges(0, 0, aWidthInTiles, aHeightInTiles);
	}

	function calculateEdges(minX:Int, minY:Int, maxX:Int, maxY:Int) {
		for (tileY in minY...(maxY + 1)) {
			for (tileX in minX...(maxX + 1)) {
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

	/* INTERFACE ICollider */
	public function collide(aCollider:ICollider, ?NotifyCallback:ICollider->ICollider->Void):Bool {
		if (aCollider.collisionType() == CollisionType.Box) {
			// TODO calculate more points if the box is much larger than tiles
			var box:CollisionBox = cast aCollider;
			var minX:Int = Std.int(box.x / tileWidth);
			var minY:Int = Std.int(box.y / tileHeight);
			var maxX:Int = Std.int((box.x + box.width) / tileWidth) + 1;
			var maxY:Int = Std.int((box.y + box.height) / tileHeight) + 1;

			var toReturn:Bool = false;
			for (tileY in minY...maxY) {
				for (tileX in minX...maxX) {
					if (getTileId(tileX, tileY) >= startingCollisionIndex) {
						helperTile.collisionAllow = edges[tileX + tileY * widthIntTiles];
						helperTile.x = tileX * tileWidth;
						helperTile.y = tileY * tileHeight;
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
						helperTile.x = tileX * tileWidth;
						helperTile.y = tileY * tileHeight;
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

	public function edgeType(tileX:Int, tileY:Int):Int {
		return edges[tileX + tileY * widthIntTiles];
	}

	public function edgeType2(aX:Float, aY:Float):Int {
		return edgeType(Std.int(aX / tileWidth), Std.int(aY / tileHeight));
	}

	public function changeEdgeType(tileX:Int, tileY:Int, edgeType:Int):Void {
		edges[tileX + tileY * widthIntTiles] = edgeType;
	}
	#if DEBUGDRAW
	public function debugDraw(canvas:kha.Canvas):Void{}
	#end
}
