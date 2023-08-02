// Umi
// Manager
// Alex Hartford
// July 2023

manager : struct {
    turn_number := 0;
    teams := Team.[.YOU, .THEM];
    current_turn_team_index : int;
}

Team :: enum {
    NONE;
    YOU;
    THEM;
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
            apply_status_effects(it);

            if it.sinking != 0 {
                it.moved = true;
                it.exhausted = true;
                it.sinking -= 1;
                if it.sinking == 0 {
                    kill(it);
                }
            }
        }
    }

    if turn == .YOU then turn_number += 1;

    if turn == .THEM {
        ai.to_check = array_copy(query_units(map.units, (x) => (x.team == .THEM && !x.moved)));
    }

    return whose_turn();
}
