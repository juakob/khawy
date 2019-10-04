#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform vec4 colorMul;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec4 texcolor = texture(tex, texCoord)*colorMul;
	FragColor = texcolor;
}
