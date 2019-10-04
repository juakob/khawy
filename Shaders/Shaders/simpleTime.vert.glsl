#version 450

in vec3 vertexPosition;
in vec2 texPosition;

uniform mat4 projectionMatrix;
out vec2 texCoord;


void kore() {
	gl_Position =  projectionMatrix*vec4(vertexPosition.xyz, 1.0) ;
	texCoord = texPosition;
}
