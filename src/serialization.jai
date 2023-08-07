// Umi
// Serialization
// Alex Hartford
// June 2023

VERSION :: 1;

sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/audio/music";
sfx_path        :: "assets/audio/sfx";

data_path       :: "data";
levels_path     :: "data/levels";
dialogues_path  :: "data/dialogues";

next_id_value := 0;
next_id :: () -> int {
    next_id_value += 1;
    return next_id_value - 1;
}

//
//

save_units :: (units : [..] *Unit, filename : string) -> success : bool {
    builder : String_Builder;
    defer free_buffers(*builder);

    print_to_builder(*builder, "[%] # Version\n", VERSION);

    for units {
        print_to_builder(*builder, "\n");
        success := serialize_structure(it.*, *builder, per_level=false);
        if !success return false;
    }

    write_entire_file(tprint("%/%", data_path, filename), *builder);
    log("Saved units to \"%\".\n", filename, flags=.VERBOSE_ONLY);

    return true;
}

load_units :: (units : *[..] *Unit, filename : string) -> success : bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    start_file(*handler, filename, tprint("%/%", data_path, filename), optional = false);
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
        success := unserialize_structure(new_unit, *handler, per_level=false);
        if !success error(handler, "File Handler problem with %.\n", filename);
        array_add(units, new_unit);
    }

    log("Loaded units from \"%\".\n", filename, flags=.VERBOSE_ONLY);

    return true;
}

#scope_file

// %1          = member name
// type_of(%1) = member type
for_each_member :: ($T: Type, format: string, per_level : bool) -> string
{
    builder: String_Builder;
    defer free_buffers(*builder);

    struct_info := cast(*Type_Info_Struct) T;
    assert(struct_info.type == Type_Info_Tag.STRUCT);

    for member : struct_info.members 
    {
        if member.flags & .CONSTANT continue;

        if !array_find(member.notes, "Always") {
            if array_find(member.notes, "NoSerialize") then continue; 
            if per_level && !array_find(member.notes, "PerLevel") then continue;
            if !per_level && array_find(member.notes, "PerLevel") then continue;
        }

        print_to_builder(*builder, format, member.name);
    }

    return builder_to_string(*builder);
}

serialize_structure :: (s: $T, builder: *String_Builder, $per_level : bool) -> success: bool
{
    #insert #run for_each_member(T, "if !serialize(s.%1, \"%1\", builder) return false;\n", per_level);
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
serialize  :: (to_serialize: s32, name : string, builder: *String_Builder) -> success: bool { 
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
serialize  :: (to_serialize: Status, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Ability, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "# ---\n");
    success := serialize_structure(to_serialize, builder, false);
    return success;
}
serialize  :: (to_serialize: Ability_Targeting_Mode, name : string, builder: *String_Builder) -> success: bool {
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
serialize  :: (to_serialize: Ability_Special, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: AI_Behavior, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Captain, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

//
//
//

unserialize_structure :: (s: *$T, handler: *Text_File_Handler, $per_level : bool) -> success: bool
{
    success : bool;
    #insert #run for_each_member(T, "if !unserialize(*s.%1, handler) return false;\n", per_level);
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
unserialize  :: (to_unserialize: *s32, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_int(handler, s32);
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
unserialize  :: (to_unserialize: *Status, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Status)i;
    return success;
}
unserialize  :: (to_unserialize: *Ability, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    success = unserialize_structure(to_unserialize, handler, false);
    return success;
}
unserialize  :: (to_unserialize: *Ability_Targeting_Mode, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Ability_Targeting_Mode)i;
    return success;
}
unserialize  :: (to_unserialize: *Ability_Orientation, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Ability_Orientation)i;
    return success;
}
unserialize  :: (to_unserialize: *Ability_Special, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Ability_Special)i;
    return success;
}
unserialize  :: (to_unserialize: *AI_Behavior, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(AI_Behavior)i;
    return success;
}
unserialize  :: (to_unserialize: *Captain, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Captain)i;
    return success;
}


//
// Level Loading/Saving
//
#scope_module

