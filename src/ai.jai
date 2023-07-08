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
    action_delay :: 1.0;
    action_time := 0.0;

    commands: [..] *void;
}

ai_update :: (using map: *Map, units: *[..] *Unit, dt : float) {
    using ai;

    action_time += dt;
    if action_time < action_delay
        return;

    next_turn(units);

    action_time = 0.0;
}

ai_plan :: (using map: *Map, units: *[..] Unit) {
    using ai;

    array_add(*commands, cast(*void)next_turn);
}

//
// Commands
//
