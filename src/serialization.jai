// Tactics
// Serialization
// Alex Hartford
// June 2023

VERSION :: 1;

sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/audio/music";
sfx_path        :: "assets/audio/sfx";

levels_path     :: "data/levels";
units_path      :: "data";
abilities_path  :: "data";

//
//

save_units :: (units : [..] *Unit, filename : string) -> success : bool {
    builder : String_Builder;
    defer free_buffers(*builder);

    print_to_builder(*builder, "[%] # Version\n", VERSION);

    for units {
        print_to_builder(*builder, "\n");
        success := serialize_structure(it.*, *builder);
        if !success return false;
    }

    File.write_entire_file(tprint("%/%", units_path, filename), *builder);
    log("Saved units to \"%\".\n", filename, flags=.VERBOSE_ONLY);

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
    reset(*units_pool, overwrite_memory=true);
    
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *units_pool;

    while handler.file_data {
        new_unit := New(Unit, allocator=a);
        success := unserialize_structure(new_unit, *handler);
        if !success error(handler, "File Handler problem with %.\n", filename);
        array_add(units, new_unit);
    }

    log("Loaded units from \"%\".\n", filename, flags=.VERBOSE_ONLY);

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
serialize  :: (to_serialize: Ability, name : string, builder: *String_Builder) -> success: bool {
    if name print_to_builder(builder, "# %\n", name);
    success := serialize_structure(to_serialize, builder);
    return success;
}
serialize  :: (to_serialize: Ability_Kind, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Ability_Orientation, name : string, builder: *String_Builder) -> success: bool {
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
    str :, success = parse_string(handler);
    if str == "!" then to_unserialize.* = "";
    else {
        a: Allocator;
        a.proc = flat_pool_allocator_proc;
        a.data = *units_pool;

        to_unserialize.* = copy_string(str, allocator=a);
    }
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
unserialize  :: (to_unserialize: *Ability, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    success = unserialize_structure(to_unserialize, handler);
    return success;
}
unserialize  :: (to_unserialize: *Ability_Kind, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Ability_Kind)i;
    return success;
}
unserialize  :: (to_unserialize: *Ability_Orientation, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Ability_Orientation)i;
    return success;
}

//
// Level Loading/Saving
//
#scope_module

save_level :: (using map : Map, filename : string) -> bool {
    builder: String_Builder;
    defer free_buffers(*builder);

    init_string_builder(*builder);
    print_to_builder(*builder, "[%]\t# Version Number\n\n", VERSION);
    print_to_builder(*builder, "%\t# Width\n", map_width);
    print_to_builder(*builder, "%\t# Height\n\n", map_height);

    print_to_builder(*builder, "# Tiles:\n");
    print_tiles_to_builder(*builder, tiles);
    print_to_builder(*builder, "---\n");
    print_units_to_builder(*builder, units);

    success := File.write_entire_file(tprint("%/%", levels_path, filename), builder_to_string(*builder, allocator=temp));

    log("Saved tiles to \"%\"\n", filename, flags=.VERBOSE_ONLY);
    return success;
}

load_level :: (map : *Map, units: [..] *Unit, filename : string) -> success: bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    start_file(*handler, filename, tprint("%/%", levels_path, filename), optional = false);
    if handler.failed return false;

    if handler.version != VERSION
        return error_out(handler, "Invalid version number.");

    // Tiles
    {
        found : bool;
        line : string;
        line, found = consume_next_line(*handler);
        file_says_map_width := string_to_int(line);
        line, found = consume_next_line(*handler);
        file_says_map_height := string_to_int(line);

        assert(file_says_map_width == map_width);
        assert(file_says_map_height == map_height);

        for row : 0..map_height-1 {
            line, found = consume_next_line(*handler);

            for col : 0..line.count-1 {
                character := slice(line, col, 1);
                kind := cast(Tile_Kind)string_to_int(character, base=16);
                map.tiles[col][row].kind = kind;
                map.tiles[col][row].sprite_index = default_tile_sprite_index(kind);
            }
        }

        line, found = consume_next_line(*handler);
        assert(found);
        assert(line == "---");

        line, found = consume_next_line(*handler);
        while found {
            if line == "---" break;
            values := split(line, cast(u8)(#char " "));
            if values.count != 3
                return error_out(handler, "Problem with sprite indices. Should be in the format x y index.");

            col := string_to_int(values[0]);
            row := string_to_int(values[1]);
            index := string_to_int(values[2]);

            map.tiles[col][row].sprite_index = index;

            line, found = consume_next_line(*handler);
        }
    }

    // Units
    {
        array_reset(*map.units);

        a: Allocator;
        a.proc = flat_pool_allocator_proc;
        a.data = *level_pool;

        unit_name, success := consume_next_line(*handler);
        while success {
            new_unit := New(Unit, allocator=a);
            if !success {
                error(handler, "Expected a Unit name while parsing level %.\n", filename);
                return false;
            }

            found_unit : bool;
            for units {
                if unit_name == it.name {
                    memcpy(new_unit, it, size_of(Unit));
                    found_unit = true;
                    break;
                }
            }
            if !found_unit {
                error(handler, "Invalid unit name: We don't know who % is! While parsing level %.\n", unit_name, filename);
                return false;
            }

            new_unit.square, success = parse_square(*handler);
            if !success {
                error(handler, "Expected a square while parsing level %.\n", filename);
                return false;
            }

            new_unit.id = map.units.count;
            array_add(*map.units, new_unit);

            unit_name, success = consume_next_line(*handler);
        }
    }

    log("Loaded level from \"%\".\n", filename, flags=.VERBOSE_ONLY);

    return true;
}

#scope_file
print_tiles_to_builder :: (builder : *String_Builder, tiles : [map_width][map_height] Tile) {
    new_context := context;
    push_context new_context 
    {
        format_int := *context.print_style.default_format_int;
        format_int.base = 16;

        exceptions: [..] Square;
        defer array_reset(*exceptions);

        for row : 0..map_height-1 {
            for col : 0..map_width-1 {
                kind := tiles[col][row].kind;
                if tiles[col][row].sprite_index != default_tile_sprite_index(kind)
                    array_add(*exceptions, .{col, row});

                print_to_builder(builder, "%", cast(int)kind);
            }
            print_to_builder(builder, "\n");
        }

        print_to_builder(builder, "---\n");
        print_to_builder(builder, "# Sprite Index Exceptions:\n");
        for exceptions {
            print_to_builder(builder, "% % %\n", it.col, it.row, tiles[it.col][it.row].sprite_index);
        }

    }
}

print_units_to_builder :: (builder : *String_Builder, units: [..] *Unit) {
    print_to_builder(builder, "# Level Units:\n");
    for units {
        print_to_builder(builder, "\n%\n", it.name);
        print_to_builder(builder, "%\n", it.square);
    }
}
