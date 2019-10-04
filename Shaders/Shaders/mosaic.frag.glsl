#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform float tiles;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec2 uv = texCoord.xy;
	uv = floor(uv*tiles)/tiles;
	FragColor = texture( tex, uv );
}
