// Tactics
// AI
// Alex Hartford
// July 2023

ai : struct {
    action_delay :: 0.2;
    action_time := 0.2;
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
    available_red_units := query_units(map.units, (x) => (x.team == .RED && !x.moved));
    if !available_red_units {
        next_turn(map);
        return;
    }

    // @CONSIDER: Deterministic unit order? Make this visible to the user?
    selected := available_red_units[0];

    {
        command := New(Move_Cursor_To_Command);
        command.square = selected.square;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }
     
    {
        command := New(Begin_Moving_Unit_Command);
        command.map = map;
        command.team = .RED;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    action := action_choose(selected.*, map);

    path, success := get_shortest_path(map, selected, action.square);
    defer array_reset(*path);
    assert(success); // For now...

    move_to := move_down_path(map.*, *path, selected.*);

    {
        command := New(Move_Cursor_To_Command);
        command.square = move_to;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    {
        command := New(Place_Unit_Command);
        command.map = map;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    if action.target == null then return;

    target_in_range := (manhattan_distance(move_to, action.target.square) >= selected.min_range &&
                        manhattan_distance(move_to, action.target.square) <= selected.max_range);
    if !target_in_range then return;

    // If there is a target you can attack...
    {
        command := New(Begin_Targeting_Command);
        command.map = map;
        command.team = .RED;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    {
        command := New(Move_Cursor_To_Command);
        command.square = action.target.square;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    {
        command := New(Use_Ability_Command);
        command.map = map;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }
}

Action :: struct {
    square: Square;
    target: *Unit;
}

action_choose :: (unit: Unit, map: Map) -> Action {
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
}

action_attack_in_range :: (unit: Unit, map: Map, extended := false) -> Action {
    action: Action;

    // Find the nearest blue unit
    shortest_distance := 100;
    blue_units := query_units(map.units, (x) => (x.team == .BLUE));
    for blue_unit: blue_units {
        squares_for_this_target := get_squares_you_could_use_an_ability_from(map, unit.ability, unit, blue_unit);
        for squares_for_this_target {
            test_path, success := get_shortest_path(map, unit, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                action.square = it;
                action.target = blue_unit;
            }
        }
    }

    if shortest_distance == 100 {
        action.square = unit.square;
        action.target = null;
    }

    total_range := unit.movement + unit.max_range;
    double_range := total_range + unit.movement;
    if ((!extended && shortest_distance > total_range) ||
        (extended && shortest_distance > double_range))
        return action_wait(unit);

    if extended && shortest_distance > double_range
        action.target = null;

    return action;
}

action_pursue_and_attack_nearest :: (unit: Unit, map: Map) -> Action {
    action: Action;

    // Find the nearest blue unit
    shortest_distance := 100;
    blue_units := query_units(map.units, (x) => (x.team == .BLUE));
    for blue_unit: blue_units {
        squares_for_this_target := get_squares_you_could_use_an_ability_from(map, unit.ability, unit, blue_unit);
        for squares_for_this_target {
            test_path, success := get_shortest_path(map, unit, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                action.square = it;
                action.target = blue_unit;
            }
        }
    }

    if shortest_distance == 100 {
        action.square = unit.square;
        action.target = null;
    }

    return action;
}

action_pursue_nearest :: (unit: Unit, map: Map) -> Action {
    action: Action;

    // Find the nearest blue unit
    shortest_distance := 100;
    blue_units := query_units(map.units, (x) => (x.team == .BLUE));
    for blue_unit: blue_units {
        squares_for_this_target := get_squares_right_next_to_unit(map, unit, blue_unit);
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

    return action;
}

action_wait :: (unit: Unit) -> Action {
    action: Action;
    action.square = unit.square;
    action.target = null;

    return action;
}

action_wait_but_attack :: (unit: Unit, map: Map) -> Action {
    action: Action;

    action.square = unit.square;

    blue_units := query_units(map.units, (x) => (x.team == .BLUE));
    for blue_units {
        can_attack_target := (manhattan_distance(it.square, unit.square) >= unit.min_range && 
                              manhattan_distance(it.square, unit.square) <= unit.max_range);
        if can_attack_target {
            action.target = it;
            break;
        }
    }

    return action;
}

action_random_movement :: (unit: Unit, map: Map) -> Action {
    action: Action;

    // If a unit cannot attack, it chooses a square to go to at random.
    accessible := get_accessible_squares_from_position(map, unit);
    assert(accessible.count != 0);

    action.square = random_choice(accessible);
    action.target = null;

    return action;
}

//
// Commands
//

Move_Cursor_To_Command :: struct {
    using #as base: Command;
    kind = .MOVE_CURSOR_TO;
    square : Square;
}

execute :: (using command: *Move_Cursor_To_Command) {
    if on_grid(square)
        cursor.square = square;
}
