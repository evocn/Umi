// Umi
// Render
// Alex Hartford
// June 2023

render :: (map: Map, dialogue: Dialogue) {
    {
        // Render all this to the framebuffer.
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(color_bg.x, color_bg.y, color_bg.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_mode == {
            case .GAME;
                render_map(map);
                render_ui(map);

            case .START;
                render_start_screen();
                render_start_menu(start_menu);

            case .EDITOR;
                render_map(map);
                render_ui(map);

            case .CUTSCENE;
                render_cutscene(dialogue);

            case .DIALOGUE;
                render_map(map, transparency = 0.3);
                render_dialogue(dialogue);

            case .MENU;
                if prior_program_mode == {
                    case .GAME;
                        render_map(map, transparency = 0.3);
                        render_ui(map, transparency = 0.3);

                    case .DIALOGUE;
                        render_map(map, transparency = 0.3);
                        render_ui(map, transparency = 0.3);
                        render_dialogue(dialogue, transparency = 0.3);

                    case .CUTSCENE;
                        render_cutscene(dialogue, transparency = 0.3);
                }
                render_menu(menu);

            case .GAME_OVER;
                render_map(map, transparency = 0.3);
                render_ui(map, transparency = 0.3);
                render_game_over();

            case .CREDITS;
                render_credits();
        }

        render_slice();
        render_fade();
    }

    {
        // Render the framebuffer to the screen.
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glViewport(0, 0, xx window_width, xx window_height);
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);

        render_framebuffer_to_screen();
    }
}

//
//
//

render_slice :: (transparency := 1.0) {
    if !screen_slice.active then return;

    use_tile_shader(transparency);
    for col: 0..VIEWPORT_WIDTH {
        for row: -1..VIEWPORT_HEIGHT {
            draw_background(.{col, row}, color_2);
        }
    }

    picture_name := get_slice_picture_name();

    picture := table_find_pointer(*rendering.slices, picture_name);
    if !picture {
        log_error("Unable to find this slice picture: %\n", picture_name);
        return;
    }

    use_sprite_shader(transparency);
    draw_sprite(picture.*, y_offset = PIXEL_HEIGHT / 4);

    {
        using screen_slice.result;
        using screen_slice.display;

        if user {
            use_sprite_shader(transparency);
            if user.captain != .NONE
                render_captain(user.captain, right=false);

            use_text_shader(transparency);
            draw_text(user.name, .{0, 0});

            use_tile_shader(transparency);
            draw_ship(user.sprite_index, .EAST, .{1, 0}, color=color_black);

            draw_tile(942, .{3, 0}, color_black);
            draw_number(user_hull, .{3, -1}, color_black);

            draw_tile(519, .{4, 0}, color_black);
            draw_number(user_crew, .{4, -1}, color_black);

            if user_die_result != 0 {
                percent := (screen_slice.progress) / (USER_DICE_ROLLED_AT) * 3;
                percent = clamp(percent, 0.0, 1.0);
                draw_die_number(user_die_result, .{4, 8}, offset=.{0, percent * 2 * TILE_SIZE}, color=color_black);
            }
            if user_die_bonus != 0 {
                draw_tile(1016, .{5, 7}, color=color_black);
                draw_number(user_die_bonus, .{6, 7}, color=color_black);
            }
        }

        if victim {
            use_sprite_shader(transparency);
            if victim.captain != .NONE
                render_captain(victim.captain, right=true);

            use_text_shader(transparency);
            draw_text(victim.name, .{13, 0});

            use_tile_shader(transparency);
            draw_ship(victim.sprite_index, .WEST, .{14, 0}, color=color_black);

            draw_tile(942, .{12, 0}, color_black, horizontal_flip=true);
            draw_number(victim_hull, .{12, -1}, color_black);

            draw_tile(519, .{11, 0}, color_black);
            draw_number(victim_crew, .{11, -1}, color_black);
        }
    }
}

render_fade :: () {
    if !fade.active then return; 

}

