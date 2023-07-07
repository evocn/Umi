// Tactics
// Spritesheet
// Alex Hartford
// June 2023

SCREEN_TILES_COLUMNS :: 16;
SCREEN_TILES_ROWS    :: 9;

TILE_SIZE :: 16;
// in pixels

Spritesheet :: struct {
    texture : Texture = ---;
    columns, rows : int;
}

make_spritesheet :: (using spritesheet : *Spritesheet, filename : string) -> success: bool {

    texture =, success := load_texture(filename);
    columns = texture.width  / TILE_SIZE;
    rows    = texture.height / TILE_SIZE;

    return success;
}

draw_sprite :: (shader: Shader, using spritesheet : Spritesheet, index: int, square : Square, color := white) {
    assert(index >= 0 && index < columns * rows);

    col := index % columns;
    row := index / columns;

    spritesheet_offset := Vector2.{col / cast(float)columns, row / cast(float)rows};
    set_vec2(shader, "spritesheet_offset", spritesheet_offset);

    relative_sheet_scale := Vector2.{1.0 / columns, 1.0 / rows};
    set_vec2(shader, "relative_sheet_scale", relative_sheet_scale);

    model := Matrix4_Identity;
    translate(*model, Vector3.{square.col * (1.0 / SCREEN_TILES_COLUMNS), (map_height - square.row - 1) * (1.0 / SCREEN_TILES_ROWS), 1});
    scale(*model, Vector3.{1.0 / SCREEN_TILES_COLUMNS, 1.0 / SCREEN_TILES_ROWS, 1});
    set_mat4(shader, "model", model);

    set_vec4(shader, "color_override", color);

    draw_quad();
}

