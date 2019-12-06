package com.imageAtlas;

import com.helpers.Rectangle;
import com.imageAtlas.Bitmap;

class ImageTree {
	private var firstNode:Node;
	private var imageSeparation:Float;

	public function new(width:Float, height:Float, imageSeparation:Float) {
		firstNode = new Node();
		firstNode.rect = new Rectangle(0, 0, width, height);
		this.imageSeparation = imageSeparation * 2;
	}

	public function insertImage(bitmap:Bitmap):Rectangle {
		var node:Node = Insert(bitmap, firstNode);
		if (node != null) {
			var rec:Rectangle = node.rect.clone();
			rec.x += imageSeparation * 0.5;
			rec.y += imageSeparation * 0.5;
			return rec;
		} else {
			return null;
		}
	}

	private function Insert(bitmap:Bitmap, node:Node):Node {
		// if we're not a leaf then
		if (node.Right != null || node.Left != null) {
			var newNode:Node = Insert(bitmap, node.Left);
			if (newNode != null)
				return newNode;

			return Insert(bitmap, node.Right);
		} else {
			if (node.bitmap != null)
				return null;

			// try to fit
			if (!rectangleFitIn(node.rect, bitmap))
				return null;
			var normal:Bool = rectangleFitIn(node.rect, bitmap);

			var rotated:Bool = rectangleFitIn(node.rect, bitmap);

			if (!normal && !rotated) {
				return null;
			} else {
				if (rotated && !normal) {}
			}

			if (rectangleFitPerfect(node.rect, bitmap)) {
				node.bitmap = bitmap;
				return node;
			};

			var rc:Rectangle = node.rect;
			node.Left = new Node();
			node.Right = new Node();

			var dw:Float = rc.width - (bitmap.width + imageSeparation);
			var dh:Float = rc.height - (bitmap.height + imageSeparation);

			if (dw < dh) {
				// horizontal
				node.Left.rect = new Rectangle(rc.x, rc.y, rc.width, bitmap.height + imageSeparation);
				node.Right.rect = new Rectangle(rc.x, rc.y + bitmap.height + imageSeparation, rc.width, rc.height - (bitmap.height + imageSeparation));
			} else {
				// vertical
				node.Left.rect = new Rectangle(rc.x, rc.y, bitmap.width + imageSeparation, rc.height);
				node.Right.rect = new Rectangle(rc.x + bitmap.width + imageSeparation, rc.y, rc.width - (bitmap.width + imageSeparation), rc.height);
			}
			return Insert(bitmap, node.Left);
		}
		// cant fit
		return null;
	}

	private function rectangleFitPerfect(rect:Rectangle, bitmap:Bitmap):Bool {
		return rect.width == (bitmap.width + imageSeparation) && rect.height == (bitmap.height + imageSeparation);
	}

	private function rectangleFitIn(rect:Rectangle, bitmap:Bitmap):Bool {
		return rect.width >= (bitmap.width + imageSeparation) && rect.height >= (bitmap.height + imageSeparation);
	}
}
