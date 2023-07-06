// Tactics
// Editor
// Alex Hartford
// June 2023

update_and_draw_editor :: () {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse    = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard = io.WantCaptureKeyboard;
    program_state.framerate = io.Framerate;

    //
    //

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();

    /*
    entities_editor(entities);
    if editor.selected_entity != -1 {
        entity_editor((<<entities)[editor.selected_entity], entities);
    }
    */

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

    ImGui.Render();
}

/*
entity_editor :: (using entity: *Entity, entities : *[..] *Entity) {
    ImGui.Begin("Entity");
    {
        ImGui.Text("% | %", serial, name);

        if ImGui.Button("delete") {
            delete_entity(entities, editor.selected_entity);
            editor.selected_entity = -1;
        }
        ImGui.SameLine();
        if ImGui.Button("copy") {
            duplicate_entity(entities, editor.selected_entity);
            editor.selected_entity += 1;
        }
    }
    ImGui.End();
}
*/

/*
entities_editor :: (entities : *[..] *Entity) {
    ImGui.Begin("Entities");
    {
        ImGui.Text("Current level: %", program_state.current_level_name);
        if(ImGui.Button("Save")) {
            success := save_entities(<<entities, program_state.current_level_name);
        }
        ImGui.SameLine();
        if(ImGui.Button("load")) {
            success := load_entities(entities, program_state.current_level_name);
        }

        if ImGui.BeginListBox("###420") {
            for <<entities {
                if ImGui.Selectable(to_c_string(tprint("% | %", it_index, it.name)), editor.selected_entity == it_index)
                    editor.selected_entity = it_index;
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}
*/

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
