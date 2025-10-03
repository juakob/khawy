#version 450

uniform sampler2D tex;
uniform vec2 dirInv; // (blurX / texWidth, 0) o (0, blurY / texHeight)

in vec2 texCoord;
out vec4 fragColor;

void main() {
    // Kernel gaussiano 9 samples (sigma ~ 3.0)
    float weights[9] = float[](
        0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216,
        0.016216, 0.054054, 0.1216216, 0.1945946
    );

    vec2 offsets[9] = vec2[](
        vec2(0.0, 0.0),
        dirInv * 1.0,
        -dirInv * 1.0,
        dirInv * 2.0,
        -dirInv * 2.0,
        dirInv * 3.0,
        -dirInv * 3.0,
        dirInv * 4.0,
        -dirInv * 4.0
    );

    vec4 sum = vec4(0.0);
    for (int i = 0; i < 9; i++) {
        sum += texture(tex, texCoord + offsets[i]) * weights[i];
    }

    fragColor = sum;
}
