// Umi
// Init
// Alex Hartford
// June 2023

init :: () -> bool {
	// Set the working directory to the base of the project so we can access our folders nicely.
	executable_path := path_strip_filename(System.get_path_of_running_executable());
	set_working_directory (tprint("%/../", executable_path));

    // SDL
    {
        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK);

        window = SDL_CreateWindow("Umi",
            SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_width, window_height,
            SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

        if !window {
            print("Could not create window: %\n", to_string(SDL_GetError()));
            return false;
        }
        SDL_SetWindowResizable(window, xx false);

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
        basic_shader = make_shader("screen.vs", "basic.fs");
        shader       = make_shader("screen.vs", "texture.fs");
        text_shader  = make_shader("text.vs", "text.fs");
        quad_shader  = make_shader("quad.vs", "quad.fs");
        sprite_shader= make_shader("sprite.vs", "texture.fs");

        // Primitives
        init_quad_rendering_objects(*quad);

        // Sprites
        success : bool;

        full_path := tprint("%/big.png", sprites_path);
        success = make_spritesheet(*spritesheet, full_path);
        assert(success);

        full_path = tprint("%/ships.png", sprites_path);
        success = make_spritesheet(*ship_spritesheet, full_path, tile_size = TILE_SIZE * 2);
        assert(success);

        {
            register_sprite :: (name: string) {
                new_sprite : Sprite;
                full_path := tprint("%/%.png", sprites_path, name);
                success := make_sprite(*new_sprite, full_path);
                if !success {
                    log_error("Unable to load %.\n", full_path);
                    assert(false);
                }
                table_add(*rendering.sprites, name, new_sprite);
            }

            register_sprite("aki");
            register_sprite("ojii");
            register_sprite("young takeda");

            register_sprite("takeda");
            register_sprite("motonari");
            register_sprite("arukahime");

            register_sprite("haruhachi");
            register_sprite("haruhachi_laugh");
            register_sprite("haruhachi_haughty");
            register_sprite("haruhachi_serious");

            register_sprite("limahong");
            register_sprite("yoshitaka");

            register_sprite("ui");
        }

        {
            register_mural :: (name: string) {
                new_mural : Sprite;
                full_path := tprint("%/%.png", murals_path, name);
                success := make_sprite(*new_mural, full_path);
                if !success {
                    log_error("Unable to load %.\n", full_path);
                    assert(false);
                }
                assert(success);
                table_add(*rendering.murals, name, new_mural);
            }

            register_mural("title");
            register_mural("wave");
            register_mural("black");

            register_mural("noshima");
            register_mural("study");
            register_mural("room");

            register_mural("ocean_day");
            register_mural("ocean_night");
            register_mural("ocean_evening");
        }

        {
            register_slice :: (name: string) {
                new_slice : Sprite;
                full_path := tprint("%/%.png", slices_path, name);
                success := make_sprite(*new_slice, full_path);
                if !success {
                    log_error("Unable to load %.\n", full_path);
                    assert(false);
                }
                table_add(*rendering.slices, name, new_slice);
            }

            register_slice("archers");
            register_slice("wave");
        }

        init_framebuffer();
    }

    init_fonts();

    init_audio();

    init_menus();

    init_levels();

    // Init Gamepad
    if SDL_NumJoysticks() > 0 {
        print("Houston, we have a gamepad!\n");
        gamepad = SDL_JoystickOpen(0);
        assert(gamepad != null);
    }

    //toggle_fullscreen();
    sound_player.mix_all = 1.0;

    return true;
}

init_fonts :: () {
    initialize_freetype();

    deinit(*main_font.characters);
    //initialize_font(*main_font, "mkd.ttf", 16);
    initialize_font(*main_font, "venice/VeniceClassic.ttf", 19);
}
        
