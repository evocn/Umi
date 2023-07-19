// Tactics
// Main
// Alex Hartford
// June 2023

window          : *SDL_Window;
gl_context      : *SDL_GLContext;
imgui_context   : *ImGui.ImGuiContext;

WINDOW_WIDTH  :: 1280;
WINDOW_HEIGHT :: 720;

window_width  : s32 = WINDOW_WIDTH;
window_height : s32 = WINDOW_HEIGHT;
aspect_ratio  : float = 1.78;

running : bool;

//
//

using program_state : struct {
    program_mode : enum {
        GAME;
        EDITOR;
        MENU;
        GAME_OVER;
    }

    program_paused : bool;

    current_level_index := 0;

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;

    framerate : float;
}

pool        : Flat_Pool;
units_pool  : Flat_Pool;
level_pool  : Flat_Pool;

settings : struct {
    line_mode := false;
    fullscreen := false;
    // fps
    // resolution
}

debug : struct {
    active: bool;
    lines : [16] string;
    traversed : Traversal_Result;
}

rendering : struct {
    using shaders : struct {
        shader      : Shader;
        text_shader : Shader;
    }

    quad : Quad;
    spritesheet : Spritesheet;
}
font : Font;

// Loggers
//

logging := Log_Level.NORMAL;

save_load_logger :: (message: string, data: *void, info: Log_Info) {
    if !(info.common_flags & .VERBOSE_ONLY) || logging == .VERBOSE {
        print("[Save/Load]: %", message);
    }
}

// @TODO: Decide where this ought to go.
menu : Menu;

// Main
//

main :: () {
    print("Booting up...\n");
    defer print("Program exited successfully.\n");

    init_result := init();
    assert(init_result);

    units : [..] *Unit;
    map : Map;

    // init gameplay objects
    {
        success : bool;

        success = load_units(*units, "all.units");
        assert(success);

        // @TODO: Default level
        init_level(*map, units, levels[current_level_index]);
    }

    // The Loop
    dt, last_frame := 0.0;
    running = true;

    print("Welcome to Tactics.\n");
    while running {
        reset_temporary_storage();
        current_time := cast(float32)get_time();
        dt = current_time - last_frame;
        last_frame = current_time;

        handle_events();

        // Simulation
        if #complete program_mode == {
            case .GAME;
            if !program_paused {
                turn := whose_turn();
                if #complete turn == {
                    case .BLUE;
                    cursor_update(*map);
                    for command_queue {
                        execute(it);
                        free(it);
                    }
                    array_reset(*command_queue);

                    case .RED;
                    ai_update(*map, dt);

                    case .NONE;
                    print("This team shouldn't be active!\n");
                }

                for map.units {
                    if it.dead {
                        remove_occupant(*map, it.square);
                        remove it;
                    }
                }

                blue_left := query_units(map.units, (x) => (x.team == .BLUE));
                if blue_left.count == 0 {
                    program_mode = .GAME_OVER;
                }
            }

            case .EDITOR;
            update_and_draw_editor(*map, *units);

            if !program_state.imgui_capturing_keyboard {
                update_editor_cursor(*map);
            }

            case .MENU;
            resolve_menu_inputs(*menu);

            case .GAME_OVER;
            resolve_game_over(*map, units);
        }

        // Set Debug Console
        debug.lines[0] = to_lower_copy(tprint("Turn % - %", manager.turn_number, whose_turn()), allocator=temp);
        debug.lines[1] = to_lower_copy(tprint("Cursor State - %", cursor.state), allocator=temp);

        // Render
        if #complete program_mode == {
            case .GAME;
            render(map);

            case .EDITOR;
            render(map);
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());

            case .MENU;
            render_menu(menu);

            case .GAME_OVER;
            render_game_over();
        }
        SDL_GL_SwapWindow(window);

        SDL_Delay(1);
    }

    reset(*pool, overwrite_memory=true);

    array_reset(*units);
    reset(*units_pool, overwrite_memory=true);

    array_reset(*map.units);
    reset(*level_pool, overwrite_memory=true);

    array_reset(*menu.elements);
    array_reset(*levels);

    deinit(*font.characters);

    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();

    #if DEBUG_MEMORY then report_memory_leaks();
}

BUILD : enum { DEVELOPING; DEPLOYING; } : .DEVELOPING;
//DEBUG_MEMORY :: BUILD == .DEPLOYING;
DEBUG_MEMORY :: BUILD == .DEVELOPING;

using Basic :: #import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);

#import "String";
#import "Math";
#import "Hash_Table";
#import "Text_File_Handler";
#import "Flat_Pool";

Thread      :: #import "Thread";            // For lock() and unlock(). (used with audio.jai)
Wav_File    :: #import "Wav_File";          // For get_wav_header() and wav format stuff.
File        :: #import "File";              // For read_ and write_ entire_file()
File_Utilities :: #import "File_Utilities"; // for file_list()
System      :: #import "System";            // For get_path_of_running_executable()
Random      :: #import "Random";            // For random_get_within_range()

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "stb_image";
#import "freetype255";
