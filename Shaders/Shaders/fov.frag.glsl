#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform sampler2D gbufferD;
in vec2 texCoord;
out vec4 FragColor;



// DoF with bokeh GLSL shader by Martins Upitis (martinsh) (devlog-martinsh.blogspot.com)
// Creative Commons Attribution 3.0 Unported License


 const float compoDOFDistance = 0.2; // Focal distance value in meters
 const float compoDOFLength = 250.0; // Focal length in mm 18-200
 const float compoDOFFstop = 15.0; // F-stop value


const int samples = 2; // Samples on the first ring
const int rings = 2; // Ring count
const vec2 focus = vec2(0.5, 0.4);
const float coc = 0.11; // Circle of confusion size in mm (35mm film = 0.03mm)
const float maxblur = 1.0;
const float threshold = 0.5; // Highlight threshold
const float gain = 2.0; // Highlight gain
const float bias = 0.5; // Bokeh edge bias
const float fringe = 0.7; // Bokeh chromatic aberration/fringing
const float namount = 0.0001; // Dither amount
const float PI = 3.1415926535;
const float PI2 = PI * 2.0;

vec2 rand2(const vec2 coord) {
	const float width = 1100;
	const float height = 500;
	float noiseX = ((fract(1.0 - coord.s * (width / 2.0)) * 0.25) + (fract(coord.t * (height / 2.0)) * 0.75)) * 2.0 - 1.0;
	float noiseY = ((fract(1.0 - coord.s * (width / 2.0)) * 0.75) + (fract(coord.t * (height / 2.0)) * 0.25)) * 2.0 - 1.0;	
	return vec2(noiseX, noiseY);
}
vec3 color(vec2 coords, const float blur, const sampler2D tex, const vec2 texStep) {
	vec3 col = vec3(0.0);
	col.r = texture(tex, coords + vec2(0.0, 1.0) * texStep * fringe * blur).r;
	col.g = texture(tex, coords + vec2(-0.866, -0.5) * texStep * fringe * blur).g;
	col.b = texture(tex, coords + vec2(0.866, -0.5) * texStep * fringe * blur).b;
	
	const vec3 lumcoeff = vec3(0.299, 0.587, 0.114);
	float lum = dot(col.rgb, lumcoeff);
	float thresh = max((lum - threshold) * gain, 0.0);
	return col + mix(vec3(0.0), col, thresh * blur);
}
float linearize(const float depth, vec2 cameraProj) {
	// to viewz
	return cameraProj.y / (depth - cameraProj.x);
}

vec3 dof(const vec2 texCoord, const float gdepth, const sampler2D tex, const sampler2D gbufferD, const vec2 texStep, const vec2 cameraProj) {
	float depth = linearize(gdepth, cameraProj);
	// const float fDepth = linearize(compoDOFDistance,;
	float fDepth = linearize(texture(gbufferD, focus).r * 2.0 - 1.0, cameraProj); // Autofocus
	
	const float f = compoDOFLength; // Focal length in mm
	const float d = fDepth * 1000.0; // Focal plane in mm
	float o = depth * 1000.0; // Depth in mm
	float a = (o * f) / (o - f); 
	float b = (d * f) / (d - f); 
	float c = (d - f) / (d * compoDOFFstop * coc); 
	float blur = abs(a - b) * c;
	blur = clamp(blur, 0.0, 1.0);
	
	vec2 noise = rand2(texCoord) * namount * blur;
	float w = (texStep.x) * blur * maxblur + noise.x;
	float h = (texStep.y) * blur * maxblur + noise.y;
	vec3 col = vec3(0.0);
	if (blur < 0.05) {
		col = texture(tex, texCoord).rgb;
	}
	else {
		col = texture(tex, texCoord).rgb;
		float s = 1.0;
		int ringsamples;
		
		for (int i = 1; i <= rings; ++i) {   
			ringsamples = i * samples;
			for (int j = 0 ; j < ringsamples; ++j) {
				float step = PI2 / float(ringsamples);
				float pw = (cos(float(j) * step) * float(i));
				float ph = (sin(float(j) * step) * float(i));
				float p = 1.0;
				// if (pentagon) p = penta(vec2(pw, ph));
				col += color(texCoord + vec2(pw * w, ph * h), blur, tex, texStep) * mix(1.0, (float(i)) / (float(rings)), bias) * p;  
				s += 1.0 * mix(1.0, (float(i)) / (float(rings)), bias) * p;  
			}
		}
		col /= s;
	}
	return col;
}


void kore() {
    float depth = texture(gbufferD, texCoord).r;
	vec4 col=vec4(dof(texCoord,depth,tex,gbufferD,vec2(0.01,0.01),vec2(0.2,0.25)).xyz,1);

	FragColor = col;
}