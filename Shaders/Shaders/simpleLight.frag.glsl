#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform sampler2D tex2;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec4 light = texture(tex, texCoord) ;
	vec4 texcolor = texture(tex2, texCoord) ;
	texcolor.xyz=texcolor.xyz*light.xyz;
	FragColor = texcolor;
}
