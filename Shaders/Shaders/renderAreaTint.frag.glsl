#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec4 texcolor = texture(tex, texCoord) ;
	vec4 col=vec4(texcolor.x+0.1,texcolor.y,texcolor.z,texcolor.w+0.1);

	FragColor = col;
}
