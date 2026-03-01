package com.collision;

import kha.math.FastVector2;
import com.collision.platformer.CollisionTileMap;

class Pathfinder {
	static inline var ORTHO_COST:Float = 1.0;
	static inline var DIAG_COST:Float = 1.4142;

	/**
	 * Generic 8-direction A* pathfinding.
	 */
	public static function findPath(map:CollisionTileMap, start:FastVector2, goal:FastVector2, ?isBlocked:Int->Int->Bool):Array<FastVector2> {
		var startX = Std.int(start.x / map.tileWidth);
		var startY = Std.int(start.y / map.tileHeight);
		var goalX = Std.int(goal.x / map.tileWidth);
		var goalY = Std.int(goal.y / map.tileHeight);

		var open:Array<Node> = [];
		var openMap:Map<String, Node> = new Map();
		var closed:Map<String, Bool> = new Map();
		var nodes:Map<String, Node> = new Map();

		inline function key(x:Int, y:Int):String return '$x,$y';

		inline function getNode(x:Int, y:Int):Node {
			var k = key(x, y);
			var n = nodes.get(k);
			if (n == null) {
				n = new Node(x, y);
				nodes.set(k, n);
			}
			return n;
		}

		var startNode = getNode(startX, startY);
		startNode.g = 0;
		startNode.h = heuristic(startX, startY, goalX, goalY);
		open.push(startNode);
		openMap.set(key(startX, startY), startNode);

		while (open.length > 0) {
			var currentIndex = 0;
			var current = open[0];
			for (i in 1...open.length) {
				if (open[i].f < current.f) {
					current = open[i];
					currentIndex = i;
				}
			}

			open.splice(currentIndex, 1);
			openMap.remove(key(current.x, current.y));
			closed.set(key(current.x, current.y), true);

			if (current.x == goalX && current.y == goalY) {
				return reconstructPath(current, map);
			}

			for (neighbor in neighbors(current, map)) {
				var k = key(neighbor.x, neighbor.y);
				if (closed.exists(k)) continue;
				if (map.getTileId(neighbor.x, neighbor.y) >= map.startingCollisionIndex) continue;
				if (isBlocked != null && isBlocked(neighbor.x, neighbor.y)) continue;

				var cost = (neighbor.x == current.x || neighbor.y == current.y) ? ORTHO_COST : DIAG_COST;
				var tentativeG = current.g + cost;
				var existing = openMap.get(k);

				if (existing == null || tentativeG < existing.g) {
					var n = existing != null ? existing : getNode(neighbor.x, neighbor.y);
					n.parent = current;
					n.g = tentativeG;
					n.h = heuristic(n.x, n.y, goalX, goalY);

					if (existing == null) {
						open.push(n);
						openMap.set(k, n);
					}
				}
			}
		}

		return [];
	}

