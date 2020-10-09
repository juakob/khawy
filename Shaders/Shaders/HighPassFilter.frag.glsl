#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
in vec2 texCoord;
out vec4 FragColor;

void kore() {
    vec4 color = texture( tex, texCoord );
    // check whether fragment output is higher than threshold, if so output as brightness color
    float brightness = dot(color.rgb, vec3(1, 0.7152, 0.0));
    if(brightness > 0.8)
        FragColor = vec4(color.rgb, 1.0);
    else
        FragColor = vec4(0.0, 0.0, 0.1, 1.0);
    
    FragColor*= vec4(0.2, 0.3, 0.7, 1.0);
}
