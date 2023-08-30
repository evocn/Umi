// Umi
// Spine
// Alex Hartford
// July 2023

Chapter :: struct {
    name : string;

    intro : string;
    level : string;
    outro : string;

    intro_song : string;
    level_song : string;
    outro_song : string;

    intro_ambience : string;
    level_ambience : string;
    outro_ambience : string;
}

spine : struct {
    chapters: [..] Chapter;

    ready_for_next_section : bool;

    current_chapter : int = -1;
    current_section : int = -1;
}

reset_game :: () {
    spine.current_chapter = -1;
    spine.current_section = -1;
    go_to_start_screen();
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
        current_section = -1;
    }
    if current_chapter >= chapters.count {
        reset_game();
        return;
    }

    log("Going to chapter %, section %.\n", current_chapter, current_section);

    if current_section == {
        case -1; 
            stop_music();
            switch_mode(.CHAPTER);

        case 0; 
            load_dialogue_file(dialogue, tprint("%.dialogue", chapters[current_chapter].intro));
            stop_music();
            play_music(chapters[current_chapter].intro_song);
            play_ambience(chapters[current_chapter].intro_ambience);
            switch_mode(.CUTSCENE);

        case 1;
            init_and_load_level(map, units, chapters[current_chapter].level);
            stop_music();
            play_music(chapters[current_chapter].level_song);
            play_ambience(chapters[current_chapter].level_ambience);
            switch_mode(.GAME);

            // @TODO: Function this ish
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
            stop_music();
            play_music(chapters[current_chapter].outro_song);
            play_ambience(chapters[current_chapter].outro_ambience);
            switch_mode(.CUTSCENE);
    }
}

spine_next_chapter :: (map: *Map, units: [..] *Unit, dialogue: *Dialogue) {
    using spine;

    current_chapter += 1;
    current_section = -1;
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

        // Name
        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.name = copy_string(line, allocator=a);

        // Intro
        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.intro = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.intro_song = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.intro_ambience = copy_string(line, allocator=a);

        // Level
        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.level = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.level_song = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.level_ambience = copy_string(line, allocator=a);

        // Outro
        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.outro = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.outro_song = copy_string(line, allocator=a);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        new_chapter.outro_ambience = copy_string(line, allocator=a);

        // Add the new section.
        array_add(*spine.chapters, new_chapter);

        line, found = consume_next_line(*handler);
        if !found return error_out(handler, "Weird input found here.\n");
        if handler.file_data && line != "---" return error_out(handler, "No section left?\n");
    }

    return true;
}

//
// Miscellaneous stuff. @TODO: Move these out?
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
        init_and_load_level(map, units, copy_string(map.name));
        switch_mode(.GAME);
        play_woodblock_sound();
    }

    if pressed(*button_menu) {
        go_to_start_screen();
    }
}

init_and_load_level :: (map: *Map, units: [..] *Unit, level_name : string) {
    for map.units remove_occupant(map, it.square);

    reset(*level_pool, overwrite_memory=true);

    success := load_level(map, units, tprint("%.level", level_name));
    assert(success);

    for map.units occupy(map, it.square, it);

    manager.turn_number = 0;
    set_turn(.YOU);
}

resolve_chapter_screen :: () {
    if !fade.active {
        fade_start(.OUT, next_section_fade_in, length=4.0);
    }
}
