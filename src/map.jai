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

Tile_Kind :: enum #specified {
    NONE    :: 0;
    COVER   :: 1;
    WALL    :: 2;
    GAP     :: 3;
}

Tile :: struct {
    tile_kind : Tile_Kind;
}

//
//

is_impassible :: (using tile: Tile) -> bool {
    if tile_kind == .WALL
    {
        return true;
    }
    return false;
}

