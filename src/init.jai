// Tactics
// Init
// Alex Hartford
// June 2023

init :: () -> bool {
	// Set the working directory to the base of the project so we can access our folders nicely.
	executable_path := path_strip_filename(System.get_path_of_running_executable());
	set_working_directory (tprint("%/../", executable_path));

    set_my_print_format();

    // SDL
    {
        SDL_Init(SDL_INIT_VIDEO);

        // Create an application window with the following settings:
        window = SDL_CreateWindow("Tactics",
            SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_width, window_height,
            SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

        if !window {
            print("Could not create window: %\n", to_string(SDL_GetError()));
            return false;
        }

        // Settings
        SDL_ShowCursor(0);
        SDL_SetRelativeMouseMode(SDL_TRUE);

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
    }

    // GL
    {
        gl_context = SDL_GL_CreateContext(window);
        if !gl_context {
            print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
            return false;
        }  

        gl_load(*gl, SDL_GL_GetProcAddress);
        //print("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
        //print("GL Version = %\n", to_string(glGetString(GL_VERSION)));

        // Settings
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
        // @TODO: This is not a complete solution. In order to properly do alpha blending...
        // 1. Draw all the opaque objects.
        // 2. Sort all the transparent objects by distance to the viewer.
        // 3. Draw all the transparent object in sorted order.

        glLineWidth(1);
        glPointSize(5);
    }

    // ImGui
    {
        imgui_context = ImGui.CreateContext();
        ImGui_ImplSdl_Init(window);

        ImGui.StyleColorsClassic();
        //ImGui.StyleColorsLight();
    }

    //init_audio();

    return true;
}

/*
init_audio :: () {
    sound_player = New(Sound_Player);
    sound_player.update_history = true;

    //
    // Load sound effects
    //
    load_sound :: (basename: string) -> *Mixer_Sound_Data {
        name := tprint("%/%.wav", sfx_path, basename);
        data := load_audio_file(name);

        if !data {
            log_error("Could not load wav file: %\n", name);
            assert(false);
        }

        return data;
    }

    sound_paths := File_Utilities.file_list(sfx_path, recursive = true, follow_symlinks = false);

    for sound_paths {
        short_name := path_strip_extension(path_filename(it));
        table_add(*sounds, short_name, load_sound(short_name));
    }

    // Start Screen Music
    // @TODO: Put this where we initialize the start screen and stuff.
    play_music("mohican");

    wmInfo : SDL_SysWMinfo;
    SDL_VERSION(*wmInfo.version);
    SDL_GetWindowWMInfo(window, *wmInfo);
    hwnd := wmInfo.info.win.window;

    success := init(sound_player, hwnd, true, true);
    //assert(success);

    sound_player.mix_props = 1.0;
}
*/

//
//

set_my_print_format :: (c : *Context = null)
{
    if c == null then c = *context;

    // structs
    {
        using c.print_style.default_format_struct;
        //draw_type_name = true;
        //use_long_form_if_more_than_this_many_members = -1;
        //separator_between_name_and_value    = " = ";
        short_form_separator_between_fields = " ";
        long_form_separator_between_fields  = " ";
        begin_string = "";
        end_string   = "";
        indentation_width = 4;
        use_newlines_if_long_form = true;
    }

    // arrays
    {
        using c.print_style.default_format_array;
        separator = ", ";
        begin_string = "[";
        end_string   = "]";
        printing_stopped_early_string = "...";
        draw_separator_after_last_element = false;
        stop_printing_after_this_many_elements = 16;
    }

    // floats
    {
        using c.print_style.default_format_float;
        zero_removal = .ONE_ZERO_AFTER_DECIMAL;
    }
}
