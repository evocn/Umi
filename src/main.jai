// Everett
// Main
// Alex Hartford
// June 2023

window : *SDL_Window;
gl_context : *SDL_GLContext;
imgui_context : *ImGui.ImGuiContext;

window_width  : s32 = 1080;
window_height : s32 = 600;
aspect_ratio  : float = 1.8;

running : bool;

// @TODO: We should probably keep primitives like this one that we'll draw a lot in a structure together.
quad : Quad;
cube : Cube;

fonts : Table(string, Font);

// Program-Level State
//

program_state : struct {
    Program_Mode :: enum {
        GAME;
        EDITOR;
    }
    mode : Program_Mode;

    paused : bool;

    current_level_name := "level1.entities";

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
    lines : [..] string;
}

// Render-Level State
//

render_context : struct {
    using shaders : struct {
        basic_shader     : Shader;
        texture_shader   : Shader;

        screen_shader    : Shader;
        text_shader      : Shader;
    }
}

// Game-Level State
//

game_state : struct {
    teams : [..] Team;
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

texture : Texture;

// Main
//

main :: () {
    print("Booting up...\n");
    defer print("Program exited successfully.\n");

    init_result := init();
    assert(init_result);

    // Shaders
    render_context.basic_shader     = make_shader("basic.vs", "basic.fs");
    render_context.texture_shader   = make_shader("texture.vs", "basic.fs");

    render_context.screen_shader    = make_shader("screen.vs", "texture.fs");
    render_context.text_shader      = make_shader("text.vs", "text.fs");

    // Primitives
    init_quad_rendering_objects(*quad);
    init_cube_rendering_objects(*cube);

    // Fonts
    table_add(*fonts, "Header", make_font("JosefinSans-Regular.ttf", 24));
    //table_add(*fonts, "Body",   make_font("OpenSans-BoldItalic.ttf", 22));

    /*
    // Animations
    anim : Sampled_Animation;
    loaded = load_animation_from_file(*anim, "assets/animations/idle.anim");
    if !loaded
        log_error ("Could not load % animation.", basename);

    init_rendering_objects(animation_shader);

    animation_time := 0.0;
    animation_speed_in_fps := 20.0;

    pose : Skeleton_Pose;
    pose = make_pose_for_skeleton(*mesh.skeleton);
    */

    // Gameplay structures setup
    map : Map;
    load_grid(*map, "level1.map");

    array_add(*game_state.teams, .BLUE);
    array_add(*game_state.teams, .RED);

    // The Game Loop
    print("Welcome to the Everett Engine.\n");

    dt, last_frame := 0.0;
    running = true;
    while running {
        reset_temporary_storage();
        current_time := cast(float32)get_time();
        dt = current_time - last_frame;
        last_frame = current_time;

        // Debug Console
        array_reset(*debug.lines);
        array_add(*debug.lines, tprint("Cursor Position: %", cursor.square));
        array_add(*debug.lines, tprint("Cursor State: %", cursor.state));

        // Handle Events
        handle_events();

        // Simulate
        if program_state.mode == .GAME {
            if !program_state.paused {
                update_cursor(*map);
            }
        }

        /*
        reset_to_bind_pose(*pose);
        sample_animation(anim, animation_time, *pose, .LINEAR);

        // Increment animation time
        animation_time += dt * animation_speed_in_fps;
        animation_time = fmod_cycling(animation_time, xx anim.sample_count);

        // We transpose the result because OpenGL stores matrices in column-major
        generate_skinning_matrices(*pose, transpose_result = true);
        */

        // Editor
        if program_state.mode == .EDITOR {
            update_and_draw_editor();
        }

        // Render
        render(map);
        if program_state.mode == .EDITOR {
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }
        SDL_GL_SwapWindow(window);

        SDL_Delay(1);
    }

    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

using Basic :: #import "Basic";
#import "String";
#import "System"; // get_path_of_running_executable()
#import "Math";
#import "Hash_Table";
#import "Deep_Copy";
Reflection :: #import "Reflection"; // Inspect()

#import "File";
#import "Text_File_Handler";
#import "stb_image";
#import "freetype255";

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
