// Tactics
// Serialization
// Alex Hartford
// June 2023

save_units :: (units : [..] *Unit, filename : string) -> success : bool {
    builder : String_Builder;
    defer free_buffers(*builder);

    print_to_builder(*builder, "[%] # Version\n\n", 1);

    for units {
        print_to_builder(*builder, "\n");
        success := serialize_structure(it.*, *builder);
        if !success return false;
    }

    write_entire_file(tprint("%/%", units_path, filename), *builder);
    log("Saved units to \"%\".\n", filename);

    return true;
}

load_units :: (units : *[..] *Unit, filename : string) -> success : bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    start_file(*handler, filename, tprint("%/%", units_path, filename), optional = false);
    if handler.failed return false;

    if handler.version != VERSION
        return error_out(handler, "Invalid version number.");

    array_reset(units);
    
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *pool;

    while handler.file_data {
        new_unit := New(Unit, allocator=a);
        success := unserialize_structure(new_unit, *handler);
        if !success log_error("File Handler problem with %.\n", filename);
        array_add(units, new_unit);
    }

    log("Loaded units from \"%\".\n", filename);

    return true;
}

#scope_file

// %1          = member name
// type_of(%1) = member type
for_each_member :: ($T: Type, format: string) -> string
{
    builder: String_Builder;
    defer free_buffers(*builder);

    struct_info := cast(*Type_Info_Struct) T;
    assert(struct_info.type == Type_Info_Tag.STRUCT);

    for member : struct_info.members 
    {
        if member.flags & .CONSTANT continue;

        for note: member.notes {
            if note == "NoSerialize" then continue member;
        }

        print_to_builder(*builder, format, member.name);
    }

    return builder_to_string(*builder);
}

serialize_structure :: (s: $T, builder: *String_Builder) -> success: bool
{
    #insert #run for_each_member(T, "if !serialize(s.%1, \"%1\", builder) return false;\n" );
    return true;
}

// Definitions for how we want to serialize things.
// Think of these not as code, but as a bunch of settings.
//

serialize  :: (to_serialize: int, name : string, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true; 
}
serialize  :: (to_serialize: u64, name : string, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true; 
}
serialize  :: (to_serialize: float, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: bool, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: string, name : string, builder: *String_Builder) -> success: bool { 
    if !to_serialize
        print_to_builder(builder, "!");
    else
        print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

//
//

serialize  :: (to_serialize: Square, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "% %", to_serialize.col, to_serialize.row);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

serialize  :: (to_serialize: Direction, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Team, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Unit_Flags, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

//
//
//

unserialize_structure :: (s: *$T, handler: *Text_File_Handler) -> success: bool
{
    success : bool;
    #insert #run for_each_member(T, "if !unserialize(*s.%1, handler) return false;\n" );
    return true;
}

// Definitions for how we want to unserialize things.
// Think of these not as code, but as a bunch of settings.
//

unserialize  :: (to_unserialize: *int, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_int(handler);
    return success;
}
unserialize  :: (to_unserialize: *u64, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_int(handler, u64);
    return success;
}
unserialize  :: (to_unserialize: *float, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_float(handler);
    return success;
}
unserialize  :: (to_unserialize: *bool, handler : *Text_File_Handler) -> success: bool { 
    b, success := parse_int(handler);
    <<to_unserialize = cast(bool)b;
    return success;
}
unserialize  :: (to_unserialize: *string, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_string(handler);
    if <<to_unserialize == "!" then <<to_unserialize = "";
    return success;
}
unserialize  :: (to_unserialize: *Square, handler: *Text_File_Handler) -> success: bool {
    success : bool;
    <<to_unserialize, success = parse_square(handler);
    return success;
}
unserialize  :: (to_unserialize: *Direction, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Direction)i;
    return success;
}
unserialize  :: (to_unserialize: *Team, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Team)i;
    return success;
}
unserialize  :: (to_unserialize: *Unit_Flags, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Unit_Flags)i;
    return success;
}


//
// Grid Loading/Saving
//

#scope_module
save_grid :: (using map : Map, filename : string) {
    print("Saving %\n", filename);
    builder: String_Builder;
    defer free_buffers(*builder);

    init_string_builder(*builder);
    print_to_builder(*builder, "[%] # Version Number\n\n", VERSION);
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

#scope_file
parse_grid :: (using map : *Map, full_path : string) -> bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    found_slash, dir, basename := split_from_right(full_path, #char "/");
    if !found_slash then basename = full_path;
    start_file(*handler, basename, full_path, optional = false);
    if handler.failed return false;

    if handler.version != VERSION
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
