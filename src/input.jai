// Tactics
// Input
// Alex Hartford
// June 2023

Button :: struct {
    pressed : bool;
    held_for : float;
}

press_button :: (using button: *Button) {
    pressed = true;
    held_for = 0.0;
}

release_button :: (using button: *Button) {
    pressed = false;
    held_for = 0.0;
}

pressed :: (using button: *Button) -> bool {
    if pressed {
        pressed = false;
        return true;
    }

    return false;
}

HOLD_REPEAT_TIME :: 0.15;

update_input_hold_times :: (dt: float) {
    using input;

    maybe_increment_hold_time :: (button: *Button, dt: float) {
        if button.held_for > HOLD_REPEAT_TIME {
            press_button(button);
        }

        if button.pressed || button.held_for != 0.0 {
            button.held_for += dt;
        }
    }

    maybe_increment_hold_time(*up, dt);
    maybe_increment_hold_time(*left, dt);
    maybe_increment_hold_time(*down, dt);
    maybe_increment_hold_time(*right, dt);
    //maybe_increment_hold_time(*button_1, dt);
    //maybe_increment_hold_time(*button_2, dt);
    //maybe_increment_hold_time(*button_3, dt);
    //maybe_increment_hold_time(*button_4, dt);
    //maybe_increment_hold_time(*button_menu, dt);
    //maybe_increment_hold_time(*button_select, dt);
    //maybe_increment_hold_time(*button_info, dt);
    //maybe_increment_hold_time(*button_5, dt);
    //maybe_increment_hold_time(*button_6, dt);
}

//
//

input : struct {
    up    : Button;
    left  : Button;
    down  : Button;
    right : Button;

    button_1 : Button;
    button_2 : Button;
    button_3 : Button;
    button_4 : Button;

    button_menu  : Button;
    button_select : Button;
    button_info   : Button;

    button_5 : Button;
    button_6 : Button;
    button_7 : Button;
    button_8 : Button;
}

//update_input :: 

gamepad : *SDL_Joystick;
JOYSTICK_DEAD_ZONE :: 8000;

//
//

