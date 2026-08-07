#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
uniform vec2 dirInv; // (blurX / texWidth, 0) o (0, blurY / texHeight)

in vec2 texCoord;
out vec4 fragColor;

void main() {
    // Explicit taps avoid GLSL ES array constructors on strict mobile drivers.
    vec4 sum = texture(tex, texCoord) * 0.227027;
    sum += texture(tex, texCoord + dirInv * 1.0) * 0.1945946;
    sum += texture(tex, texCoord - dirInv * 1.0) * 0.1216216;
    sum += texture(tex, texCoord + dirInv * 2.0) * 0.054054;
    sum += texture(tex, texCoord - dirInv * 2.0) * 0.016216;
    sum += texture(tex, texCoord + dirInv * 3.0) * 0.016216;
    sum += texture(tex, texCoord - dirInv * 3.0) * 0.054054;
    sum += texture(tex, texCoord + dirInv * 4.0) * 0.1216216;
    sum += texture(tex, texCoord - dirInv * 4.0) * 0.1945946;

    fragColor = sum;
}
