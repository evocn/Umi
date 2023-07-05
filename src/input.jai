// Everett
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

handle_events :: () {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        ImGui_ImplSdl_ProcessEvent(*event);
        if event.type == {
            case SDL_QUIT;
                running = false;
            case SDL_KEYUP;
                if event.key.keysym.sym == SDLK_w input.up    = false;
                if event.key.keysym.sym == SDLK_a input.left  = false;
                if event.key.keysym.sym == SDLK_s input.down  = false;
                if event.key.keysym.sym == SDLK_d input.right = false;
                if event.key.keysym.sym == SDLK_SPACE  input.button_1 = false;
                if event.key.keysym.sym == SDLK_LSHIFT input.button_2 = false;
                if event.key.keysym.sym == SDLK_q      input.button_3 = false;
                if event.key.keysym.sym == SDLK_e      input.button_4 = false;

            case SDL_KEYDOWN;
                if event.key.keysym.sym == SDLK_ESCAPE running = false;

                // Settings
                if event.key.keysym.sym == SDLK_l {
                    if settings.line_mode
                        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
                    else
                        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
                    settings.line_mode = !settings.line_mode;
                }

                if event.key.keysym.sym == SDLK_0 {
                    program_state.paused = !program_state.paused;
                }

                if event.key.keysym.sym == SDLK_r {
                    if program_state.mode == {
                        case .GAME;
                        program_state.mode = .EDITOR;

                        case .EDITOR;
                        program_state.mode = .GAME;
                    }
                }

                // Actual Inputs
                if event.key.keysym.sym == SDLK_w input.up    = true;
                if event.key.keysym.sym == SDLK_a input.left  = true;
                if event.key.keysym.sym == SDLK_s input.down  = true;
                if event.key.keysym.sym == SDLK_d input.right = true;
                if event.key.keysym.sym == SDLK_SPACE  input.button_1 = true;
                if event.key.keysym.sym == SDLK_LSHIFT input.button_2 = true;
                if event.key.keysym.sym == SDLK_q      input.button_3 = true;
                if event.key.keysym.sym == SDLK_e      input.button_4 = true;


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

        }
    }
}
