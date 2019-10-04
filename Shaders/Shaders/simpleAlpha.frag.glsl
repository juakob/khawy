#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
in vec3 texCoord;
out vec4 FragColor;

void kore() {
	vec4 texcolor = texture(tex, texCoord.xy)*texCoord.z;
	FragColor = texcolor;
}
