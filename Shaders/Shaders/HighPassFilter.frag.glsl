#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform vec3 brightIndex;
uniform vec3 darkColor;
uniform vec3 tintColor;
uniform float tolerance;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
    vec4 color = texture( tex, texCoord );
    // check whether fragment output is higher than threshold, if so output as brightness color
    float brightness = dot(color.rgb, brightIndex);
    if(brightness > tolerance)
        FragColor = vec4(color.rgb, 1.0);
    else
        FragColor = vec4(darkColor.rgb, 1.0);
    
    FragColor*= vec4(tintColor.rgb, 1.0);
}
