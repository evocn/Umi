// Tactics
// Render
// Alex Hartford
// June 2023


Color :: Vector4;

// This is simply a list of all the colors we will use in the game.
black  :: Color.{.16, .12, .14, 1};
white  :: Color.{.97, .93, .73, 1};
red    :: Color.{.74, .31, .18, 1};
blue   :: Color.{.20, .82, .69, 1};

//
//
//

render :: (map : Map, units: [..] *Unit)
{
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(black.x, black.y, black.z, 1);
    glClear(GL_COLOR_BUFFER_BIT);

    // Draw Game Board
    {
        shader := rendering.shader;
        use_shader(shader);
        defer disable_shaders();

        bind(rendering.spritesheet.texture, 0);

        orthographic := orthographic_projection_matrix(0, 1, 0, 1, -1, 1);
        set_mat4(shader, "projection", orthographic);

        for column, x: map.tiles {
            for tile, y: column {
                tile_index := tile.sprite_index;
                draw_sprite(shader, rendering.spritesheet, tile_index, .{x, y});
            }
        }

        // Draw Overlays
        draw_squares_overlay(shader, cursor.accessible);
        draw_squares_overlay(shader, cursor.interactible, color = red);

        if cursor.path {
            draw_path(shader, cursor.path, color = red);
        }

        // Draw Units
        for units {
            draw_unit(it, shader);
        }

        // Draw Cursor
        draw_sprite(shader, rendering.spritesheet, 49 * 12 + 35, cursor.square, blue);

        // Editor Cursor
        if program_mode == .EDITOR {
            draw_sprite(shader, rendering.spritesheet, 49 * 12 + 37, editor.cursor, white);
        }
    }

    // Draw UI Elements
    {
    }

    // Draw Text
    {
        shader := rendering.text_shader;
        use_shader(shader);
        defer disable_shaders();

        orthographic := orthographic_projection_matrix(0, xx window_width, 0, xx window_height, -1, 1);
        set_mat4(shader, "projection", orthographic);

        font, found := table_find(*rendering.fonts, "Header");
        for debug.lines {
            draw_text_centered(shader, font, it, 5 + cast(float)(it_index) * font.height, scale = 1.0, color = blue);
        }
    }
}

//
//

draw_unit :: (using unit : Unit, shader : Shader) {
    color : Color = ---;
    if #complete team == {
        case .NONE;  color = white;
        case .BLUE;  color = blue;
        case .RED;   color = red;
    }

    draw_sprite(shader, rendering.spritesheet, sprite_index, square, color);

    if whose_turn() == team {
        if !moved {
            draw_sprite(shader, rendering.spritesheet, 1056, square, white);
        }
        else if !exhausted {
            draw_sprite(shader, rendering.spritesheet, 1007, square, white);
        }
    }
}

draw_squares_overlay :: (shader : Shader, squares : [..] Square, color := white) {
    for squares {
        draw_square_overlay(shader, it, color);
    }
}

draw_square_overlay :: (shader : Shader, square : Square, color : Color) {
    draw_sprite(shader, rendering.spritesheet, 49 * 13 + 41, square, color);
}

draw_path :: (shader : Shader, path: Path, color : Color) {
    for path {
        draw_square_overlay(shader, it, color);
    }
}
