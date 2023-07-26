// Tactics
// Render
// Alex Hartford
// June 2023

render :: (map : Map, transparency := 1.0)
{
    use_tile_shader(transparency);

    // Draw Game Board
    {
        for col: (viewport.corner.col)..(viewport.corner.col + VIEWPORT_WIDTH - 1) {
            for tile, row: map.tiles[col] {
                tile_index := tile.sprite_index;
                draw_tile(tile_index, .{col, row} - viewport.corner);
            }
        }

        // Draw Overlays
        overlay_color := color_4;
        if cursor.selected {
            targeting_ability := cursor.selected.primary;
            if cursor.state == .TARGETING_SECONDARY {
                targeting_ability = cursor.selected.secondary;
            }

            if targeting_ability.targeting == {
                case .ALLY;     overlay_color = color_1;
                case .ENEMY;    overlay_color = color_2;
            }
        }
        draw_squares_overlay(cursor.interactible, color = overlay_color);
        draw_squares_overlay(cursor.accessible);

        if cursor.path {
            draw_path(cursor.path, color = color_3);
        }

        // Draw Units
        for map.units {
            draw_unit(it);
        }

        // Draw Cursor
        cursor_color := color_fg;
        if whose_turn() == .YOU then cursor_color = color_1;
        else cursor_color = color_2;

        if get_occupant(map, cursor.square) then cursor_color = color_4;

        draw_tile(49 * 12 + 35, cursor.square - viewport.corner, cursor_color);

        // Editor Cursor
        if program_mode == .EDITOR {
            draw_tile(49 * 12 + 37, editor.cursor, color_4);
        }
    }
}

