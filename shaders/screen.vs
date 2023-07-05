#version 330 core
layout (location = 0) in vec3 VertexPosition;

uniform mat4 projection;
uniform mat4 model;

out vec2 texture_coordinates;

void main()
{
    texture_coordinates = VertexPosition.xy;
    gl_Position = projection * model * vec4(VertexPosition, 1.0);
}
