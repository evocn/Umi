// Tactics
// Path
// Alex Hartford
// June 2023

get_interactible_squares_from_position :: (using map : Map, unit : Unit) -> [..] Square {
    interactible : [..] Square;

    traversed := traverse(map, unit.square, unit.team, cast(bool)(unit.unit_flags & .FLYING), pass=true);
    for traversed.squares {
        if it.distance_by_air <= unit.max_range && it.distance_by_air >= unit.min_range
            array_add(*interactible, it.square);
    }
    return interactible;
}

get_accessible_squares_from_position :: (using map : Map, unit : Unit) -> [..] Square {
    accessible : [..] Square;

    traversed := traverse(map, unit.square, unit.team, flying=cast(bool)(unit.unit_flags & .FLYING), pass=cast(bool)(unit.unit_flags & .PASS));
    for traversed.squares {
        if it.distance <= unit.movement && !it.occupied
            array_add(*accessible, it.square);
    }
    return accessible;
}

 
//
// Path Methods
//

// @NOTE: Paths are backwards in this engine. There are some good reasons for this.
Path :: [..] Square;

move_down_path :: (path: *Path, desired_distance: int) -> Square {
    distance := min(desired_distance, path.count);
    path.count = path.count - distance;
    return path.*[path.count-1];
}

// @NOTE: This is for debugging purposes. Check here first if there's wonky AI stuff going on.
print_distance_field :: (using map : Map, origin: Square) {
    traversed := traverse(map, origin);
    for col: traversed.field {
        for data_point: col {
            print("%\t", data_point.distance);
        }
        print("\n");
    }
}

get_shortest_path :: (using map : Map, unit: Unit, destination: Square) -> Path, success: bool {
    path: Path;
    traversed := traverse(map, unit.square, unit.team, cast(bool)(unit.unit_flags & .FLYING));

    destination_is_reachable := traversed.field[destination.col][destination.row].reachable;
    //destination_is_occupied  := traversed.field[destination.col][destination.row].occupied;
    destination_is_origin := unit.square == destination;

    if !destination_is_reachable then return path, false;
    if destination_is_origin {
        array_add(*path, destination);
        return path, true;
    }

    rows :: int.[-1,  0,  1,  0];
    cols :: int.[ 0,  1,  0, -1];

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
traverse :: (using map : Map, origin : Square, team := Team.BLUE, flying := false, pass := false) -> Traversal_Result {
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
        field[from_square.col][from_square.row].reachable = true;
        field[from_square.col][from_square.row].square = from_square;

        for i : 0..3 {
            using new_square := Square.{from_square.col + cols[i], from_square.row + rows[i]};
            if !on_grid(new_square) then continue;

            new_square_occupant := map.occupancy[new_square.col][new_square.row];
            field[col][row].occupied = new_square_occupant != null;

            new_square_is_occupied_by_enemy_unit := (new_square_occupant != null && new_square_occupant.team != team) && !pass;
            if new_square_is_occupied_by_enemy_unit then continue;

            new_square_is_impassible := is_impassible(map.tiles[new_square.col][new_square.row]) && !flying;
            if new_square_is_impassible then continue;

            // @TODO: Different costs for tile type traversals will go here (Desert, water, mountain tiles, etc)
            new_distance := field[from_square.col][from_square.row].distance + 1;
            new_distance_is_shorter := new_distance < field[col][row].distance;

            new_distance_by_air := field[from_square.col][from_square.row].distance_by_air + 1;
            new_distance_by_air_is_shorter := new_distance_by_air < field[col][row].distance_by_air;

            if !new_distance_is_shorter && !new_distance_by_air_is_shorter then continue;
            if new_distance_is_shorter
                field[col][row].distance = new_distance;
            if new_distance_by_air_is_shorter
                field[col][row].distance_by_air = new_distance_by_air;

            array_add(*unexplored, new_square);
        }
    }
    array_reset(*unexplored);

    return result;
}
