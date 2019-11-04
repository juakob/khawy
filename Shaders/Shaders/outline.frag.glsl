#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform vec3 color;
uniform vec2 stepSize;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
	vec4 base= texture( tex, texCoord);
	float alpha1 = texture( tex, texCoord + vec2(0,stepSize.y)).a;
    	alpha1 -= texture( tex, texCoord + vec2(0,-stepSize.y)).a;
	alpha1=abs(alpha1);
	float alpha2 = texture( tex, texCoord + vec2(stepSize.x,0)).a;
    	alpha2 -= texture( tex, texCoord + vec2(-stepSize.x,0)).a;
	alpha2=abs(alpha2);
	float alpha=clamp(alpha1+alpha2,0,1);
	//float inverse=1-alpha;
    	// calculate resulting color
		FragColor = vec4( base.rgb+color*alpha, base.a+alpha);
    //	FragColor = vec4( base.rgb*inverse+color*(alpha*base.a), base.a*inverse+(alpha*base.a));
    
}
