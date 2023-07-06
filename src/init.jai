// Tactics
// Init
// Alex Hartford
// June 2023

init :: () -> bool {
    SDL_Init(SDL_INIT_VIDEO);

    // Create an application window with the following settings:
    window = SDL_CreateWindow("Tactics",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_width, window_height,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

    if !window {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return false;
    }

    // SDL Settings
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

    gl_context = SDL_GL_CreateContext(window);
    if !gl_context {
        print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        return false;
    }  

    gl_load(*gl, SDL_GL_GetProcAddress);
    //print("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
    //print("GL Version = %\n", to_string(glGetString(GL_VERSION)));

    // GL Settings
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
    // @TODO: This is not a complete solution. In order to properly do alpha blending...
    // 1. Draw all the opaque objects.
    // 2. Sort all the transparent objects by distance to the viewer.
    // 3. Draw all the transparent object in sorted order.

    glLineWidth(1);
    glPointSize(5);


    // ImGui Setup
    imgui_context = ImGui.CreateContext();
    ImGui_ImplSdl_Init(window);

    ImGui.StyleColorsClassic();
    //ImGui.StyleColorsLight();


	// Set the working directory to the base of the project so we can access our folders nicely.
	executable_path := path_strip_filename(get_path_of_running_executable());
	set_working_directory (tprint("%/../", executable_path));

    // Do more... personal things
    set_my_print_format();

    return true;
}

//
//

// @TODO: Ensure that this only affects serialization code.
// To do this, we will most likely have to learn about contexts for real.
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
