#version 450

#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D tex;
uniform float brightness;
in vec2 texCoord;
out vec4 color;

void main()
{
    vec4 col = texture( tex, texCoord);
    col.rgb*=brightness;
    color= col;
}