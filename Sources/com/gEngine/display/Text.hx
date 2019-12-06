package com.gEngine.display;

import kha.Assets;
import com.basicDisplay.SpriteSheetDB;
import kha.Color;
import kha.Kravur.KravurImage;

/**
 * ...
 * @author Joaquin
 */
class Text extends Layer {
	private var mLetters:Array<BasicSprite>;

	public var spaceSeparation:Float = 10;
	public var mType:String;
	public var separation:Float;
	public var heigthSeparation:Float;
	public var text(default, set):String;
	public var letterWidth:Float = 20;
	public var fontSize:Int = 0;

	var sourceFontSize:Int = 0;

	public var color(default, set):Color;

	var bakedQuadCache = new kha.Kravur.AlignedQuad();

	public var alpha(default, set):Float = 1;

	public function new(type:String) {
		super();
		mLetters = new Array();
		mType = type;
		sourceFontSize = this.fontSize = (cast SpriteSheetDB.i.getData(type)).fontSize;
		color = Color.White;
	}

	public function set_text(aText:String):String {
		text = aText;
		var counter:Int = 0;
		var displayLetter:BasicSprite;
		var currentWordLetters:Array<BasicSprite> = new Array();
		var font = Assets.fonts.get(mType)._get(fontSize);
		var xpos = 0.;
		var ypos = 0.;
		var i:Int = 0;
		var scaleFont:Float = this.fontSize / sourceFontSize;
		var fontSize = Math.round((this.fontSize / sourceFontSize) * sourceFontSize);
		while (i < text.length) {
			if (text.charAt(i) == "\n") {
				i += 2;
				ypos += fontSize * 0.8;
				xpos = 0;
				bakedQuadCache.xadvance = 0;
				continue;
			}
			var charCodeIndex = findIndex(StringTools.fastCodeAt(text, i));
			var q = font.getBakedQuad(bakedQuadCache, charCodeIndex, xpos, ypos);
			if (q != null) {
				if (mLetters.length <= counter) {
					displayLetter = new BasicSprite(mType);
					addChild(displayLetter);
					mLetters.push(displayLetter);
				} else {
					displayLetter = mLetters[counter];
					if (displayLetter.parent == null) {
						addChild(displayLetter);
					}
				}
				++counter;

				displayLetter.timeline.gotoAndStop(charCodeIndex);
				currentWordLetters.push(displayLetter);
				displayLetter.x = xpos;
				displayLetter.y = ypos;
				displayLetter.scaleX = displayLetter.scaleY = scaleFont;
				xpos += q.xadvance;
			}
			++i;
		}
		for (k in counter...mLetters.length) {
			mLetters[k].removeFromParent();
		}
		color = color;
		return aText;
	}

	public function getLetter(aId:Int):BasicSprite {
		return mLetters[aId];
	}

	private static function findIndex(charCode:Int):Int {
		var blocks = KravurImage.charBlocks;
		var offset = 0;
		for (i in 0...Std.int(blocks.length / 2)) {
			var start = blocks[i * 2];
			var end = blocks[i * 2 + 1];
			if (charCode >= start && charCode <= end)
				return offset + charCode - start;
			offset += end - start + 1;
		}
		return 0;
	}

	public function set_color(color:Color):Color {
		for (child in children) {
			(cast child).colorMultiplication(color.R, color.G, color.B, color.A);
		}
		this.color = color;
		return color;
	}

	public function set_alpha(value:Float):Float {
		alpha = value;
		for (child in children) {
			(cast child).alpha = value;
		}
		return value;
	}
}
