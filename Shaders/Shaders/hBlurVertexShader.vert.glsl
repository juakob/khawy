#version 450

in vec3 vertexPosition;
in vec2 texPosition;

 
out vec2 v_texCoord;
out vec2 v_blurCoord0;
out vec2 v_blurCoord1;
out vec2 v_blurCoord2;
out vec2 v_blurCoord3;
out vec2 v_blurCoord4;
out vec2 v_blurCoord5;



uniform mat4 projectionMatrix;
uniform vec2 resolution;
 
void main()
{
    gl_Position =  projectionMatrix*vec4(vertexPosition.xyz, 1.0) ;
	v_texCoord = texPosition.xy;
    v_blurCoord0 = texPosition.xy+ vec2(-3.0,-3.0)*resolution;
	v_blurCoord1 = texPosition.xy+ vec2(-2.0,-2.0)*resolution;
    v_blurCoord2 = texPosition.xy+ vec2(-1.0,-1.0)*resolution;
    v_blurCoord3 = texPosition.xy+ vec2(1.0,1.0)*resolution;
	v_blurCoord4 = texPosition.xy+ vec2(2.0, 2.0)*resolution;
	v_blurCoord5 = texPosition.xy+ vec2(3.0, 3.0)*resolution;


}