// Tactics
// Build
// Alex Hartford
// May 2023

build :: () {
    w := compiler_create_workspace("Tactics Workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    options := get_build_options(w);
    options.output_executable_name = "tactics";

    // Add ext/ to the import path.
    import_path: [..] string;
    array_add(*import_path, ..options.import_path);
    array_add(*import_path, "../ext");
    options.import_path = import_path;

    // NOTE(alex): this refers to a relative path from this (build.jai) file.
    options.output_path = "../bin";
    options.output_type = .EXECUTABLE;
    options.text_output_flags = 2;

    set_build_options(options, w);
    set_build_options_dc(.{do_output=false});

	compiler_begin_intercept(w);

    add_build_file(tprint("%/main.jai", #filepath), w);
    add_build_file(tprint("%/utils.jai", #filepath), w);

    add_build_file(tprint("%/init.jai", #filepath), w);
    add_build_file(tprint("%/imgui_init.jai", #filepath), w);
    add_build_file(tprint("%/input.jai", #filepath), w);

    add_build_file(tprint("%/editor.jai", #filepath), w);
    add_build_file(tprint("%/serialization.jai", #filepath), w);

    add_build_file(tprint("%/spine.jai", #filepath), w);

    add_build_file(tprint("%/manager.jai", #filepath), w);
    add_build_file(tprint("%/cursor.jai", #filepath), w);
    add_build_file(tprint("%/command.jai", #filepath), w);
    add_build_file(tprint("%/ai.jai", #filepath), w);

    add_build_file(tprint("%/unit.jai", #filepath), w);
    add_build_file(tprint("%/ability.jai", #filepath), w);
    add_build_file(tprint("%/map.jai", #filepath), w);
    add_build_file(tprint("%/path.jai", #filepath), w);
    add_build_file(tprint("%/combat.jai", #filepath), w);

    add_build_file(tprint("%/menu.jai", #filepath), w);

    add_build_file(tprint("%/render.jai", #filepath), w);
    add_build_file(tprint("%/font.jai", #filepath), w);
    add_build_file(tprint("%/primitives.jai", #filepath), w);
    add_build_file(tprint("%/parse_utils.jai", #filepath), w);

    add_build_file(tprint("%/shader.jai", #filepath), w);
    add_build_file(tprint("%/texture.jai", #filepath), w);
    add_build_file(tprint("%/spritesheet.jai", #filepath), w);

	// Set up ctags options
	ctags: CTags;
	ctags.base_path = get_working_directory();
	defer reset(*ctags);

	while true {
		message := compiler_wait_for_message();
		if !message continue;

		if message.workspace == w {
			process_message(*ctags, message);
		}

		if message.kind == .COMPLETE break;
	}
}

#run build();


#import "Basic";
#import "Compiler";
#import "ctags";
