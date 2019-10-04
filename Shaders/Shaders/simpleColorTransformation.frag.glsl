#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
in vec2 texCoord;
in vec4 _colorMul;
in vec4 _colorAdd;
out vec4 FragColor;

void kore() {
	vec4 texcolor = texture(tex, texCoord)*_colorMul;
	texcolor.xyz*=_colorMul.w;
	texcolor+=_colorAdd*texcolor.w;
	
	FragColor = texcolor;

}
