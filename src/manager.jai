// Umi
// Manager
// Alex Hartford
// July 2023

// @Improvement: teams can be stored as just an int, keeping track of which teams exist on a given level.

manager : struct {
    turn_number := 0;
    teams := Team.[.MURAKAMI, .WAKO, .ODA, .MORI];
    current_turn_team_index : int;
}

Team :: enum {
    NONE;
    MURAKAMI;
    WAKO;
    ODA;
    MORI;
}

Team_Info :: struct {
    captain : Captain;
    color : Color;
    enemies : [3] Team;
}

Murakami :: Team_Info.{captain=.TAKEDA, color=color_1, enemies=.[.WAKO, .ODA, .NONE]};
Wako     :: Team_Info.{captain=.LIMAHONG, color=color_2, enemies=.[.MURAKAMI, .MORI, .NONE]};
Oda      :: Team_Info.{captain=.YOSHITAKA, color=color_3, enemies=.[.MURAKAMI, .MORI, .NONE]};
Mori     :: Team_Info.{captain=.MOTONARI, color=color_4, enemies=.[.WAKO, .ODA, .NONE]};

get_team_information :: (team : Team) -> Team_Info {
    if #complete team == {
        case .NONE;     return .{};
        case .MURAKAMI; return Murakami;
        case .WAKO;     return Wako;
        case .ODA;      return Oda;
        case .MORI;     return Mori;
    }
}

get_enemy_units :: (map : Map, team : Team) -> [] *Unit {
    enemies := get_team_information(team).enemies;

    result : [..] *Unit;
    result.allocator = temp;

    for map.units {
        if it.team == enemies[0] || it.team == enemies[1] || it.team == enemies[2]
            array_add(*result, it);
    }

    return result;
}

team_color :: (team : Team) -> Color {
    info := get_team_information(team);
    return info.color;
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

any_left_on_current_team :: (map : Map) -> bool {
    for map.units {
        if it.team == whose_turn() {
            return true;
        }
    }

    return false;
}

next_turn :: (using map: *Map) -> Team {
    using manager;

    if map.units.count == 0 {
        return .NONE;
    }

    // Go to the next team's index (skipping empty teams)
    {
        current_turn_team_index += 1;
        if current_turn_team_index >= teams.count
            current_turn_team_index = 0;
        while !any_left_on_current_team(map.*) {
            current_turn_team_index += 1;
            if current_turn_team_index >= teams.count
                current_turn_team_index = 0;
        }
    }

    turn := whose_turn();

    for units {
        if it.team == turn {
            it.moved = false;
            it.exhausted = false;
            apply_status_effects(it);

            if it.sinking != 0 {
                it.moved = true;
                it.sinking -= 1;
                if it.sinking == 0 {
                    kill(it);
                }
            }
        }
    }

    if turn == .MURAKAMI {
        turn_number += 1;

        put_cursor_over_commander(map.*);
    }
    else {
        ai.to_check = array_copy(query_units(map.units, (x) => (x.team == whose_turn() && !x.moved)));
    }

    return whose_turn();
}


put_cursor_over_commander :: (map: Map) {
    for map.units {
        if it.team == .MURAKAMI {
            if it.captain == .YOUNG_TAKEDA || it.captain == .TAKEDA {
                cursor.square = it.square;
                set_viewport_to_contain(it.square, map);
                return;
            }
        }
    }
}
