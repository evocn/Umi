// Tactics
// Dialogue
// Alex Hartford
// July 2023

Dialogue_Line :: struct {
    name: string;
    text: string;
    mural_name : string;
}

Dialogue :: struct {
    lines: [..] Dialogue_Line;
    line_index: int;

    mural_name_index : int = -1;

    // Speakers rendering stuff
    speakers : [2] string;

    left_sprite_offset : int;
    left_animator  : Animator;
    left_animator2 : Animator;

    right_sprite_offset : int;
    right_animator  : Animator;
    right_animator2 : Animator;
}

next_line :: (using dialogue: *Dialogue) {
    line_index += 1;
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

update_and_resolve_dialogue_inputs :: (dialogue: *Dialogue, dt: float) {
    update(*dialogue.left_animator, dt);
    update(*dialogue.left_animator2, dt);

    update(*dialogue.right_animator, dt);
    update(*dialogue.right_animator2, dt);

    using input;

    if pressed(*button_menu) {
        switch_mode(.MENU);
        menu.element_index = 0;
        play_sfx("selection");
    }

    if pressed(*button_1) {
        if next_line_has_speaker(dialogue.*) {
            new_speaker_name := dialogue.lines[dialogue.line_index + 1].name;
            new_speaker_is_not_already_in_conversation := dialogue.speakers[0] != new_speaker_name && dialogue.speakers[1] != new_speaker_name;

            if new_speaker_is_not_already_in_conversation {
                no_speakers := !dialogue.speakers[0] && !dialogue.speakers[1];
                left_empty := !dialogue.speakers[0];
                right_empty := !dialogue.speakers[1];
                both_full := !(!dialogue.speakers[0] || !dialogue.speakers[1]);

                if no_speakers || left_empty || both_full {
                    dialogue.speakers[0] = new_speaker_name;
                    restart(*dialogue.left_animator);
                }
                else if right_empty {
                    dialogue.speakers[1] = new_speaker_name;
                    restart(*dialogue.right_animator);
                }
            }
        }

        if next_line_has_mural_name(dialogue.*) {
            dialogue.mural_name_index = dialogue.line_index + 1;
        }

        next_line(dialogue);
    }

    if pressed(*button_select) {
        finish_dialogue();
        reset_dialogue(dialogue);
    }

    if is_finished(dialogue) {
        finish_dialogue();
        reset_dialogue(dialogue);
    }
}

reset_dialogue :: (using dialogue: *Dialogue) {
    line_index = 0;
    mural_name_index = -1;
    speakers[0] = "";
    speakers[1] = "";
}

finish_dialogue :: () {
    if program_mode == .CUTSCENE {
        spine.ready_for_next_section = true;
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

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *level_pool;

    while handler.file_data {
        line, success := parse_string(*handler);

        if contains(line, #char "@") {
            assert(dialogue.lines.count > 0, "Can't have an @ before any lines!");
            replace_chars(line, "@", #char " ");
            trimmed := trim(line);
            dialogue.lines[dialogue.lines.count - 1].mural_name = copy_string(trimmed, a);
            continue;
        }
        // @NOTE: Put special case lines here. (Extra expressions, sound effects, etc.)

        found_separator, left, right := split_from_left(line, #char "|");
        if found_separator {
            array_add(*dialogue.lines, .{copy_string(trim_right(left), allocator=a), copy_string(trim_left(right), allocator=a), ""});
        }
        else {
            array_add(*dialogue.lines, .{"", copy_string(line, allocator=a), ""});
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
