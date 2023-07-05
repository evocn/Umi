// Everett
// Grid
// Alex Hartford
// June 2023

// The new command architecture:
// * Inputs flow through the whole program, everything can see its state.
// * We call update_cursor every frame.
// * We only eat the inputs and change state if it's our turn.
// * Some time later, we call update_ui every frame.
// * It only eats the inputs and changes state if it's their turn.
// * Therefore, we don't put everything in one monolithic command hierarchy, but rather two.

cursor : struct {
    using square : Square = .{grid_width / 2, grid_height / 2};

    state : enum {
        NEUTRAL;
        MOVING;    // Soft limit
        DIRECTING;
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

        case .DIRECTING;
        {
            maybe_direct_unit();

            if input.button_1 {
                finish_directing_unit();
                input.button_1 = false;
            }

            if input.button_2 {
                put_unit_back(map);
                input.button_2 = false;
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
        selected = get_occupant(map, square);
        if !selected return;
    }
    else {
        square = selected.square;
        array_reset(*interactible);
    }

    selected_initial_square = square;
    accessible = get_accessible_squares_from_position(map, selected);
    filter_out_impassible(*accessible, map);

    state = .MOVING;
}

deselect_unit :: () {
    using cursor;

    if selected {
        selected_initial_square = .{-1, -1};
        array_reset(*accessible);
        array_reset(*interactible);

        state = .NEUTRAL;
    }
    selected = null;
}

put_unit_back :: (map : *Map) {
    using cursor;

    remove_occupant(map, selected.square);
    occupy(map, selected_initial_square, selected);
    selected.square = selected_initial_square;
    square = selected_initial_square;
    array_reset(*accessible);
    selected_initial_square = .{-1, -1};
    selected = null;

    state = .NEUTRAL;
}

place_unit :: (map : *Map) {
    using cursor;
    assert(state == .MOVING);

    square_occupant := get_occupant(map, square);
    if square_occupant && square_occupant != selected return;
    if !array_find(accessible, square) return;

    remove_occupant(map, selected_initial_square);
    occupy(map, square, selected);
    selected.square = square;
    array_reset(*accessible);

    state = .DIRECTING;
}

finish_directing_unit :: () {
    using cursor;

    selected = null;
    selected_initial_square = Square.{-1, -1};
    state = .NEUTRAL;
}

begin_targeting :: (map : *Map) {
    using cursor;

    if !selected {
        selected = get_occupant(map, square);
        if !selected return;
    }
    else {
        square = selected.square;
        array_reset(*accessible);
    }

    selected_initial_square = square;
    interactible = get_interactible_squares_from_position(square, max = selected.range);

    // We might need to filter out stuff based on the type of attacks later...
    //filter_out_impassible(*interactible, map);

    state = .TARGETING;
}

attack_target :: (map : *Map) {
    using cursor;

    target := get_occupant(map, square);
    if !target return;

    resolve_attack(selected, target);

    deselect_unit();
}

//
//

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

//
//

maybe_direct_unit :: () {
    using cursor;

    if input.up {
        selected.direction = .NORTH;
        input.up = false;
    }
    if input.left {
        selected.direction = .WEST;
        input.left = false;
    }
    if input.down {
        selected.direction = .SOUTH;
        input.down = false;
    }
    if input.right {
        selected.direction = .EAST;
        input.right = false;
    }
}
