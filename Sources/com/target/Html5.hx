package com.target;

import com.gEngine.GEngine;
import kha.Macros;
#if (kha_html5 && js)
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
import js.Browser.navigator;
#end

class Html5 {
	public static inline function hotReload() {
		#if hotml new hotml.client.Client(); #end
	}

	public static function setFullWindowCanvas():Void {
		#if kha_html5
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";

		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.documentElement.style.width = "100%";
		document.documentElement.style.height = "100%";
		document.documentElement.style.overflow = "hidden"; // Deshabilitar scroll

		document.body.style.padding = "0";
		document.body.style.margin = "0";
		document.body.style.width = "100%";
		document.body.style.height = "100%";
		document.body.style.overflow = "hidden"; // Deshabilitar scroll

		final canvas:CanvasElement = cast document.getElementById(Macros.canvasId());
		canvas.style.position = "absolute";
		canvas.style.top = "0";
		canvas.style.left = "0";
		canvas.style.width = "100%";
		canvas.style.height = "100%";
		canvas.style.display = "block";
		canvas.style.backgroundColor = "black"; // Evitar flashes blancos

		final resize = function() {
			var w = document.documentElement.clientWidth;
			var h = document.documentElement.clientHeight;

			if (w == 0 || h == 0) {
				w = window.innerWidth > 0 ? window.innerWidth : 800; // Fallback si el tamaño es inválido
				h = window.innerHeight > 0 ? window.innerHeight : 600;
			}

			canvas.width = Std.int(w * window.devicePixelRatio);
			canvas.height = Std.int(h * window.devicePixelRatio);

			if (GEngine.i != null) {
				GEngine.i.resize(canvas.width, canvas.height);
			}
		};
		window.onresize = resize;
		resize();
		#end
	}
}
