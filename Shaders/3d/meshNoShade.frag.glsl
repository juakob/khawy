#version 450

precision mediump float;

uniform sampler2D tex;
//in vec3 norm;
in vec2 texCoord;
out vec4 color;


void kore() {
	color = texture(tex, texCoord.xy);
}
