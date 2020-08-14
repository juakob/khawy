package com.gEngine.display;

import com.gEngine.helpers.Timeline;

interface IAnimation extends IDraw {
	var timeline(default, null):Timeline;
}
