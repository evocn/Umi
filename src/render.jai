// Everett
// Render
// Alex Hartford
// June 2023

render :: (map : Map)
{
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Draw Game Board
    {
        // Draw Grid

        // Draw Highlighted Grid Square

        // Draw Units

        // Draw Cursor
    }

    // Draw Overlays
    {
        shader := render_context.basic_shader;
        use_shader(shader);
        defer disable_shaders();

        draw_squares_overlay(shader, cursor.accessible);
        draw_squares_overlay(shader, cursor.interactible, color = red);
        draw_square_overlay(shader, cursor.square, color = blue, alpha = 0.8, height_above_stage = 0.1);
    }

    /*
    // Draw Lines
    {
        shader := render_context.basic_shader;
        use_shader(shader);
        defer disable_shaders();

        set_vec4(shader, "color", black);

        set_mat4(shader, "model", Matrix4_Identity);

        for lines {
            draw_line(it);
        }
    }
    */

    // Draw UI Elements
    {
        shader := render_context.screen_shader;
        use_shader(shader);
        defer disable_shaders();

        if whose_turn() == {
            case .NONE;  set_vec4(shader, "color", black);
            case .BLUE;  set_vec4(shader, "color", blue);
            case .RED;   set_vec4(shader, "color", red);
            case .GREEN; set_vec4(shader, "color", green);
        }

        bind(texture, 0);
        orthographic := orthographic_projection_matrix(0, 10.0, 0, 10.0, -1, 1);
        set_mat4(shader, "projection", orthographic);

        /*
        // The API I would love to have:
        size := Vector2.{1.0, 1.0};
        position := Vector2.{0.5, 0.5};

        // The Problem: It draws from the fucking center...

        scale := make_scale_matrix4(Vector3.{size.x, size.y, 1});
        translation := make_translation_matrix4(Vector3.{position.x, position.y, 0});
        model := translation * scale;
        set_mat4(shader, "model", model);
        */

        set_mat4(shader, "model", Matrix4_Identity);

        draw_quad();
    }

    // Draw Text
    {
        shader := render_context.text_shader;
        use_shader(shader);
        defer disable_shaders();

        orthographic := orthographic_projection_matrix(0, xx window_width, 0, xx window_height, -1, 1);
        set_mat4(shader, "projection", orthographic);

        font, found := table_find(*fonts, "Header");
        for debug.lines {
            draw_text(shader, font, it, 10, window_height - 10 - cast(float)(it_index + 1) * font.height, 1.0);
        }
    }
}

//
//
//GL_BIG_DATA_UNIFORM_BINDING :: 0;
//g_big_data_ubo : GLuint;

draw_tiles :: (using map : Map, shader : Shader) {

    for col : 0..grid_width-1 {
        for row : 0..grid_height-1 {
            using tile := map.grid[col][row];
            if tile_kind == {
                case .PLAIN;
                set_vec4(shader, "color", white);

                case .HOLE;
                continue;
                //set_vec4(shader, "color", black);

                case .FOREST;
                set_vec4(shader, "color", green);

                case;
                set_vec4(shader, "color", white);
            }

            square := Square.{col, row};

            //draw_skinned_mesh(cube_mesh, .[]);
        }
    }
}

draw_unit :: (using unit : Unit, shader : Shader) {
    if team == {
        case .NONE;  set_vec4(shader, "color", black);
        case .BLUE;  set_vec4(shader, "color", blue);
        case .RED;   set_vec4(shader, "color", red);
        case .GREEN; set_vec4(shader, "color", green);
    }

    //draw_skinned_mesh(mesh, .[]);
}

get_world_space_center_of_a_tile :: (using square : Square) -> Vector3 {
    return Vector3.{(2.0 * col) - grid_width + 0.5, 0.0, (2.0 * row) - grid_height + 0.5};
}

draw_squares_overlay :: (shader : Shader, squares : [..] Square, color := green, alpha := 0.5, height_above_stage := 0.05) {
    set_vec4(shader, "color", color - Vector4.{0, 0, 0, 1 - alpha});

    for squares {
        position := get_world_space_center_of_a_tile(it);
        translation := make_translation_matrix4(position + Vector3.{y=height_above_stage});

        orientation : Quaternion;
        set_from_axis_and_angle(*orientation, 1, 0, 0, PI * 0.5);
        rotation := rotation_matrix(Matrix4, orientation);

        model := translation * rotation;

        set_mat4(shader, "model", model);
        draw_quad();
    }
}

draw_square_overlay :: (shader : Shader, square : Square, color := green, alpha := 0.5, height_above_stage := 0.05) {
    set_vec4(shader, "color", color - Vector4.{0, 0, 0, 1 - alpha});

    position := get_world_space_center_of_a_tile(square);
    translation := make_translation_matrix4(position + Vector3.{y=height_above_stage});

    orientation : Quaternion;
    set_from_axis_and_angle(*orientation, 1, 0, 0, PI * 0.5);
    rotation := rotation_matrix(Matrix4, orientation);
    model := translation * rotation;

    set_mat4(shader, "model", model);
    draw_quad();
}

//
//

draw_cursor :: (shader: Shader) {
    using cursor;

    set_vec4(shader, "color", blue);
}
