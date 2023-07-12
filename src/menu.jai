// Tactics
// Menu
// Alex Hartford
// July 2023

Go_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .GO;

    name : string;
    callback : #type ();
}

Checkbox_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .CHECKBOX;

    name : string;
    value : *bool;
}

Slider_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .SLIDER;

    name : string;
    value : *float;

    increment : float = 0.01;
    min : float = 0.0;
    max : float = 1.0;
}

Menu_Element :: struct {
    kind : enum #complete {
        GO;
        CHECKBOX;
        SLIDER;
        //OPTIONS;
    }
}

Menu :: struct {
    name : string;
    elements : [..] *Menu_Element;
    element_index : int;
}

resolve_menu_inputs :: (using menu: *Menu) {
    using input;

    if up {
        up = false;
        element_index -= 1;
        if element_index < 0 {
            //element_index = elements.count - 1;
            element_index += 1;
        }
    }
    if down {
        down = false;
        element_index += 1;
        if element_index >= elements.count {
            //element_index = 0;
            element_index -= 1;
        }
    }
    if left {
        //left = false;
        nudge_menu_element(elements[element_index], left=true);
    }
    if right {
        //right = false;
        nudge_menu_element(elements[element_index]);
    }

    if button_1 {
        button_1 = false;
        toggle_menu_element(elements[element_index]);
    }
    if button_2 {
        button_2 = false;
    }
}

// @TODO: This could return false if we want there to be menu options that bonk on failure.
// Not sure what that would be useful for, just figured I'd mention it in case it became useful.
toggle_menu_element :: (using element: *Menu_Element) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            callback();

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            value.* = !value;

        case .SLIDER;
            // Don't do anything.

            /*
        case .OPTIONS;
            using cast(*Options_Element)element;
            */
    }
}


nudge_menu_element :: (using element: *Menu_Element, left := false) {
    if kind == {
        case .GO;
            // Don't do anything.

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            value.* = !value;

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

/*
toggle_fullscreen :: () {
    desire_fullscreen : bool;
    if !fullscreen then desire_fullscreen = true;
    fullscreen = !fullscreen;

    success:, window_width, window_height = Window_Creation.toggle_fullscreen(window, desire_fullscreen, *saved);
}
*/
