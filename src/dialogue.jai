// Umi
// Dialogue
// Alex Hartford
// July 2023

Dialogue_Effect :: struct {
    kind : enum {
        NONE;
        ENTER;
        EXIT;

        NEUTRAL;
        HAPPY;
        SAD;
        ANGRY;
    }

    name: string;
}

Dialogue_Line :: struct {
    name: string;
    text: string;
    mural_name : string;
    effect : Dialogue_Effect;
}

Dialogue :: struct {
    lines: [..] Dialogue_Line;
    line_index: int;

    mural_name_index : int = -1;

    // Input delays
    // @POLISH: Allow the user to this in a settings menu?
    time_per_character :: 0.03;

    line_time := 0.0;
    characters_at_progress := 0;

    // Speakers rendering stuff
    speakers : [2] string;

    left_sprite_offset : int;
    left_animator  : Animator;
    left_animator2 : Animator;

    right_sprite_offset : int;
    right_animator  : Animator;
    right_animator2 : Animator;

    weather : Weather = .DAY;
}

next_line :: (using dialogue: *Dialogue) {
    line_index += 1;
    if !is_finished(dialogue) {
        characters_at_progress = 0;
        line_time = 0.0;
    }
}

is_finished :: (using dialogue: *Dialogue) -> bool {
    return line_index >= lines.count;
}

next_line_has_speaker :: (using dialogue: Dialogue) -> bool {
    if line_index >= lines.count - 1 then return false;
    if lines[line_index + 1].name then return true;
    else return false;
}

next_line_has_mural_name :: (using dialogue: Dialogue) -> bool {
    if line_index >= lines.count - 1 then return false;
    if lines[line_index + 1].mural_name then return true;
    else return false;
}

next_line_has_effect :: (using dialogue: Dialogue) -> bool {
    if line_index >= lines.count - 1 then return false;
    if lines[line_index + 1].effect.kind != .NONE then return true;
    else return false;
}

update_dialogue_animators :: (using dialogue: *Dialogue, dt: float) {
    if lines.count {
        line_time += dt;
        if characters_at_progress < lines[line_index].text.count
            characters_at_progress = cast(int)(line_time / time_per_character);
    }

    update(*left_animator, dt);
    update(*left_animator2, dt);

    update(*right_animator, dt);
    update(*right_animator2, dt);
}

resolve_dialogue_inputs :: (dialogue: *Dialogue) {
    using input;

    if pressed(*button_menu) {
        switch_mode(.MENU);
        menu.element_index = 0;
        play_sfx("selection");
    }

    if pressed(*button_1) {
        if dialogue.characters_at_progress == dialogue.lines[dialogue.line_index].text.count
        {
            if next_line_has_speaker(dialogue.*) {
                new_speaker_name := dialogue.lines[dialogue.line_index + 1].name;
                new_speaker_is_not_already_in_conversation := dialogue.speakers[0] != new_speaker_name && dialogue.speakers[1] != new_speaker_name;

                if new_speaker_is_not_already_in_conversation {
                    no_speakers := !dialogue.speakers[0] && !dialogue.speakers[1];
                    left_empty := !dialogue.speakers[0];
                    right_empty := !dialogue.speakers[1];
                    both_full := !(!dialogue.speakers[0] || !dialogue.speakers[1]);

                    if no_speakers || left_empty {
                        dialogue.speakers[0] = new_speaker_name;
                        restart(*dialogue.left_animator);
                    }
                    else if right_empty || both_full {
                        dialogue.speakers[1] = new_speaker_name;
                        restart(*dialogue.right_animator);
                    }
                }
            }

            if next_line_has_effect(dialogue.*) {
                effect := dialogue.lines[dialogue.line_index + 1].effect;
                if #complete effect.kind == {
                    case .NONE;
                        log_error("Shouldn't get here!\n");

                    case .ENTER;
                        if effect.name == dialogue.speakers[0] {
                            restart(*dialogue.left_animator);
                        }
                        else if effect.name == dialogue.speakers[1] {
                            restart(*dialogue.right_animator);
                        }
                        else {
                            log_error("Unknown party is entering the scene.\n");
                        }

                    case .EXIT;
                        if effect.name == dialogue.speakers[0] {
                            restart(*dialogue.left_animator2);
                        }
                        else if effect.name == dialogue.speakers[1] {
                            restart(*dialogue.right_animator2);
                        }
                        else {
                            log_error("Unknown party is exiting the scene.\n");
                        }

                    // @TODO
                    case .NEUTRAL;
                    case .HAPPY;
                    case .SAD;
                    case .ANGRY;
                }
            }

            if next_line_has_mural_name(dialogue.*) {
                dialogue.mural_name_index = dialogue.line_index + 1;
            }

            next_line(dialogue);

            // @NOTE: Developer hack to get through dialogue quickly.
            if !is_finished(dialogue) && button_2.held {
                dialogue.characters_at_progress = dialogue.lines[dialogue.line_index].text.count;
            }
        }
        else {
            dialogue.characters_at_progress = dialogue.lines[dialogue.line_index].text.count;
        }
    }

    if pressed(*button_select) {
        finish_dialogue();
    }

    if is_finished(dialogue) {
        dialogue.line_index -= 1;
        finish_dialogue();
    }
}

