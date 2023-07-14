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
    USE_ABILITY;
    DESELECT_UNIT;

    MOVE_CURSOR_TO;
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
    team: Team;
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

        if selected.team != team {
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
    team: Team;
}

execute :: (using command: *Begin_Targeting_Command) {
    using cursor;

    if selected { // Switching from move mode
        array_reset(*path);

        if selected.exhausted
            return;

        square = selected.square;
        array_reset(*accessible);
    }
    else { // Targeting with new unit
        selected = map.occupancy[square.col][square.row];
        if !selected return;

        if selected.team != team {
            selected = null;
            return;
        }

        if selected.exhausted {
            selected = null;
            return;
        }
    }

    selected_initial_square = square;
    interactible = get_ability_squares_from_position(map, selected.ability, selected);

    // Filter ability use squares based on the type of the ability.
    if selected.ability.ability_kind == {
        case .WARP;
        filter_out_impassible(*interactible, map);
        filter_out_occupied(*interactible, map);
    }

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

    if square_occupant {
        if square_occupant == selected {
            selected.moved = true;
            deselect_unit();
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

    deselect_unit();
}


Use_Ability_Command :: struct {
    using #as base: Command;
    kind = .USE_ABILITY;
    map: *Map;
}

execute :: (using command: *Use_Ability_Command) {
    using cursor;

    if !array_find(interactible, square) return;

    ability_has_target : bool;
    {
        using k := selected.ability.ability_kind;
        ability_has_target = (k == .ATTACK || 
                              k == .PARALYZE || 
                              k == .SHIELD_BUFF || 
                              k == .AUGMENT_BUFF || 
                              k == .SPEED_BUFF || 
                              k == .PUSH || 
                              k == .DANCE
                             );
    }

    if ability_has_target {
        target := map.occupancy[square.col][square.row];
        if !target return;

        // Filter on what units you should be able to use the ability for.
        if selected.ability.ability_kind == {
            case .ATTACK;        #through;
            case .PARALYZE;
            if target.team == selected.team return;

            case .SHIELD_BUFF;   #through;
            case .AUGMENT_BUFF;  #through;
            case .SPEED_BUFF;
            if target.team != selected.team return;

            case .PUSH;
        }

        resolve_ability(map, selected, target, square);
    }
    else {
        resolve_ability(map, selected, null, square);
    }

    selected.exhausted = true;
    // @CONSIDER: It might be interesting if you could move after attack, but for now attacking also uses your movement.
    // Think of like a canto-type ability.
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
