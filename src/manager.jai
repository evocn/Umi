// Tactics
// Manager
// Alex Hartford
// July 2023

manager : struct {
    turn_number := 0;
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

    if turn == .BLUE then turn_number += 1;

    for units {
        if it.team == turn {
            if cast(bool)(it.effects & .PARALYZED) {
                it.moved = true;
                it.exhausted = true;
                it.effects = 0;
                continue;
            }

            it.moved = false;
            it.exhausted = false;
            it.effects = 0;
        }
    }

    return whose_turn();
}
