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

set_turn :: (team: Team) {
    using manager;

    _, index := array_find(teams, team);
    current_turn_team_index = index;
}

whose_turn :: inline () -> Team {
    return manager.teams[manager.current_turn_team_index];
}

next_turn :: (using map: *Map) -> Team {
    using manager;

    current_turn_team_index += 1;
    if current_turn_team_index >= teams.count
        current_turn_team_index = 0;

    turn := whose_turn();
    for units {
        if it.team == turn {
            it.moved = false;
            it.exhausted = false;
        }
    }

    return whose_turn();
}
