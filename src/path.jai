// Tactics
// Path
// Alex Hartford
// June 2023

clear_path :: (first: Square, second: Square, map: Map) -> bool {
    if first.col != second.col && first.row != second.row then return false;

    if first.col == second.col {
        a := first; b := second;
        if a.row < b.row {
            a = second;
            b = first;
        }

        for (b.row + 1)..(a.row - 1) {
            query_square := Square.{a.col, it};
            if get_occupant(map, query_square) then return false;
        }
    }

    if first.row == second.row {
        a := first; b := second;
        if a.col < b.col {
            a = second;
            b = first;
        }

        for (b.col + 1)..(a.col - 1) {
            query_square := Square.{it, a.row};
            if get_occupant(map, query_square) then return false;
        }
    }

    return true;
}

filter_get_port_and_starboard :: (orthographic : *[..] Square, origin: Square, facing: Direction) {
    if #complete facing == {
        case .NORTH; #through;
        case .SOUTH;
            for orthographic.* if origin.row != it.row remove it;

        case .EAST;  #through;
        case .WEST;
            for orthographic.* if origin.col != it.col remove it;
    }
}

filter_get_port :: (orthographic : *[..] Square, origin: Square, facing: Direction) {
    if #complete facing == {
        case .NORTH;
            for orthographic.* if origin.row != it.row || origin.col < it.col then remove it;
        case .SOUTH;
            for orthographic.* if origin.row != it.row || origin.col > it.col then remove it;

        case .EAST;
            for orthographic.* if origin.col != it.col || origin.row < it.row then remove it;
        case .WEST;
            for orthographic.* if origin.col != it.col || origin.row > it.row then remove it;
    }
}

filter_get_starboard :: (orthographic : *[..] Square, origin: Square, facing: Direction) {
    if #complete facing == {
        case .NORTH;
            for orthographic.* if origin.row != it.row || origin.col > it.col then remove it;
        case .SOUTH;
            for orthographic.* if origin.row != it.row || origin.col < it.col then remove it;

        case .EAST;
            for orthographic.* if origin.col != it.col || origin.row > it.row then remove it;
        case .WEST;
            for orthographic.* if origin.col != it.col || origin.row < it.row then remove it;
    }
}

filter_get_fore :: (orthographic : *[..] Square, origin: Square, facing: Direction) {
    if #complete facing == {
        case .NORTH;
            for orthographic.* if origin.col != it.col || origin.row < it.row then remove it;
        case .SOUTH;
            for orthographic.* if origin.col != it.col || origin.row > it.row then remove it;

        case .EAST;
            for orthographic.* if origin.row != it.row || origin.col > it.col then remove it;
        case .WEST;
            for orthographic.* if origin.row != it.row || origin.col < it.col then remove it;
    }
}

filter_get_aft :: (orthographic : *[..] Square, origin: Square, facing: Direction) {
    if #complete facing == {
        case .NORTH;
            for orthographic.* if origin.col != it.col || origin.row > it.row then remove it;
        case .SOUTH;
            for orthographic.* if origin.col != it.col || origin.row < it.row then remove it;

        case .EAST;
            for orthographic.* if origin.row != it.row || origin.col < it.col then remove it;
        case .WEST;
            for orthographic.* if origin.row != it.row || origin.col > it.col then remove it;
    }
}

get_orthographic_squares_from_position :: (using map : Map, ability: Ability, unit : Unit, origin: Square) -> [..] Square {
    interactible : [..] Square;

    traversed := traverse(map, origin, unit.team, pass=true, swift=true);
    debug.traversed = traversed;
    for traversed.squares {
        within_range := it.distance_by_air <= ability.max_range && it.distance_by_air >= ability.min_range;
        orthographic := it.square.col == origin.col || it.square.row == origin.row;
        path_is_clear:= clear_path(origin, it.square, map);
        if within_range && orthographic && path_is_clear
            array_add(*interactible, it.square);
    }

    return interactible;
}

