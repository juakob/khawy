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
	private var mLetters:Array<Sprite>;

	public var mType:String;
	public var text(default, set):String;
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
		if(text==aText)return text;
		text = aText;
		var counter:Int = 0;
		var displayLetter:Sprite;
		var currentWordLetters:Array<Sprite> = new Array();
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
					displayLetter = new Sprite(mType);
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

	public function getLetter(aId:Int):Sprite {
		return mLetters[aId];
	}
	public function width():Float {
		var min:Float=Math.POSITIVE_INFINITY;
		var max:Float=Math.NEGATIVE_INFINITY;
		for(letter in mLetters){
			if(letter.x<min){
				min=letter.x;
			}else 
			if(letter.x+letter.width()>max){
				max=letter.x+letter.width();
			}
		}
		return max-min;
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
		for (child in mLetters) {
			child.colorMultiplication(color.R, color.G, color.B, color.A);
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
