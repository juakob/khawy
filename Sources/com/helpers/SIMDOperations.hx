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

    public static inline function multiplyMat(a:FastMatrix4,b:FastMatrix4):FastMatrix4 {
        #if cpp
        var bX0=Float32x4.loadFast(b._00, b._10, b._20, b._30);
        var bX1=Float32x4.loadFast(b._01, b._11, b._21, b._31);
        var bX2=Float32x4.loadFast(b._02, b._12, b._22, b._32);
        var bX3=Float32x4.loadFast(b._03, b._13, b._23, b._33);
        
        var row0 = Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._00),bX0),Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._10),bX1),
                                Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._20),bX2),Float32x4.mul(Float32x4.loadAllFast(a._30),bX3))));

        var row1 = Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._01),bX0),Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._11),bX1),
                                Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._21),bX2),Float32x4.mul(Float32x4.loadAllFast(a._31),bX3))));

        var row2 = Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._02),bX0),Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._12),bX1),
                                Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._22),bX2),Float32x4.mul(Float32x4.loadAllFast(a._32),bX3))));

        var row3 = Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._03),bX0),Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._13),bX1),
                                Float32x4.add(Float32x4.mul(Float32x4.loadAllFast(a._23),bX2),Float32x4.mul(Float32x4.loadAllFast(a._33),bX3))));

        return new FastMatrix4(Float32x4.getFast(row0,0),Float32x4.getFast(row0,1),Float32x4.getFast(row0,2),Float32x4.getFast(row0,3),
                                Float32x4.getFast(row1,0),Float32x4.getFast(row1,1),Float32x4.getFast(row1,2),Float32x4.getFast(row1,3),
                                Float32x4.getFast(row2,0),Float32x4.getFast(row2,1),Float32x4.getFast(row2,2),Float32x4.getFast(row2,3),
                                Float32x4.getFast(row3,0),Float32x4.getFast(row3,1),Float32x4.getFast(row3,2),Float32x4.getFast(row3,3));
        #else
        return a.multmat(b);
        #end
        
    }


}