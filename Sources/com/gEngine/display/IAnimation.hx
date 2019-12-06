package com.gEngine.display;

import com.gEngine.helper.Timeline;

interface IAnimation extends IDraw {
	var timeline(default, null):Timeline;
}
