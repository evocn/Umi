// Tactics
// Spine
// Alex Hartford
// July 2023

resolve_game_over :: (map: *Map, units: [..] *Unit) {
    if input.button_1 {
        init_level(map, units, levels[current_level_index]);
        program_mode = .GAME;
        input.button_1 = false;
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

    set_turn(.BLUE);
}
