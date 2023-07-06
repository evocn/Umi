#version 330 core
out vec4 FragColor;

in vec2 texture_coordinates;

uniform vec4 color_override;
uniform sampler2D texture_to_sample;

void main()
{
    FragColor = vec4(color_override.xyz, texture(texture_to_sample, texture_coordinates).a);
    if (FragColor.a < 0.01) discard;
}