init_audio :: () {
    sound_player = New(Sound_Player);
    sound_player.update_history = true;

    // Load sound effects
    load_sound :: (basename: string) -> *Mixer_Sound_Data {
        name := tprint("%/%.wav", sfx_path, basename);
        data := load_audio_file(name);

        if !data {
            print("Error: Could not load wav file: %\n", name);
            assert(false);
            return null;
        }

        return data;
    }

    load_sfx :: (basename: string) {
        table_add(*sfx, basename, load_sound(basename));
    }

    load_sfx("arrow");
    load_sfx("attack");
    load_sfx("bat");
    load_sfx("buff");
    load_sfx("choose");
    load_sfx("click");
    load_sfx("dead");
    load_sfx("explosion");
    load_sfx("monster");
    load_sfx("move");
    load_sfx("place");
    load_sfx("potion");
    load_sfx("sea");
    load_sfx("selection");
    load_sfx("warp");

    load_sfx("wb1");
    load_sfx("wb2");
    load_sfx("wb3");

    load_sfx("haruhachi");
    load_sfx("haruhachi_haughty");
    load_sfx("haruhachi_laugh");
    load_sfx("haruhachi_serious");

    wmInfo : SDL_SysWMinfo;
    SDL_VERSION(*wmInfo.version);
    SDL_GetWindowWMInfo(window, *wmInfo);
    hwnd := wmInfo.info.win.window;

    success := init(sound_player, xx hwnd, true, true);
    assert(success);

    sound_player.mix_props = 1.0;
    sound_player.mix_ambiences = 1.0;
    sound_player.mix_music = 1.0;

    go_to_start_screen();
}

init_menus :: () {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *pool;

    {
        using menu;
        elements.allocator = a;
        name = "pause";

        resume := New(Go_Element, allocator=a);
        resume.name = "resume";
        resume.callback = resume_game;
        resume.sprite_index = 22;
        array_add(*elements, cast(*Menu_Element)resume);

        fullscreen := New(Checkbox_Element, allocator=a);
        fullscreen.name = "fullscreen";
        fullscreen.callback = toggle_fullscreen;
        fullscreen.value = *settings.fullscreen;
        fullscreen.sprite_index = 831;
        fullscreen.sprite_index_two = 830;
        array_add(*elements, cast(*Menu_Element)fullscreen);

        music := New(Slider_Element, allocator=a);
        music.name = "Music";
        music.value = *sound_player.mix_music;
        music.sprite_index = 957;
        music.sprite_index_two = 956;
        array_add(*elements, cast(*Menu_Element)music);

        ambience := New(Slider_Element, allocator=a);
        ambience.name = "Ambience";
        ambience.value = *sound_player.mix_ambiences;
        ambience.sprite_index = 963;
        ambience.sprite_index_two = 962;
        array_add(*elements, cast(*Menu_Element)ambience);

        sfx := New(Slider_Element, allocator=a);
        sfx.name = "sfx";
        sfx.value = *sound_player.mix_props;
        sfx.sprite_index = 961;
        sfx.sprite_index_two = 960;
        array_add(*elements, cast(*Menu_Element)sfx);

        home := New(Go_Element, allocator=a);
        home.name = "home";
        home.callback = go_to_start_screen;
        home.sprite_index = 825;
        array_add(*elements, cast(*Menu_Element)home);
    }

    {
        using start_menu;
        elements.allocator = a;
        name = "start";

        resume := New(Go_Element, allocator=a);
        resume.name = "start";
        resume.callback = start_game;
        resume.sprite_index = 22;
        array_add(*elements, cast(*Menu_Element)resume);

        credits := New(Go_Element, allocator=a);
        credits.name = "credits";
        credits.callback = show_credits;
        credits.sprite_index = 768;
        array_add(*elements, cast(*Menu_Element)credits);

        settings := New(Go_Element, allocator=a);
        settings.name = "settings";
        settings.callback = go_to_settings;
        settings.sprite_index = 829;
        array_add(*elements, cast(*Menu_Element)settings);

        quit := New(Go_Element, allocator=a);
        quit.name = "quit";
        quit.callback = quit_game;
        quit.sprite_index = 120;
        array_add(*elements, cast(*Menu_Element)quit);
    }
}

//
//

levels : [..] string;
init_levels :: () {
    array_reset(*levels);

    levels_paths := File_Utilities.file_list(levels_path, recursive = true, follow_symlinks = false);

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *pool;

    for levels_paths {
        short_name := copy_string(path_strip_extension(path_filename(it)), allocator=a);
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
