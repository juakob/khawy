package com.collision;

import kha.math.FastVector2;
import com.collision.platformer.CollisionTileMap;

class Pathfinder {
	static inline var ORTHO_COST:Float = 1.0;
	static inline var DIAG_COST:Float = 1.4142;

	public static function findPath(map:CollisionTileMap, start:FastVector2, goal:FastVector2):Array<FastVector2> {
		var startX = Std.int(start.x / map.tileWidth);
		var startY = Std.int(start.y / map.tileHeight);
		var goalX = Std.int(goal.x / map.tileWidth);
		var goalY = Std.int(goal.y / map.tileHeight);

		// --- Cache y estructuras ---
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
			// Seleccionar el nodo con menor F (g + h)
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

			if (current.x == goalX && current.y == goalY)
				return reconstructPath(current, map);

			for (neighbor in neighbors(current, map)) {
				var k = key(neighbor.x, neighbor.y);
				if (closed.exists(k)) continue;
				if (map.getTileId(neighbor.x, neighbor.y) >= map.startingCollisionIndex) continue;

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

		return []; // sin camino
	}

	static function heuristic(x1:Int, y1:Int, x2:Int, y2:Int):Float {
		// Heurística Euclídea (más suave que Manhattan)
		var dx = x1 - x2;
		var dy = y1 - y2;
		return Math.sqrt(dx * dx + dy * dy);
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
            // destino debe ser caminable
            if (!map.isWalkableTile(nx, ny)) continue;
            // evitar diagonales cortando esquinas
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
