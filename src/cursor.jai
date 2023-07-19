// Tactics
// Grid
// Alex Hartford
// June 2023

cursor : struct {
    using square : Square = .{map_width / 2, map_height / 2};

    state : enum {
        NEUTRAL;
        MOVING;
        TARGETING;
    }

    selected : *Unit;
    selected_initial_square : Square = .{-1, -1};

    targeted : *Unit;

    accessible : [..] Square;
    interactible : [..] Square;

    path : Path;
}

cursor_update :: (using map : *Map) {
    using cursor;

    if state == {
        case .NEUTRAL;
        {
            maybe_move_cursor();

            if input.button_1 {
                begin_moving_unit(map);
                input.button_1 = false;
            }

            if input.button_3 {
                begin_targeting(map);
                input.button_3 = false;
            }

            if input.button_4 {
                next_turn(map);
                input.button_4 = false;
            }

            return;
        }

        case .MOVING;
        {
            if array_find(cursor.accessible, cursor.square) {
                array_reset(*path);
                path =, success := get_shortest_path(map, selected, cursor.square);
            }

            maybe_move_cursor();

            if input.button_1 {
                place_unit(map);
                input.button_1 = false;
            }

            if input.button_2 {
                deselect_unit();
                input.button_2 = false;
            }

            if input.button_3 {
                begin_targeting(map);
                input.button_3 = false;
            }

            return;
        }

        case .TARGETING;
        {
            maybe_move_cursor();

            if input.button_1 {
                if square == selected.square {
                    begin_moving_unit(map);
                }
                else {
                    use_ability(map);
                }
                input.button_1 = false;
            }

            if input.button_2 {
                deselect_unit();
                input.button_2 = false;
            }

            if input.button_3 {
                use_ability(map);
                input.button_3 = false;
            }

            return;
        }
    }
}

maybe_move_cursor :: () {
    if input.up {
        move_cursor(.NORTH);
        input.up = false;
    }
    if input.left {
        move_cursor(.WEST);
        input.left = false;
    }
    if input.down {
        move_cursor(.SOUTH);
        input.down = false;
    }
    if input.right {
        move_cursor(.EAST);
        input.right = false;
    }
}

//
// Commands
//

move_cursor :: (direction : Direction) {
    command := New(Move_Cursor_Command);
    command.direction = direction;
    array_add(*command_queue, cast(*Command)command);
}

begin_moving_unit :: (map : *Map) {
    command := New(Begin_Moving_Unit_Command);
    command.map = map;
    command.team = .BLUE;
    array_add(*command_queue, cast(*Command)command);
}

begin_targeting :: (map : *Map) {
    command := New(Begin_Targeting_Command);
    command.map = map;
    command.team = .BLUE;
    array_add(*command_queue, cast(*Command)command);
}

deselect_unit :: () {
    command := New(Deselect_Unit_Command);
    array_add(*command_queue, cast(*Command)command);
}

place_unit :: (map : *Map) {
    command := New(Place_Unit_Command);
    command.map = map;
    array_add(*command_queue, cast(*Command)command);
}

use_ability :: (map : *Map) {
    command := New(Use_Ability_Command);
    command.map = map;
    array_add(*command_queue, cast(*Command)command);
}
