// Umi
// Primitives
// Alex Hartford
// June 2023

// Quad
//

Quad :: struct {
    points := float.[0, 0, 0,
                     0, 1, 0,
                     1, 1, 0,
                     1, 0, 0];
    indices:= u32.[0, 1, 2,
                   0, 2, 3];
    vao, vbo, ibo : GLuint;
}

init_quad_rendering_objects :: (using quad : *Quad) {
	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);
	glGenBuffers(1, *ibo);

	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBufferData(GL_ARRAY_BUFFER, size_of(float) * points.count, points.data, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
	defer glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * indices.count, indices.data, GL_STATIC_DRAW);

	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), cast(*void)0);
	glEnableVertexAttribArray(0);
}

draw_quad :: (using quad: Quad) {
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}

// Lines
//

// @NOTE: These lines cannot add more members after being initialized.
// We should create a more robust solution.
Line :: struct {
    points: [..] Vector3;
    vao, vbo : GLuint;
}

init_line_rendering_objects :: (using line: *Line)
{
    glGenVertexArrays(1, *vao);
    glGenBuffers(1, *vbo);

    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, points.count * size_of(Vector3), *points[0], GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), cast(*void)0);
}

draw_line :: (using line: Line, color: Vector4 = Vector4.{1.0, 1.0, 1.0, 1.0})
{
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferSubData(GL_ARRAY_BUFFER, 0, size_of(Vector3) * points.count, points.data);
	glDrawArrays(GL_LINE_STRIP, 0, xx points.count);
}

draw_points :: (using line: Line, color: Vector4 = Vector4.{1.0, 1.0, 1.0, 1.0})
{
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferSubData(GL_ARRAY_BUFFER, 0, size_of(Vector3) * points.count, points.data);
	glDrawArrays(GL_POINTS, 0, xx points.count);
}
