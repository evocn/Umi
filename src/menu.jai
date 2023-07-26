// Tactics
// Menu
// Alex Hartford
// July 2023

Go_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .GO;

    callback : #type ();
}

Checkbox_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .CHECKBOX;

    value : *bool;

    callback : #type ();

    sprite_index_two : int;
}

Slider_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .SLIDER;

    value : *float;

    increment : float = 0.25;
    min : float = 0.0;
    max : float = 1.0;

    sprite_index_two : int;
}

Menu_Element :: struct {
    kind : enum #complete {
        GO;
        CHECKBOX;
        SLIDER;
    }

    name : string;
    sprite_index : int;
}

Menu :: struct {
    name : string;

    elements : [..] *Menu_Element;
    element_index : int;
}

resolve_menu_inputs :: (using menu: *Menu) {
    using input;

    if pressed(*button_menu) {
        program_mode = .GAME;
        play_sfx("place");
    }

    if pressed(*up) {
        element_index -= 1;
        if element_index < 0 {
            element_index = elements.count - 1;
        }
        play_sfx("click");
    }
    if pressed(*down) {
        element_index += 1;
        if element_index >= elements.count {
            element_index = 0;
        }
        play_sfx("click");
    }
    if pressed(*left) {
        nudge_menu_element(elements[element_index], left=true);
        play_sfx("choose");
    }
    if pressed(*right) {
        nudge_menu_element(elements[element_index]);
        play_sfx("choose");
    }

    if pressed(*button_1) {
        toggle_menu_element(elements[element_index]);
    }
    if pressed(*button_2) {
    }
}

// @TODO: This could return false if we want there to be menu options that bonk on failure.
// Not sure what that would be useful for, just figured I'd mention it in case it became useful.
toggle_menu_element :: (using element: *Menu_Element) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            callback();
            play_sfx("place");

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            callback();
            value.* = !(value.*);
            play_sfx("choose");

        case .SLIDER;
            // Don't do anything.
    }
}


nudge_menu_element :: (using element: *Menu_Element, left := false) {
    if kind == {
        case .GO;
            // Don't do anything.

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            value.* = !value;
            play_sfx("choose");

        case .SLIDER;
            using cast(*Slider_Element)element;
            if left {
                value.* = clamp(value.* - increment, min, max);
            }
            else {
                value.* = clamp(value.* + increment, min, max);
            }
    }
}



//
// Callbacks for Go_Elements
//

start_game :: () {
    program_mode = .GAME;
}

resume_game :: () {
    program_mode = .GAME;
}

quit_game :: () {
    running = false;
}

toggle_fullscreen :: () {
    using settings;

    desire_fullscreen : bool;
    if !fullscreen then desire_fullscreen = true;

    display_mode : SDL_DisplayMode;

    SDL_GetDesktopDisplayMode(0, *display_mode);

    if desire_fullscreen {
        SDL_SetWindowResizable(window, SDL_FALSE);
        SDL_SetWindowBordered(window, SDL_FALSE);
        SDL_SetWindowPosition(window, 0, 0);
        SDL_SetWindowSize(window, display_mode.w, display_mode.h);
    }
    else {
        SDL_SetWindowResizable(window, SDL_TRUE);
        SDL_SetWindowBordered(window, SDL_TRUE);
        SDL_SetWindowSize(window, WINDOW_WIDTH, WINDOW_HEIGHT);
        SDL_SetWindowPosition(window, display_mode.w / 2 - WINDOW_WIDTH / 2, display_mode.h / 2 - WINDOW_HEIGHT / 2);
        SDL_SetWindowResizable(window, SDL_FALSE);
    }

    SDL_GetWindowDisplayMode(window, *display_mode);

    // @TODO: When fonts are figured out at last...
    //init_fonts();
}

draw_menu_element :: (using element: *Menu_Element, index: int, color := color_fg, second_color := color_3) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            draw_tile(sprite_index, .{3, index}, color);

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            if value.* {
                draw_tile(sprite_index, .{3, index}, color);
            }
            else {
                draw_tile(sprite_index_two, .{3, index}, color);
            }

        case .SLIDER;
            using cast(*Slider_Element)element;
            draw_tile(754, .{1, index}, second_color);
            draw_tile(755, .{2, index}, second_color);
            draw_tile(755, .{3, index}, second_color);
            draw_tile(755, .{4, index}, second_color);
            draw_tile(754, .{5, index}, second_color, horizontal_flip=true);

            value_index := cast(int)(value.* * 4) + 1;
            if value_index == 1 {
                draw_tile(sprite_index_two, .{value_index, index}, color);
            }
            else {
                draw_tile(sprite_index, .{value_index, index}, color);
            }
    }
}

//
// deprecated for this project, maybe useful later.
//

/*
draw_menu_element_text :: (shader: Shader, font: Font, using element: *Menu_Element, height : float, color := color_fg) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            draw_text_centered(shader, font, name, height, color);

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            str := "Off";
            if value
                str = "On";
            draw_text_centered(shader, font, tprint("% - %", name, str), height, color);

        case .SLIDER;
            using cast(*Slider_Element)element;
            draw_text_centered(shader, font, tprint("% - %", name, value.*), height, color);
    }
}
*/