render_map :: (map : Map, transparency := 1.0)
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
            if cursor.targeting_with {
                if cursor.targeting_with.targeting == {
                    case .ALLY;     overlay_color = color_1;
                    case .ENEMY;    overlay_color = color_2;
                    case .ORTHOGRAPHIC;     overlay_color = color_2;
                    case .BOARDING;     overlay_color = color_2;
                }
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
    draw_ability_ui :: (using ability : Ability, square: Square, num_square: Square, button_index := 0, color := color_bg) {
        draw_tile(sprite_index, square, color);

        draw_tile(803 + button_index, num_square, color);
    }

    // Draw UI Elements
    use_tile_shader(transparency);

    for 0..VIEWPORT_WIDTH-1 {
        draw_background(.{it, -1}, color_3);
    }

    ui_unit := get_occupant(map, cursor.square);
    if ui_unit == null && cursor.selected
        ui_unit = cursor.selected;

    if ui_unit {
        use_text_shader(transparency);
        draw_text(ui_unit.name, .{11, 0});
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
        draw_tile(942, .{1, 0}, color_black);
        draw_number(health, .{2, 0}, color_black);

        draw_tile(519, .{1, 1}, color_black);
        draw_number(crew, .{2, 1}, color_black);

        // movement
        if moved {
            draw_tile(1048, .{1, 2}, color_white);
            draw_number(movement, .{2, 2}, color_white);
        }
        else {
            draw_tile(1048, .{1, 2}, color_black);
            draw_number(movement, .{2, 2}, color_black);
        }

        if status & .AFLAME {
            draw_tile(504, .{1, 3}, color_2);
        }
        if status & .ADRIFT {
            draw_tile(48, .{2, 3}, color_2);
        }

        color := color_black;
        if exhausted
            color = color_white;
        if primary.active {
            draw_ability_ui(primary, .{1, 4}, .{2, 4}, 0, color);
        }
        if secondary.active {
            draw_ability_ui(secondary, .{1, 5}, .{2, 5}, 1, color);
        }

        draw_ability_ui(repair, .{0, 7}, .{1, 7}, 2, color_black);
        draw_ability_ui(board,  .{4, 7}, .{5, 7}, 3, color_black);

        {
            use_text_shader(transparency);

            draw_text(description, .{0, 0});

            draw_text(summarize_unit_flags(flags), .{0, 0}, second=true);

            draw_text("hull", .{3, 1});
            draw_text("crew", .{3, 2});
            draw_text("movement", .{3, 3});

            if primary.active {
                draw_text(tprint("%-%", primary.min_range, primary.max_range), .{0, 5});
                draw_text("rng.", .{0, 5}, second=true);

                draw_text(primary.name, .{3, 5});

                text_color := color_1; if primary.damage > 0 then text_color = color_2;
                draw_text(summarize_ability(primary), .{3, 5}, text_color, second=true);
            }
            if secondary.active {
                draw_text(tprint("%-%", secondary.min_range, secondary.max_range), .{0, 6});
                draw_text("rng.", .{0, 6}, second=true);

                draw_text(secondary.name, .{3, 6});

                text_color := color_1; if secondary.damage > 0 then text_color = color_2;
                draw_text(summarize_ability(secondary), .{3, 6}, text_color, second=true);
            }

            {
                text_color := color_1;

                draw_text("Repair", .{2, 8}, text_color);
            }
            {
                text_color := color_2;

                draw_text("Board", .{6, 8}, text_color);
            }
        }

        if captain != .NONE {
            use_sprite_shader(transparency);
            render_captain(captain);

            use_tile_shader(transparency);
            draw_background(.{12, 7}, color_3);
            draw_background(.{13, 7}, color_3);
            draw_background(.{14, 7}, color_3);
            draw_background(.{15, 7}, color_3);

            use_text_shader(transparency);
            draw_text(get_captain_name(captain), .{12, 8});
        }
    }
    else if ui_unit {
        using ui_unit;

        // health
        draw_tile(532, .{1, -1}, color_black);
        draw_number(health, .{1, -1}, color_white);

        draw_tile(519, .{2, -1}, color_black);
        draw_number(crew, .{2, -1}, color_white);

        // movement
        if moved {
            draw_tile(1048, .{3, -1}, color_black);
            draw_number(movement, .{3, -1}, color_white);
        }
        else {
            draw_tile(1048, .{3, -1}, color_white);
            draw_number(movement, .{3, -1}, color_black);
        }

        if status & .AFLAME {
            draw_tile(504, .{4, -1}, color_2);
        }
        if status & .ADRIFT {
            draw_tile(48, .{4, -1}, color_2);
        }

        color := color_black;
        if exhausted
            color = color_white;
        if primary.active {
            draw_ability_ui(primary, .{5, -1}, .{6, -1}, 0, color);
        }
        if secondary.active {
            draw_ability_ui(secondary, .{8, -1}, .{9, -1}, 1, color);
        }

        ti := type_info(Unit_Flags);
        for ti.values {

        }
    }
}

