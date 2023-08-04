// Umi
// Main
// Alex Hartford
// June 2023

running : bool;

window          : *SDL_Window;
gl_context      : *SDL_GLContext;
imgui_context   : *ImGui.ImGuiContext;

WINDOW_WIDTH  :: 1536;
WINDOW_HEIGHT :: 864;

//WINDOW_WIDTH  :: 512;
//WINDOW_HEIGHT :: 288;

PIXEL_WIDTH :: 512;
PIXEL_HEIGHT :: 288;

window_width  : s32 = WINDOW_WIDTH;
window_height : s32 = WINDOW_HEIGHT;
aspect_ratio  : float = 1.78;

//
//

Program_Mode :: enum {
    GAME;
    START;
    EDITOR;
    CUTSCENE;
    DIALOGUE;
    MENU;
    GAME_OVER;
    CREDITS;
}

switch_mode :: (new_mode: Program_Mode) {
    prior_program_mode = program_mode;
    program_mode = new_mode;
}

return_to_prior_mode :: () {
    prior_mode_tmp := prior_program_mode;
    prior_program_mode = program_mode;
    program_mode = prior_mode_tmp;
}

using program_state : struct {
    program_mode : Program_Mode = .START;
    prior_program_mode : Program_Mode;

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
    fullscreen := false;
    // fps
    // resolution
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

    controls : Sprite;
    sprites : Table(string, Sprite);
    murals : Table(string, Sprite);
    slices : Table(string, Sprite);
}
main_font   : Font;
second_font : Font;

menu : Menu;
start_menu : Menu;

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
main :: () {
    init_result := init();
    assert(init_result);
    // init gameplay objects
    units : [..] *Unit;
    success := load_units(*units, "all.units");
    assert(success, "Unable to run the game without the units file.\n");

    map : Map;

    dialogue: Dialogue;
    initialize(*dialogue);

    spine_load("the.spine");

    // The Loop
    dt, last_frame := 0.0;
    running = true;

    while running {
        reset_temporary_storage();
        current_time := cast(float32)get_time();
        dt = current_time - last_frame;
        last_frame = current_time;

        handle_events();
        update_input_hold_times(dt);

        simulate(*map, *dialogue, units, dt);

        render(map, dialogue);
        {
            // Draw extra things on top of the framebuffer.
            if program_mode == .EDITOR {
                update_and_draw_editor(*map, *units);
                ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
            }
        }

        SDL_GL_SwapWindow(window);
        SDL_Delay(1);
    }

    {
        // Cleanup
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
    }

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
