// Tactics
// Manager
// Alex Hartford
// July 2023

manager : struct {
    teams := Team.[.BLUE, .RED];
    current_turn_team_index : int;
}

Team :: enum {
    NONE;
    BLUE;
    RED;
}

//
//

whose_turn :: inline () -> Team {
    return manager.teams[manager.current_turn_team_index];
}

next_turn :: (units: *[..] *Unit) -> Team {
    using manager;

    current_turn_team_index += 1;
    if current_turn_team_index >= teams.count
        current_turn_team_index = 0;

    turn := whose_turn();
    for units.* {
        if it.team == turn {
            it.moved = false;
            it.exhausted = false;
        }
    }

    return whose_turn();
}
