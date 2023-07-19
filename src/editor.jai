// Tactics
// Editor
// Alex Hartford
// June 2023

editor : struct {
    cursor : Square = .{map_width / 2, map_height / 2};
    selected_unit : *Unit;

    moving_unit : *Unit;

    should_save : bool;
}

//
//

update_and_draw_editor :: (map: *Map, units: *[..] *Unit) {
    using editor;

    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse    = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard = io.WantCaptureKeyboard;
    program_state.framerate = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();

    new_context := context;
    new_context.logger      = save_load_logger;
    push_context new_context {
        if should_save {
            should_save = false;

            success : bool;

            success = save_units(units.*, "all.units");
            if !success {
                log_error("Error saving units.\n");
            }

            success = save_level(map, tprint("%.level", levels[program_state.current_level_index]));
            if !success {
                log_error("Error saving level.\n");
            }
        }

        save_load(map, units);
    }

    units_editor(units);
    if selected_unit {
        template_editor(selected_unit, units, map);
        percolate_changes_to_map_units(map, selected_unit);
    }

    if moving_unit {
        unit_editor(moving_unit, map);
    }

    level_editor(map);

    tile_editor(map);

    settings_editor();
    
    using ImGui.MouseCursor;
    if ImGui.GetMouseCursor() == {
        case Arrow;         SDL_SetCursor(cursor_arrow);
        case TextInput;     SDL_SetCursor(cursor_text_input);
        case Hand;          SDL_SetCursor(cursor_move);
        case ResizeNS;      SDL_SetCursor(cursor_resize_ns);
        case ResizeEW;      SDL_SetCursor(cursor_resize_ew);
        case ResizeNESW;    SDL_SetCursor(cursor_resize_nesw);
        case ResizeNWSE;    SDL_SetCursor(cursor_resize_nwse);
    }

    ImGui.ShowDemoWindow();

    ImGui.Render();
}