render_ui :: (map: Map, transparency := 1.0) {
    draw_ability_ui :: (using ability : Ability, square: Square, num_square: Square, color := color_bg) {
        draw_tile(sprite_index, square, color);

        if damage > 0 {
            draw_die_number(damage, num_square, color_2);
        }
        else if damage < 0 {
            draw_die_number(damage, num_square, color_4);
        }
    }

    // Draw UI Elements
    use_tile_shader(transparency);

    for 0..VIEWPORT_WIDTH-1 {
        draw_background(.{it, -1}, color_3);
    }

    if roll_time != 0.0 {
        draw_die_number(roll_result, .{0, -1}, color_bg);
    }

    ui_unit := get_occupant(map, cursor.square);
    if ui_unit == null && cursor.selected
        ui_unit = cursor.selected;

    if ui_unit {
        {
            shader := use_text_shader(transparency);
            draw_text(shader, main_font, ui_unit.name, .{11, 0}, color_bg);
        }
    }
    use_tile_shader(transparency);

    if cursor.inspecting {
        for col: 0..VIEWPORT_WIDTH / 2 - 1 {
            for row: -1..VIEWPORT_HEIGHT {
                draw_background(.{col, row}, color_3);
            }
        }

        using cursor.inspecting;

        // health
        draw_tile(532, .{1, 0}, color_bg);
        draw_number(health, .{2, 0}, color_1);

        // armor
        draw_tile(33, .{1, 1}, color_bg);
        draw_number(armor, .{2, 1}, color_1);

        // movement
        if moved {
            draw_tile(1048, .{1, 2}, color_fg);
            draw_number(movement, .{2, 2}, color_1);
        }
        else {
            draw_tile(1048, .{1, 2}, color_bg);
            draw_number(movement, .{2, 2}, color_1);
        }

        // direction
        if turned {
            draw_direction(direction, .{1, 3}, color_fg);
        }
        else {
            draw_direction(direction, .{1, 3}, color_bg);
        }

        color := color_bg;
        if exhausted
            color = color_fg;
        if primary_active {
            draw_ability_ui(primary, .{1, 5}, .{2, 5}, color);
        }
        if secondary_active {
            draw_ability_ui(secondary, .{1, 6}, .{2, 6}, color);
        }

        {
            shader := use_text_shader(transparency);

            draw_text(shader, main_font, description, .{0, 0}, color_1);

            draw_text(shader, main_font, "health", .{3, 1}, color_1);
            draw_text(shader, main_font, "armor",  .{3, 2}, color_1);
            draw_text(shader, main_font, "movement", .{3, 3}, color_1);
            draw_text(shader, main_font, "facing", .{3, 4}, color_1);

            if primary_active {
                text_color := color_1; if primary.damage > 0 then text_color = color_2;

                draw_text(shader, main_font, tprint("% - %", primary.min_range, primary.max_range), .{0, 6}, text_color);
                draw_text(shader, main_font, "rng.", .{0, 6}, text_color, second=true);

                draw_text(shader, main_font, primary.name, .{3, 6}, text_color);
                draw_text(shader, main_font, summarize_ability(primary), .{3, 6}, color_bg, second=true);
            }
            if secondary_active {
                text_color := color_1; if secondary.damage > 0 then text_color = color_2;

                draw_text(shader, main_font, tprint("% - %", secondary.min_range, secondary.max_range), .{0, 7}, text_color);
                draw_text(shader, main_font, "rng.", .{0, 7}, text_color, second=true);

                draw_text(shader, main_font, secondary.name, .{3, 7}, text_color);
                draw_text(shader, main_font, summarize_ability(secondary), .{3, 7}, color_bg, second=true);
            }

            draw_text(shader, main_font, summarize_unit_flags(flags), .{0, 8}, color_1);
        }
    }
    else if ui_unit {
        using ui_unit;

        // health
        draw_tile(532, .{1, -1}, color_bg);
        draw_number(health, .{1, -1}, color_1);

        // armor
        draw_tile(33, .{2, -1}, color_bg);
        draw_number(armor, .{2, -1}, color_1);

        // movement
        if moved {
            draw_tile(1048, .{3, -1}, color_fg);
            draw_number(movement, .{3, -1}, color_1);
        }
        else {
            draw_tile(1048, .{3, -1}, color_bg);
            draw_number(movement, .{3, -1}, color_1);
        }

        if turned {
            draw_direction(direction, .{4, -1}, color_fg);
        }
        else {
            draw_direction(direction, .{4, -1}, color_bg);
        }

        color := color_bg;
        if exhausted
            color = color_fg;
        if primary_active {
            draw_ability_ui(primary, .{6, -1}, .{7, -1}, color);
        }
        if secondary_active {
            draw_ability_ui(secondary, .{9, -1}, .{10, -1}, color);
        }

        ti := type_info(Unit_Flags);
        for ti.values {

        }

        for effects {
            if #complete it.kind == {
                case .NONE;
                case .DEFEND;   draw_number(armor, .{2, -1}, color_4);
                case .PIERCE;   draw_number(armor, .{2, -1}, color_2);
                case .QUICKEN;  draw_number(movement, .{3, -1}, color_4);
                case .SLOW;     draw_number(movement, .{3, -1}, color_2);

                case .EMPOWER;
                    if primary.damage > 0   draw_die_number(primary.damage, .{6, -1}, color_4);
                    if secondary.damage > 0 draw_die_number(primary.damage, .{9, -1}, color_4);
                case .WEAKEN;
                    if primary.damage > 0   draw_die_number(primary.damage, .{6, -1}, color_2);
                    if secondary.damage > 0 draw_die_number(primary.damage, .{9, -1}, color_2);

                case .PARALYZE;
            }
            // @TODO: DRAW EFFECT INDICATORS ON THE UI!!!
        }
    }
}

render_dialogue :: (transparency := 1.0) {
    use_sprite_shader(transparency);
    draw_sprite(rendering.uncle, right=true);
}

// Renders the given framebuffer as a texture on a screen-space quad.
render_framebuffer_to_screen :: () {
    shader := rendering.quad_shader;
    use_shader(shader);
    defer disable_shaders();

    model := Matrix4_Identity;

    translation_vector := Vector3.{-1, -1, 1};
    translate(*model, translation_vector);

    scale_vector := Vector3.{2, 2, 1};
    scale(*model, scale_vector);

    set_mat4(shader, "model", model);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, render_texture);
    draw_quad(rendering.quad);
}

//
//

draw_unit :: (using unit : Unit) {
    /*
    if whose_turn() == team {
        if !moved {
            draw_tile(1072, square - viewport.corner, color_3);
        }
        if !exhausted {
            draw_tile(1071, square - viewport.corner, color_3);
        }
    }
    */

    color := team_color(team);

    draw_ship(sprite_index, direction, square - viewport.corner, color);

    /*
    if cursor.state == .TARGETING_PRIMARY || cursor.state == .TARGETING_SECONDARY {
        draw_number(health, square, color_3);
    }
    */
}

