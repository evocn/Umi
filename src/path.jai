// Tactics
// Path
// Alex Hartford
// June 2023

get_squares_you_could_use_an_ability_from :: (using map : Map, ability: Ability, attacker : Unit, target : Unit) -> [..] Square {
    squares_to_attack_from : [..] Square;
    squares_to_attack_from.allocator = temp;

    traversed := traverse(map, target.square, attacker.team,
                          flying=cast(bool)(attacker.flags & .FLYING), 
                          pass=cast(bool)(attacker.flags & .PASS), 
                          land_stride=cast(bool)(attacker.flags & .LAND_STRIDE)
                         );
    print_reachable(traversed);
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

get_ability_squares_from_position :: (using map : Map, ability: Ability, unit : Unit) -> [..] Square {
    interactible : [..] Square;

    traversed := traverse(map, unit.square, unit.team, flying=true, pass=true, land_stride=true);
    for traversed.squares {
        if it.distance_by_air <= ability.max_range && it.distance_by_air >= ability.min_range
            array_add(*interactible, it.square);
    }
    return interactible;
}

get_accessible_squares_from_position :: (using map : Map, unit : Unit) -> [..] Square {
    accessible : [..] Square;

    traversed := traverse(map, unit.square, unit.team, 
                          flying=cast(bool)(unit.flags & .FLYING), 
                          pass=cast(bool)(unit.flags & .PASS), 
                          land_stride=cast(bool)(unit.flags & .LAND_STRIDE)
                         );
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

move_down_path :: (map: Map, path: *Path, unit: Unit, desired_distance: int) -> Square {
    distance := min(desired_distance, path.count);
    furthest_index := max(path.count - distance, 1);

    occupant := get_occupant(map, path.*[furthest_index - 1]);
    square_can_be_occupied := occupant == null || occupant.id == unit.id;
    while !square_can_be_occupied {
        furthest_index += 1;

        occupant = get_occupant(map, path.*[furthest_index - 1]);
        square_can_be_occupied = occupant == null || occupant.id == unit.id;
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

get_shortest_path :: (using map : Map, unit: Unit, dest: Square) -> Path, success: bool {
    path: Path;

    // @TODO: This is funky. We determine walkable squares in a different way than we determine shortest paths.
    // I'd like to not have to special case these qualifiers.
    traversed := traverse(map, unit.square, unit.team, flying=cast(bool)(unit.flags & .FLYING), pass=cast(bool)(unit.flags & .PASS));

    destination := dest;

    destination_is_reachable := traversed.field[destination.col][destination.row].reachable;
    //destination_is_occupied  := traversed.field[destination.col][destination.row].occupied;
    destination_is_origin := unit.square == destination;

    rows :: int.[-1,  0,  1,  0];
    cols :: int.[ 0,  1,  0, -1];

    if !destination_is_reachable {
        print("Destination is unreachable!\n");

        shortest_distance_of_the_directions := 100;
        shortest_square : Square;
        for i : 0..3 {
            using new_square := Square.{destination.col + cols[i], destination.row + rows[i]};
            if !on_grid(new_square) then continue;

            if traversed.field[col][row].distance < shortest_distance_of_the_directions {
                shortest_square = new_square;
                shortest_distance_of_the_directions = traversed.field[col][row].distance;
            }
        }
        destination = shortest_square;
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
            if !on_grid(new_square) then continue;

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

#scope_file
Traversal_Result :: struct {
    Data_Point :: struct {
        reachable : bool;
        square : Square;
        distance : int;
        distance_by_air : int;
        occupied : bool;
    }

    field : [map_width][map_height] Data_Point;
    #place field;
    squares : [map_width * map_height] Data_Point;
}

// @TODO: It would be nice if we didn't end up with a proliferation of flags.
traverse :: (using map : Map, origin : Square, team := Team.BLUE, flying := false, pass := false, land_stride := false) -> Traversal_Result {
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
            if !on_grid(new_square) then continue;

            new_square_occupant := map.occupancy[new_square.col][new_square.row];
            field[col][row].occupied = new_square_occupant != null;

            cannot_traverse_due_to_enemy_unit := (new_square_occupant != null && new_square_occupant.team != team) && !pass;
            if cannot_traverse_due_to_enemy_unit then continue;

            cannot_traverse_due_to_impassible_tile := is_impassible(map.tiles[new_square.col][new_square.row]) && !flying;
            if cannot_traverse_due_to_impassible_tile then continue;

            field[from_square.col][from_square.row].reachable = true;

            //

            new_distance_by_air := field[from_square.col][from_square.row].distance_by_air + 1;
            new_distance_by_air_is_shorter := new_distance_by_air < field[col][row].distance_by_air;
            if new_distance_by_air_is_shorter
                field[col][row].distance_by_air = new_distance_by_air;

            //

            traversal_cost := 1;
            if get_tile(map, new_square).kind == .SLOW && !land_stride
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
