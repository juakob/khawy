#version 450


uniform float time;
const float A = 0.009;
const float B = 200.0;
const float C = 100.0;

const float D = 0.009;
const float E = 13.0;
const float F = 100.0;


uniform sampler2D tex;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	FragColor =  texture(tex, texCoord);
	FragColor.a = 1.0; //Best to make sure nothing seems transparent
	float x =  A * texCoord.x * sin(C * time);
	float y =  D * texCoord.y * cos(F * time);
	vec2 c = vec2(texCoord.x + x, texCoord.y +y);
	vec4 diffuse_color =  texture(tex, c);
	FragColor = diffuse_color;
}
