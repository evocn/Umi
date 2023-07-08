// Tactics
// Main
// Alex Hartford
// June 2023

VERSION :: 1;

sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/audio/music";
sfx_path        :: "assets/audio/sfx";

tiles_path      :: "data";
units_path      :: "data";

window : *SDL_Window;
gl_context : *SDL_GLContext;
imgui_context : *ImGui.ImGuiContext;

window_width  : s32 = 1280;
window_height : s32 = 720;
aspect_ratio  : float = 1.78;

running : bool;

// Audio Stuff
sound_player : *Sound_Player;
music : *Mixer_Sound_Data;
sounds: Table(string, *Mixer_Sound_Data);

// Program-Level State
//

using program_state : struct {
    program_mode : enum {
        GAME;
        EDITOR;
    }

    program_paused : bool;

    current_level_name := "level1";

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;

    framerate : float;
}

pool: Flat_Pool;

settings : struct {
    line_mode := false;
    // fps
    // resolution
    // fullscreened
}

debug : struct {
    lines : [16] string;
}

// Render-Level State
//

rendering : struct {
    using shaders : struct {
        shader      : Shader;
        text_shader : Shader;
    }

    quad : Quad;
    fonts : Table(string, Font);
    spritesheet : Spritesheet;
}

// Main
//

main :: () {
    print("Booting up...\n");
    defer print("Program exited successfully.\n");

    init_result := init();
    assert(init_result);

    // Init Rendering Structures
    {
        using rendering;
        // Shaders
        shader       = make_shader("screen.vs", "texture.fs");
        text_shader  = make_shader("text.vs", "text.fs");

        // Primitives
        init_quad_rendering_objects(*quad);

        // Fonts
        table_add(*fonts, "Header", make_font("JosefinSans-Regular.ttf", 24));
        // @BUG: This crashes the program for some reason...
        //table_add(*fonts, "Body",   make_font("OpenSans-BoldItalic.ttf", 22));
        
        // Sprites
        success := make_spritesheet(*spritesheet, "sheet.png");
        assert(success);
    }

    map : Map;
    units : [..] *Unit;

    // Init Gameplay Objects
    {
        load_tiles(*map, "level1.tiles");

        success := load_units(*units, "level1.units");
        assert(success);

        for units {
            occupy(*map, it.square, it);
        }

        success = save_units(units, "level1.units");
        assert(success);
    }

    // The Game Loop
    print("Welcome to the Tactics Game.\n");

    dt, last_frame := 0.0;
    running = true;
    while running {
        reset_temporary_storage();
        current_time := cast(float32)get_time();
        dt = current_time - last_frame;
        last_frame = current_time;

        //update_sound_player(dt);

        handle_events();

        // Simulation
        if program_mode == .GAME {
            if !program_paused {
                turn := whose_turn();
                if #complete turn == {
                    case .BLUE;
                    cursor_update(*map, *units);

                    case .RED;
                    ai_update(*map, *units, dt);

                    case .NONE;
                    print("This team shouldn't be active!\n");
                }

                for units {
                    if it.dead {
                        remove_occupant(*map, it.square);
                        remove it;
                    }
                }
            }

            for command_queue {
                execute(it);
                free(it);
            }
            array_reset(*command_queue);
        }

        // Editor
        if program_mode == .EDITOR {
            update_and_draw_editor(*map, *units);

            if !program_state.imgui_capturing_keyboard {
                update_editor_cursor(*map);
            }
        }

        // Set Debug Console
        debug.lines[0] = tprint("Turn: %", whose_turn());
        debug.lines[1] = tprint("Cursor State: %", cursor.state);

        // Render
        render(map, units);
        if program_mode == .EDITOR {
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }
        SDL_GL_SwapWindow(window);

        SDL_Delay(1);
    }

    array_reset(*units);
    reset(*pool, overwrite_memory=true);

    for rendering.fonts
        deinit(*it.characters);
    deinit(*rendering.fonts);

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

Thread      :: #import "Thread";   // For lock() and unlock(). (used with audio.jai)
Wav_File    :: #import "Wav_File"; // For get_wav_header() and wav format stuff.
File        :: #import "File";     // For read_ and write_ entire_file()
File_Utilities :: #import "File_Utilities"; // for file_list()
System      :: #import "System";   // For get_path_of_running_executable()
Random      :: #import "Random";   // For random_get_within_range()

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "stb_image";
#import "freetype255";
#import "Sound_Player";
