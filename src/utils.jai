// Tactics
// Utils
// Alex Hartford
// June 2023

radians :: (degrees: float) -> float {
    return degrees * PI / 180.0;
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
    return col >= 0 && col < grid_width && row >= 0 && row < grid_height;
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
