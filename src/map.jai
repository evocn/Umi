// Umi
// Tile
// Alex Hartford
// July 2023

MAX_MAP_WIDTH  :: 64;
MAX_MAP_HEIGHT :: 64;

Map :: struct {
    tiles : [MAX_MAP_WIDTH][MAX_MAP_HEIGHT] Tile;
    occupancy : [MAX_MAP_WIDTH][MAX_MAP_HEIGHT] *Unit;

    width, height : int;

    next_id : int;
    units : [..] *Unit;
}

clear :: (using map: *Map) {
    reset(*level_pool, overwrite_memory=true);
    map.* = Map.{};
}

get_tile :: (using map: Map, using square: Square) -> *Tile {
    return *tiles[col][row];
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
    NONE        :: 0x0;
    WALL        :: 0x1;
    REWARD      :: 0x2;
    SPENT_REWARD:: 0x3;
    OBJECTIVE   :: 0x4;
    KILL        :: 0x5;
    MINE        :: 0x6;
    HOLE        :: 0x7;
    SLOW        :: 0x8;
    COVER       :: 0x9;
    HALF_COVER  :: 0xa;
    FIRE        :: 0xb;
    THUNDER     :: 0xc;
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

is_deadly :: (using tile: Tile, unit: Unit) -> bool {
    if kind == .KILL return true;
    if kind == .MINE return true;
    if kind == .HOLE return true;

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

filter_out_death :: (squares : *[..] Square, using map: Map, unit: Unit) {
    for <<squares {
        tile := get_tile(map, it);
        if is_deadly(tile, unit) remove it;
    }

}

//
//

default_tile_sprite_index :: (kind : Tile_Kind) -> int {
    if #complete kind == {
        case .NONE;         return 0;
        case .WALL;         return 643;
        case .REWARD;       return 302;
        case .SPENT_REWARD; return 303;
        case .OBJECTIVE;    return 360;
        case .KILL;         return 49 * 12 + 34;
        case .MINE;         return 486;
        case .HOLE;         return 301;
        case .SLOW;         return 101;
        case .COVER;        return 148;
        case .HALF_COVER;   return 147;
        case .FIRE;         return 504;
        case .THUNDER;      return 49 * 13 + 35;
    }
}


//
//
// Resolve gameplay tile effects
resolve_landing_effects :: (map: *Map, unit: *Unit) {
    using tile := *map.tiles[unit.square.col][unit.square.row];

    if kind == {
        case .KILL;
            kill(unit);

        case .HOLE;
            kill(unit);

        case .MINE;
            kill(unit);

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