get_squares_you_could_use_an_ability_from :: (using map : Map, ability: Ability, attacker : Unit, target : Unit) -> [..] Square {
    squares_to_attack_from : [..] Square;
    squares_to_attack_from.allocator = temp;

    traversed := traverse(map, target.square, attacker.team,
                          pass=cast(bool)(attacker.flags & .PASS), 
                          swift=cast(bool)(attacker.flags & .SWIFT)
                         );

    debug.traversed = traversed;
    for traversed.squares {
        square_within_range := it.distance_by_air <= ability.max_range && it.distance_by_air >= ability.min_range;
        occupant := get_occupant(map, it.square);
        square_can_be_occupied := occupant == null || occupant.id == attacker.id;
        square_is_reachable := it.reachable;
        if square_within_range && square_can_be_occupied && square_is_reachable {
            array_add(*squares_to_attack_from, it.square);
        }
    }

    return squares_to_attack_from;
}

get_squares_right_next_to_unit :: (using map: Map, source: Unit, target: Unit) -> [..] Square {
    squares_right_next_to_unit : [..] Square;
    squares_right_next_to_unit.allocator = temp;

    traversed := traverse(map, target.square, source.team,
                          pass=cast(bool)(source.flags & .PASS), 
                          swift=cast(bool)(source.flags & .SWIFT)
                         );

    debug.traversed = traversed;
    for traversed.squares {
        square_within_range := it.distance_by_air == 1;
        occupant := get_occupant(map, it.square);
        square_can_be_occupied := occupant == null || occupant.id == source.id;
        square_is_reachable := it.reachable;
        if square_within_range && square_can_be_occupied && square_is_reachable {
            array_add(*squares_right_next_to_unit, it.square);
        }
    }

    return squares_right_next_to_unit;
}

get_ability_squares_from_position :: (using map : Map, ability: Ability, unit : Unit, square: Square) -> [..] Square {
    interactible : [..] Square;

    if ability.targeting == .SELF {
        array_add(*interactible, square);
        return interactible;
    }

    traversed := traverse(map, square, unit.team, pass=true, swift=true);
    debug.traversed = traversed;
    for traversed.squares {
        if it.distance_by_air <= ability.max_range && it.distance_by_air >= ability.min_range
            array_add(*interactible, it.square);
    }
    return interactible;
}

get_accessible_squares_from_position :: (using map : Map, unit : Unit) -> [..] Square {
    accessible : [..] Square;

    traversed := traverse(map, unit.square, unit.team, 
                          pass=cast(bool)(unit.flags & .PASS), 
                          swift=cast(bool)(unit.flags & .SWIFT)
                         );
    debug.traversed = traversed;

    for traversed.squares {
        square_within_range := it.distance <= unit.movement;
        occupant := get_occupant(map, it.square);
        square_can_be_occupied := occupant == null || occupant.id == unit.id;
        if square_within_range && square_can_be_occupied {
            array_add(*accessible, it.square);
        }
    }
    return accessible;
}

//
// Path Methods
//

// @NOTE: all path functions return allocated paths, because sometimes you want to hold on to some path.
// For this reason, you must remember to array_reset a path you get that you don't need any more.

// @NOTE: Paths are backwards in this engine. There are some good reasons for this.
Path :: [..] Square;

move_down_path :: (map: Map, path: *Path, unit: Unit) -> Square {
    distance := min(unit.movement, path.count);
    i : int = 0;
    for < path.* {
        if distance < i break;
        if it != unit.square && get_tile(map, it).kind == .SLOW {
            distance -= 1;
        }
        i += 1;
    }
    if distance < 0 then return unit.square;

    furthest_index := max(path.count - distance, 1);

    occupant := get_occupant(map, path.*[furthest_index - 1]);
    square_can_be_occupied := occupant == null || occupant.id == unit.id;
    square_is_deadly := is_deadly(get_tile(map, path.*[furthest_index - 1]), unit);
    while !square_can_be_occupied || square_is_deadly {
        furthest_index += 1;

        occupant = get_occupant(map, path.*[furthest_index - 1]);
        square_can_be_occupied = occupant == null || occupant.id == unit.id;
        square_is_deadly = is_deadly(get_tile(map, path.*[furthest_index - 1]), unit);
    }

    path.count = furthest_index;
    return path.*[path.count-1];
}

print_reachable :: (traversed: Traversal_Result) {
    for col: traversed.field {
        for data_point: col {
            print("%\t", data_point.reachable);
        }
        print("\n");
    }
}

print_distance_field :: (traversed: Traversal_Result) {
    for col: traversed.field {
        for data_point: col {
            print("%\t", data_point.distance);
        }
        print("\n");
    }
}

print_air_distance_field :: (traversed: Traversal_Result) {
    for col: traversed.field {
        for data_point: col {
            print("%\t", data_point.distance_by_air);
        }
        print("\n");
    }
}