handle_events :: () {
    using input;

    event : SDL_Event;
    while SDL_PollEvent(*event) {
        ImGui_ImplSdl_ProcessEvent(*event);
        if event.type == {
            case SDL_QUIT;
                running = false;
            case SDL_KEYUP;
                if event.key.keysym.sym == SDLK_w       release_button(*up);
                if event.key.keysym.sym == SDLK_a       release_button(*left);
                if event.key.keysym.sym == SDLK_s       release_button(*down);
                if event.key.keysym.sym == SDLK_d       release_button(*right);

                if event.key.keysym.sym == SDLK_ESCAPE  release_button(*button_menu);
                if event.key.keysym.sym == SDLK_RETURN  release_button(*button_select);
                if event.key.keysym.sym == SDLK_TAB     release_button(*button_info);

                if event.key.keysym.sym == SDLK_SPACE   release_button(*button_1);
                if event.key.keysym.sym == SDLK_z       release_button(*button_2);
                if event.key.keysym.sym == SDLK_x       release_button(*button_3);
                if event.key.keysym.sym == SDLK_c       release_button(*button_4);

                if event.key.keysym.sym == SDLK_q       release_button(*button_5);
                if event.key.keysym.sym == SDLK_e       release_button(*button_6);

            case SDL_KEYDOWN;
                if program_state.imgui_capturing_keyboard return;

                // Main Program Inputs
                {
                    if event.key.repeat != 0 return;
                    if event.key.keysym.sym == SDLK_w       press_button(*up);
                    if event.key.keysym.sym == SDLK_a       press_button(*left);
                    if event.key.keysym.sym == SDLK_s       press_button(*down);
                    if event.key.keysym.sym == SDLK_d       press_button(*right);

                    if event.key.keysym.sym == SDLK_ESCAPE  press_button(*button_menu);
                    if event.key.keysym.sym == SDLK_RETURN  press_button(*button_select);
                    if event.key.keysym.sym == SDLK_TAB     press_button(*button_info);

                    if event.key.keysym.sym == SDLK_SPACE   press_button(*button_1);
                    if event.key.keysym.sym == SDLK_z       press_button(*button_2);
                    if event.key.keysym.sym == SDLK_x       press_button(*button_3);
                    if event.key.keysym.sym == SDLK_c       press_button(*button_4);

                    if event.key.keysym.sym == SDLK_q       press_button(*button_5);
                    if event.key.keysym.sym == SDLK_e       press_button(*button_6);
                }

                // Development keybinds
                {
                    if event.key.keysym.sym == SDLK_r {
                        if program_mode == {
                            case .GAME; #through;
                            case .GAME_OVER;
                            switch_mode(.EDITOR);
                            activate_mouse();

                            case .EDITOR;
                            switch_mode(.GAME);
                            deactivate_mouse();
                        }
                    }

                    if event.key.keysym.sym == SDLK_n {
                        spine.ready_for_next_section = true;
                    }

                    if event.key.keysym.sym == SDLK_k
                        switch_mode(.GAME_OVER);

                    if event.key.keysym.sym == SDLK_0
                        program_paused = !program_paused;
                }


            case SDL_WINDOWEVENT;
                if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                    window_width  = event.window.data1;
                    window_height = event.window.data2;
                    aspect_ratio  = window_width / cast(float)window_height;
                }

            case SDL_JOYAXISMOTION;
            // @TODO: Fix this! Too fast!
                if event.jaxis.which == 0 {
                    if event.jaxis.axis == 0 {
                        if event.jaxis.value < -JOYSTICK_DEAD_ZONE {
                            press_button(*left);
                        }
                        else if event.jaxis.value > JOYSTICK_DEAD_ZONE
                            press_button(*right);
                        else {
                            release_button(*left);
                            release_button(*right);
                        }
                    }
                    else if event.jaxis.axis == 1 {
                        if event.jaxis.value < -JOYSTICK_DEAD_ZONE
                            press_button(*up);
                        else if event.jaxis.value > JOYSTICK_DEAD_ZONE
                            press_button(*down);
                        else {
                            release_button(*up);
                            release_button(*down);
                        }
                    }
                }

            case SDL_JOYBUTTONDOWN;
                // 0, 1, 2, 3 : face buttons
                // 4, 5 : left bumper / right bumper
                // 6, 7 : select / start
                // 8, 9 : pressing in left stick / right stick

                if event.jbutton.button == 0 press_button(*button_1);
                if event.jbutton.button == 1 press_button(*button_2);
                if event.jbutton.button == 2 press_button(*button_3);
                if event.jbutton.button == 3 press_button(*button_4);

                if event.jbutton.button == 4 press_button(*button_5);
                if event.jbutton.button == 5 press_button(*button_6);

                if event.jbutton.button == 6 press_button(*button_menu);
                if event.jbutton.button == 7 press_button(*button_select);
                if event.jbutton.button == 8 press_button(*button_info);

            case SDL_JOYBUTTONUP;
                if event.jbutton.button == 0 release_button(*button_1);
                if event.jbutton.button == 1 release_button(*button_2);
                if event.jbutton.button == 2 release_button(*button_3);
                if event.jbutton.button == 3 release_button(*button_4);

                if event.jbutton.button == 4 release_button(*button_5);
                if event.jbutton.button == 5 release_button(*button_6);

                if event.jbutton.button == 6 release_button(*button_menu);
                if event.jbutton.button == 7 release_button(*button_select);
                if event.jbutton.button == 8 release_button(*button_info);

            case SDL_JOYHATMOTION;
                hat_state : u8;
                hat_state = event.jhat.value;

                if hat_state & 1 then press_button(*up);
                else release_button(*up);

                if hat_state & 2 then press_button(*right);
                else release_button(*right);

                if hat_state & 4 then press_button(*down);
                else release_button(*down);

                if hat_state & 8 then press_button(*left);
                else release_button(*left);

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
