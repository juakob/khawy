#version 450

uniform sampler2D tex;
in vec2 texCoord;
out vec4 color;

void main()
{
    vec4 col;
    vec4 bright4;
    float bright;
    
    col = texture( tex, texCoord);
    col -=1.00000;
    bright4 = -6.00000 * col * col + 2.00000;
    bright = dot( bright4, vec4( 0.333333, 0.333333, 0.333333, 0.000000) );
    col += (bright + 0.600000);
	
    color= col;
}