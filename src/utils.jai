// Umi
// Utils
// Alex Hartford
// June 2023

E :: 2.71828;

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

is_perpendicular :: (direction : Direction, to: Direction) -> bool {
    if #complete direction == {
        case .SOUTH; #through;
        case .NORTH;
            if #complete to == {
                case .NORTH;    return false;
                case .SOUTH;    return false;
                case .WEST;     return true;
                case .EAST;     return true;
            }

        case .EAST; #through;
        case .WEST;
            if #complete to == {
                case .NORTH;    return true;
                case .SOUTH;    return true;
                case .WEST;     return false;
                case .EAST;     return false;
            }
    }
}

perpendicular :: (direction : Direction) -> Direction {
    if #complete direction == {
        case .NORTH; return .EAST;
        case .SOUTH; return .WEST;
        case .WEST;  return .NORTH;
        case .EAST;  return .SOUTH;
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

// @TODO: Investigate why these two are subtly different in their respective cases.
get_best_path_direction :: (from: Square, to: Square) -> Direction {
    assert(from != to);
    using full_direction := to - from;

    if abs(col) > abs(row) {
        if col > 0 return .WEST;
        return .EAST;
    }
    else {
        if row > 0 return .NORTH;
        return .SOUTH;
    }
}

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
    index := cast(int)(random_get_zero_to_one() * array.count);
    return array[index];
}

roll_die :: (faces: int) -> int {
    result := 1 + cast(int)(random_get_zero_to_one() * faces);
    return result;
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

on_grid :: (using square : Square, map: Map) -> bool {
    return col >= 0 && col < map.width && row >= 0 && row < map.height;
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

//
// Easing functions
//

identity :: (t: float) -> float {
    return t;
}

flip :: (t: float) -> float {
    return 1 - t;
}

smooth_start :: (t: float) -> float {
    return t * t * t;
}

smooth_stop :: (t: float) -> float {
    return flip(smooth_start(flip(t)));
}

smooth_start_stop :: (t: float) -> float {
    return lerp(smooth_start(t), smooth_stop(t), t);
}

stair :: (t: float) -> float {
    return cast(float)cast(int)t;
}
