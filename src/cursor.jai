// Tactics
// Grid
// Alex Hartford
// June 2023

cursor : struct {
    using square : Square;

    state : enum {
        NEUTRAL;
        MOVING;
        TARGETING_PRIMARY;
        TARGETING_SECONDARY;
        INSPECTING;
    }

    selected : *Unit;
    selected_initial_square : Square = .{-1, -1};

    accessible : [..] Square;

    path : Path;

    targeted : *Unit;
    interactible : [..] Square;

    inspecting : *Unit;
}

resolve_cursor_inputs :: (using map : *Map) {
    using cursor;
    using input;

    if pressed(*button_menu) {
        program_mode = .MENU;
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
                begin_targeting(map, use_secondary=false);
            }

            if pressed(*button_4) {
                begin_targeting(map, use_secondary=true);
            }

            if pressed(*button_5) {
                turn_vessel(map, left=true);
            }

            if pressed(*button_6) {
                turn_vessel(map);
            }

            if pressed(*button_select) {
                next_turn(map);
            }

            if pressed(*button_info) {
                begin_inspecting(map);
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
                begin_targeting(map, use_secondary=false);
            }

            if pressed(*button_4) {
                begin_targeting(map, use_secondary=true);
            }
        }

        case .TARGETING_PRIMARY;
        {
            maybe_move_cursor(map.*);

            if pressed(*button_1) {
                use_ability(map, *selected.primary);
            }

            if pressed(*button_2) {
                deselect_unit(map.*, reset_cursor=true);
            }

            if pressed(*button_3) {
                use_ability(map, *selected.primary);
            }

            if pressed(*button_4) {
                begin_targeting(map, use_secondary=true);
            }
        }

        case .TARGETING_SECONDARY;
        {
            maybe_move_cursor(map.*);

            if pressed(*button_1) {
                use_ability(map, *selected.secondary);
            }

            if pressed(*button_2) {
                deselect_unit(map.*, reset_cursor=true);
            }

            if pressed(*button_3) {
                begin_targeting(map, use_secondary=false);
            }

            if pressed(*button_4) {
                use_ability(map, *selected.secondary);
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

begin_targeting :: (map : *Map, use_secondary : bool) {
    command := New(Begin_Targeting_Command);
    command.map = map;
    command.team = .YOU;
    command.use_secondary = use_secondary;
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

turn_vessel :: (map: *Map, left := false) {
    using cursor;

    array_reset(*interactible);
    array_reset(*accessible);

    vessel := get_occupant(map.*, square);

    if !vessel then return;

    if !vessel.turned {
        turn(vessel, left);
        vessel.turned = true;
        return;
    }

    if vessel.turned && !vessel.moved {
        turn(vessel, left);
        vessel.moved = true;
        return;
    }
}
