package com.helpers;

import kha.FastFloat;
import kha.math.FastVector4;
import kha.math.FastMatrix4;
import kha.simd.Float32x4;

class SIMDOperations {
    static var row1:Float32x4;
    static var row2:Float32x4;
    static var row3:Float32x4;
    static var row4:Float32x4;
    public static inline function setMatrix( matrix:FastMatrix4) {
        row1=Float32x4.loadFast(matrix._00,matrix._10, matrix._20,matrix._30);
        row2=Float32x4.loadFast(matrix._01,matrix._11, matrix._21,matrix._31);
        row3=Float32x4.loadFast(matrix._02,matrix._12, matrix._22,matrix._32);
        row4=Float32x4.loadFast(matrix._03,matrix._13, matrix._23,matrix._33);
    }
    public static inline function multiply(point:FastVector4):FastVector4 {
        var vec=Float32x4.loadFast(point.x,point.y,point.z,point.w);
        var xVec=Float32x4.mul(row1,vec);
        var yVec=Float32x4.mul(row2,vec);
        var zVec=Float32x4.mul(row3,vec);
        //var wVec=Float32x4.mul(row4,vec);

        return new FastVector4(vectorSum(xVec),vectorSum(yVec),vectorSum(zVec));
    }
    static inline function vectorSum(vec:Float32x4):FastFloat{
        return Float32x4.getFast(vec,0)+Float32x4.getFast(vec,1)+Float32x4.getFast(vec,2)+Float32x4.getFast(vec,3);
    }
}