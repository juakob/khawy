#version 450

uniform sampler2D tex;
uniform mat4 colorMatrix;
uniform vec4 colorOffset;

in vec2 texCoord;
out vec4 fragColor;

void main() {
    vec4 color = texture(tex, texCoord);
    fragColor = colorMatrix * color + colorOffset;
    fragColor = clamp(fragColor, 0.0, 1.0);
    fragColor.rgb *= color.a;
}
