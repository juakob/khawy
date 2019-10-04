#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform sampler2D baseColor;
uniform float amount;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec4 texcolor = texture(tex, texCoord) ;
	vec4 texcolor2 = texture(baseColor, texCoord) ;
	FragColor = texcolor*0.5+texcolor2;
}