	/**
	 * Platformer pathfinding:
	 * - standable nodes (walkable tile with solid tile below)
	 * - horizontal movement
	 * - falling through holes
	 * - optional custom links (doors, ladders, etc.)
	 */
	public static function findPlatformerPath(map:CollisionTileMap, start:FastVector2, goal:FastVector2, ?links:Array<Dynamic>,
			?isBlocked:Int->Int->Bool):Array<FastVector2> {
		var startX = Std.int(start.x / map.tileWidth);
		var startY = Std.int(start.y / map.tileHeight);
		var goalX = Std.int(goal.x / map.tileWidth);
		var goalY = Std.int(goal.y / map.tileHeight);

		var startNode = closestStandableTile(map, startX, startY, 8);
		var goalNode = closestStandableTile(map, goalX, goalY, 8);
		if (startNode == null || goalNode == null) {
			return [];
		}

		var linksBySource = buildPlatformerLinks(map, links);

		var open:Array<Node> = [];
		var openMap:Map<String, Node> = new Map();
		var closed:Map<String, Bool> = new Map();
		var nodes:Map<String, Node> = new Map();

		inline function key(x:Int, y:Int):String return '$x,$y';

		inline function getNode(x:Int, y:Int):Node {
			var k = key(x, y);
			var n = nodes.get(k);
			if (n == null) {
				n = new Node(x, y);
				nodes.set(k, n);
			}
			return n;
		}

		var startA = getNode(startNode.x, startNode.y);
		var goalAX = goalNode.x;
		var goalAY = goalNode.y;
		startA.g = 0;
		startA.h = platformerHeuristic(startA.x, startA.y, goalAX, goalAY);
		open.push(startA);
		openMap.set(key(startA.x, startA.y), startA);

		while (open.length > 0) {
			var currentIndex = 0;
			var current = open[0];
			for (i in 1...open.length) {
				if (open[i].f < current.f) {
					current = open[i];
					currentIndex = i;
				}
			}

			open.splice(currentIndex, 1);
			openMap.remove(key(current.x, current.y));
			closed.set(key(current.x, current.y), true);

			if (current.x == goalAX && current.y == goalAY) {
				return reconstructPath(current, map);
			}

			for (step in platformerNeighbors(current, map, linksBySource)) {
				var k = key(step.x, step.y);
				if (closed.exists(k)) continue;
				if (isBlocked != null && isBlocked(step.x, step.y)) continue;

				var tentativeG = current.g + step.cost;
				var existing = openMap.get(k);

				if (existing == null || tentativeG < existing.g) {
					var n = existing != null ? existing : getNode(step.x, step.y);
					n.parent = current;
					n.g = tentativeG;
					n.h = platformerHeuristic(n.x, n.y, goalAX, goalAY);

					if (existing == null) {
						open.push(n);
						openMap.set(k, n);
					}
				}
			}
		}

		return [];
	}

	static function heuristic(x1:Int, y1:Int, x2:Int, y2:Int):Float {
		var dx = x1 - x2;
		var dy = y1 - y2;
		return Math.sqrt(dx * dx + dy * dy);
	}

	static function platformerHeuristic(x1:Int, y1:Int, x2:Int, y2:Int):Float {
		var dx = Math.abs(x1 - x2);
		var dy = Math.abs(y1 - y2);
		return dx + dy * 1.5;
	}

	static function neighbors(n:Node, map:CollisionTileMap):Array<Node> {
		var dirs = [
			{x: 1, y: 0}, {x: -1, y: 0},
			{x: 0, y: 1}, {x: 0, y: -1},
			{x: 1, y: 1}, {x: -1, y: -1},
			{x: 1, y: -1}, {x: -1, y: 1}
		];
		var list:Array<Node> = [];
		for (d in dirs) {
			var nx = n.x + d.x;
			var ny = n.y + d.y;
			if (nx < 0 || ny < 0 || nx >= map.widthIntTiles || ny >= map.heightInTiles) continue;
			if (!map.isWalkableTile(nx, ny)) continue;
			if (d.x != 0 && d.y != 0) {
				if (!map.isWalkableTile(n.x + d.x, n.y)) continue;
				if (!map.isWalkableTile(n.x, n.y + d.y)) continue;
			}
			list.push(new Node(nx, ny));
		}
		return list;
	}

	static function reconstructPath(n:Node, map:CollisionTileMap):Array<FastVector2> {
		var path:Array<FastVector2> = [];
		while (n != null) {
			path.unshift(new FastVector2(
				n.x * map.tileWidth + map.tileWidth * 0.5,
				n.y * map.tileHeight + map.tileHeight * 0.5
			));
			n = n.parent;
		}
		return path;
	}

