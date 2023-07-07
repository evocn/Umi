// Tactics
// Editor
// Alex Hartford
// June 2023

editor : struct {
    cursor : Square = .{map_width / 2, map_height / 2};
    selected_unit : *Unit;
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

    units_editor(units);
    if selected_unit {
        unit_editor(selected_unit, units);
    }

    cursor_display(map);

    settings_editor();

    debug_display();
    
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

unit_editor :: (using unit: *Unit, units : *[..] *Unit) {
    using editor;

    ImGui.Begin("Unit");
    {
        ImGui.Text("%", name);

        // @TODO: Get name editing in the editor.
        /*
        label := temp_c_string("Name");
        cStr: *u8 = talloc(name.count+5); // 5 extra bytes
        memset(cStr, 0, name.count+5);
        memcpy(cStr, name.data, name.count);
        ImGui.InputText(label, cStr, xx(name.count));
        */

        if ImGui.Button("delete") {
            array_ordered_remove_by_value(units, selected_unit);
            selected_unit = null;
        }

        {
            using selected_unit;
            ImGui.DragInt("Sprite", xx *sprite_index, 1, 0, 1077, "%d", .ImGuiSliderFlags_AlwaysClamp);

            ti := type_info(Team);
            ImGui.SliderInt("Team", xx *team, 0, cast(s32)(ti.names.count - 1), temp_c_string(ti.names[xx team]));

            imgui_flags_editor(*(selected_unit.unit_flags));


            ImGui.InputInt("Movement",  xx *movement);
            ImGui.InputInt("Min Range", xx *min_range);
            ImGui.InputInt("Max Range", xx *max_range);
        }
    }
    ImGui.End();
}

last_selected_unit: int = -1;
units_editor :: (units : *[..] *Unit) {
    ImGui.Begin("Units");
    {
        ImGui.Text("Current level: %", program_state.current_level_name);
        if(ImGui.Button("Save")) {
            success := save_units(units.*, tprint("%.units", program_state.current_level_name));
        }
        ImGui.SameLine();
        if(ImGui.Button("Load")) {
            success := load_units(units, tprint("%.units", program_state.current_level_name));
            editor.selected_unit = null;
        }

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

settings_editor :: () {
    ImGui.Begin("Settings");
    {
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
//

cursor_display :: (using map: *Map) {
    using editor;

    ImGui.Begin("Cursor");
    {
        ImGui.Text("The cursor is over %.", cursor);
        ImGui.Text("That tile is: %", tiles[cursor.col][cursor.row]);

        occupant := occupancy[cursor.col][cursor.row];
        if occupant 
            ImGui.Text("Its occupant is %", occupant.name);
        else
            ImGui.Text("It is unoccupied.");
    }
    ImGui.End();
}

debug_display :: () {
    ImGui.Begin("Debug Display");
    {
        ImGui.Text("Editor");

        ImGui.Text("average % ms/frame (% FPS)", 
                   formatFloat(1000.0 / program_state.framerate, trailing_width=2), 
                   formatFloat(program_state.framerate, trailing_width=2)
                  );
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
        begin_editing_unit(map);
    }

    if input.button_2 {
        stop_editing_unit(map);
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

begin_editing_unit :: (using map: *Map) {
    using editor;
    occupant := occupancy[cursor.col][cursor.row];
    if occupant {
        selected_unit = occupant;
    }
}

stop_editing_unit :: (using map: *Map) {
    editor.selected_unit = null;
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

    if ImGui.TreeNode(temp_c_string(tprint("%\n", ti.name))) {
        for ti.names {
            ImGui.Selectable(temp_c_string(it), *selections[it_index]);
        }
        ImGui.TreePop();
    }

    flags.* = 0;
    for ti.values {
        if selections[it_index] {
            flags.* |= cast(T)it;
        }
    }
}

