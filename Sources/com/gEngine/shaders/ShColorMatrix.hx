package com.gEngine.shaders;

import kha.math.FastMatrix4;
import com.gEngine.display.Blend;
import com.gEngine.painters.Painter;
import com.helpers.MinMax;
import kha.Shaders;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.math.Matrix4;

class ShColorMatrix extends Painter {
    public var colorMatrix:kha.graphics4.ConstantLocation;
    public var colorOffset:kha.graphics4.ConstantLocation;

    public var matrix:FastMatrix4;
    public var offset:Array<Float>;

    public function new(matrix:FastMatrix4, offset:Array<Float>, autoDestroy:Bool = true, blend:Blend = null) {
        super(autoDestroy, blend);
        this.matrix = matrix;
        this.offset = offset;
    }

    override function setShaders(pipeline:PipelineState):Void {
        pipeline.vertexShader = Shaders.simple_vert;
        pipeline.fragmentShader = Shaders.colorMatrix_frag;
    }

    override public function adjustRenderArea(area:MinMax):Void {
        // Normalmente no es necesario agregar borde
    }

    override function getConstantLocations(pipeline:PipelineState) {
        super.getConstantLocations(pipeline);
        colorMatrix = pipeline.getConstantLocation("colorMatrix");
        colorOffset = pipeline.getConstantLocation("colorOffset");
    }

    override function setParameter(g:Graphics):Void {
        super.setParameter(g);
        g.setMatrix(colorMatrix, matrix);
        g.setFloat4(colorOffset, offset[0], offset[1], offset[2], offset[3]);
    }
}
