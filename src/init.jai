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
        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK);

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

    // Init Rendering Structures
    {
        using rendering;
        // Shaders
        shader       = make_shader("screen.vs", "texture.fs");
        text_shader  = make_shader("text.vs", "text.fs");

        // Primitives
        init_quad_rendering_objects(*quad);

        // Sprites
        success := make_spritesheet(*spritesheet, "sheet.png");
        assert(success);
    }

    init_fonts();

    //init_audio();

    init_menus();

    init_levels();

    // Init Gamepad
    if SDL_NumJoysticks() > 0 {
        print("Houston, we have a gamepad!\n");
        gamepad = SDL_JoystickOpen(0);
        assert(gamepad != null);
    }

    return true;
}

init_fonts :: () {
    deinit(*font.characters);
    font = make_font("mkd.ttf", xx (window_height / 16));
    //font = make_font("josefin.ttf", xx (window_height / 16));
}
        

init_audio :: () {
}

init_menus :: () {
    {
        using menu;
        name = "pause";

        a: Allocator;
        a.proc = flat_pool_allocator_proc;
        a.data = *pool;

        resume := New(Go_Element, allocator=a);
        resume.name = "resume";
        resume.callback = resume_game;
        array_add(*elements, cast(*Menu_Element)resume);

        fullscreen := New(Go_Element, allocator=a);
        fullscreen.name = "fullscreen";
        fullscreen.callback = toggle_fullscreen;
        array_add(*elements, cast(*Menu_Element)fullscreen);

        /*
        master := New(Slider_Element);
        master.name = "Master";
        master.value = *sound_player.master_volume;
        array_add(*elements, cast(*Menu_Element)master);

        music := New(Slider_Element);
        music.name = "Music";
        music.value = *sound_player.mix_music;
        array_add(*elements, cast(*Menu_Element)music);

        sfx := New(Slider_Element);
        sfx.name = "sfx";
        sfx.value = *sound_player.mix_props;
        array_add(*elements, cast(*Menu_Element)sfx);
        */

        quit := New(Go_Element, allocator=a);
        quit.name = "quit";
        quit.callback = quit_game;
        array_add(*elements, cast(*Menu_Element)quit);
    }
}

//
//

levels : [..] string;
init_levels :: () {
    array_reset(*levels);

    levels_paths := File_Utilities.file_list(levels_path, recursive = true, follow_symlinks = false);

    for levels_paths {
        short_name := path_strip_extension(path_filename(it));
        array_add(*levels, short_name);
    }

    for levels_paths {
        free(it.data);
    }
    array_free(levels_paths);
}

/*
read_levels_file :: () -> bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    filename := "levels.txt";
    start_file(*handler, filename, tprint("%/%", levels_path, filename), optional = false);
    if handler.failed return false;

    line, found := consume_next_line(*handler);
    while found {
        array_add(*levels, line);
        line, found := consume_next_line(*handler);
    }

    return true;
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
