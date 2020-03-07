package com.framework.utils;

class Random {
    inline public static function getRandom():Float {
        return kha.math.Random.getFloat();
    }
    inline public static function getRandomIn(min:Float,max:Float):Float {
        return kha.math.Random.getFloatIn(min,max);
    }
    inline public static function init(seed:Int) {
        kha.math.Random.init(seed);
    }
}