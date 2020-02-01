package com.gEngine.display;

import kha.graphics4.BlendingOperation;
import kha.graphics4.BlendingFactor;

/**
 * ...
 * @author Joaquin
 */
class Blend {
	public var blendOperation:BlendingOperation;
	public var blendSource:BlendingFactor;
	public var blendDestination:BlendingFactor;
	public var alphaBlendSource:BlendingFactor;
	public var alphaBlendDestination:BlendingFactor;

	public function new() {
		blendOperation = BlendingOperation.Add;
	}

	public static function blendAdd():Blend {
		var blend:Blend = new Blend();
		blend.blendSource = BlendingFactor.BlendOne;
		blend.blendDestination = BlendingFactor.BlendOne;
		blend.alphaBlendSource = BlendingFactor.BlendOne;
		blend.alphaBlendDestination = BlendingFactor.BlendOne;
		return blend;
	}

	public static function blendMultiply():Blend {
		var blend:Blend = new Blend();
		blend.blendSource = BlendingFactor.DestinationColor;
		blend.blendDestination = BlendingFactor.InverseSourceAlpha;
		blend.alphaBlendSource = BlendingFactor.DestinationAlpha;
		blend.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		return blend;
	}

	public static function blendScreen():Blend {
		var blend:Blend = new Blend();
		blend.blendSource = BlendingFactor.BlendOne;
		blend.blendDestination = BlendingFactor.InverseSourceColor;
		blend.alphaBlendSource = BlendingFactor.BlendOne;
		blend.alphaBlendDestination = BlendingFactor.BlendOne;
		return blend;
	}

	public static function blendMultipass():Blend {
		var blend:Blend = new Blend();
		blend.blendSource = BlendingFactor.BlendOne;
		blend.blendDestination = BlendingFactor.BlendZero;
		blend.alphaBlendSource = BlendingFactor.BlendOne;
		blend.alphaBlendDestination = BlendingFactor.BlendZero;
		return blend;
	}

	public static function blendDefault():Blend {
		var blend:Blend = new Blend();
		blend.blendSource = BlendingFactor.BlendOne;
		blend.blendDestination = BlendingFactor.InverseSourceAlpha;
		blend.alphaBlendSource = BlendingFactor.BlendOne;
		blend.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		return blend;
	}

	public static function blendEnd():Blend {
		var blend:Blend = new Blend();
		blend.blendSource = BlendingFactor.BlendOne;
		blend.blendDestination = BlendingFactor.InverseSourceAlpha;
		blend.alphaBlendSource = BlendingFactor.BlendOne;
		blend.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		return blend;
	}

	public static function blendNone():Blend {
		var blend:Blend = new Blend();
		blend.blendSource = BlendingFactor.BlendOne;
		blend.blendDestination = BlendingFactor.BlendZero;
		blend.alphaBlendSource = BlendingFactor.BlendOne;
		blend.alphaBlendDestination = BlendingFactor.BlendZero;
		return blend;
	}
}
