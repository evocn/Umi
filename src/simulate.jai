// Tactics
// Simulate
// Alex Hartford
// July 2023

simulate :: (map: *Map, dialogue: *Dialogue, units: [..] *Unit, dt: float) {
    roll_time = clamp(roll_time - dt, 0, roll_onscreen_time);

    update_sound_player(dt);

    if program_paused {
        return;
    }

    if fade.active {
        fade_update(dt);
        return;
    }
    if screen_slice.active {
        slice_update(dt);
        return;
    }

    if #complete program_mode == {
        case .GAME;
        turn := whose_turn();
        if #complete turn == {
            case .YOU;
            resolve_cursor_inputs(map);
            for command_queue {
                execute(it);
                free(it);
            }
            array_reset(*command_queue);

            case .THEM;
            ai_update(map, dt);

            case .NONE;
            print("This team shouldn't be active!\n");
        }

        for map.units {
            if it.dead {
                remove_occupant(map, it.square);
                remove it;
            }
        }

        player_units_left := query_units(map.units, (x) => (x.team == .YOU));
        if player_units_left.count == 0 {
            switch_mode(.GAME_OVER);
        }

        enemy_units_left := query_units(map.units, (x) => (x.team == .THEM));
        if enemy_units_left.count == 0 {
            spine.ready_for_next_section = true;
        }

        case .START;
        resolve_start_menu_specialties();
        resolve_menu_inputs(*start_menu);

        case .CUTSCENE;
        update_and_resolve_dialogue_inputs(dialogue, dt);

        case .DIALOGUE;
        update_and_resolve_dialogue_inputs(dialogue, dt);

        case .MENU;
        resolve_menu_inputs(*menu);

        case .GAME_OVER;
        resolve_game_over(map, units);

        case .EDITOR;
        if !program_state.imgui_capturing_keyboard {
            update_editor_cursor(map);
        }
    }

    if spine.ready_for_next_section {
        spine.ready_for_next_section = false;
        next_section(map, units, dialogue);
    }
}