reset_dialogue :: (using dialogue: *Dialogue) {
    line_index = 0;
    mural_name_index = -1;
    speakers[0] = "";
    speakers[1] = "";
    characters_at_progress = 0;
    line_time = 0.0;
}

finish_dialogue :: () {
    if program_mode == .CUTSCENE {
        fade_start(.OUT, next_section_fade_in);
    }

    else if program_mode == .DIALOGUE {
        return_to_prior_mode();
    }
}

//
//

initialize :: (using dialogue: *Dialogue) {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *pool;

    left_animator.end = 1.0;
    left_animator.animating = *left_sprite_offset;
    left_animator.interpolation_function = smooth_stop;
    left_animator.key_frames.allocator=a;

    array_add(*left_animator.key_frames, Key_Frame.{0.0, 200});
    array_add(*left_animator.key_frames, Key_Frame.{0.5, 0});

    left_animator2.end = 1.0;
    left_animator2.animating = *left_sprite_offset;
    left_animator2.interpolation_function = smooth_start;
    left_animator2.key_frames.allocator=a;

    array_add(*left_animator2.key_frames, Key_Frame.{0.0, 0});
    array_add(*left_animator2.key_frames, Key_Frame.{0.5, 200});

    right_animator.end = 1.0;
    right_animator.animating = *right_sprite_offset;
    right_animator.interpolation_function = smooth_stop;
    right_animator.key_frames.allocator=a;

    array_add(*right_animator.key_frames, Key_Frame.{0.0, 200});
    array_add(*right_animator.key_frames, Key_Frame.{0.5, 0});

    right_animator2.end = 1.0;
    right_animator2.animating = *right_sprite_offset;
    right_animator2.interpolation_function = smooth_start;
    right_animator2.key_frames.allocator=a;

    array_add(*right_animator2.key_frames, Key_Frame.{0.0, 0});
    array_add(*right_animator2.key_frames, Key_Frame.{0.5, 200});
}

load_dialogue_file :: (dialogue: *Dialogue, filename: string) -> success: bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    start_file(*handler, filename, tprint("%/%", dialogues_path, filename), optional = false);
    if handler.failed return false;

    if handler.version != VERSION
        return error_out(handler, "Invalid version number.");

    array_reset(*dialogue.lines);
    reset_dialogue(dialogue);

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *level_pool;

    while handler.file_data {
        line, success := parse_string(*handler);

        if contains(line, #char "*") {
            replace_chars(line, "*", #char " ");
            trimmed := trim(line);
            dialogue.weather = parse_weather(trimmed);
            continue;
        }

        if contains(line, #char "@") {
            assert(dialogue.lines.count > 0, "Can't have an @ before any lines!");
            replace_chars(line, "@", #char " ");
            trimmed := trim(line);
            dialogue.lines[dialogue.lines.count - 1].mural_name = copy_string(trimmed, a);
            continue;
        }

        if contains(line, #char "<") {
            assert(dialogue.lines.count > 0, "Can't have an > before any lines!");
            replace_chars(line, "<", #char " ");
            trimmed := trim(line);
            dialogue.lines[dialogue.lines.count - 1].effect.kind = .EXIT;
            dialogue.lines[dialogue.lines.count - 1].effect.name = copy_string(trimmed, a);
            continue;
        }

        if contains(line, #char ">") {
            assert(dialogue.lines.count > 0, "Can't have an < before any lines!");
            replace_chars(line, ">", #char " ");
            trimmed := trim(line);
            dialogue.lines[dialogue.lines.count - 1].effect.kind = .ENTER;
            dialogue.lines[dialogue.lines.count - 1].effect.name = copy_string(trimmed, a);
            continue;
        }
        // @NOTE: Put special case lines here. (Extra expressions, sound effects, etc.)

        found_separator, left, right := split_from_left(line, #char "|");
        if found_separator {
            array_add(*dialogue.lines, .{name=copy_string(trim_right(left), allocator=a), text=copy_string(trim_left(right), allocator=a)});
        }
        else {
            array_add(*dialogue.lines, .{text=copy_string(line, allocator=a)});
        }

        if !success {
            return error_out(handler, "Problem reading dialogue file.\n");
        }
    }

    if dialogue.lines[0].name {
        dialogue.speakers[0] = dialogue.lines[0].name;
        restart(*dialogue.left_animator);
    }

    if dialogue.lines[0].mural_name {
        dialogue.mural_name_index = 0;
    }

    return true;
}
