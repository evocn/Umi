// Tactics
// Grid
// Alex Hartford
// June 2023

Square :: struct {
    col : int;
    row : int;
}

operator == :: (a: Square, b: Square) -> bool {
    return a.col == b.col && a.row == b.row;
}
#poke_name Basic operator==;

// @TODO: Should this be a bunch of vectors?
Direction :: enum {
    NORTH;
    SOUTH;
    EAST;
    WEST;
}

//
//

Tile_Kind :: enum #specified {
    NONE    :: 0;
    COVER   :: 1;
    WALL    :: 2;
    GAP     :: 3;
}

Tile :: struct {
    tile_kind : Tile_Kind;
}

is_impassible :: (using tile: Tile) -> bool {
    if tile_kind == .WALL
    {
        return true;
    }
    return false;
}

//
//

grid_width  :: 16;
grid_height :: 9;
Map :: struct {
    grid : [grid_width][grid_height] Tile;

    occupancy : [grid_width][grid_height] *Unit;
}

get_occupant :: (using map: Map, using square: Square) -> *Unit {
    return occupancy[col][row];
}

remove_occupant :: (using map: *Map, using square: Square) {
    occupancy[col][row] = null;
}

occupy :: (using map: *Map, using square: Square, unit: *Unit) {
    occupancy[col][row] = unit;
}

get_tile :: (using map: Map, using square: Square) -> *Tile {
    return *grid[col][row];
}
