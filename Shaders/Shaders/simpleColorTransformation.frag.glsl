#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;
in vec3 texCoord;
in vec4 _colorMul;
in vec4 _colorAdd;
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
	vec4 texcolor = sampleTexture(texCoord.z, texCoord.xy) * _colorMul;
	texcolor.xyz*=_colorMul.w;
	texcolor+=_colorAdd*texcolor.w;
	
	FragColor = texcolor;

}
