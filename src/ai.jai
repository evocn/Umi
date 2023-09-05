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

        before := get_time();
        ai_plan(map);
        after := get_time();
        print("AI planning took % s.\n", after - before);
    }
}

ai_plan :: (using map: *Map) {
    using ai;

    ZoneScoped("outer");

    // Find Red Unit
    if !to_check {
        next_turn(map);
        return;
    }

    selected := pop(*to_check);
    action := action_choose(selected, map);

    while action.stay_put {
        ZoneScoped("looking for enemy\n");

        // Find Red Unit
        if !to_check {
            next_turn(map);
            return;
        }

        selected = pop(*to_check);
        action = action_choose(selected, map);
    }

    traversed := traverse(map, selected.square, selected.team, pass=cast(bool)(selected.flags & .PASS));
    path, success := get_shortest_path(traversed, map, selected, action.square);
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
            command.team = selected.team;
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
        command.team = selected.team;
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


action_choose :: (unit: *Unit, map: Map) -> Action {
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

//
//

Action :: struct {
    stay_put : bool;
    square: Square;
    target: *Unit;
    ability: *Ability;
}

//
//

action_wait :: (unit: *Unit) -> Action {
    action: Action;
    action.square = unit.square;
    action.target = null;
    action.ability = null;
    action.stay_put = true;

    return action;
}

NO_TARGET_DEFAULT :: 900;

action_attack_in_range :: (unit: *Unit, map: Map, extended := false) -> Action {
    action : Action;
    ability := *unit.board;
    
    // Find the nearest player unit
    shortest_distance := NO_TARGET_DEFAULT;
    enemy_units := get_enemy_units(map, unit.team);

    traversed := traverse(map, unit.square, unit.team);
    for enemy_unit : enemy_units {
        squares_for_this_target := get_squares_you_could_use_an_ability_from(map, ability.*, unit, enemy_unit);
        //squares_for_this_target := Square.[];
        filter_out_death(*squares_for_this_target, map, unit);

        for squares_for_this_target {
            test_path, success := get_shortest_path(traversed, map, unit, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                action.square = it;
                action.target = enemy_unit;
            }
        }
    }

    if shortest_distance == NO_TARGET_DEFAULT {
        action.square = unit.square;
        action.target = null;
        return action;
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
    shortest_distance := NO_TARGET_DEFAULT;
    enemy_units := get_enemy_units(map, unit.team);

    traversed := traverse(map, unit.square, unit.team, pass=cast(bool)(unit.flags & .PASS));

    for enemy_unit: enemy_units {
        squares_for_this_target := get_squares_you_could_use_an_ability_from(map, ability.*, unit, enemy_unit);
        //squares_for_this_target : [..] Square;
        filter_out_death(*squares_for_this_target, map, unit);

        for squares_for_this_target {
            test_path, success := get_shortest_path(traversed, map, unit, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                action.square = it;
                action.target = enemy_unit;
            }
        }
    }

    if shortest_distance == NO_TARGET_DEFAULT {
        action.square = unit.square;
        action.target = null;
    }

    action.ability = ability;

    return action;
}

action_wait_but_attack :: (unit: *Unit, map: Map) -> Action {
    action: Action;

    ability := *unit.primary;

    action.square = unit.square;
    action.ability = null;

    enemy_units := get_enemy_units(map, unit.team);
    for enemy_units {
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
