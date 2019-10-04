#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform float time;

in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec2 value = vec2(1/1280,1/720);

	vec4 c1 = texture( tex, texCoord - value );
	vec4 c2 = texture( tex, texCoord );
	vec4 c3 = texture( tex, texCoord + value );
	
	vec4 col = vec4( c1.r, c2.g, c3.b, c1.a + c2.a + c3.b );
	float scanLines =cos( time+texCoord.y * 300.5);
	
	float saturation = scanLines*scanLines;
	col.xyz = col.xyz * vec3(1.0 + 0.2 * saturation);
	
	FragColor = col;
}
