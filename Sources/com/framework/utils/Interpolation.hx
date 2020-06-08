package com.framework.utils;

class Interpolation {
    public static function easingOut(a:Float,b:Float,s:Float):Float {

        return -b*s*(s-2) + a;
    }
}