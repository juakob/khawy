#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;
in vec4 texCoord;
out vec4 FragColor;

vec4 sampleTexture(float textureIndex, vec2 uv) {
	int idx = int(textureIndex + 0.5);
	if (idx <= 0) {
		return texture(tex0, uv);
	}
	if (idx == 1) {
		return texture(tex1, uv);
	}
	if (idx == 2) {
		return texture(tex2, uv);
	}
	return texture(tex3, uv);
}

void kore() {
	vec4 texcolor = sampleTexture(texCoord.w, texCoord.xy) * texCoord.z;
	FragColor = texcolor;
}
