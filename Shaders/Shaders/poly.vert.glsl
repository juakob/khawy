#version 450

in vec3 vertexPosition;

uniform mat4 projectionMatrix;

void kore() {
	gl_Position =  projectionMatrix*vec4(vertexPosition.xyz, 1.0) ;
}
