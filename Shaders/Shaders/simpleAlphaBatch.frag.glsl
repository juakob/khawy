#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform sampler2D tex2;
uniform sampler2D tex3;
uniform sampler2D tex4;
in vec4 texCoord;
out vec4 FragColor;

vec4 sampleTexture(float textureIndex, vec2 uv) {
	int idx = int(textureIndex + 0.5);
	if (idx <= 0) {
		return texture(tex, uv);
	}
	if (idx == 1) {
		return texture(tex2, uv);
	}
	if (idx == 2) {
		return texture(tex3, uv);
	}
	return texture(tex4, uv);
}

void kore() {
	vec4 texcolor = sampleTexture(texCoord.w, texCoord.xy) * texCoord.z;
	FragColor = texcolor;
}
