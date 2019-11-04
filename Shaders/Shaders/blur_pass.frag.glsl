
#version 450

uniform sampler2D tex;

uniform vec2 dirInv;

in vec2 texCoord;
out vec4 fragColor;

void main() {	
	fragColor = texture(tex, texCoord + (dirInv * 5.5));
	fragColor += texture(tex, texCoord + (dirInv * 4.5));
	fragColor += texture(tex, texCoord + (dirInv * 3.5));
	fragColor += texture(tex, texCoord + (dirInv * 2.5));
	fragColor += texture(tex, texCoord + dirInv * 1.5);
	fragColor += texture(tex, texCoord);
	fragColor += texture(tex, texCoord - dirInv * 1.5);
	fragColor += texture(tex, texCoord - (dirInv * 2.5));
	fragColor += texture(tex, texCoord - (dirInv * 3.5));
	fragColor += texture(tex, texCoord - (dirInv * 4.5));
	fragColor += texture(tex, texCoord - (dirInv * 5.5));
	fragColor.rgba /= 11;
	//fragColor.rgb *= fragColor.a;
}