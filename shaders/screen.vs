#version 330 core
layout (location = 0) in vec3 VertexPosition;

uniform mat4 projection;
uniform mat4 model;

uniform vec2 spritesheet_offset;
uniform vec2 relative_sheet_scale;

out vec2 texture_coordinates;

void main()
{
    vec2 uv = VertexPosition.xy;
    uv.y = 1.0 - uv.y;
    texture_coordinates = spritesheet_offset + uv * relative_sheet_scale;
    gl_Position = projection * model * vec4(VertexPosition, 1.0);
}