draw_squares_overlay :: (squares : [..] Square, color := color_fg) {
    for squares {
        draw_square_overlay(it, color);
    }
}

draw_square_overlay :: (square : Square, color : Color) {
    draw_tile(49 * 13 + 41, square - viewport.corner, color);
}

draw_path :: (path: Path, color : Color) {
    for path {
        draw_square_overlay(it, color);
    }
}

draw_background :: (square: Square, color := color_fg) {
    draw_tile(1076, square, color);
}

draw_number :: (number: int, square: Square, color := color_fg) {
    get_number_sprite_index :: (i: int) -> int {
        return abs(i) + 868;
    }

    draw_tile(get_number_sprite_index(number), square, color);
}

draw_die_number :: (number: int, square: Square, color := color_fg) {
    get_die_number_sprite_index :: (i: int) -> int {
        return abs(i) + 776;
    }

    draw_tile(get_die_number_sprite_index(number), square, color);
}

draw_direction :: (direction: Direction, square: Square, color := color_fg) {
    get_direction_sprite_index :: (d: Direction) -> int {
        if #complete d == {
            case .NORTH; return 1057;
            case .EAST;  return 1058;
            case .SOUTH; return 1059;
            case .WEST;  return 1060;
        }
    }

    draw_tile(get_direction_sprite_index(direction), square, color);
}

//
// Menu
//

render_menu :: (using menu: Menu, transparency := 1.0) {
    {
        use_tile_shader(transparency);

        for col: 0..VIEWPORT_WIDTH / 2 - 1 {
            for row: -1..VIEWPORT_HEIGHT {
                draw_background(.{col, row}, color_3);
            }
        }

        for elements {
            draw_menu_element(it, it_index + 1, color_fg, color_bg);
        }

        // Draw selected element over it.
        draw_menu_element(elements[element_index], element_index + 1, color_bg, color_fg);
    }
}

//
// Game Over
//

render_game_over :: (transparency := 1.0) {
    {
        use_tile_shader(transparency);

        for col: VIEWPORT_WIDTH / 3..VIEWPORT_WIDTH - VIEWPORT_WIDTH / 3 - 1 {
            for row: -1..VIEWPORT_HEIGHT {
                draw_background(.{col, row}, color_3);
            }
        }
    }

    {
        shader := use_text_shader(transparency);

        draw_text_centered(shader, main_font, "game over", xx (PIXEL_HEIGHT / 2.0), color_bg);
        draw_text_centered(shader, main_font, "retry?", xx (PIXEL_HEIGHT / 2.0 - main_font.height), color_1);
    }
}

//
// Debug Overlays
//

draw_numbers_on_map :: () {
    using debug.traversed;

    for col: field {
        for col {
            draw_number(it.distance, it.square, color_3);
        }
    }
}

//
// Shader nonsense
//

use_tile_shader :: (transparency : float) -> Shader {
    shader := rendering.shader;
    use_shader(shader);

    orthographic := orthographic_projection_matrix(0, 1, 0, 1, -1, 1);
    set_mat4(shader, "projection", orthographic);

    set_float(shader, "transparency", transparency);
    set_vec4(shader, "background", color_bg);

    return shader;
}

use_text_shader :: (transparency : float) -> Shader {
    shader := rendering.text_shader;
    use_shader(shader);

    orthographic := orthographic_projection_matrix(0, xx PIXEL_WIDTH, 0, xx PIXEL_HEIGHT, -1, 1);
    set_mat4(shader, "projection", orthographic);

    set_float(shader, "transparency", transparency);
    set_vec4(shader, "background", color_bg);

    return shader;
}

use_sprite_shader :: (transparency : float) -> Shader {
    shader := rendering.sprite_shader;
    use_shader(shader);

    orthographic := orthographic_projection_matrix(0, 1, 0, 1, -1, 1);
    set_mat4(shader, "projection", orthographic);

    set_float(shader, "transparency", transparency);
    set_vec4(shader, "background", color_bg);

    return shader;
}
