// Umi
// Spritesheet
// Alex Hartford
// June 2023

Spritesheet :: struct {
    texture : Texture = ---;
    columns, rows : int;
}

make_spritesheet :: (using spritesheet : *Spritesheet, full_path : string, tile_size := TILE_SIZE) -> success: bool {
    texture =, success := load_texture(full_path);
    columns = texture.width  / tile_size;
    rows    = texture.height / tile_size;

    return success;
}

draw_tile :: (index: int, square : Square, color := color_black, offset := Vector2.{0, 0}, horizontal_flip := false) {
    draw_spritesheet(rendering.spritesheet, index, square, color_override=color, offset=offset, horizontal_flip=horizontal_flip);
}

draw_ship :: (index: int, direction: Direction, square : Square, color := color_black) {
    if #complete direction == {
        case .NORTH;    
            draw_spritesheet(rendering.ship_spritesheet, index * 4, square, use_color_override=false, horizontal_flip=false, scale_multiplier=2.0);
        case .SOUTH;
            draw_spritesheet(rendering.ship_spritesheet, index * 4 + 1, square, use_color_override=false, horizontal_flip=false, scale_multiplier=2.0);
        case .EAST;
            draw_spritesheet(rendering.ship_spritesheet, index * 4 + 2, square, use_color_override=false, horizontal_flip=false, scale_multiplier=2.0);
        case .WEST;
            draw_spritesheet(rendering.ship_spritesheet, index * 4 + 2, square, use_color_override=false, horizontal_flip=true, scale_multiplier=2.0);
    }
}

draw_spritesheet :: (using sheet : Spritesheet, index: int, square : Square, 
                     offset := Vector2.{0, 0}, horizontal_flip := false, use_color_override := true, color_override := color_black, scale_multiplier := 1.0) {
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
    x_translation := square.col * (1.0 / VIEWPORT_WIDTH) + offset.x / PIXEL_WIDTH - (scale_multiplier - 1.0) * 0.5 / VIEWPORT_WIDTH;
    y_translation := (VIEWPORT_HEIGHT - square.row - 1) * (1.0 / (VIEWPORT_HEIGHT + 1)) + offset.y / PIXEL_WIDTH - (scale_multiplier - 1.0) * 0.5 / VIEWPORT_HEIGHT;
    translation_vector := Vector3.{x_translation, y_translation, 0};

    x_scale := 1.0 / VIEWPORT_WIDTH * scale_multiplier;
    y_scale := 1.0 / (VIEWPORT_HEIGHT + 1) * scale_multiplier;
    scale_vector := Vector3.{x_scale, y_scale, 1};

    translate(*model, translation_vector);
    scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    set_vec4(shader, "color_override", color_override);
    set_bool(shader, "horizontal_flip", horizontal_flip);
    set_bool(shader, "use_color_override", use_color_override);

    draw_quad(rendering.quad);
}
