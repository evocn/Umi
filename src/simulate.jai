// Umi
// Simulate
// Alex Hartford
// July 2023

simulate :: (map: *Map, dialogue: *Dialogue, units: [..] *Unit, dt: float) {
    update_sound_player(dt);

    if program_paused {
        return;
    }

    if program_mode == .MENU {
        resolve_menu_inputs(*menu);
        return;
    }

    update_dialogue_animators(dialogue, dt);

    if spine.ready_for_next_section {
        spine.ready_for_next_section = false;
        spine_go_to_next_section(map, units, dialogue);
    }

    if spine.ready_for_last_section {
        spine.ready_for_last_section = false;
        spine_go_to_last_section(map, units, dialogue);
    }

    if fade.active {
        fade_update(dt);
        return;
    }

    if screen_slice.active {
        if pressed(*input.button_select) {
            screen_slice.time = screen_slice.length;
        }

        slice_update(dt);
        return;
    }

    if #complete program_mode == {
        case .GAME;
        turn := whose_turn();
        if turn == {
            case .MURAKAMI;
                resolve_cursor_inputs(map, dialogue);
                for command_queue {
                    execute(it);
                    free(it);
                }
                array_reset(*command_queue);

            case .NONE;
                log_error("This team shouldn't ever be active!\n");
                next_turn(map);

            case;
                ai_update(map, dt);

                // @NOTE: This is a little unclear... 
                // This block of code should only run after the ai has passed the turn back to the user.
                if whose_turn() == .MURAKAMI {
                    for map.events {
                        if it.turn == manager.turn_number {
                            activate_event(it, map, dialogue);
                        }
                    }
                }
        }

        // Remove dead units.
        for map.units {
            if it.dead {
                remove_occupant(map, it.square);
                remove it;
            }
        }

        // @TODO: Find where to actually do this check.
        // We want to check win conditions as infrequently as possible.
        /*
        battle_is_won := check_win_condition(.ROUT, map.*);
        if battle_is_won {
            fade_start(.OUT, next_section);
        }

        battle_is_lost := check_lost(map.*);
        if battle_is_lost {
            switch_mode(.GAME_OVER);
        }
        */

        case .START;
        resolve_start_menu_specialties();
        resolve_menu_inputs(*start_menu);

        case .CUTSCENE;
        resolve_dialogue_inputs(dialogue);

        case .DIALOGUE;
        resolve_dialogue_inputs(dialogue);

        case .MENU;
        // @NOTE: Above for control flow.

        case .GAME_OVER;
        resolve_game_over(map, units);

        case .EDITOR;
        if !program_state.imgui_capturing_keyboard {
            update_editor_cursor(map);
        }

        case .CREDITS;
            resolve_credits_input();

        case .CHAPTER;
            resolve_chapter_screen();
    }
}

//
//
//

Win_Condition :: enum {
    ROUT;
    CAPTURE;
    KINGPIN;
}

check_win_condition :: (condition : Win_Condition, map : Map) -> won: bool {
    if #complete condition == {
        case .ROUT;
            enemy_units_left := query_units(map.units, (x) => (x.team != .MURAKAMI));
            if enemy_units_left.count == 0
                return true;

        case .CAPTURE;
            for col : 0..MAX_MAP_WIDTH-1 {
                for row : 0..MAX_MAP_HEIGHT-1 {
                    if map.tiles[col][row].kind == .OBJECTIVE && map.occupancy[col][row] && map.occupancy[col][row].team == .MURAKAMI {
                        return true;
                    }
                }
            }

        case .KINGPIN;

    }

    return false;
}

check_lost :: (map : Map) -> lost : bool {
    player_units_left := query_units(map.units, (x) => (x.team == .MURAKAMI));
    if player_units_left.count == 0
        return true;

    return false;
}
