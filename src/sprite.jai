// Umi
// Sprite
// Alex Hartford
// July 2023


Sprite :: struct {
    texture : Texture = ---;
}

make_sprite :: (using sprite : *Sprite, filename : string, tiled := true) -> success: bool {
    texture =, success := load_texture(filename);
    return success;
}

draw_sprite :: (using sprite : Sprite, x_offset := 0, y_offset := 0, right := false, use_color_override := true, color_override := color_fg) {
    bind(sprite.texture, 0);
    shader := rendering.sprite_shader;

    model := Matrix4_Identity;

    if right {
        translation_vector := Vector3.{cast(float)(PIXEL_WIDTH - texture.width) / PIXEL_WIDTH + cast(float)x_offset / PIXEL_WIDTH, cast(float)(y_offset) / PIXEL_HEIGHT, 0};
        translate(*model, translation_vector);
    }
    else {
        translation_vector := Vector3.{-cast(float)x_offset / PIXEL_WIDTH, cast(float)(y_offset) / PIXEL_HEIGHT, 0};
        translate(*model, translation_vector);
    }

    scale_vector := Vector3.{cast(float)texture.width / PIXEL_WIDTH, cast(float)texture.height / PIXEL_HEIGHT, 1};
    scale(*model, scale_vector);

    set_mat4(shader, "model", model);

    set_vec4(shader, "color_override", color_override);
    set_bool(shader, "horizontal_flip", right);
    set_bool(shader, "use_actual_color", use_color_override);

    draw_quad(rendering.quad);
}