render_captain :: (captain: Captain, right := true) {
    name := get_captain_name(captain);
    if name {
        sprite := table_find_pointer(*rendering.sprites, name);
        if !sprite {
            log_error("Unable to find sprite % in the sprites catalogue.\n", name);
            return;
        }

        draw_sprite(sprite, right=right);
    }
}

render_start_screen :: (transparency := 1.0) {
    use_sprite_shader(transparency);
    mural, found := table_find(*rendering.murals, "title");
    if found {
        draw_sprite(mural);
    }
}

render_credits :: (transparency := 1.0) {
    use_text_shader(transparency);
    k := cast(float)PIXEL_HEIGHT * 3 / 4;
    draw_text_centered("Game by Alex Hartford.", k, color=color_black);
    draw_text_centered("Design by Grant Neighbor.", k - TILE_SIZE, color=color_1);
    draw_text_centered("Art by Emelia Hartford.", k - 2*TILE_SIZE, color=color_2);
    draw_text_centered("etc...", k - 3*TILE_SIZE, color=color_3);
}

render_cutscene :: (dialogue: Dialogue, transparency := 1.0) {
    use_sprite_shader(transparency);

    mural_name : string;
    if dialogue.mural_name_index != -1 {
        mural_name = dialogue.lines[dialogue.mural_name_index].mural_name;
    }

    if mural_name {
        mural, found := table_find(*rendering.murals, mural_name);
        if !found {
            log_error("Unable to find mural %.\n", mural_name);
            return;
        }

        draw_sprite(mural);
    }

    render_dialogue(dialogue, transparency);
}

render_dialogue :: (dialogue: Dialogue, transparency := 1.0) {
    {
        // Draw speaker sprites.
        use_sprite_shader(transparency);

        name := to_lower_copy(dialogue.speakers[0]);
        if name {
            sprite := table_find_pointer(*rendering.sprites, name);
            if !sprite {
                log_error("Unable to find sprite % in the sprites catalogue.\n", name);
                return;
            }

            draw_sprite(sprite, x_offset=dialogue.left_sprite_offset, y_offset=TILE_SIZE);
        }

        name = to_lower_copy(dialogue.speakers[1]);
        if name {
            sprite := table_find_pointer(*rendering.sprites, name);
            if !sprite {
                log_error("Unable to find sprite % in the sprites catalogue.\n", name);
                return;
            }

            draw_sprite(sprite, x_offset=dialogue.right_sprite_offset, y_offset=TILE_SIZE, right=true);
        }
    }

    {
        // Draw dialogue box
        use_tile_shader(transparency);
        for col: 0..VIEWPORT_WIDTH {
            for row: VIEWPORT_HEIGHT - 1 .. VIEWPORT_HEIGHT {
                draw_background(.{col, row}, color_3);
            }
        }

        // Draw dialogue text
        use_text_shader(transparency);
        current_speaker_name := dialogue.lines[dialogue.line_index].name;

        if dialogue.speakers[0] == current_speaker_name {
            draw_text(current_speaker_name, xx (TILE_SIZE / 2), xx (TILE_SIZE / 2), color_1);
        }

        else if dialogue.speakers[1] == current_speaker_name {
            draw_text_right(current_speaker_name, xx (TILE_SIZE / 2), nudge_x = xx (-TILE_SIZE / 2), color=color_1);
        }

        line := dialogue.lines[dialogue.line_index].text;
        draw_text_centered(line, 5);
    }
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

    if sinking != 0 {
        draw_tile(1, square - viewport.corner, color);
    }
    else {
        draw_ship(sprite_index, direction, square - viewport.corner, color);
    }

    /*
    if cursor.state == .TARGETING_PRIMARY || cursor.state == .TARGETING_SECONDARY {
        draw_number(health, square, color_3);
    }
    */
}

