#version 330 core
out vec4 FragColor;

in vec2 texture_coordinates;

uniform sampler2D text;
uniform vec4 color;

uniform vec4 background;
uniform float transparency;

void main()
{    
    vec4 sampled = vec4(1.0, 1.0, 1.0, texture(text, texture_coordinates).r);
    FragColor = color * sampled;

    if (FragColor.a < 0.01) discard;
    FragColor = mix(background, FragColor, transparency);
    FragColor.a = 1.0;
}  
