#version 330 core
out vec4 FragColor;

in vec2 texture_coordinates;

uniform sampler2D texture_to_sample;

void main()
{
    FragColor = texture(texture_to_sample, texture_coordinates);
} 
