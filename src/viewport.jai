// Tactics
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

maybe_move_viewport :: (map: Map, using square: Square) {
    if within_viewport(square) return;

    if col >= viewport.col + VIEWPORT_WIDTH
        move_viewport(map, .EAST);
    else if col < viewport.col
        move_viewport(map, .WEST);

    if row >= viewport.row + VIEWPORT_HEIGHT
        move_viewport(map, .SOUTH);
    else if row < viewport.row
        move_viewport(map, .NORTH);

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

set_viewport_to_contain :: (using square: Square, map: Map) {
    if within_viewport(square) then return;

    viewport.col = col / VIEWPORT_WIDTH;
    viewport.row = row / VIEWPORT_HEIGHT;

    viewport.col = clamp(viewport.col * VIEWPORT_WIDTH,
                         0, map.width - VIEWPORT_WIDTH);
    viewport.row = clamp(viewport.row * VIEWPORT_HEIGHT,
                         0, map.height - VIEWPORT_HEIGHT);
}
