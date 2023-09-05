// Umi
// Viewport
// Alex Hartford
// July 2023

VIEWPORT_WIDTH  :: 16;
VIEWPORT_HEIGHT :: 8;

TILE_SIZE :: 32; // in pixels

viewport : struct {
    using corner: Square; // upper left.
}

//
//

within_viewport :: (using square: Square) -> bool {
    return viewport.col <= col
        && viewport.col + VIEWPORT_WIDTH > col
        && viewport.row <= row
        && viewport.row + VIEWPORT_HEIGHT > row;
}

within_soft_viewport :: (using square: Square) -> bool {
    return viewport.col + 2 <= col
        && viewport.col + VIEWPORT_WIDTH - 2 > col
        && viewport.row + 2 <= row
        && viewport.row + VIEWPORT_HEIGHT - 2 > row;
}

square_is_on_the_fringe :: (using square: Square, map : Map) -> bool {
    return square.col < 2
        || map.width - square.col <= 2
        || square.row < 2
        || map.height - square.row <= 2;
}

maybe_move_viewport :: (map: Map, using square: Square) {
    if within_soft_viewport(square) then return;

    if col >= viewport.col + VIEWPORT_WIDTH - 2 && map.width - col > 2 {
        move_viewport(map, .EAST);
    }
    else if col < viewport.col + 2 && square.col >= 2 {
        move_viewport(map, .WEST);
    }

    if row >= viewport.row + VIEWPORT_HEIGHT - 2 && map.height - square.row > 2 {
        move_viewport(map, .SOUTH);
    }
    else if row < viewport.row + 2 && square.row >= 2 {
        move_viewport(map, .NORTH);
    }
}

move_viewport :: (map: Map, direction : Direction) {
    if #complete direction == {
        case .SOUTH; viewport.row += 1;
        case .NORTH; viewport.row -= 1;
        case .EAST;  viewport.col += 1;
        case .WEST;  viewport.col -= 1;
    }

    assert(on_grid(viewport.corner, map) && on_grid(viewport.corner + .{VIEWPORT_WIDTH-1, VIEWPORT_HEIGHT-1}, map));
}

// @TODO: Soft_viewport_to_contain
set_viewport_to_contain :: (using square: Square, map: Map) {
    if within_viewport(square) then return;

    viewport.col = clamp(col, 0, map.width - VIEWPORT_WIDTH);
    viewport.row = clamp(row, 0, map.height - VIEWPORT_HEIGHT);
}
