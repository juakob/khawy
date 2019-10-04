#version 450
precision mediump float;
 
uniform sampler2D tex;
 
in vec2 v_texCoord;
in vec2 v_blurCoord0;
in vec2 v_blurCoord1;
in vec2 v_blurCoord2;
in vec2 v_blurCoord3;
in vec2 v_blurCoord4;
in vec2 v_blurCoord5;
out vec4 color;
 
void main()
{
	
    vec4 texcolor = texture(tex, v_blurCoord2);
	color=texcolor;
   
}
