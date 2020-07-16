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
	float alpha3=abs(alpha1-base.a);
    float alpha1_ = texture( tex, texCoord + vec2(0,-stepSize.y)).a;
	alpha1=abs(alpha1-alpha1_);
	float alpha5=abs(alpha1_-base.a);
	float alpha2 = texture( tex, texCoord + vec2(stepSize.x,0)).a;
	float alpha4=abs(alpha2-base.a);
    float alpha2_ = texture( tex, texCoord + vec2(-stepSize.x,0)).a;
	alpha2=abs(alpha2-alpha2_);
	float alpha6=abs(alpha2_-base.a);
	
	
	float alpha=clamp(alpha1+alpha2+alpha3+alpha4+alpha5+alpha6,0,1);
	//float inverse=1-alpha;
    	// calculate resulting color
		FragColor = vec4( base.rgb+color*alpha, base.a+alpha);
    //	FragColor = vec4( base.rgb*inverse+color*(alpha*base.a), base.a*inverse+(alpha*base.a));
    
}
