// Tactics
// Main
// Alex Hartford
// June 2023

VERSION :: 1;

sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";

grids_path      :: "data";
units_path      :: "data";

pool: Flat_Pool;

window : *SDL_Window;
gl_context : *SDL_GLContext;
imgui_context : *ImGui.ImGuiContext;

window_width  : s32 = 1280;
window_height : s32 = 720;
aspect_ratio  : float = 1.78;

running : bool;

quad : Quad;
fonts : Table(string, Font);
spritesheet : Spritesheet;

// Program-Level State
//

program_state : struct {
    Program_Mode :: enum {
        GAME;
        EDITOR;
    }
    mode : Program_Mode;

    paused : bool;

    current_level_name := "level1";

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;

    framerate : float;
}

settings : struct {
    line_mode := false;
}

editor : struct {
}

debug : struct {
    lines : [4] string;
}

// Render-Level State
//

render_context : struct {
    using shaders : struct {
        shader      : Shader;
        text_shader : Shader;
    }
}

// Game-Level State
//

game_state : struct {
    teams := Team.[.BLUE, .RED];
    current_turn_team_index : int;
}

whose_turn :: () -> Team {
    using game_state;
    return teams[current_turn_team_index];
}

next_turn :: () -> Team {
    using game_state;

    current_turn_team_index += 1;
    if current_turn_team_index > teams.count
        current_turn_team_index = 0;

    return whose_turn();
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
        // Shaders
        render_context.shader       = make_shader("screen.vs", "texture.fs");
        render_context.text_shader  = make_shader("text.vs", "text.fs");

        // Primitives
        init_quad_rendering_objects(*quad);

        // Fonts
        table_add(*fonts, "Header", make_font("JosefinSans-Regular.ttf", 24));
        //table_add(*fonts, "Body",   make_font("OpenSans-BoldItalic.ttf", 22));
        
        // Sprites
        success := make_spritesheet(*spritesheet, "sheet.png");
        assert(success);
    }

    map : Map;
    units : [..] *Unit;

    // Init Gameplay Objects
    {
        load_grid(*map, "level1.map");

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

        // Debug Console
        debug.lines[0] = tprint("Cursor Position: %", cursor.square);
        debug.lines[1] = tprint("Cursor State: %", cursor.state);

        // Handle Events
        handle_events();

        // Simulate
        if program_state.mode == .GAME {
            if !program_state.paused {
                update_cursor(*map);
            }
        }

        // Editor
        if program_state.mode == .EDITOR {
            update_and_draw_editor();
        }

        // Render
        render(map, units);
        if program_state.mode == .EDITOR {
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }
        SDL_GL_SwapWindow(window);

        SDL_Delay(1);
    }

    array_reset(*units);
    reset(*pool, overwrite_memory=true);

    for fonts
    deinit(*it.characters);
    deinit(*fonts);

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

#import "File";     // read_ and write_ entire_file()
#import "System";   // get_path_of_running_executable()

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "stb_image";
#import "freetype255";
