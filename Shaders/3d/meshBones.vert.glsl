#version 450

in vec3 pos;
in vec3 normal;
in vec2 uv;
in vec4 weights;
in vec4 boneIndex;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
uniform mat4 bones[23];

//out vec3 norm;
out vec2 texCoord;

void kore() {

	vec4 newVertex;
    vec4 newNormal;
    int index;
    // --------------------
    index=int(boneIndex.x); // Cast to int
    newVertex = (bones[index] * vec4(pos, 1.0)) * weights.x;
    newNormal = (bones[index] * vec4(normal, 0.0)) * weights.x;
    index=int(boneIndex.y); //Cast to int
    newVertex = (bones[index] * vec4(pos, 1.0)) * weights.y + newVertex;
    newNormal = (bones[index] * vec4(normal, 0.0)) * weights.y + newNormal;
    index=int(boneIndex.z); //Cast to int
    newVertex = (bones[index] * vec4(pos, 1.0)) * weights.z + newVertex;
    newNormal = (bones[index] * vec4(normal, 0.0)) * weights.z + newNormal;
    index=int(boneIndex.w); //Cast to int
    newVertex = (bones[index] * vec4(pos, 1.0)) * weights.w + newVertex;
    newNormal = (bones[index] * vec4(normal, 0.0)) * weights.w + newNormal;
   // norm = vec3(model* view * newNormal);
    texCoord=uv;
	gl_Position = projection * view * model *  vec4(newVertex.xyz, 1.0);
	/////
   /* int index;
    vec4 newVertex;
    index=int(boneIndex.x); // Cast to int
    newVertex = (bones[index] * vec4(pos, 1.0)) * weights.x;
	norm = (model * vec4(normal, 0.0)).xyz;
	gl_Position = projection * view * model * vec4(pos, 1.0);*/
}