level_index := -1;
save_load :: (map: *Map, units: *[..] *Unit) {
    ImGui.Begin("Menu");
    {
        if(ImGui.Button("Save"))
            editor.should_save = true;

        ImGui.SameLine();
        if(ImGui.Button("Load")) {
            load_units(units, "all.units");
            init_level(map, units.*, levels[program_state.current_level_index]);
            editor.selected_unit = null;
            editor.moving_unit = null;
        }

        ImGui.SameLine();
        if(ImGui.Button("New")) {
            success := save_level(map, "new.level");
            if !success {
                log_error("Error making new level.\n");
            }
            init_levels();
            _, program_state.current_level_index = array_find(levels, "new");
            init_level(map, units.*, levels[program_state.current_level_index]);
            //
        }

        ImGui.SameLine();
        if(ImGui.Button("Delete")) {
            success := File.file_delete(tprint("%/%.level", levels_path, levels[program_state.current_level_index]));
            assert(success);
            init_levels();
            program_state.current_level_index = 0;
            init_level(map, units.*, levels[program_state.current_level_index]);
        }

        if ImGui.BeginListBox("###007", Vector2.{-FLOAT32_MIN, -FLOAT32_MIN}) {
            for levels {
                if ImGui.Selectable(temp_c_string(it), program_state.current_level_index == it_index) {
                    program_state.current_level_index = it_index;

                    init_level(map, units.*, levels[it_index]);
                    editor.selected_unit = null;
                    editor.moving_unit = null;
                }
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}

ability_buffer : [64] u8;
name_buffer    : [64] u8;
level_buffer   : [64] u8;

last_moving_unit := -1;
level_editor :: (using map: *Map) {
    ImGui.Begin("Level");
    {
        if ImGui.InputText("### 9999", level_buffer.data, level_buffer.count) {
            a: Allocator;
            a.proc = flat_pool_allocator_proc;
            a.data = *pool;

            levels[program_state.current_level_index] = copy_string(to_string(level_buffer.data), allocator=a);
            memset(level_buffer.data, 0, level_buffer.count);
        }
        ImGui.SameLine();
        ImGui.Text("%", levels[program_state.current_level_index]);

        if ImGui.Button("Add") {
            if editor.selected_unit {
                new_unit_square : Square;
                if !get_occupant(map, editor.cursor) {
                    new_unit_square = editor.cursor;
                }
                else
                {
                    unoccupied, available_spaces := get_unoccupied(map);
                    new_unit_square = unoccupied[0];

                    if !available_spaces {
                        log_error("Cannot add any more units to this level!\n");
                        ImGui.End();
                        return;
                    }
                }

                a: Allocator;
                a.proc = flat_pool_allocator_proc;
                a.data = *level_pool;

                new_unit := New(Unit, allocator=a);
                memcpy(new_unit, editor.selected_unit, size_of(Unit));
                new_unit.id = map.next_id;
                map.next_id += 1;
                array_add(*map.units, new_unit);

                new_unit.square = new_unit_square;
                occupy(map, new_unit.square, new_unit);
            }
            else {
                log_error("You don't have a unit template selected to add to the level!\n");
            }
        }
        ImGui.SameLine();
        if ImGui.Button("Remove") {
            if editor.moving_unit == null {
                log_error("You don't have a unit selected to remove!\n");
                ImGui.End();
                return;
            }

            remove_occupant(map, editor.moving_unit.square);
            success := array_ordered_remove_by_value(*units, editor.moving_unit);

            editor.moving_unit = null;
            last_moving_unit = -1;
            ImGui.End();
            return;
        }
        ImGui.SameLine();
        if ImGui.Button("Deselect") {
            last_moving_unit = -1;
            editor.moving_unit = null;
        }

        for units {
            if editor.moving_unit == it {
                last_moving_unit = it_index;
            }
        }

        if editor.moving_unit == null then last_moving_unit = -1;
        if ImGui.BeginListBox("###420", Vector2.{-FLOAT32_MIN, -FLOAT32_MIN}) {
            for units {
                if ImGui.Selectable(temp_c_string(tprint("% | %", it_index, it.name)), last_moving_unit == it_index) {
                    last_moving_unit = it_index;
                    editor.moving_unit = it;
                    editor.cursor = it.square;
                }
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}

unit_editor :: (using unit: *Unit, map: *Map) {
    ImGui.SetNextWindowPos(.{50, 400}, ImGui.Cond.Once);
    ImGui.SetNextWindowSize(.{200, 100}, ImGui.Cond.Once);
  
    ImGui.Begin("Unit");
    {
        ImGui.Text("% | %", name, id);
        ti := type_info(Team);
        ImGui.SliderInt("Team", xx *team, 0, cast(s32)(ti.names.count - 1), temp_c_string(ti.names[xx team]));

        ti = type_info(AI_Behavior);
        ImGui.SliderInt("AI", xx *ai, 0, cast(s32)(ti.names.count - 1), temp_c_string(ti.names[xx ai]));
    }
    ImGui.End();
}

template_editor :: (using unit: *Unit, units : *[..] *Unit, map: *Map) {
    using editor;

    ImGui.SetNextWindowPos(.{1000, 400}, ImGui.Cond.Once);
    ImGui.SetNextWindowSize(.{250, 250}, ImGui.Cond.Once);
  
    ImGui.Begin("Template");
    {
        if ImGui.BeginTabBar("Unit Tabs")
        {
            if ImGui.BeginTabItem("Properties")
            {
                if ImGui.InputText("### 9999", name_buffer.data, name_buffer.count) {
                    a: Allocator;
                    a.proc = flat_pool_allocator_proc;
                    a.data = *pool;

                    name = copy_string(to_string(name_buffer.data), allocator=a);
                    memset(name_buffer.data, 0, name_buffer.count);
                }
                ImGui.SameLine();
                ImGui.Text("%", name);

                {
                    using selected_unit;
                    ImGui.DragInt("Sprite", xx *sprite_index, 1, 0, 1077, "%d", .ImGuiSliderFlags_AlwaysClamp);

                    ImGui.InputInt("Movement",  xx *movement);
                }

                ImGui.EndTabItem();
            }
            if ImGui.BeginTabItem("Passive")
            {
                imgui_flags_editor(*(selected_unit.flags));
                ImGui.EndTabItem();
            }
            if (ImGui.BeginTabItem("Active"))
            {
                if ImGui.InputText("### 4444", ability_buffer.data, ability_buffer.count) {
                    a: Allocator;
                    a.proc = flat_pool_allocator_proc;
                    a.data = *pool;

                    ability_name = copy_string(to_string(ability_buffer.data), allocator=a);
                    memset(ability_buffer.data, 0, ability_buffer.count);
                }
                ImGui.SameLine();
                ImGui.Text("%", ability_name);

                ti := type_info(Ability_Kind);
                ImGui.SliderInt("Kind", xx *ability_kind, 0, cast(s32)(ti.names.count - 1), temp_c_string(ti.names[xx ability_kind]));

                ImGui.InputInt("Min",  xx *min_range);
                ImGui.InputInt("Max",  xx *max_range);

                ImGui.InputInt("Amount",  xx *amount);

                ti = type_info(Ability_Orientation);
                ImGui.SliderInt("Orient.", xx *orientation, 0, cast(s32)(ti.names.count - 1), temp_c_string(ti.names[xx orientation]));

                ImGui.EndTabItem();
            }
            ImGui.EndTabBar();
        }
    }
    ImGui.End();
}

percolate_changes_to_map_units :: (map: *Map, unit: *Unit) {
    for map.units {
        if it.name == unit.name {
            unit_copy := New(Unit, allocator=temp);
            memcpy(unit_copy, it, size_of(Unit));
            memcpy(it, unit, size_of(Unit));
            it.team = unit_copy.team;
            it.ai = unit_copy.ai;
            it.id = unit_copy.id;
            it.square = unit_copy.square;
        }
    }
}

last_selected_unit: int = -1;
units_editor :: (units : *[..] *Unit) {
    ImGui.Begin("Unit Templates");
    {
        if ImGui.Button("Deselect") {
            last_selected_unit = -1;
            editor.selected_unit = null;
        }
        ImGui.SameLine();
        if(ImGui.Button("New")) {
            a: Allocator;
            a.proc = flat_pool_allocator_proc;
            a.data = *pool;

            new_unit := New(Unit, allocator=a);

            new_unit.sprite_index = 677;
            new_unit.square = editor.cursor;

            array_add(units, new_unit);
            editor.selected_unit = new_unit;
        }

        if editor.selected_unit == null then last_selected_unit = -1;
        if ImGui.BeginListBox("###420", Vector2.{-FLOAT32_MIN, -FLOAT32_MIN}) {
            for units.* {
                if ImGui.Selectable(temp_c_string(tprint("% | %", it_index, it.name)), last_selected_unit == it_index) {
                    editor.selected_unit = units.*[it_index];
                    last_selected_unit = it_index;
                }
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}

//
//

tile_editor :: (using map: *Map) {
    using editor;

    ImGui.Begin("Cursor");
    {
        tile := *tiles[cursor.col][cursor.row];
        ImGui.Text("The cursor is over %.", cursor);
        ImGui.Text("That tile is: %", tile.*);

        occupant := occupancy[cursor.col][cursor.row];
        if occupant 
            ImGui.Text("Its occupant is %", occupant.name);
        else
            ImGui.Text("It is unoccupied.");

        if ImGui.Button(" Kind ") {
            tile.kind = .NONE;
            tile.sprite_index = default_tile_sprite_index(tile.kind);
        }
        ImGui.SameLine();
        ti := type_info(Tile_Kind);
        if ImGui.SliderInt("### 666", xx *tile.kind, 0, cast(s32)(ti.names.count - 1), temp_c_string(ti.names[xx tile.kind]))
            tile.sprite_index = default_tile_sprite_index(tile.kind);

        if ImGui.Button("Sprite")
            tile.sprite_index = default_tile_sprite_index(tile.kind);
        ImGui.SameLine();
        ImGui.DragInt("### 531", xx *tile.sprite_index, 1, 0, 1077, "%d", .ImGuiSliderFlags_AlwaysClamp);
    }
    ImGui.End();
}

settings_editor :: () {
    ImGui.Begin("Editor");
    {
        ImGui.Text("average % ms/frame (% FPS)", 
                   formatFloat(1000.0 / program_state.framerate, trailing_width=2), 
                   formatFloat(program_state.framerate, trailing_width=2)
                  );


        if ImGui.Checkbox("Line Mode", *settings.line_mode) {
            if settings.line_mode
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            else
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }
    }
    ImGui.End();
}

//
// Cursor Things
//

update_editor_cursor :: (map: *Map) {
    using editor;

    maybe_move_editor_cursor();

    if input.button_1 {
        if moving_unit && get_occupant(map, cursor) == null {
            remove_occupant(map, moving_unit.square);
            occupy(map, cursor, moving_unit);
            moving_unit.square = cursor;
        }
        else {
            editor_begin_moving_unit(map);
        }
        input.button_1 = false;
    }

    if input.button_2 {
        if moving_unit {
            editor_stop_moving_unit(map);
        }
        else {
            maybe_remove_unit_under_cursor(map);
        }
        input.button_2 = false;
    }
}

maybe_move_editor_cursor :: () {
    if input.up {
        move_editor_cursor(.NORTH);
        input.up = false;
    }
    if input.left {
        move_editor_cursor(.WEST);
        input.left = false;
    }
    if input.down {
        move_editor_cursor(.SOUTH);
        input.down = false;
    }
    if input.right {
        move_editor_cursor(.EAST);
        input.right = false;
    }
}

move_editor_cursor :: (direction : Direction) {
    using editor.cursor; 

    new_square : Square;
    if direction == {
        case .NORTH; new_square = Square.{col,   row-1};
        case .SOUTH; new_square = Square.{col,   row+1};
        case .WEST;  new_square = Square.{col-1, row};
        case .EAST;  new_square = Square.{col+1, row};
    }

    if on_grid(new_square)
        editor.cursor = new_square;
}

editor_begin_moving_unit :: (using map: *Map) {
    using editor;
    occupant := occupancy[cursor.col][cursor.row];
    if occupant {
        moving_unit = occupant;
    }
}

editor_stop_moving_unit :: (using map: *Map) {
    editor.moving_unit = null;
}

maybe_remove_unit_under_cursor :: (using map: *Map) {
    using editor;
    occupant := occupancy[cursor.col][cursor.row];
    if occupant {
        remove_occupant(map, occupant.square);
        array_ordered_remove_by_value(*map.units, occupant);
    }
}

//
// Extensions of imgui's functionality
//

imgui_flags_editor :: (flags: *$T) {
    ti := type_info(T);
    assert(ti.type == .ENUM);

    selections: [..] bool;
    selections.count = ti.values.count;
    selections.data = cast(*bool)alloc(ti.values.count);
    memset(selections.data, 0, ti.values.count);
    defer array_reset(*selections);

    for ti.values {
        if flags.* & cast(T)it {
            selections[it_index] = true;
        }
    }

    for ti.names {
        ImGui.Selectable(temp_c_string(it), *selections[it_index]);
    }

    flags.* = 0;
    for ti.values {
        if selections[it_index] {
            flags.* |= cast(T)it;
        }
    }
}

