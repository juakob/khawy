package com.loading.basicResources;

import com.gEngine.GEngine;
import com.basicDisplay.SpriteSheetDB;
import com.imageAtlas.Bitmap;
import kha.Assets;
import com.gEngine.AnimationData;
import com.gEngine.Label;
import com.gEngine.Frame;
import kha.Blob;
import kha.Image;
import haxe.xml.Access;

class SparrowLoader extends TilesheetLoader {
	var dataName:String;

	public function new(imageName:String, dataName:String) {
		super(imageName, 0, 0, 0);
		this.dataName = dataName;
	}

	override function load(callback:Void->Void):Void {
		Assets.loadImage(imageName, function(image:Image) {
			Assets.loadBlob(dataName, function(b:Blob) {
				fromSpriteSheet();
				callback();
			});
		});
	}

	override function fromSpriteSheet() {
		var text:Blob = Reflect.field(kha.Assets.blobs, dataName);
		var data:Access = new Access(Xml.parse(text.toString()).firstElement());
		var image:Image = Reflect.field(kha.Assets.images, imageName);

		animation = new AnimationData();
		var frames:Array<Frame> = new Array();
		var labels:Array<Label> = new Array();
		bitmaps = new Array();

		var counter:Int = 0;
		var currentAnimation:String = null;
		var textures = data.nodes.SubTexture;
		textures.sort(function(a:Access, b:Access):Int {
			if (a.att.name < b.att.name) return -1;
            if (a.att.name > b.att.name) return 1;
            return 0;
        });
/*
		textures.sort(function(a:Access, b:Access):Int {
			var aName = a.att.name;
			var aNumber:String = "";
			var aString:String = "";
			for (char in 0...text.length) {
				if (Std.parseInt(aName.charAt(char)) != null) {
					aNumber += aName.charAt(char);
				} else {
					aString += aName.charAt(char);
				}
			}
			var bName = b.att.name;
			var bNumber:String = "";
			var bString:String = "";
			for (char in 0...text.length) {
				if (Std.parseInt(bName.charAt(char)) != null) {
					bNumber += bName.charAt(char);
				} else {
					bString += bName.charAt(char);
				}
			}
			var aInt = Std.parseInt(aNumber);
			var bInt = Std.parseInt(bNumber);
			if (aString == bString) {
				if (aInt < bInt)
					return -1;
				if (aInt > bInt)
					return 1;
			}
			if (aString < bString)
				return -1;
			if (aString > bString)
				return 1;
			return 0;
		});*/
		for (texture in textures) {
			var name = texture.att.name;
			var trimmed = texture.has.frameX;
			var rotated = (texture.has.rotated && texture.att.rotated == "true");
			var flipX = (texture.has.flipX && texture.att.flipX == "true");
			var flipY = (texture.has.flipY && texture.att.flipY == "true");

			var baseName = getBaseName(name);
			if (currentAnimation != baseName) {
				currentAnimation = baseName;
				var label:Label = new Label(baseName, counter);
				labels.push(label);
			}
			++counter;
			var name_parts = name.split("#");
			var frameX =0.;
			var frameY =0.;
			var offsets:Array<String> = null;
			if (name_parts.length>1){
				var offsets = name_parts[1].split("x");
				frameX =0+Std.parseFloat(offsets[0]);// trimmed ? -Std.parseInt(texture.att.frameX) : 0;
				frameY =0+Std.parseFloat(offsets[1]);
			}else{
				frameX = trimmed ? -Std.parseInt(texture.att.frameX) : 0;
				frameY = trimmed ? -Std.parseInt(texture.att.frameY) : 0;
			}
			// trimmed ? -Std.parseInt(texture.att.frameY) : 0;
			
			frames.push(TilesheetLoader.createFrame(frameX, frameY, Std.parseInt(texture.att.width), Std.parseInt(texture.att.height), rotated,
				Std.parseInt(texture.att.x), Std.parseInt(texture.att.y), image.realWidth, image.realHeight));
			// var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));
			var bitmap:Bitmap = new Bitmap();
			if (offsets!=null) {
				bitmap.x = Std.parseInt(texture.att.x)+Std.parseFloat(offsets[0]);
				bitmap.y = Std.parseInt(texture.att.y)+Std.parseFloat(offsets[1]);
			}
			bitmap.width = Std.parseInt(texture.att.width);
			bitmap.height = Std.parseInt(texture.att.height);
			bitmap.name = name_parts[0]+name_parts[2];
			bitmap.image = image;
			bitmaps.push(bitmap);
		}

		animation.frames = frames;
		animation.name = imageName;
		animation.labels = labels;
		animation.texturesID = GEngine.i.addTexture(image);
		SpriteSheetDB.i.add(animation);
	}

	static function getBaseName(fullName:String):String {
		var foundInt:Bool = false;
		var counter:Int = fullName.length - 1;
		while (counter >= 0) {
			if (Std.parseInt(fullName.charAt(counter)) != null) {
				fullName = fullName.substring(0, counter) + fullName.substring(counter + 1);
				foundInt = true;
			} else if (foundInt) {
				break;
			}
			--counter;
		}
		return fullName;
	}
}
