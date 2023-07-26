// Tactics
// Main
// Alex Hartford
// June 2023

running : bool;

window          : *SDL_Window;
gl_context      : *SDL_GLContext;
imgui_context   : *ImGui.ImGuiContext;

WINDOW_WIDTH  :: 1280;
WINDOW_HEIGHT :: 720;

PIXEL_WIDTH :: 512;
PIXEL_HEIGHT :: 288;

window_width  : s32 = WINDOW_WIDTH;
window_height : s32 = WINDOW_HEIGHT;
aspect_ratio  : float = 1.78;

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
audio_pool  : Flat_Pool;

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
        shader          : Shader;
        text_shader     : Shader;
        quad_shader     : Shader;
        sprite_shader   : Shader;
    }

    quad : Quad;
    spritesheet : Spritesheet;
    ship_spritesheet : Spritesheet;
    uncle : Sprite;
}
main_font   : Font;
second_font : Font;

// @TODO: Decide where this ought to go.
menu : Menu;

sound_player : *Sound_Player;
music : *Mixer_Sound_Data;
sfx   : Table(string, *Mixer_Sound_Data);

// Loggers
//

logging := Log_Level.NORMAL;

save_load_logger :: (message: string, data: *void, info: Log_Info) {
    if !(info.common_flags & .VERBOSE_ONLY) || logging == .VERBOSE {
        print("[Save/Load]: %", message);
    }
}
// Main
//
animator : Animator;
animator2 : Animator;

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

    // @TODO: How do we actually want to initialize these? Some kind of constructing function?
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *pool;

    animator.end = 1.0;
    animator.animating = *rendering.uncle.offset;
    animator.interpolation_function = smooth_stop;
    animator.key_frames.allocator=a;

    array_add(*animator.key_frames, Key_Frame.{0.0, 200});
    array_add(*animator.key_frames, Key_Frame.{0.5, 0});

    animator2.end = 1.0;
    animator2.animating = *rendering.uncle.offset;
    animator2.interpolation_function = smooth_start;
    animator2.key_frames.allocator=a;

    array_add(*animator2.key_frames, Key_Frame.{0.0, 0});
    array_add(*animator2.key_frames, Key_Frame.{0.5, 200});

    // The Loop
    dt, last_frame := 0.0;
    running = true;

    print("Welcome to Tactics.\n");
    while running {
        reset_temporary_storage();
        current_time := cast(float32)get_time();
        dt = current_time - last_frame;
        last_frame = current_time;

        update_sound_player(dt);

        handle_events();
        update_input_hold_times(dt);

        // Simulation
        update(*animator, dt);
        update(*animator2, dt);
        roll_time = clamp(roll_time - dt, 0, roll_onscreen_time);

        if #complete program_mode == {
            case .GAME;
            if !program_paused {
                turn := whose_turn();
                if #complete turn == {
                    case .YOU;
                    resolve_cursor_inputs(*map);
                    for command_queue {
                        execute(it);
                        free(it);
                    }
                    array_reset(*command_queue);

                    case .THEM;
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

                player_units_left := query_units(map.units, (x) => (x.team == .YOU));
                if player_units_left.count == 0 {
                    program_mode = .GAME_OVER;
                }
            }

            case .MENU;
            resolve_menu_inputs(*menu);

            case .GAME_OVER;
            resolve_game_over(*map, units);

            case .EDITOR;
            if !program_state.imgui_capturing_keyboard {
                update_editor_cursor(*map);
            }
        }

        // Set Debug Console
        debug.lines[0] = to_lower_copy(tprint("Cursor State - %", cursor.state), allocator=temp);

        // Render
        {
            // Render all this to the framebuffer.
            {
                glBindFramebuffer(GL_FRAMEBUFFER, fbo);
                glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
                glClearColor(color_bg.x, color_bg.y, color_bg.z, 1);
                glClear(GL_COLOR_BUFFER_BIT);

                if #complete program_mode == {
                    case .GAME;
                    render(map);
                    render_ui(map);
                    render_dialogue();

                    case .EDITOR;
                    render(map);
                    render_ui(map);

                    case .MENU;
                    render(map, transparency = 0.3);
                    render_ui(map, transparency = 0.3);
                    render_dialogue(transparency = 0.3);
                    render_menu(menu);

                    case .GAME_OVER;
                    render(map, transparency = 0.3);
                    render_ui(map, transparency = 0.3);
                    render_dialogue(transparency = 0.3);
                    render_game_over();
                }
            }

            {
                // Render the framebuffer to the screen.
                glBindFramebuffer(GL_FRAMEBUFFER, 0);
                glViewport(0, 0, xx window_width, xx window_height);
                glClearColor(1.0, 1.0, 1.0, 1.0);
                glClear(GL_COLOR_BUFFER_BIT);

                render_framebuffer_to_screen();
            }
            {
                // Draw extra things on top of the framebuffer.
                if program_mode == .EDITOR {
                    update_and_draw_editor(*map, *units);
                    ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
                }
            }
            SDL_GL_SwapWindow(window);
        }

        SDL_Delay(1);
    }

    reset(*pool, overwrite_memory=true);

    array_reset(*units);
    reset(*units_pool, overwrite_memory=true);

    reset(*level_pool, overwrite_memory=true);

    array_reset(*menu.elements);
    array_reset(*levels);

    deinit(*main_font.characters);
    deinit(*second_font.characters);

    stop_all_sounds_abruptly(sound_player, 0);
    shutdown(sound_player);

    free(sound_player);
    reset(*audio_pool, overwrite_memory=true);
    deinit(*sfx);

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

#import "Sound_Player";
#import "Wav_File";
#import "stb_vorbis";
#import "Thread";
#import "Random";           
#import "Sort";
#import "File";

File_Utilities :: #import "File_Utilities"; // for file_list()
System         :: #import "System";         // For get_path_of_running_executable()

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "stb_image";
#import "freetype-2.12.1";
