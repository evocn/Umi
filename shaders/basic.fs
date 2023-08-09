#version 330 core
layout(location = 0) out vec4 FragColor;

uniform vec4 color;

uniform vec4 background;
uniform float transparency;

void main()
{
    FragColor = color;
    FragColor = mix(background, FragColor, transparency);
    FragColor.a = 1.0;
} 
