// Tactics
// Grid
// Alex Hartford
// June 2023

cursor : struct {
    using square : Square = .{map_width / 2, map_height / 2};

    state : enum {
        NEUTRAL;
        MOVING;    // Soft limit
        TARGETING; // Hard limit?

        NONE;
    }

    selected : *Unit;
    selected_initial_square : Square = .{-1, -1};

    targeted : *Unit;

    // @TODO: We could probably combine these into one array which changes its purpose based on the mode...
    // This would simplify things on our end, and be smaller too, which would be nice.
    accessible : [..] Square;
    interactible : [..] Square;

    path : Path;
}

update_cursor :: (map : *Map) {
    using cursor;

    if state == {
        case .NONE; return;

        case .NEUTRAL;
        {
            maybe_move_cursor();

            if input.button_1 {
                begin_moving(map);
                input.button_1 = false;
            }

            if input.button_3 {
                begin_targeting(map);
                input.button_3 = false;
            }
            return;
        }

        case .MOVING;
        {
            // @LEAK: There's something going on here, we need to free the path, and I think we do, but I think this extra copy is funky.
            if maybe_move_cursor() {
                if array_find(cursor.accessible, cursor.square) {
                    new_path, success := get_shortest_path(map, selected, cursor.square);
                    if success {
                        path = new_path;
                    }
                    else {
                        array_reset(*new_path);
                    }
                }
                else {
                    array_reset(*path);
                }
            }

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
                    begin_moving(map);
                }
                else {
                    attack_target(map);
                }
                input.button_1 = false;
            }

            if input.button_2 {
                deselect_unit();
                input.button_2 = false;
            }

            if input.button_3 {
                attack_target(map);
                input.button_3 = false;
            }

            return;
        }
    }
}

//
//

begin_moving :: (map : *Map) {
    using cursor;

    if !selected {
        selected = map.occupancy[square.col][square.row];
        if !selected return;
    }
    else {
        square = selected.square;
        array_reset(*interactible);
    }

    selected_initial_square = square;
    accessible = get_accessible_squares_from_position(map, selected);

    state = .MOVING;
}

deselect_unit :: () {
    using cursor;

    if selected {
        selected_initial_square = .{-1, -1};
        array_reset(*accessible);
        array_reset(*interactible);
        array_reset(*path);

        state = .NEUTRAL;
    }
    selected = null;
}

put_unit_back :: (map : *Map) {
    using cursor;

    map.occupancy[selected.square.col][selected.square.row] = null;
    occupy(map, selected_initial_square, selected);
    selected.square = selected_initial_square;
    square = selected_initial_square;
    array_reset(*accessible);
    array_reset(*path);
    selected_initial_square = .{-1, -1};
    selected = null;

    state = .NEUTRAL;
}

place_unit :: (map : *Map) {
    using cursor;
    assert(state == .MOVING);

    square_occupant := map.occupancy[square.col][square.row];
    if square_occupant && square_occupant != selected return;
    if !array_find(accessible, square) return;

    map.occupancy[selected_initial_square.col][selected_initial_square.row] = null;
    occupy(map, square, selected);
    selected.square = square;
    array_reset(*accessible);
    array_reset(*path);

    selected = null;
    selected_initial_square = Square.{-1, -1};
    state = .NEUTRAL;
}

begin_targeting :: (map : *Map) {
    using cursor;

    if !selected {
        selected = map.occupancy[square.col][square.row];
        if !selected return;
    }
    else {
        square = selected.square;
        array_reset(*accessible);
    }

    selected_initial_square = square;
    interactible = get_interactible_squares_from_position(map, selected);

    // We might need to filter out stuff based on the type of attacks later...
    //filter_out_impassible(*interactible, map);

    state = .TARGETING;
}

attack_target :: (map : *Map) {
    using cursor;

    if !array_find(interactible, square) return;

    target := map.occupancy[square.col][square.row];
    if !target return;
    if target.team == selected.team return;

    resolve_attack(selected, target);

    deselect_unit();
}

//
//

maybe_move_cursor :: () -> moved: bool {
    moved: bool;
    if input.up {
        move_cursor(.NORTH);
        input.up = false;
        moved = true;
    }
    if input.left {
        move_cursor(.WEST);
        input.left = false;
        moved = true;
    }
    if input.down {
        move_cursor(.SOUTH);
        input.down = false;
        moved = true;
    }
    if input.right {
        move_cursor(.EAST);
        input.right = false;
        moved = true;
    }
    return moved;
}

move_cursor :: (direction : Direction) {
    using cursor;

    new_square : Square;
    if direction == {
        case .NORTH; new_square = Square.{col,   row-1};
        case .SOUTH; new_square = Square.{col,   row+1};
        case .WEST;  new_square = Square.{col-1, row};
        case .EAST;  new_square = Square.{col+1, row};
    }

    if on_grid(new_square)
        square = new_square;
}
