// Tactics
// Command
// Alex Hartford
// July 2023

command_queue : [..] *Command;

//
//

Move_Cursor_Command :: struct {
    using #as base: Command;
    kind = .MOVE_CURSOR;
    direction: Direction;
    map: Map;
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

    if !on_grid(new_square, map) return;
    square = new_square;

    maybe_move_viewport(map, square);

    play_sfx("move");
}


Begin_Moving_Unit_Command :: struct {
    using #as base: Command;
    kind = .BEGIN_MOVING_UNIT;
    map: *Map;
    team: Team;
}

execute :: (using command: *Begin_Moving_Unit_Command) {
    using cursor;

    array_reset(*interactible);
    array_reset(*accessible);

    assert(selected == null);
    selected = map.occupancy[square.col][square.row];
    if !selected return;

    if selected.team != team {
        selected = null;
        return;
    }

    if selected.moved {
        selected = null;
        return;
    }

    selected_initial_square = square;
    accessible = get_accessible_squares_from_position(map, selected);

    state = .MOVING;

    play_sfx("selection");
}

Show_Unit_Range_Command :: struct {
    using #as base: Command;
    kind = .SHOW_UNIT_RANGE;
    map: *Map;
    team: Team;
}

execute :: (using command: *Show_Unit_Range_Command) {
    using cursor;

    if selected {
        return;
    }

    the_unit := get_occupant(map.*, cursor.square);
    if !the_unit return;

    array_reset(*interactible);
    array_reset(*accessible);

    assert(the_unit.team != .YOU);

    accessible = get_accessible_squares_from_position(map, the_unit);
    for accessible {
        new_interactible := get_ability_squares_from_position(map, the_unit.primary, the_unit, it);
        defer array_reset(*new_interactible);
        for new_interactible {
            array_add_if_unique(*interactible, it);
        }
    }

    play_sfx("selection");
}


Begin_Targeting_Command :: struct {
    using #as base: Command;
    kind = .BEGIN_TARGETING;
    map: *Map;
    team: Team;
    use_secondary : bool;
}

execute :: (using command: *Begin_Targeting_Command) {
    using cursor;

    if selected { // Switching from move mode
        if use_secondary && !selected.secondary_active {
            return;
        }

        array_reset(*path);

        if selected.exhausted
            return;

        square = selected.square;
    }
    else { // Targeting with new unit
        selected = map.occupancy[square.col][square.row];
        if !selected return;

        if use_secondary && !selected.secondary_active {
            selected = null;
            return;
        }

        if selected.team != team {
            selected = null;
            return;
        }

        if selected.exhausted {
            selected = null;
            return;
        }
    }

    array_reset(*interactible);
    array_reset(*accessible);

    ability: *Ability;
    if use_secondary {
        ability = *selected.secondary;
        state = .TARGETING_SECONDARY;
    }
    else {
        ability = *selected.primary;
        state = .TARGETING_PRIMARY;
    }

    selected_initial_square = square;
    if ability.targeting == {
        case .ORTHOGRAPHIC;
            interactible = get_orthographic_squares_from_position(map, ability.*, selected, selected.square);

        case .PORT;
            interactible = get_orthographic_squares_from_position(map, ability.*, selected, selected.square);
            filter_get_port(*interactible, selected.square, selected.direction);

        case .STARBOARD;
            interactible = get_orthographic_squares_from_position(map, ability.*, selected, selected.square);
            filter_get_starboard(*interactible, selected.square, selected.direction);

        case .PORT_AND_STARBOARD;
            interactible = get_orthographic_squares_from_position(map, ability.*, selected, selected.square);
            filter_get_port_and_starboard(*interactible, selected.square, selected.direction);

        case .FORE;
            interactible = get_orthographic_squares_from_position(map, ability.*, selected, selected.square);
            filter_get_fore(*interactible, selected.square, selected.direction);

        case .AFT;
            interactible = get_orthographic_squares_from_position(map, ability.*, selected, selected.square);
            filter_get_aft(*interactible, selected.square, selected.direction);

        case;
            interactible = get_ability_squares_from_position(map, ability.*, selected, selected.square);
    }

    // Filter ability use squares based on the type of the ability.
    if ability.targeting == {
        case .EMPTY_SQUARE;
        filter_out_impassible(*interactible, map);
        filter_out_occupied(*interactible, map);

        // @TODO: This is where things go now
    }

    play_sfx("selection");
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

    if square_occupant {
        if square_occupant == selected {
            selected.moved = true;
            deselect_unit(map.*);
            return;
        }
        else {
            return;
        }
    }

    if !array_find(accessible, square) then return;

    remove_occupant(map, selected_initial_square);
    occupy(map, square, selected);
    selected.square = square;

    selected.moved = true;

    resolve_landing_effects(map, selected);

    deselect_unit(map.*);
}


Use_Ability_Command :: struct {
    using #as base: Command;
    kind = .USE_ABILITY;
    map: *Map;
    ability: *Ability;
}

execute :: (using command: *Use_Ability_Command) {
    using cursor;

    if !array_find(interactible, square) return;

    if has_target(ability.*) {
        target := map.occupancy[square.col][square.row];
        if !target return;

        // Filter on what units you should be able to use the ability for.
        if ability.targeting == {
            case .ENEMY;
            if target.team == selected.team return;

            case .ALLY; #through;
            case .SELF;
            if target.team != selected.team return;

            case .ANY;
        }

        resolve_ability(map, ability, selected, target, square);
    }
    else {
        resolve_ability(map, ability, selected, null, square);
    }

    selected.exhausted = true;

    reset_cursor := true;
    if ability.special == .WARP {
        reset_cursor = false;
    }

    deselect_unit(map.*, reset_cursor=reset_cursor);
}


Deselect_Unit_Command :: struct {
    using #as base: Command;
    kind = .DESELECT_UNIT;
    map: Map;
    reset_cursor : bool;
}

execute :: (using command: *Deselect_Unit_Command) {
    using cursor;

    if selected {
        if reset_cursor {
            assert(selected_initial_square != .{-1, -1});
            square = selected_initial_square;
            set_viewport_to_contain(square, map);
        }

        play_sfx("place");
    }

    selected_initial_square = .{-1, -1};
    array_reset(*accessible);
    array_reset(*interactible);
    array_reset(*path);

    state = .NEUTRAL;
    selected = null;
}

//
//

Command :: struct {
    kind : Command_Kind;
}

Command_Kind :: enum #complete {
    MOVE_CURSOR;
    BEGIN_MOVING_UNIT;
    SHOW_UNIT_RANGE;
    BEGIN_TARGETING;
    PLACE_UNIT;
    USE_ABILITY;
    DESELECT_UNIT;

    MOVE_CURSOR_TO;
}

execute :: (using command: *Command) {
    if kind == {
        case .MOVE_CURSOR;
        execute(cast(*Move_Cursor_Command)command);

        case .BEGIN_MOVING_UNIT;
        execute(cast(*Begin_Moving_Unit_Command)command);

        case .SHOW_UNIT_RANGE;
        execute(cast(*Show_Unit_Range_Command)command);

        case .BEGIN_TARGETING;
        execute(cast(*Begin_Targeting_Command)command);

        case .PLACE_UNIT;
        execute(cast(*Place_Unit_Command)command);

        case .USE_ABILITY;
        execute(cast(*Use_Ability_Command)command);

        case .DESELECT_UNIT;
        execute(cast(*Deselect_Unit_Command)command);

        case .MOVE_CURSOR_TO;
        execute(cast(*Move_Cursor_To_Command)command);
    }
}

//
//
