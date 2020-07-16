package com.gEngine.display;

import kha.Color;
import kha.math.FastVector4;
import com.gEngine.painters.IPainter;
import com.helpers.MinMax;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;

class BakeLayer extends Layer {

    var renderCamera:Camera;
    var renderBake:Bool=false;
    var renderUpdate:Bool=false;
    var width:Int=0;
    var height:Int=0;
    var scale:Float=1;

    public function bake(resolution:Float=1,width:Int=-1,height:Int=-1) {
        if(width<0 ||height<0){
            var area=new MinMax();
            getDrawArea(area,FastMatrix4.identity());
            width=Math.ceil(area.width());
            height=Math.ceil(area.height());
        }
        this.width=Math.ceil(width*resolution);
        this.height=Math.ceil(height*resolution);
        this.scale=resolution;

        if(renderCamera!=null){
            if(renderCamera.width != this.width || renderCamera.height != this.height){
                renderCamera.destroy();
                renderCamera = new Camera(this.width,this.height);
            }
        }else{
            renderCamera = new Camera(this.width,this.height);
        }
       renderCamera.scale=resolution;
        
        renderBake=renderUpdate=true;
    }
    override function render(paintMode:PaintMode, transform:FastMatrix4) {
        if(renderBake){
            if(renderUpdate){
                paintMode.render();
                GEngine.i.endCanvas();
                var lastTarger:Int=GEngine.i.currentCanvasId();
                GEngine.i.setCanvas(renderCamera.renderTarget);
                GEngine.i.beginCanvas();
                var lastCamera=paintMode.camera;
                paintMode.camera=renderCamera;
                super.render(paintMode,FastMatrix4.translation(-renderCamera.width*0.5,-renderCamera.height*0.5,0).multmat(FastMatrix4.scale(scale,scale,1)));
                paintMode.render(true);
                paintMode.camera=lastCamera;
                GEngine.i.endCanvas();
                GEngine.i.setCanvas(lastTarger);
                GEngine.i.beginCanvas();
                renderUpdate=false;
            }
            paintMode.render();
            renderBuffer(renderCamera.renderTarget,GEngine.i.getSimplePainter(BlendMode.Default),x,y,width,height,paintMode,transform);
        }else{
            super.render(paintMode, transform);
        }
    }

    public function renderBuffer(source:Int, painter:IPainter, x:Float, y:Float, width:Float, height:Float,paintMode:PaintMode,transform:FastMatrix4) {
        painter.textureID = source;
        painter.setProjection(paintMode.camera.projection);
		var tex = GEngine.i.getTexture(source);
		var texWidth = tex.realWidth ;
        var texHeight = tex.realHeight ;
        

		writeVertex(painter, x, y, 0, texWidth, texHeight,transform);

		writeVertex(painter, x + width, y, 0, texWidth, texHeight,transform);

		writeVertex(painter, x, y + height, 0, texWidth, texHeight,transform);

		writeVertex(painter, x + width, y + height, 0, texWidth, texHeight,transform);

		painter.render();
	}

	inline function writeVertex(painter:IPainter, x:Float, y:Float, z:Float, sWidth:Float, sHeight:Float,transform:FastMatrix4) {
        var pos=transform.multmat(FastMatrix4.scale(1/scale,1/scale,1)).multvec(new FastVector4(x,y,z));
        painter.write(pos.x );
		painter.write(pos.y  );
		painter.write(pos.z);
		painter.write(x  / sWidth);
		painter.write(y  / sHeight);
	}
    
}

