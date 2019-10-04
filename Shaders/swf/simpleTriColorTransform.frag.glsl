#version 450

#ifdef GL_ES
precision mediump float;
#endif
uniform vec4 colorAdd;
uniform vec4 colorMul;
in vec4 fragmentColor;
out vec4 FragColor;

void kore() {
	FragColor = max(vec4(0),min(fragmentColor*(colorMul/256)+(colorAdd/255),vec4(1)));
	FragColor.rgb=FragColor.rgb*FragColor.a;
}