	static function buildPlatformerLinks(map:CollisionTileMap, links:Array<Dynamic>):Map<String, Array<PlatformerStep>> {
		var bySource:Map<String, Array<PlatformerStep>> = new Map();
		if (links == null) {
			return bySource;
		}

		for (link in links) {
			if (link == null) continue;
			var fromX:Int = Std.int(Reflect.field(link, "fromX"));
			var fromY:Int = Std.int(Reflect.field(link, "fromY"));
			var toX:Int = Std.int(Reflect.field(link, "toX"));
			var toY:Int = Std.int(Reflect.field(link, "toY"));
			var cost:Float = Reflect.hasField(link, "cost") ? Reflect.field(link, "cost") : 1.0;

			if (!isStandableTile(map, fromX, fromY) || !isStandableTile(map, toX, toY)) continue;

			var k = '$fromX,$fromY';
			var arr = bySource.get(k);
			if (arr == null) {
				arr = [];
				bySource.set(k, arr);
			}
			arr.push(new PlatformerStep(toX, toY, cost));
		}
		return bySource;
	}

	static inline function isStandableTile(map:CollisionTileMap, tx:Int, ty:Int):Bool {
		if (tx < 0 || ty < 0 || tx >= map.widthIntTiles || ty >= map.heightInTiles - 1) {
			return false;
		}
		if (!map.isWalkableTile(tx, ty)) {
			return false;
		}
		return map.getTileId(tx, ty + 1) >= map.startingCollisionIndex;
	}

	static function closestStandableTile(map:CollisionTileMap, tx:Int, ty:Int, maxRadius:Int):Node {
		if (isStandableTile(map, tx, ty)) {
			return new Node(tx, ty);
		}

		for (radius in 1...(maxRadius + 1)) {
			var minX = tx - radius;
			var maxX = tx + radius;
			var minY = ty - radius;
			var maxY = ty + radius;
			for (y in minY...(maxY + 1)) {
				for (x in minX...(maxX + 1)) {
					if (!isStandableTile(map, x, y)) continue;
					return new Node(x, y);
				}
			}
		}
		return null;
	}

	static function platformerNeighbors(n:Node, map:CollisionTileMap, linksBySource:Map<String, Array<PlatformerStep>>):Array<PlatformerStep> {
		var list:Array<PlatformerStep> = [];

		for (dx in [-1, 1]) {
			var nx = n.x + dx;
			if (isStandableTile(map, nx, n.y)) {
				list.push(new PlatformerStep(nx, n.y, ORTHO_COST));
			}
		}

		for (dx in -1...2) {
			var fx = n.x + dx;
			if (fx < 0 || fx >= map.widthIntTiles) continue;
			if (!map.isWalkableTile(fx, n.y)) continue;
			if (n.y + 1 >= map.heightInTiles) continue;
			if (!map.isWalkableTile(fx, n.y + 1)) continue;

			var landingY = findLandingTileY(map, fx, n.y + 1);
			if (landingY >= 0 && landingY != n.y) {
				var dropHeight = landingY - n.y;
				var cost = ORTHO_COST + dropHeight * 0.6;
				list.push(new PlatformerStep(fx, landingY, cost));
			}
		}

		var linkSteps = linksBySource.get('${n.x},${n.y}');
		if (linkSteps != null) {
			for (step in linkSteps) {
				list.push(step);
			}
		}

		return list;
	}

	static function findLandingTileY(map:CollisionTileMap, x:Int, startY:Int):Int {
		var y = startY;
		while (y < map.heightInTiles - 1) {
			if (!map.isWalkableTile(x, y)) {
				return -1;
			}
			if (map.getTileId(x, y + 1) >= map.startingCollisionIndex) {
				return y;
			}
			y++;
		}
		return -1;
	}
}

private class Node {
	public var x:Int;
	public var y:Int;
	public var parent:Node;
	public var g:Float = 0;
	public var h:Float = 0;
	public var f(get, never):Float;

	inline function get_f():Float return g + h;

	public function new(x:Int, y:Int) {
		this.x = x;
		this.y = y;
	}
}

private class PlatformerStep {
	public var x:Int;
	public var y:Int;
	public var cost:Float;

	public function new(x:Int, y:Int, cost:Float) {
		this.x = x;
		this.y = y;
		this.cost = cost;
	}
}
