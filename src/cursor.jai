// Umi
// Grid
// Alex Hartford
// June 2023

cursor : struct {
    using square : Square;

    state : enum {
        NEUTRAL;
        MOVING;
        TARGETING;
        INSPECTING;
    }

    selected : *Unit;
    selected_initial_square : Square = .{-1, -1};
    selected_initial_direction : Direction;

    targeting_with : *Ability;

    accessible : [..] Square;

    path : Path;

    targeted : *Unit;
    interactible : [..] Square;

    inspecting : *Unit;
}

resolve_cursor_inputs :: (using map : *Map, dialogue: *Dialogue) {
    using cursor;
    using input;

    if pressed(*button_menu) {
        switch_mode(.MENU);
        menu.element_index = 0;
        play_sfx("selection");
    }

    if state == {
        case .NEUTRAL;
        {
            maybe_move_cursor(map.*);

            if pressed(*button_1) {
                occupant := get_occupant(map, square);
                if occupant {
                    if occupant.team == .YOU {
                        begin_moving_unit(map);
                    }
                    else {
                        show_unit_range(map);
                    }
                }
            }

            if pressed(*button_2) {
                deselect_unit(map.*, reset_cursor=true);
            }

            if pressed(*button_3) {
                begin_targeting(map, which_ability=0);
            }

            if pressed(*button_4) {
                begin_targeting(map, which_ability=1);
            }

            if pressed(*button_5) {
                begin_targeting(map, which_ability=2);
            }

            if pressed(*button_6) {
                begin_targeting(map, which_ability=3);
            }

            if pressed(*button_select) {
                next_turn(map);
            }

            if pressed(*button_info) {
                begin_inspecting(map);
                occupant := get_occupant(map, square);
                if occupant && occupant.flashback {
                    success := load_dialogue_file(dialogue, tprint("%.dialogue", occupant.flashback));
                    if !success {
                        log_error("Flashback: Unable to load dialogue file %.\n", occupant.flashback);
                        return;
                    }
                    switch_mode(.DIALOGUE);
                    occupant.flashback = "";
                }
            }
        }

        case .MOVING;
        {
            if array_find(cursor.accessible, cursor.square) {
                array_reset(*path);
                path =, success := get_shortest_path(map, selected, cursor.square);
            }

            maybe_move_cursor(map.*);

            if pressed(*button_1) {
                place_unit(map);
            }

            if pressed(*button_2) {
                deselect_unit(map.*, reset_cursor=true);
            }

            if pressed(*button_3) {
                begin_targeting(map, which_ability=0);
            }

            if pressed(*button_4) {
                begin_targeting(map, which_ability=1);
            }

            if pressed(*button_5) {
                begin_targeting(map, which_ability=2);
            }

            if pressed(*button_6) {
                begin_targeting(map, which_ability=3);
            }
        }

        case .TARGETING;
        {
            maybe_move_cursor(map.*);

            if pressed(*button_1) {
                use_ability(map, cursor.targeting_with);
            }

            if pressed(*button_2) {
                deselect_unit(map.*, reset_cursor=true);
            }

            if pressed(*button_3) {
                if cursor.targeting_with == *selected.primary {
                    use_ability(map, cursor.targeting_with);
                }
                else {
                    begin_targeting(map, which_ability=0);
                }
            }

            if pressed(*button_4) {
                if cursor.targeting_with == *selected.secondary {
                    use_ability(map, cursor.targeting_with);
                }
                else {
                    begin_targeting(map, which_ability=1);
                }
            }

            if pressed(*button_5) {
                if cursor.targeting_with == *selected.repair {
                    use_ability(map, cursor.targeting_with);
                }
                else {
                    begin_targeting(map, which_ability=2);
                }
            }

            if pressed(*button_6) {
                if cursor.targeting_with == *selected.board {
                    use_ability(map, cursor.targeting_with);
                }
                else {
                    begin_targeting(map, which_ability=3);
                }
            }
        }

        case .INSPECTING;
        {
            if pressed(*button_2) {
                stop_inspecting();
            }

            if pressed(*button_info) {
                stop_inspecting();
            }
        }
    }
}

maybe_move_cursor :: (map: Map) {
    using input;

    if pressed(*up) {
        move_cursor(.NORTH, map);
    }
    if pressed(*left) {
        move_cursor(.WEST, map);
    }
    if pressed(*down) {
        move_cursor(.SOUTH, map);
    }
    if pressed(*right) {
        move_cursor(.EAST, map);
    }
}

//
// Commands
//

move_cursor :: (direction : Direction, map: Map) {
    command := New(Move_Cursor_Command);
    command.direction = direction;
    command.map = map;
    array_add(*command_queue, cast(*Command)command);
}

begin_moving_unit :: (map : *Map) {
    command := New(Begin_Moving_Unit_Command);
    command.map = map;
    command.team = .YOU;
    array_add(*command_queue, cast(*Command)command);
}

show_unit_range :: (map : *Map) {
    command := New(Show_Unit_Range_Command);
    command.map = map;
    command.team = .THEM;
    array_add(*command_queue, cast(*Command)command);
}

begin_targeting :: (map : *Map, which_ability : int) {
    command := New(Begin_Targeting_Command);
    command.map = map;
    command.team = .YOU;
    assert(which_ability >= 0 && which_ability <= 3);
    command.which_ability = which_ability;
    array_add(*command_queue, cast(*Command)command);
}

use_ability :: (map : *Map, ability: *Ability) {
    command := New(Use_Ability_Command);
    command.map = map;
    command.ability = ability;
    array_add(*command_queue, cast(*Command)command);
}

deselect_unit :: (map: Map, reset_cursor := false) {
    command := New(Deselect_Unit_Command);
    command.map = map;
    command.reset_cursor = reset_cursor;
    array_add(*command_queue, cast(*Command)command);
}

place_unit :: (map : *Map) {
    command := New(Place_Unit_Command);
    command.map = map;
    array_add(*command_queue, cast(*Command)command);
}

//
//

begin_inspecting :: (map: *Map) {
    using cursor;

    array_reset(*interactible);
    array_reset(*accessible);

    assert(selected == null);
    assert(inspecting == null);

    inspecting = map.occupancy[square.col][square.row];
    if !inspecting return;

    state = .INSPECTING;
    play_sfx("selection");
}

stop_inspecting :: () {
    using cursor;

    inspecting = null;
    state = .NEUTRAL;
    play_sfx("place");
}
