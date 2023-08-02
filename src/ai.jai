// Umi
// AI
// Alex Hartford
// July 2023

ai : struct {
    action_delay :: 0.15;
    action_time := 0.15;

    to_check : [] *Unit;
}

ai_update :: (using map: *Map, dt : float) {
    using ai;

    action_time += dt;
    if action_time < action_delay
        return;

    action_time = 0.0;

    if command_queue {
        next := pop(*command_queue);
        //log("Executing %.\n", next.kind);
        execute(next);
        free(next);
    }
    else {
        array_reset(*command_queue);
        ai_plan(map);
    }
}

ai_plan :: (using map: *Map) {
    using ai;

    // Find Red Unit
    if !to_check {
        next_turn(map);
        array_reset(*to_check);
        return;
    }

    selected := pop(*to_check);

    action := action_choose(selected, map);

    path, success := get_shortest_path(map, selected, action.square);
    defer array_reset(*path);
    assert(success); // For now...

    move_to := move_down_path(map.*, *path, selected.*);

    if action.square != selected.square {
        {
            command := New(Move_Cursor_To_Command);
            command.square = selected.square;
            command.map = map.*;
            array_insert_at(*command_queue, cast(*Command)command, 0);
        }

        {
            command := New(Begin_Moving_Unit_Command);
            command.map = map;
            command.team = .THEM;
            array_insert_at(*command_queue, cast(*Command)command, 0);
        }

        {
            command := New(Move_Cursor_To_Command);
            command.square = move_to;
            command.map = map.*;
            array_insert_at(*command_queue, cast(*Command)command, 0);
        }

        {
            command := New(Place_Unit_Command);
            command.map = map;
            array_insert_at(*command_queue, cast(*Command)command, 0);
        }
    }
    else if action.target != null {
        command := New(Move_Cursor_To_Command);
        command.square = selected.square;
        command.map = map.*;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    if action.target == null then return;
    if action.ability == null then return;

    target_in_range := (manhattan_distance(move_to, action.target.square) >= action.ability.min_range &&
                        manhattan_distance(move_to, action.target.square) <= action.ability.max_range);
    if action.ability.targeting == .SELF then target_in_range = true;

    if !target_in_range then return;

    which_ability := 0;
    if action.ability.targeting == .SELF {
        which_ability = 2;
    }

    // If there is a target you can attack...
    {
        command := New(Begin_Targeting_Command);
        command.map = map;
        command.team = .THEM;
        command.which_ability = which_ability;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    {
        command := New(Move_Cursor_To_Command);
        command.square = action.target.square;
        command.map = map.*;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    {
        command := New(Use_Ability_Command);
        command.map = map;
        command.ability = action.ability;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }
}

Action :: struct {
    square: Square;
    target: *Unit;
    ability: *Ability;
}

action_choose :: (unit: *Unit, map: Map) -> Action {
    if unit.health <= 1 {
        print("Repairing.");
        return action_repair(unit);
    }

    if unit.primary.targeting == {
        case .ORTHOGRAPHIC;
            #through;
        case .ENEMY;
        if #complete unit.ai == {
            case .NO_BEHAVIOR;          return action_wait(unit);
            case .PURSUE;               return action_pursue_and_attack_nearest(unit, map);
            case .PURSUE_AFTER_1;       if manager.turn_number < 1 then return action_attack_in_range(unit, map); else return action_pursue_and_attack_nearest(unit, map);
            case .PURSUE_AFTER_2;       if manager.turn_number < 2 then return action_attack_in_range(unit, map); else return action_pursue_and_attack_nearest(unit, map);
            case .PURSUE_AFTER_3;       if manager.turn_number < 3 then return action_attack_in_range(unit, map); else return action_pursue_and_attack_nearest(unit, map);
            case .BOSS;                 return action_wait_but_attack(unit, map);
            case .ATTACK_IN_RANGE;      return action_attack_in_range(unit, map);
            case .ATTACK_IN_TWO;        return action_attack_in_range(unit, map, extended=true);
            case .FLEE;                 return action_wait(unit);
            case .TREASURE_THEN_FLEE;   return action_wait(unit);
        }

        case;
        log_error("This unit's AI cannot make choices for this ability yet! Wait for Alex!\n");
        return action_wait(unit);
    }

}

action_attack_in_range :: (unit: *Unit, map: Map, extended := false) -> Action {
    action: Action;

    ability : *Ability;
    if random_get_zero_to_one() > 0.5 {
        ability = *unit.primary;
    }
    else {
        ability = *unit.board;
    }

    // Find the nearest player unit
    shortest_distance := 100;
    player_units := query_units(map.units, (x) => (x.team == .YOU));
    for player_unit: player_units {
        squares_for_this_target := get_squares_you_could_use_an_ability_from(map, ability.*, unit, player_unit);
        filter_out_death(*squares_for_this_target, map, unit);
        for squares_for_this_target {
            test_path, success := get_shortest_path(map, unit, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                action.square = it;
                action.target = player_unit;
            }
        }
    }

    if shortest_distance == 100 {
        action.square = unit.square;
        action.target = null;
    }

    total_range := unit.movement + unit.primary.max_range;
    double_range := total_range + unit.movement;
    if ((!extended && shortest_distance > total_range) ||
        (extended && shortest_distance > double_range))
        return action_wait(unit);

    if extended && shortest_distance > double_range
        action.target = null;

    action.ability = ability;

    return action;
}

action_pursue_and_attack_nearest :: (unit: *Unit, map: Map) -> Action {
    action: Action;

    ability : *Ability;
    if random_get_zero_to_one() > 0.5 {
        ability = *unit.primary;
    }
    else {
        ability = *unit.board;
    }

    // Find the nearest player unit
    shortest_distance := 100;
    player_units := query_units(map.units, (x) => (x.team == .YOU));
    for player_unit: player_units {
        squares_for_this_target := get_squares_you_could_use_an_ability_from(map, ability.*, unit, player_unit);
        filter_out_death(*squares_for_this_target, map, unit);
        for squares_for_this_target {
            test_path, success := get_shortest_path(map, unit, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                action.square = it;
                action.target = player_unit;
            }
        }
    }

    if shortest_distance == 100 {
        action.square = unit.square;
        action.target = null;
    }

    action.ability = ability;

    return action;
}

action_pursue_nearest :: (unit: *Unit, map: Map) -> Action {
    action: Action;

    // Find the nearest player unit
    shortest_distance := 100;
    player_units := query_units(map.units, (x) => (x.team == .YOU));
    for player_unit: player_units {
        squares_for_this_target := get_squares_right_next_to_unit(map, unit, player_unit);
        filter_out_death(*squares_for_this_target, map, unit);
        for squares_for_this_target {
            test_path, success := get_shortest_path(map, unit, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                action.square = it;
            }
        }
    }

    if shortest_distance == 100 {
        action.square = unit.square;
    }

    action.target = null;

    action.ability = null;

    return action;
}

action_repair :: (unit: *Unit) -> Action {
    action: Action;
    action.square = unit.square;
    action.target = unit;
    action.ability = *unit.repair;

    return action;
}

action_wait :: (unit: *Unit) -> Action {
    action: Action;
    action.square = unit.square;
    action.target = null;
    action.ability = null;


    return action;
}

action_wait_but_attack :: (unit: *Unit, map: Map) -> Action {
    action: Action;

    ability : *Ability;
    if random_get_zero_to_one() > 0.5 {
        ability = *unit.primary;
    }
    else {
        ability = *unit.board;
    }

    action.square = unit.square;
    action.ability = null;

    player_units := query_units(map.units, (x) => (x.team == .YOU));
    for player_units {
        can_attack_target := (manhattan_distance(it.square, unit.square) >= ability.min_range && 
                              manhattan_distance(it.square, unit.square) <= ability.max_range);
        if can_attack_target {
            action.target = it;
            action.ability = ability;
            break;
        }
    }

    return action;
}

action_random_movement :: (unit: *Unit, map: Map) -> Action {
    action: Action;

    // If a unit cannot attack, it chooses a square to go to at random.
    accessible := get_accessible_squares_from_position(map, unit);
    filter_out_death(*accessible, map, unit);

    assert(accessible.count != 0);

    action.square = random_choice(accessible);
    action.target = null;
    action.ability = null;


    return action;
}

//
// Commands
//

Move_Cursor_To_Command :: struct {
    using #as base: Command;
    kind = .MOVE_CURSOR_TO;
    square : Square;
    map: Map;
}

execute :: (using command: *Move_Cursor_To_Command) {
    if on_grid(square, map)
        cursor.square = square;

    set_viewport_to_contain(square, map);
}
