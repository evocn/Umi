// Tactics
// Spritesheet
// Alex Hartford
// June 2023

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

draw_tile :: (index: int, square : Square, color := color_fg, horizontal_flip := false) {
    draw_spritesheet(rendering.spritesheet, index, square, color_override=color, horizontal_flip=horizontal_flip);
}

draw_ship :: (index: int, direction: Direction, square : Square, color := color_fg) {
    if #complete direction == {
        case .NORTH;    
            draw_spritesheet(rendering.ship_spritesheet, index * 4, square, color_override=color, horizontal_flip=false);
        case .SOUTH;
            draw_spritesheet(rendering.ship_spritesheet, index * 4 + 1, square, color_override=color, horizontal_flip=false);
        case .EAST;
            draw_spritesheet(rendering.ship_spritesheet, index * 4 + 2, square, color_override=color, horizontal_flip=false);
        case .WEST;
            draw_spritesheet(rendering.ship_spritesheet, index * 4 + 2, square, color_override=color, horizontal_flip=true);
    }
}

draw_spritesheet :: (using sheet : Spritesheet, index: int, square : Square, horizontal_flip := false, use_color_override := true, color_override := color_fg) {
    bind(sheet.texture, 0);
    shader := rendering.shader;

    assert(index >= 0 && index < columns * rows);

    col := index % columns;
    row := index / columns;

    spritesheet_offset := Vector2.{col / cast(float)columns, row / cast(float)rows};
    set_vec2(shader, "spritesheet_offset", spritesheet_offset);

    relative_sheet_scale := Vector2.{1.0 / columns, 1.0 / rows};
    set_vec2(shader, "relative_sheet_scale", relative_sheet_scale);

    model := Matrix4_Identity;
    translation_vector := Vector3.{square.col * (1.0 / VIEWPORT_WIDTH), (VIEWPORT_HEIGHT - square.row - 1) * (1.0 / (VIEWPORT_HEIGHT + 1)), 1};
    scale_vector := Vector3.{1.0 / VIEWPORT_WIDTH, 1.0 / (VIEWPORT_HEIGHT + 1), 1};

    translate(*model, translation_vector);
    scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    set_vec4(shader, "color_override", color_override);
    set_bool(shader, "horizontal_flip", horizontal_flip);
    set_bool(shader, "use_color_override", use_color_override);

    draw_quad(rendering.quad);
}