draw_squares_overlay :: (squares : [..] Square, color := color_1) {
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

draw_number :: (number: int, square: Square, color := color_black) {
    get_number_sprite_index :: (i: int) -> int {
        if i < 10
            return i + 868 + 49 * 0;
        else if i < 20
            return i % 10 + 868 + 49 * 1;
        else if i < 30
            return i % 10 + 868 + 49 * 2;

        log_error("Unprintable number: %\n", i);
        return 0;
    }

    draw_tile(get_number_sprite_index(abs(number)), square, color);
}

draw_die_number :: (number: int, square: Square, offset := Vector2.{0, 0}, color := color_black) {
    get_die_number_sprite_index :: (i: int) -> int {
        if i > 6 {
            log_error("Can't draw % on a die!\n", i);
            return 0;
        }
        return abs(i) + 776;
    }

    draw_tile(get_die_number_sprite_index(abs(number)), square, color, offset);
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
            draw_menu_element(it, .{3, it_index + 1}, color_white, color_black);
        }

        // Draw selected element over it.
        if elements.count {
            draw_menu_element(elements[element_index], .{3, element_index + 1}, color_black, color_white);
        }
    }

    use_sprite_shader(transparency);
    draw_sprite(rendering.controls, x_offset=0, y_offset=0);
}

render_start_menu :: (using menu: Menu, transparency := 1.0) {
    {
        use_tile_shader(transparency);

        for elements {
            draw_menu_element(it, .{15, it_index + (PIXEL_HEIGHT / TILE_SIZE) - elements.count - 1}, color_1, color_4);
        }

        if elements.count {
            // Draw selected element over it.
            draw_menu_element(elements[element_index], .{15, element_index + (PIXEL_HEIGHT / TILE_SIZE) - elements.count - 1}, color_3, color_4);
        }
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
        use_text_shader(transparency);

        draw_text_centered("game over", xx (PIXEL_HEIGHT / 2.0), color=color_bg);
        draw_text_centered("retry?", xx (PIXEL_HEIGHT / 2.0 - main_font.height), color=color_1);
    }
}

//
// Menus
//

draw_menu_element :: (using element: *Menu_Element, square: Square, color := color_fg, second_color := color_3) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            draw_tile(sprite_index, square, color);

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            if value.* {
                draw_tile(sprite_index, square, color);
            }
            else {
                draw_tile(sprite_index_two, square, color);
            }

        case .SLIDER;
            using cast(*Slider_Element)element;
            draw_tile(754, square - .{2, 0}, second_color);
            draw_tile(755, square - .{1, 0}, second_color);
            draw_tile(755, square, second_color);
            draw_tile(755, square + .{1, 0}, second_color);
            draw_tile(754, square + .{2, 0}, second_color, horizontal_flip=true);

            value_index := cast(int)(value.* * 4) - 2;
            if value_index == -2 {
                draw_tile(sprite_index_two, square + .{value_index, 0}, color);
            }
            else {
                draw_tile(sprite_index, square + .{value_index, 0}, color);
            }
    }
}

//
// deprecated for this project, maybe useful later.
//

draw_menu_element_text :: (using element: *Menu_Element, height : float, color := color_fg) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            draw_text_centered(name, height, color=color);

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            str := "Off";
            if value
                str = "On";
            draw_text_centered(tprint("% - %", name, str), height, color=color);

        case .SLIDER;
            using cast(*Slider_Element)element;
            draw_text_centered(tprint("% - %", name, value.*), height, color=color);
    }
}