save_level :: (map : Map, filename : string) -> bool {
    builder: String_Builder;
    defer free_buffers(*builder);

    init_string_builder(*builder);
    print_to_builder(*builder, "[%]\t# Version Number\n\n", VERSION);

    // Tiles
    print_to_builder(*builder, "%\t# Width\n", map.width);
    print_to_builder(*builder, "%\t# Height\n\n", map.height);

    print_to_builder(*builder, "# Tiles:\n");
    print_tiles_to_builder(*builder, map);

    print_to_builder(*builder, "---\n");

    // Events
    print_to_builder(*builder, "# Events: \n");
    for map.events {
        print_to_builder(*builder, "\n");
        print_to_builder(*builder, "%\n", it.kind);
        print_to_builder(*builder, "%\n", it.turn);
        if #complete it.kind == {
            case .DIALOGUE;
                using cast(*Dialogue_Event)it;
                print_to_builder(*builder, "%\n", dialogue_name);

            case .ENVIRONMENTAL;

            case .REINFORCEMENTS;

        }
    }

    print_to_builder(*builder, "---\n");

    // Units
    for map.units {
        print_to_builder(*builder, "\n");
        success := serialize_structure(it.*, *builder, per_level=true);
        if !success return false;
    }

    success := write_entire_file(tprint("%/%", levels_path, filename), builder_to_string(*builder, allocator=temp));

    log("Saved level to \"%\"\n", filename, flags=.VERBOSE_ONLY);
    return success;
}

load_level :: (map : *Map, units: [..] *Unit, filename : string) -> success: bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    start_file(*handler, filename, tprint("%/%", levels_path, filename), optional = false);
    if handler.failed return false;

    if handler.version != VERSION
        return error_out(handler, "Invalid version number.");

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *level_pool;

    // Tiles
    {
        found : bool;
        line : string;
        line, found = consume_next_line(*handler);
        file_says_map_width := string_to_int(line);
        line, found = consume_next_line(*handler);
        file_says_map_height := string_to_int(line);

        assert(file_says_map_width <= MAX_MAP_WIDTH);
        assert(file_says_map_height <= MAX_MAP_HEIGHT);

        map.width = file_says_map_width;
        map.height = file_says_map_height;

        for row : 0..map.height-1 {
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

    // Events
    {
        array_reset(*map.events);

        map.events.allocator=a;

        line, found := consume_next_line(*handler);
        while found {
            if line == "---" break;
            if line == {
                case "DIALOGUE";
                    new_event := New(Dialogue_Event, allocator=a);
                    success : bool;
                    new_event.turn, success = parse_int(*handler);
                    if !success error(handler, "No event turn! %.\n", filename);

                    new_event.dialogue_name, success = parse_string(*handler);
                    if !success error(handler, "No name for the dialogue event! %.\n", filename);

                    array_add(*map.events, cast(*Event)new_event);
                    
                case "REINFORCEMENTS";
                    
                case "ENVIRONMENTAL";
                    
            }

            line, found = consume_next_line(*handler);
        }
    }


    // Units
    {
        array_reset(*map.units);

        next_id_value = 0;

        map.units.allocator=a;
        while handler.file_data {
            new_unit := New(Unit, allocator=a);

            success := unserialize_structure(new_unit, *handler, per_level=true);

            for units {
                if new_unit.name == it.name {
                    unit_copy := New(Unit, allocator=temp);
                    memcpy(unit_copy, new_unit, size_of(Unit));
                    memcpy(new_unit, it, size_of(Unit));

                    new_unit.team = unit_copy.team;
                    new_unit.ai = unit_copy.ai;
                    new_unit.captain = unit_copy.captain;
                    new_unit.crew = unit_copy.crew;
                    new_unit.square = unit_copy.square;
                    new_unit.direction = unit_copy.direction;
                    new_unit.flashback = unit_copy.flashback;

                    new_unit.health = new_unit.max_health;
                    break;
                }
            }

            new_unit.id = next_id();

            if !success error(handler, "File Handler problem with %.\n", filename);
            array_add(*map.units, new_unit);
        }
    }

    log("Loaded level from \"%\".\n", filename, flags=.VERBOSE_ONLY);

    return true;
}

#scope_file
print_tiles_to_builder :: (builder : *String_Builder, using map: Map) {
    exceptions: [..] Square;
    defer array_reset(*exceptions);

    new_context := context;
    push_context new_context 
    {
        format_int := *context.print_style.default_format_int;
        format_int.base = 16;

        for row : 0..height-1 {
            for col : 0..width-1 {
                kind := tiles[col][row].kind;
                if tiles[col][row].sprite_index != default_tile_sprite_index(kind)
                    array_add(*exceptions, .{col, row});

                print_to_builder(builder, "%", cast(int)kind);
            }
            print_to_builder(builder, "\n");
        }
    }

    print_to_builder(builder, "---\n");
    print_to_builder(builder, "# Sprite Index Exceptions:\n");
    for exceptions {
        print_to_builder(builder, "% % %\n", it.col, it.row, tiles[it.col][it.row].sprite_index);
    }
}
