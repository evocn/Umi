// Umi
// Render
// Alex Hartford
// June 2023

MENU_TRANSPARENCY_MODIFIER :: 0.3;
DIALOGUE_TRANSPARENCY_MODIFIER :: 0.9;

render :: (map: Map, dialogue: Dialogue) {
    {
        weather : Weather;

        if spine.current_section == 0 || spine.current_section == 2 {
            weather = dialogue.weather;
        }
        else {
            weather = map.weather;
        }

        // Set the colors according to the mode we're in.
        if weather == {
            case .DAY;
                bg = color_bg;
                fg = color_fg;
                ui = color_3;
                text = color_black;
                text_2 = color_white;

        case .NIGHT; #through;
        case .STORM;
            bg = color_fg;
            fg = color_bg;
            ui = color_black;
            text = color_3;
            text_2 = color_white;
        }
    }


    fade_progress := 0.0;
    if fade.active || spine.ready_for_next_section
        fade_progress = fade_get_t_value();

    {
        // Render all this to the framebuffer.
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(bg.x, bg.y, bg.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_mode == {
            case .GAME;
                render_map(map, transparency = 1.0 - fade_progress);
                render_ui(map, transparency = 1.0 - fade_progress);

            case .START;
                render_start_screen(transparency = 1.0 - fade_progress);
                render_start_menu(start_menu, transparency = 1.0 - fade_progress);

            case .EDITOR;
                render_map(map);
                render_ui(map);

            case .CUTSCENE;
                render_cutscene(dialogue, transparency = 1.0 - fade_progress);

            case .DIALOGUE;
                render_map(map, transparency = MENU_TRANSPARENCY_MODIFIER);
                render_dialogue(dialogue);

            case .MENU;
                if prior_program_mode == {
                    case .GAME;
                        render_map(map, transparency = MENU_TRANSPARENCY_MODIFIER);
                        render_ui(map, transparency = MENU_TRANSPARENCY_MODIFIER);

                    case .DIALOGUE;
                        render_map(map, transparency = MENU_TRANSPARENCY_MODIFIER);
                        render_ui(map, transparency = MENU_TRANSPARENCY_MODIFIER);
                        render_dialogue(dialogue, transparency = MENU_TRANSPARENCY_MODIFIER);

                    case .CUTSCENE;
                        render_cutscene(dialogue, transparency = MENU_TRANSPARENCY_MODIFIER);

                    case .START;
                        render_start_screen(transparency = MENU_TRANSPARENCY_MODIFIER);
                        render_start_menu(start_menu, transparency = MENU_TRANSPARENCY_MODIFIER);
                }
                render_menu(menu);

            case .GAME_OVER;
                render_map(map, transparency = MENU_TRANSPARENCY_MODIFIER);
                render_ui(map, transparency = MENU_TRANSPARENCY_MODIFIER);
                render_game_over();

            case .CREDITS;
                render_credits();
        }

        render_slice();
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

render_map :: (map : Map, transparency := 1.0) {
    // Draw Game Board
    {
        use_tile_shader(transparency);

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
            draw_unit(it, transparency);
        }

        // Draw Cursor
        cursor_color := fg;
        if whose_turn() == .YOU then cursor_color = color_1;
        else cursor_color = color_2;

        if get_occupant(map, cursor.square) then cursor_color = color_4;

        use_tile_shader(transparency);
        draw_tile(49 * 12 + 35, cursor.square - viewport.corner, cursor_color);

        // Editor Cursor
        if program_mode == .EDITOR {
            draw_tile(49 * 12 + 37, editor.cursor, color_4);
        }
    }
}

render_ui :: (map: Map, transparency := 1.0) {
    draw_ability_ui :: (using ability : Ability, square: Square, num_square: Square, button_index := 0) {
        draw_tile(sprite_index, square, text);

        draw_tile(803 + button_index, num_square, text_2);
    }

    // Draw UI Elements
    use_tile_shader(transparency);

    for 0..VIEWPORT_WIDTH-1 {
        draw_background(.{it, -1}, ui);
    }

    draw_minimap(map, transparency = transparency);

    ui_unit := get_occupant(map, cursor.square);
    if ui_unit == null && cursor.selected
        ui_unit = cursor.selected;

    if ui_unit {
        use_text_shader(transparency);
        draw_text_right(ui_unit.name, PIXEL_HEIGHT - TILE_SIZE / 2 + 2, nudge_x = -5);
        draw_text_right(get_captain_name(ui_unit.captain), PIXEL_HEIGHT - TILE_SIZE + 2, nudge_x = -5);
    }
    use_tile_shader(transparency);

    if cursor.inspecting {
        for col: 0..VIEWPORT_WIDTH / 2 - 1 {
            for row: -1..VIEWPORT_HEIGHT {
                draw_background(.{col, row}, ui);
            }
        }

        using cursor.inspecting;

        // health
        draw_tile(942, .{1, 0}, text);
        draw_number(hull, .{2, 0}, text_2);

        draw_tile(929, .{3, 0}, text);
        draw_number(max_hull, .{4, 0}, text_2);

        draw_tile(519, .{1, 1}, text);
        draw_number(crew, .{2, 1}, text_2);

        draw_tile(929, .{3, 1}, text);
        draw_number(max_crew, .{4, 1}, text_2);

        // movement
        draw_tile(1048, .{1, 2}, text);
        draw_number(movement, .{2, 2}, text_2);

        if status & .AFLAME {
            draw_tile(504, .{1, 3}, color_2);
        }
        if status & .ADRIFT {
            draw_tile(48, .{2, 3}, color_2);
        }

        if primary.active {
            draw_ability_ui(primary, .{1, 4}, .{2, 4}, 0);
        }
        if secondary.active {
            draw_ability_ui(secondary, .{1, 5}, .{2, 5}, 1);
        }

        draw_ability_ui(interact, .{0, 6}, .{1, 6}, 4);
        draw_ability_ui(repair, .{0, 7}, .{1, 7}, 2);
        draw_ability_ui(board,  .{4, 7}, .{5, 7}, 3);

        {
            use_text_shader(transparency);

            draw_text(description, .{0, 0}, nudge_x = 5);

            draw_text(summarize_unit_flags(flags), .{0, 0}, second=true);

            draw_text("hull", .{5, 1});
            draw_text("crew", .{5, 2});
            draw_text("movement", .{3, 3});

            if primary.active {
                draw_text(tprint("%-%", primary.min_range, primary.max_range), .{0, 5});
                draw_text("rng.", .{0, 5}, second=true);

                draw_text(primary.name, .{3, 5});

                draw_text(summarize_ability(primary), .{3, 5}, second=true);
            }
            if secondary.active {
                draw_text(tprint("%-%", secondary.min_range, secondary.max_range), .{0, 6});
                draw_text("rng.", .{0, 6}, second=true);

                draw_text(secondary.name, .{3, 6});

                draw_text(summarize_ability(secondary), .{3, 6}, second=true);
            }

            {
                text_color := color_1;

                draw_text("Interact", .{2, 7});
            }
            {
                text_color := color_1;

                draw_text("Repair", .{2, 8});
            }
            {
                text_color := color_2;

                draw_text("Attack", .{6, 8});
            }
        }

        if captain != .NONE {
            use_sprite_shader(transparency);
            render_captain(captain);

            use_tile_shader(transparency);
            for 8..16 {
                draw_background(.{it, 7}, ui);
            }

            use_text_shader(transparency);
            draw_text_right(get_captain_description(captain), TILE_SIZE / 2, nudge_x = -4);
        }

        for captains_in_the_hold {
        }
        //draw_text_right(get_captain_name(captain), TILE_SIZE / 2, nudge_x = -4);
    }
    else if ui_unit {
        using ui_unit;

        // health
        draw_tile(532, .{1, -1}, text);
        draw_number(hull, .{1, -1}, text_2);

        draw_tile(519, .{2, -1}, text);
        draw_number(crew, .{2, -1}, text_2);

        // movement
        draw_tile(1048, .{3, -1}, text);
        draw_number(movement, .{3, -1}, text_2);

        if status & .AFLAME {
            draw_tile(504, .{4, -1}, color_2);
        }
        if status & .ADRIFT {
            draw_tile(48, .{4, -1}, color_2);
        }

        if primary.active {
            draw_ability_ui(primary, .{5, -1}, .{6, -1}, 0);
        }
        if secondary.active {
            draw_ability_ui(secondary, .{8, -1}, .{9, -1}, 1);
        }

        // @TODO!
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

        draw_sprite(sprite, right=right, y_offset=TILE_SIZE);
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
    draw_text_centered("| Umi Development Team |", k + TILE_SIZE);

    draw_text_centered("Game by Alex Hartford.", k);
    draw_text_centered("Art by Emelia Hartford.", k - TILE_SIZE);
    draw_text_centered("Murals by Bryce Nevitt.", k - 2*TILE_SIZE);
    draw_text_centered("System Design by Grant Neighbor.", k - 3*TILE_SIZE);
    draw_text_centered("Level Design by Josh Elijah.", k - 4*TILE_SIZE);
    draw_text_centered("Music and Sounds by Riley Morris.", k - 5*TILE_SIZE);
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
    current_speaker_name := dialogue.lines[dialogue.line_index].name;
    {
        // Draw speaker sprites.
        {
            speaker_transparency := DIALOGUE_TRANSPARENCY_MODIFIER;
            if dialogue.speakers[0] == current_speaker_name {
                speaker_transparency = 1.0;
            }

            name := to_lower_copy(dialogue.speakers[0]);
            use_sprite_shader(transparency * speaker_transparency);

            if name {
                sprite := table_find_pointer(*rendering.sprites, name);
                if !sprite {
                    log_error("Unable to find sprite % in the sprites catalogue.\n", name);
                    return;
                }

                draw_sprite(sprite, x_offset=dialogue.left_sprite_offset, y_offset=TILE_SIZE);
            }
        }

        {
            speaker_transparency := DIALOGUE_TRANSPARENCY_MODIFIER;
            if dialogue.speakers[1] == current_speaker_name {
                speaker_transparency = 1.0;
            }

            name := to_lower_copy(dialogue.speakers[1]);
            use_sprite_shader(transparency * speaker_transparency);

            if name {
                sprite := table_find_pointer(*rendering.sprites, name);
                if !sprite {
                    log_error("Unable to find sprite % in the sprites catalogue.\n", name);
                    return;
                }

                draw_sprite(sprite, x_offset=dialogue.right_sprite_offset, y_offset=TILE_SIZE, right=true);
            }
        }
    }

    {
        // Draw dialogue box
        use_tile_shader(transparency);
        for col: 0..VIEWPORT_WIDTH {
            for row: VIEWPORT_HEIGHT - 1 .. VIEWPORT_HEIGHT {
                draw_background(.{col, row}, ui);
            }
        }

        // Draw dialogue text
        use_text_shader(transparency);
        if dialogue.speakers[0] == current_speaker_name {
            draw_text(current_speaker_name, cast(float)(TILE_SIZE / 2), cast(float)(TILE_SIZE / 2));
        }

        else if dialogue.speakers[1] == current_speaker_name {
            draw_text_right(current_speaker_name, xx (TILE_SIZE / 2), nudge_x = xx (-TILE_SIZE / 2));
        }

        line := dialogue.lines[dialogue.line_index].text;
        draw_text_centered_with_progress(line, 5, dialogue.characters_at_progress);
    }
}

draw_screen_quad :: (shader: Shader) {
    model := Matrix4_Identity;

    translation_vector := Vector3.{-1, -1, 1};
    translate(*model, translation_vector);

    scale_vector := Vector3.{2, 2, 1};
    scale(*model, scale_vector);

    set_mat4(shader, "model", model);

    draw_quad(rendering.quad);
}

// Renders the given framebuffer as a texture on a screen-space quad.
render_framebuffer_to_screen :: () {
    shader := rendering.quad_shader;
    use_shader(shader);
    defer disable_shaders();

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, render_texture);

    draw_screen_quad(shader);
}

//
//

draw_mini_health_bar :: (using square: Square, health: int, max_health: int, transparency : float) {
    pip_size := cast(float)TILE_SIZE / 16;
    between_pips := cast(float)TILE_SIZE / 32;
    bar_width := TILE_SIZE - pip_size - between_pips;

    x := cast(float)(square.col - viewport.corner.col) * TILE_SIZE + between_pips;
    y := cast(float)(square.row - viewport.corner.row) * TILE_SIZE + TILE_SIZE;

    ratio := cast(float)health / max_health;

    for 0..9 {
        if it >= max_health then return;
        draw_colored_rectangle(x + (between_pips + pip_size) * it, y, pip_size, pip_size, color=color_white, transparency=transparency);
        if it >= health then continue;
        draw_colored_rectangle(x + (between_pips + pip_size) * it, y, pip_size, pip_size, color=color_1, transparency=transparency);
    }

    if 10 >= max_health then return;

    y += pip_size + between_pips;

    for 10..19 {
        if it >= max_health then return;
        draw_colored_rectangle(x + (between_pips + pip_size) * (it - 10), y, pip_size, pip_size, color=color_white, transparency=transparency);
        if it >= health then continue;
        draw_colored_rectangle(x + (between_pips + pip_size) * (it - 10), y, pip_size, pip_size, color=color_1, transparency=transparency);
    }

    if 20 >= max_health then return;

    y += pip_size + between_pips;

    for 20..29 {
        if it >= max_health then return;
        draw_colored_rectangle(x + (between_pips + pip_size) * (it - 20), y, pip_size, pip_size, color=color_white, transparency=transparency);
        if it >= health then return;
        draw_colored_rectangle(x + (between_pips + pip_size) * (it - 20), y, pip_size, pip_size, color=color_1, transparency=transparency);
    }
}

draw_unit :: (using unit : Unit, transparency : float) {
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

    use_tile_shader(transparency);

    color := team_color(team);

    draw_ship(sprite_index, direction, square - viewport.corner, color);
    if sinking != 0 {
        draw_tile(672, square - viewport.corner, color_white);
    }

    draw_mini_health_bar(square, crew, max_crew, transparency);

    /*
    if cursor.state == .TARGETING_PRIMARY || cursor.state == .TARGETING_SECONDARY {
        draw_number(hull, square, color_3);
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

        for col: 0..VIEWPORT_WIDTH / 2 - 2 {
            for row: -1..VIEWPORT_HEIGHT {
                draw_background(.{col, row}, ui);
            }
        }

        for elements {
            draw_menu_element(it, .{3, it_index + 1}, text, ui);
        }

        // Draw selected element over it.
        if elements.count {
            draw_menu_element(elements[element_index], .{3, element_index + 1}, text_2, text);
        }
    }

    use_sprite_shader(transparency);
    controls_sprite, success := table_find(*rendering.sprites, "ui");
    draw_sprite(controls_sprite, x_offset=-PIXEL_WIDTH * 9 / 16, y_offset=PIXEL_HEIGHT * 2 / 5, use_color_override = true, color_override = color_black);
}

render_start_menu :: (using menu: Menu, transparency := 1.0) {
    {
        use_tile_shader(transparency);

        for elements {
            draw_menu_element(it, .{15, it_index + (PIXEL_HEIGHT / TILE_SIZE) - elements.count - 2}, color_black, color_3);
        }

        if elements.count {
            // Draw selected element over it.
            draw_menu_element(elements[element_index], .{15, element_index + (PIXEL_HEIGHT / TILE_SIZE) - elements.count - 2}, color_2, color_black);
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
                draw_background(.{col, row}, ui);
            }
        }
    }

    {
        use_text_shader(transparency);

        draw_text_centered("game over", xx (PIXEL_HEIGHT / 2.0));
        draw_text_centered("retry?", xx (PIXEL_HEIGHT / 2.0 - main_font.height));
    }
}

//
// Menus
//

draw_menu_element :: (using element: *Menu_Element, square: Square, color := color_black, second_color := color_3) {
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

draw_menu_element_text :: (using element: *Menu_Element, height : float) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            draw_text_centered(name, height);

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            str := "Off";
            if value
                str = "On";
            draw_text_centered(tprint("% - %", name, str), height);

        case .SLIDER;
            using cast(*Slider_Element)element;
            draw_text_centered(tprint("% - %", name, value.*), height);
    }
}

//
// Minimap
//

draw_colored_rectangle :: (x: float, y: float, width: float, height: float, color := color_white, transparency := 1.0) {
    shader := use_basic_shader(transparency);

    model := Matrix4_Identity;
    top_left_y := 1.0 - height / PIXEL_HEIGHT;
    translation_vector := Vector3.{x / PIXEL_WIDTH, top_left_y - y / PIXEL_HEIGHT, 0.0};
    scale_vector := Vector3.{width / PIXEL_WIDTH, height / PIXEL_HEIGHT, 1.0};

    translate(*model, translation_vector);
    scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    set_vec4(shader, "color", color);

    draw_quad(rendering.quad);
}

draw_minimap :: (using map: Map, transparency := 1.0) {
    viewport_pixels_wide := cast(float)VIEWPORT_WIDTH;
    viewport_pixels_tall := cast(float)VIEWPORT_HEIGHT;

    draw_colored_rectangle(0.0, 0.0, xx (map.width), xx (map.height), text, transparency);
    draw_colored_rectangle(xx viewport.corner.col, xx viewport.corner.row, viewport_pixels_wide, viewport_pixels_tall, text_2, transparency);
}
