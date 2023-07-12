// Tactics
// Unit
// Alex Hartford
// June 2023

Unit :: struct {
    // Properties
    name : string;
    team : Team;
    sprite_index : int;

    movement : int;
    flags : Unit_Flags;

    using ability: Ability;

    // State
    id : int;               @NoSerialize
    using square : Square;  @NoSerialize
    moved : bool;           @NoSerialize
    exhausted : bool;       @NoSerialize
    dead : bool;            @NoSerialize
}

Unit_Flags :: enum_flags {
    FLYING;
    PASS;
    IMPERVIOUS;
    IMMORTAL;
    LAND_STRIDE;
}

kill :: (using unit: *Unit) {
    dead = true;
}


query_units :: (units: [..] *Unit, query: (*Unit) -> bool) -> [] *Unit {
    result : [..] *Unit;
    result.allocator = temp;

    for units {
        if query(it)
            array_add(*result, it);
    }

    return result;
}

find_nearest_unit :: (using map: Map, unit: Unit, query: (*Unit) -> bool) -> *Unit {
    prospects := query_units(units, query);
    if !prospects
        return null;

    nearest : *Unit;
    shortest_distance := 100;
    for prospects {
        test_path, success := get_shortest_path(map, unit, it.square);
        defer array_reset(*test_path);
        if !success continue;

        if test_path.count < shortest_distance {
            shortest_distance = test_path.count;
            nearest = it;
        }
    }

    return nearest;
}
