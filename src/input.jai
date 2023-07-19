// Tactics
// Input
// Alex Hartford
// June 2023

input : struct {
    up    := false;
    left  := false;
    down  := false;
    right := false;

    button_1 := false;
    button_2 := false;
    button_3 := false;
    button_4 := false;

    left_click  := false;
    right_click := false;

    /*
    menu_button := false;
    button_5 := false;
    button_6 := false;
    button_7 := false;
    button_8 := false;
    */
}

// @TODO: Decide where this ought to go.
gamepad : *SDL_Joystick;
JOYSTICK_DEAD_ZONE :: 8000;

handle_events :: () {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        ImGui_ImplSdl_ProcessEvent(*event);
        if event.type == {
            case SDL_QUIT;
                running = false;
            case SDL_KEYUP;
                if event.key.keysym.sym == SDLK_w       input.up    = false;
                if event.key.keysym.sym == SDLK_a       input.left  = false;
                if event.key.keysym.sym == SDLK_s       input.down  = false;
                if event.key.keysym.sym == SDLK_d       input.right = false;
                if event.key.keysym.sym == SDLK_SPACE   input.button_1 = false;
                if event.key.keysym.sym == SDLK_z       input.button_2 = false;
                if event.key.keysym.sym == SDLK_q       input.button_3 = false;
                if event.key.keysym.sym == SDLK_e       input.button_4 = false;

            case SDL_KEYDOWN;
                if program_state.imgui_capturing_keyboard return;

                if event.key.keysym.sym == SDLK_r {
                    if program_mode == {
                        case .GAME;
                        program_mode = .EDITOR;
                        activate_mouse();

                        case .EDITOR;
                        program_mode = .GAME;
                        deactivate_mouse();
                    }
                }

                if event.key.keysym.sym == SDLK_k {
                    program_mode = .GAME_OVER;
                }

                if event.key.keysym.sym == SDLK_0
                    program_paused = !program_paused;

                if event.key.keysym.sym == SDLK_g
                    debug.active = !debug.active;

                if event.key.keysym.sym == SDLK_ESCAPE {
                    if program_mode == .GAME {
                        program_mode = .MENU;
                        menu.element_index = 0;
                    }
                    else if program_mode == .MENU {
                        program_mode = .GAME;
                    }
                    else if program_mode == .GAME_OVER {
                        running = false;
                    }
                }

                // Main Program Inputs
                {
                    if event.key.repeat != 0 return;
                    if event.key.keysym.sym == SDLK_w       input.up    = true;
                    if event.key.keysym.sym == SDLK_a       input.left  = true;
                    if event.key.keysym.sym == SDLK_s       input.down  = true;
                    if event.key.keysym.sym == SDLK_d       input.right = true;
                    if event.key.keysym.sym == SDLK_SPACE   input.button_1 = true;
                    if event.key.keysym.sym == SDLK_z       input.button_2 = true;
                    if event.key.keysym.sym == SDLK_q       input.button_3 = true;
                    if event.key.keysym.sym == SDLK_e       input.button_4 = true;
                }

                // Settings
                /*
                if event.key.keysym.sym == SDLK_l {
                    if settings.line_mode
                        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
                    else
                        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
                    settings.line_mode = !settings.line_mode;
                }
                */

            case SDL_MOUSEBUTTONDOWN;
                if event.button.button == SDL_BUTTON_LEFT input.left_click = true;
                if event.button.button == SDL_BUTTON_RIGHT input.right_click = true;

            case SDL_MOUSEBUTTONUP;
                if event.button.button == SDL_BUTTON_LEFT input.left_click = false;
                if event.button.button == SDL_BUTTON_RIGHT input.right_click = false;

            case SDL_WINDOWEVENT;
                if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                    window_width  = event.window.data1;
                    window_height = event.window.data2;
                    aspect_ratio  = window_width / cast(float)window_height;
                }

            case SDL_JOYAXISMOTION;
                if event.jaxis.which == 0 {
                    if event.jaxis.axis == 0 {
                        if event.jaxis.value < -JOYSTICK_DEAD_ZONE
                            input.left = true;
                        else if event.jaxis.value > JOYSTICK_DEAD_ZONE
                            input.right = true;
                        else {
                            input.left = false;
                            input.right = false;
                        }
                    }
                    else if event.jaxis.axis == 1 {
                        if event.jaxis.value < -JOYSTICK_DEAD_ZONE
                            input.up = true;
                        else if event.jaxis.value > JOYSTICK_DEAD_ZONE
                            input.down = true;
                        else {
                            input.up = false;
                            input.down = false;
                        }
                    }
                }

            case SDL_JOYBUTTONDOWN;
                if event.jbutton.button == 0 input.button_1 = true;
                if event.jbutton.button == 1 input.button_2 = true;
                if event.jbutton.button == 2 input.button_3 = true;
                if event.jbutton.button == 3 input.button_4 = true;

                // 4, 5 : left bumper / right bumper
                // 6, 7 : select / start
                // 8, 9 : pressing in left stick / right stick

            case SDL_JOYBUTTONUP;
                if event.jbutton.button == 0 input.button_1 = false;
                if event.jbutton.button == 1 input.button_2 = false;
                if event.jbutton.button == 2 input.button_3 = false;
                if event.jbutton.button == 3 input.button_4 = false;

            case SDL_JOYHATMOTION;
                hat_state : u8;
                hat_state = event.jhat.value;

                if hat_state & 1 input.up = true;
                else input.up = false;

                if hat_state & 2 input.right = true;
                else input.right = false;

                if hat_state & 4 input.down = true;
                else input.down = false;

                if hat_state & 8 input.left = true;
                else input.left = false;

            case SDL_JOYDEVICEADDED;
                log("Gamepad connected!");
                gamepad = SDL_JoystickOpen(0);
                assert(gamepad != null);

            case SDL_JOYDEVICEREMOVED;
                log("Gamepad removed!");
                gamepad = null;
        }
    }
}
