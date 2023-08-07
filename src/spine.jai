// Umi
// Spine
// Alex Hartford
// July 2023

Chapter :: struct {
    intro : string;
    level : string;
    outro : string;

    intro_song : string;
    level_song : string;
    outro_song : string;
}

spine : struct {
    chapters: [..] Chapter;

    ready_for_next_section : bool;

    current_chapter : int = -1;
    current_section : int = -1;
}

spine_reset :: () {
    spine.current_chapter = -1;
    spine.current_section = -1;
}

next_section :: () {
    spine.ready_for_next_section = true;
}

next_section_fade_in :: () {
    spine.ready_for_next_section = true;

    do_nothing :: () {}
    fade_start(.IN, do_nothing, easing = smooth_start);
}

spine_go_to_next_section :: (map: *Map, units: [..] *Unit, dialogue: *Dialogue) {
    using spine;

    current_section += 1;
    if current_section >= 3 {
        spine_next_chapter(map, units, dialogue);
    }

    if current_chapter == -1 {
        spine_next_chapter(map, units, dialogue);
        current_section = 0;
    }
    if current_chapter >= chapters.count {
        spine_reset();
        stop_stream_abruptly(sound_player, music);
        play_music("mohican");
        switch_mode(.START);
        return;
    }

    print("Going to chapter %, section %\n", current_chapter, current_section);

    if current_section == {
        case 0; 
            load_dialogue_file(dialogue, tprint("%.dialogue", chapters[current_chapter].intro));
            stop_stream_abruptly(sound_player, music);
            play_music(chapters[current_chapter].intro_song);
            switch_mode(.CUTSCENE);

        case 1;
            init_level(map, units, chapters[current_chapter].level);
            stop_stream_abruptly(sound_player, music);
            play_music(chapters[current_chapter].level_song);
            switch_mode(.GAME);

            // @TODO: Function this
            {
                for map.events {
                    if it.turn == 0 {
                        activate_event(it, map, dialogue);
                    }
                }
            }

            put_cursor_over_commander(map.*);

        case 2;
            load_dialogue_file(dialogue, tprint("%.dialogue", chapters[current_chapter].outro));
            stop_stream_abruptly(sound_player, music);
            play_music(chapters[current_chapter].outro_song);
            switch_mode(.CUTSCENE);
    }
}

spine_next_chapter :: (map: *Map, units: [..] *Unit, dialogue: *Dialogue) {
    using spine;

    current_chapter += 1;
    current_section = 0;
}

spine_load :: (filename: string) -> success: bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    start_file(*handler, filename, tprint("%/%", data_path, filename), optional = false);
    if handler.failed return false;

    if handler.version != VERSION
        return error_out(handler, "Invalid version number.");

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *pool;
    spine.chapters.allocator = a;

    array_reset(*spine.chapters);

    while handler.file_data {
        new_chapter : Chapter;

        line : string;
        found : bool;

        // Intro
        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.intro = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.intro_song = copy_string(line, allocator=a);

        // Level
        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.level = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.level_song = copy_string(line, allocator=a);

        // Outro
        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.outro = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.outro_song = copy_string(line, allocator=a);

        // Add the new section.
        array_add(*spine.chapters, new_chapter);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        if handler.file_data && line != "---" return error_out(handler, "No section left?\n");
    }

    return true;
}

//
//

resolve_start_menu_specialties :: () {
    using input;

    if pressed(*button_menu) {
        running = false;
    }
}

resolve_game_over :: (map: *Map, units: [..] *Unit) {
    using input;

    if pressed(*button_1) {
        init_level(map, units, levels[current_level_index]);
        switch_mode(.GAME);
        play_sfx("choose");
    }

    if pressed(*button_menu) {
        running = false;
    }
}

init_level :: (map: *Map, units: [..] *Unit, level_name : string) {
    for map.units remove_occupant(map, it.square);

    reset(*level_pool, overwrite_memory=true);

    new_context := context;
    new_context.logger      = save_load_logger;
    push_context new_context {
        success := load_level(map, units, tprint("%.level", level_name));
        assert(success);
    }

    for map.units occupy(map, it.square, it);

    manager.turn_number = 0;
    set_turn(.YOU);
}
