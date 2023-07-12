// Tactics
// AI
// Alex Hartford
// July 2023

/*
The goal of this system is to create a simple struct which uses some logic to generate commands.
Commands are plain functions. Things like move_cursor() and place_unit().
The structure will have some form of planning logic which will generate a list of commands,
then over the AI's turn, those commands will be applied.
*/

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

    move_to : Square;

    // If a unit cannot attack, it chooses a square to go to at random.
    if selected.ability.min_range == 0 && selected.ability.max_range == 0 {
        accessible := get_accessible_squares_from_position(map.*, selected);
        assert(accessible.count != 0);

        // @TODO: Different behaviors!
        move_to = random_choice(accessible);

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

        return;
    }

    // Find Blue Unit
    target : *Unit;

    shortest_distance := 100;
    blue_units := query_units(map.units, (x) => (x.team == .BLUE));
    for blue: blue_units {
        squares_for_this_target := get_squares_you_could_use_an_ability_from(map.*, selected.ability, selected, blue);
        for squares_for_this_target {
            test_path, success := get_shortest_path(map, selected, it);
            defer array_reset(*test_path);
            if !success continue;

            if test_path.count < shortest_distance {
                shortest_distance = test_path.count;
                move_to = it;
                target = blue;
            }
        }
    }


    // If there are no squares you could attack a unit from...
    if shortest_distance == 100 {
        print("No possible squares to attack a unit from.\n");
        {
            command := New(Place_Unit_Command);
            command.map = map;
            array_insert_at(*command_queue, cast(*Command)command, 0);
        }

        return;
    }

    path, success := get_shortest_path(map, selected, move_to);
    defer array_reset(*path);
    assert(success); // For now...

    move_to = move_down_path(map.*, *path, selected.*);

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

    if path.count != 1 then return;

    // If there is a target you can attack...
    {
        command := New(Begin_Targeting_Command);
        command.map = map;
        command.team = .RED;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    {
        command := New(Move_Cursor_To_Command);
        command.square = target.square;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }

    {
        command := New(Use_Ability_Command);
        command.map = map;
        array_insert_at(*command_queue, cast(*Command)command, 0);
    }
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
