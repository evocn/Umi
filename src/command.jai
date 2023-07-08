// Tactics
// Command
// Alex Hartford
// July 2023

command_queue : [..] *Command;

Command_Kind :: enum #complete {
    MOVE_CURSOR;
    BEGIN_MOVING_UNIT;
    BEGIN_TARGETING;
    PLACE_UNIT;
    ATTACK_TARGET;
    DESELECT_UNIT;
}

Command :: struct {
    kind : Command_Kind;
}

execute :: (using command: *Command) {
    if kind == {
        case .MOVE_CURSOR;
        execute(cast(*Move_Cursor_Command)command);

        case .BEGIN_MOVING_UNIT;
        execute(cast(*Begin_Moving_Unit_Command)command);

        case .BEGIN_TARGETING;
        execute(cast(*Begin_Targeting_Command)command);

        case .PLACE_UNIT;
        execute(cast(*Place_Unit_Command)command);

        case .ATTACK_TARGET;
        execute(cast(*Attack_Target_Command)command);

        case .DESELECT_UNIT;
        execute(cast(*Deselect_Unit_Command)command);
    }
}

//
//

Move_Cursor_Command :: struct {
    using #as base: Command;
    kind = .MOVE_CURSOR;
    direction: Direction;
}

execute :: (using command: *Move_Cursor_Command) {
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


Begin_Moving_Unit_Command :: struct {
    using #as base: Command;
    kind = .BEGIN_MOVING_UNIT;
    map: *Map;
}

execute :: (using command: *Begin_Moving_Unit_Command) {
    using cursor;

    if selected { // Switching from using ability mode
        if selected.moved
            return;

        square = selected.square;
        array_reset(*interactible);
    }
    else { // Selecting new unit
        selected = map.occupancy[square.col][square.row];
        if !selected return;

        if selected.team != .BLUE {
            selected = null;
            return;
        }

        if selected.moved {
            selected = null;
            return;
        }
    }

    selected_initial_square = square;
    accessible = get_accessible_squares_from_position(map, selected);

    state = .MOVING;
}


Begin_Targeting_Command :: struct {
    using #as base: Command;
    kind = .BEGIN_TARGETING;
    map: *Map;
}

execute :: (using command: *Begin_Targeting_Command) {
    using cursor;

    if selected { // Switching from move mode
        if selected.exhausted
            return;

        square = selected.square;
        array_reset(*accessible);
    }
    else { // Targeting with new unit
        selected = map.occupancy[square.col][square.row];
        if !selected return;

        if selected.team != .BLUE {
            selected = null;
            return;
        }

        if selected.exhausted {
            selected = null;
            return;
        }
    }

    selected_initial_square = square;
    interactible = get_interactible_squares_from_position(map, selected);

    // We might need to filter out stuff based on the type of attacks later...
    //filter_out_impassible(*interactible, map);

    state = .TARGETING;
}


Place_Unit_Command :: struct {
    using #as base: Command;
    kind = .PLACE_UNIT;
    map: *Map;
}

execute :: (using command: *Place_Unit_Command) {
    using cursor;
    assert(state == .MOVING);

    square_occupant := map.occupancy[square.col][square.row];
    if square_occupant && square_occupant != selected return;
    if !array_find(accessible, square) return;

    remove_occupant(map, selected_initial_square);
    occupy(map, square, selected);
    selected.square = square;

    selected.moved = true;

    // Resolve gameplay tile effects
    {
        using tile := *map.tiles[square.col][square.row];

        if tile_kind == {
            case .KILL;
            kill(selected);

            case .HOLE;
            if !cast(bool)(selected.unit_flags & .FLYING)
                kill(selected);

            case .MINE;
            kill(selected);
            tile_kind = .NONE;
            sprite_index = default_tile_sprite_index(.NONE);

            case .REWARD;
            tile_kind = .SPENT_REWARD;
            sprite_index = default_tile_sprite_index(.SPENT_REWARD);
            print("You get a reward now!\n");

            case .OBJECTIVE;
            print("You finished the level!\n");
        }
    }

    deselect_unit();
}


Attack_Target_Command :: struct {
    using #as base: Command;
    kind = .ATTACK_TARGET;
    map: *Map;
}

execute :: (using command: *Attack_Target_Command) {
    using cursor;

    if !array_find(interactible, square) return;

    target := map.occupancy[square.col][square.row];
    if !target return;
    if target.team == selected.team return;

    resolve_attack(selected, target);

    selected.exhausted = true;
    // @CONSIDER: It might be interesting if you could move after attack, but for now attacking also uses your movement.
    selected.moved = true;

    deselect_unit();
}


Deselect_Unit_Command :: struct {
    using #as base: Command;
    kind = .DESELECT_UNIT;
}


execute :: (using command: *Deselect_Unit_Command) {
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
