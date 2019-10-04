#version 450

in vec3 vertexPosition;
in vec2 texPosition;
in vec4 colorMul;
in vec4 colorAdd;

uniform mat4 projectionMatrix;
out vec2 texCoord;
out vec4 _colorMul;
out vec4 _colorAdd;


void kore() {
	gl_Position =  projectionMatrix*vec4(vertexPosition.xyz, 1.0) ;
	texCoord = texPosition;
	_colorMul = colorMul;
	_colorAdd = colorAdd;

}
