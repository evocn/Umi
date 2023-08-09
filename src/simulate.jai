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
                resolve_cursor_inputs(map, dialogue);
                for command_queue {
                    execute(it);
                    free(it);
                }
                array_reset(*command_queue);

            case .THEM;
                ai_update(map, dt);

                // @NOTE: This is a little unclear... 
                // This block of code should only run after the ai has passed the turn back to the user.
                if whose_turn() == .YOU {
                    for map.events {
                        if it.turn == manager.turn_number {
                            activate_event(it, map, dialogue);
                        }
                    }
                }

            case .NONE;
                log_error("This team shouldn't ever be active!\n");
        }

        // Remove dead units.
        for map.units {
            if it.dead {
                remove_occupant(map, it.square);
                remove it;
            }
        }

        {
            player_units_left := query_units(map.units, (x) => (x.team == .YOU));
            enemy_units_left := query_units(map.units, (x) => (x.team == .THEM));

            // @RELEASE: Put this back in for the actual gameplay.
            /*
            if player_units_left.count == 0 {
                switch_mode(.GAME_OVER);
            }
            if enemy_units_left.count == 0 {
                fade_start(.OUT, next_section);
            }
            */
        }

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
    }
}
