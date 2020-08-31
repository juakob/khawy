package com.gEngine.display;

import com.gEngine.helpers.Timeline;

interface IAnimation extends DisplayObject {
	var timeline(default, null):Timeline;
}
