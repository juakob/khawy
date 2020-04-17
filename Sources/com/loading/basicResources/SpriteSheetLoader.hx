package com.loading.basicResources;

import com.gEngine.Frame;
import com.gEngine.Label;

class SpriteSheetLoader extends TilesheetLoader{
    var animations:Array<Sequence>;
    var baseFrames:Array<Frame>;
    public function new(imageName:String, tileWidth:Int, tileHeight:Int, spacing:Int,animations:Array<Sequence>) {
        super(imageName,tileWidth,tileHeight,spacing);
        this.animations=animations;
    }
    override function fromSpriteSheet() {
        super.fromSpriteSheet();
        baseFrames=animation.frames;
        var frames:Array<Frame> = new Array();
        var frameCounter:Int=0;
        for(seq in animations){
            var label=new Label(seq.name,frameCounter);
            animation.labels.push(label);
            for(frame in seq.frames){
                frames.push(baseFrames[frame]);
            }
            frameCounter+=seq.frames.length;
        }
        animation.frames=frames;

    }
    override function update(atlasId:Int) {
        var temp=animation.frames;
        animation.frames=baseFrames;
        super.update(atlasId);
        animation.frames=temp;
    }
}
class Sequence {
    public var name:String;
    public var frames:Array<Int>;
    public function new(name,frames) {
        this.name = name;
        this.frames = frames;
    }
}