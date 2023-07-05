// Everett
// Serialization
// Alex Hartford
// June 2023

entities_path :: "data/entities";

//
// Grids
//

GRID_VERSION :: 1;
grids_path :: "data/levels";

save_grid :: (using map : Map, filename : string) {
    print("Saving %\n", filename);
    builder: String_Builder;
    defer free_buffers(*builder);

    init_string_builder(*builder);
    print_to_builder(*builder, "[%] # Version Number\n\n", GRID_VERSION);
    print_to_builder(*builder, "% # Width\n", grid_width);
    print_to_builder(*builder, "% # Height\n\n", grid_height);

    print_grid_to_builder(*builder, grid);

    write_entire_file(tprint("%/%", grids_path, filename), builder_to_string(*builder));
}

load_grid :: (using map : *Map, filename : string) {
    print("Loading %\n", filename);
    success := parse_grid(map, tprint("%/%", grids_path, filename));
    assert(success, "Unable to load file %\n", filename);
}

print_grid_to_builder :: (builder : *String_Builder, grid : [grid_width][grid_height] Tile) {
    for col : 0..grid_width-1 {
        for row : 0..grid_height-1 {
            print_to_builder(builder, "%", cast(int)grid[col][row].tile_kind);
        }
        print_to_builder(builder, "\n");
    }
}

parse_grid :: (using map : *Map, full_path : string) -> bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    found_slash, dir, basename := split_from_right(full_path, #char "/");
    if !found_slash then basename = full_path;
    start_file(*handler, basename, full_path, optional = false);
    if handler.failed return false;

    if handler.version != GRID_VERSION
        return error_out(handler, "Invalid version number.");

    found : bool;
    line : string;
    line, found = consume_next_line(*handler);
    file_says_grid_width := string_to_int(line);
    line, found = consume_next_line(*handler);
    file_says_grid_height := string_to_int(line);

    assert(file_says_grid_width == grid_width);
    assert(file_says_grid_height == grid_height);

    for row : 0..grid_height-1 {
        line, found = consume_next_line(*handler);
        for character, col : cast([] u8)line {
            grid[col][row].tile_kind = cast(Tile_Kind)(character - 48);
        }
    }

    return true;
}
