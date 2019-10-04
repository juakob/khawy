#version 450

in vec3 pos;
in vec3 normal;
in vec2 uv;


uniform mat4 mvp;


//uniform mat4 depthBias;

//out vec3 norm;
out vec2 texCoord;
//out vec4 shadowCoord;

void kore() {
	vec3 norm = normal.xyz+vec3(0.1);
    texCoord=uv;
	//shadowCoord = depthBias*vec4(pos,1);
	gl_Position = mvp * vec4(pos, 1.0);
	
}
