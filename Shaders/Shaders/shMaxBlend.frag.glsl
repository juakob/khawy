#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform sampler2D mask;
in vec2 texCoord;
in vec2 texCoordMask;
out vec4 FragColor;

void kore() {
	vec4 texcolor = texture(tex, texCoord) ;
	vec4 maskColor=texture(mask, texCoordMask) ;
	FragColor = max(texcolor,maskColor);
}
