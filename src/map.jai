// Tactics
// Tile
// Alex Hartford
// July 2023

map_width  :: 16;
map_height :: 8;

Map :: struct {
    tiles : [map_width][map_height] Tile;
    occupancy : [map_width][map_height] *Unit;

    next_id : int;
    units : [..] *Unit;
}

get_tile :: (using map: Map, using square: Square) -> Tile {
    return tiles[col][row];
}

get_occupant :: (using map: Map, using square: Square) -> *Unit {
    return occupancy[col][row];
}

occupy :: (using map: *Map, using square: Square, unit: *Unit) {
    occupancy[col][row] = unit;
}

remove_occupant :: (using map: *Map, using square: Square) {
    occupancy[col][row] = null;
}

get_unoccupied :: (using map: *Map) -> [] Square, bool {
    unoccupied : [..] Square;
    unoccupied.allocator = temp;

    for col: 0..occupancy.count-1 {
        for row: 0..occupancy[col].count-1 {
            if !occupancy[col][row] then array_add(*unoccupied, .{col, row});
        }
    }

    return unoccupied, unoccupied.count > 0;
}

Tile_Kind :: enum u8 #specified {
    NONE            :: 0x0;
    WALL            :: 0x1;
    REWARD          :: 0x2;
    SPENT_REWARD    :: 0x3;
    OBJECTIVE       :: 0x4;
    KILL            :: 0x5;
    MINE            :: 0x6;
    HOLE            :: 0x7;
    SLOW            :: 0x8;
    COVER           :: 0x9;
    HALF_COVER      :: 0xa;
    // :: 11;
    // :: 12;
    // :: 13;
    // :: 14;
    // :: 15;
    // Once we go past these, we have to parse the tiles differently, because we store them in a single hex digit.
}

Tile :: struct {
    kind : Tile_Kind;
    sprite_index : int;
}

//
//

is_impassible :: (using tile: Tile) -> bool {
    if kind == .WALL
        return true;

    return false;
}

filter_out_impassible :: (squares : *[..] Square, using map: Map) {
    for <<squares {
        tile := get_tile(map, it);
        if is_impassible(tile) remove it;
    }

}

filter_out_occupied :: (squares : *[..] Square, using map: Map) {
    for << squares {
        if get_occupant(map, it) remove it;
    }
}

//
//

default_tile_sprite_index :: (kind : Tile_Kind) -> int {
    if #complete kind == {
        case .NONE;         return 0;
        case .WALL;         return 101;
        case .REWARD;       return 302;
        case .SPENT_REWARD; return 303;
        case .OBJECTIVE;    return 360;
        case .KILL;         return 49 * 12 + 34;
        case .MINE;         return 486;
        case .HOLE;         return 301;
        case .SLOW;         return 737;
        case .COVER;        return 148;
        case .HALF_COVER;   return 147;
    }
}


//
//
// Resolve gameplay tile effects
resolve_landing_effects :: (map: *Map, unit: *Unit) {
    using tile := *map.tiles[unit.square.col][unit.square.row];

    if kind == {
        case .KILL;
        if !cast(bool)(unit.flags & .IMMORTAL)
            kill(unit);

        case .HOLE;
        if !cast(bool)(unit.flags & .FLYING)
            kill(unit);

        case .MINE;
        if !cast(bool)(unit.flags & .IMMORTAL) {
            kill(unit);
        }
        kind = .NONE;
        sprite_index = default_tile_sprite_index(.NONE);

        case .REWARD;
        kind = .SPENT_REWARD;
        sprite_index = default_tile_sprite_index(.SPENT_REWARD);
        print("You get a reward now!\n");

        case .OBJECTIVE;
        print("You finished the level!\n");
    }
}

