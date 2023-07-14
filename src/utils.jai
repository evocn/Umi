// Tactics
// Utils
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

operator + :: (a: Square, b: Square) -> Square {
    return Square.{a.col + b.col, a.row + b.row};
}

operator - :: (a: Square, b: Square) -> Square {
    return Square.{a.col - b.col, a.row - b.row};
}

Direction :: enum {
    NORTH;
    SOUTH;
    EAST;
    WEST;
}

rotate :: (direction : Direction, clockwise := true) -> Direction {
    if clockwise {
        if #complete direction == {
            case .NORTH; return .WEST;
            case .WEST;  return .SOUTH;
            case .SOUTH; return .EAST;
            case .EAST;  return .NORTH;
        }
    }
    else {
        if #complete direction == {
            case .NORTH; return .EAST;
            case .EAST;  return .SOUTH;
            case .SOUTH; return .WEST;
            case .WEST;  return .NORTH;
        }
    }
}

flip :: (direction : Direction) -> Direction {
    if #complete direction == {
        case .NORTH; return .SOUTH;
        case .SOUTH; return .NORTH;
        case .WEST;  return .EAST;
        case .EAST;  return .WEST;
    }
}

move :: (start : Square, direction: Direction) -> Square {
    if #complete direction == {
        case .NORTH; return start + Square.{0, -1};
        case .SOUTH; return start + Square.{0, 1};
        case .WEST;  return start + Square.{1, 0};
        case .EAST;  return start + Square.{-1, 0};
    }
}

//
//

get_best_unit_direction :: (from: Square, to: Square) -> Direction {
    assert(from != to);
    using full_direction := to - from;

    if abs(col) > abs(row) {
        if col > 0 return .WEST;
        return .EAST;
    }
    else {
        if row > 0 return .SOUTH;
        return .NORTH;
    }
}

radians :: (degrees: float) -> float {
    return degrees * PI / 180.0;
}

random_choice :: (array: [] $T) -> T {
    index := cast(int)(Random.random_get_zero_to_one() * array.count);
    return array[index];
}

//
//

deactivate_mouse :: () {
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

activate_mouse :: () {
    SDL_ShowCursor(1);
    SDL_SetRelativeMouseMode(SDL_FALSE);
    SDL_WarpMouseInWindow(window, window_width / 2, window_height / 2);
}

// Grid Methods
//

on_grid :: (using square : Square) -> bool {
    return col >= 0 && col < map_width && row >= 0 && row < map_height;
}

manhattan_distance :: (a : Square, b : Square) -> int {
    return abs(a.col - b.col) + abs(a.row - b.row);
}

// OpenGL
//

check_gl_error :: (str := "-") {
    err := glGetError();
    if err print("error(%) = %\n", str, err);
}