get_shortest_path :: (using map : Map, unit: Unit, destination: Square) -> Path, success: bool {
    path: Path;

    // @TODO: This is funky. We determine walkable squares in a different way than we determine shortest paths.
    // I'd like to not have to special case these qualifiers.
    traversed := traverse(map, unit.square, unit.team, pass=cast(bool)(unit.flags & .PASS));

    destination_is_reachable := traversed.field[destination.col][destination.row].reachable;
    //destination_is_occupied  := traversed.field[destination.col][destination.row].occupied;
    destination_is_origin := unit.square == destination;

    rows :: int.[-1,  0,  1,  0];
    cols :: int.[ 0,  1,  0, -1];

    if !destination_is_reachable {
        //log("Destination is unreachable!\n");
        return path, false;
    }
    if destination_is_origin {
        array_add(*path, destination);
        //log("Destination is origin.\n");
        return path, true;
    }

    next := destination;
    while next != unit.square {
        array_add(*path, next);

        shortest_distance_of_the_directions := 100;
        shortest_square : Square;
        for i : 0..3 {
            using new_square := Square.{next.col + cols[i], next.row + rows[i]};
            if !on_grid(new_square, map) then continue;

            if traversed.field[col][row].distance < shortest_distance_of_the_directions {
                shortest_square = new_square;
                shortest_distance_of_the_directions = traversed.field[col][row].distance;
            }
        }

        next = shortest_square;
    }
    array_add(*path, unit.square);

    return path, true;
}

Traversal_Result :: struct {
    Data_Point :: struct {
        reachable : bool;
        square : Square;
        distance : int;
        distance_by_air : int;
        occupied : bool;
    }

    field : [MAX_MAP_WIDTH][MAX_MAP_HEIGHT] Data_Point;
    #place field;
    squares : [MAX_MAP_WIDTH * MAX_MAP_HEIGHT] Data_Point;
}

#scope_file
// @TODO: It would be nice if we didn't end up with a proliferation of flags.
traverse :: (using map : Map, origin : Square, team := Team.YOU, pass := false, swift := false) -> Traversal_Result {
    rows :: int.[-1,  0,  1,  0];
    cols :: int.[ 0,  1,  0, -1];

    using result : Traversal_Result;

    for * squares {
        it.distance = 100;
        it.distance_by_air = 100;
    }

    unexplored : [..] Square;
    array_add(*unexplored, origin);
    field[origin.col][origin.row].reachable = true;
    field[origin.col][origin.row].square = Square.{origin.col, origin.row};
    field[origin.col][origin.row].distance = 0;
    field[origin.col][origin.row].distance_by_air = 0;
    field[origin.col][origin.row].occupied = false;

    while unexplored {
        from_square := pop(*unexplored);
        field[from_square.col][from_square.row].square = from_square;

        for i : 0..3 {
            using new_square := Square.{from_square.col + cols[i], from_square.row + rows[i]};
            if !on_grid(new_square, map) then continue;

            new_square_occupant := map.occupancy[new_square.col][new_square.row];
            field[col][row].occupied = new_square_occupant != null;

            cannot_traverse_due_to_enemy_unit := (new_square_occupant != null && new_square_occupant.team != team) && !pass;
            if cannot_traverse_due_to_enemy_unit then continue;

            cannot_traverse_due_to_impassible_tile := is_impassible(map.tiles[new_square.col][new_square.row]);
            if cannot_traverse_due_to_impassible_tile then continue;

            field[from_square.col][from_square.row].reachable = true;

            //

            new_distance_by_air := field[from_square.col][from_square.row].distance_by_air + 1;
            new_distance_by_air_is_shorter := new_distance_by_air < field[col][row].distance_by_air;
            if new_distance_by_air_is_shorter
                field[col][row].distance_by_air = new_distance_by_air;

            //

            traversal_cost := 1;
            if get_tile(map, new_square).kind == .SLOW && !swift
                traversal_cost = 2;

            new_distance := field[from_square.col][from_square.row].distance + traversal_cost;
            new_distance_is_shorter := new_distance < field[col][row].distance;
            if new_distance_is_shorter
                field[col][row].distance = new_distance;

            if new_distance_is_shorter || new_distance_by_air_is_shorter {
                array_add(*unexplored, new_square);
            }
        }
    }
    array_reset(*unexplored);

    return result;
}
