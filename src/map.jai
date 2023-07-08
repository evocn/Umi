// Tactics
// Tile
// Alex Hartford
// July 2023

map_width  :: 16;
map_height :: 9;

Map :: struct {
    tiles : [map_width][map_height] Tile;
    occupancy : [map_width][map_height] *Unit;
}

occupy :: (using map: *Map, using square: Square, unit: *Unit) {
    occupancy[col][row] = unit;
}

remove_occupant :: (using map: *Map, using square: Square) {
    occupancy[col][row] = null;
}

Tile_Kind :: enum #specified {
    NONE            :: 0;
    COVER           :: 1;
    WALL            :: 2;
    REWARD          :: 3;
    SPENT_REWARD    :: 4;
    OBJECTIVE       :: 5;
    KILL            :: 6;
    MINE            :: 7;
    HOLE            :: 8;
}

Tile :: struct {
    tile_kind : Tile_Kind;
    sprite_index : int;
}

//
//

is_impassible :: (using tile: Tile) -> bool {
    if tile_kind == .WALL
        return true;

    return false;
}

//
//

default_tile_sprite_index :: (kind : Tile_Kind) -> int {
    if #complete kind == {
        case .NONE;      return 0;
        case .COVER;     return 6;
        case .WALL;      return 101;
        case .REWARD;    return 302;
        case .SPENT_REWARD; return 303;
        case .OBJECTIVE; return 360;
        case .KILL;      return 49 * 12 + 34;
        case .MINE;      return 486;
        case .HOLE;      return 301;
    }
}
