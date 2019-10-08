#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform vec2 resolution;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec2 value = resolution;
	vec4 c1 = texture( tex, texCoord - value );
	vec4 c2 = texture( tex, texCoord );
	vec4 c3 = texture( tex, texCoord + value);
	vec4 col = vec4( c1.r, c2.g, c3.b, c1.a + c2.a + c3.b );
	FragColor = col;
}
