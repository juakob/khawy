package com.gEngine.helpers;

import com.gEngine.display.Text;

class WaveText extends Text {
    
    public var amplitud = 5;
    public var angularVelocity = 7;
    public var waveLength=1;
    var time:Float=0;

    override function update(passedTime:Float) {
        super.update(passedTime);
        time+=passedTime;
        for(i in 0...length){
            var l = getLetter(i);
            l.y = amplitud*Math.cos(time*angularVelocity-i*waveLength);
        }
    }

}