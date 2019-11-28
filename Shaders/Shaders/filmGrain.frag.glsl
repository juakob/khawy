#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform vec2 resolution;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	float strength = 5.0;
	float x = (texCoord.x + 4.0 ) * (texCoord.y + 4.0 ) * (1. * 10.0);
	vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;
	grain = 1.0 - grain;
	vec2 value = resolution*grain.xy*0.0;
	
	vec4 c1 = texture( tex, texCoord - value );
	vec4 c2 = texture( tex, texCoord );
	vec4 c3 = texture( tex, texCoord + value);
	
	vec4 col = vec4( c1.r, c2.g, c3.b, c1.a + c2.a + c3.b );

	
    
    
    
    
	
	FragColor = col* grain;
}
