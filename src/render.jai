// Tactics
// Render
// Alex Hartford
// June 2023

Color :: Vector4;
Hex_Color :: u32;

// 5 Color Palettes
/**/
// Byrne 5 Palette
black_hex : Hex_Color : 0x02080b;
white_hex : Hex_Color : 0xfcf3d9;
red_hex   : Hex_Color : 0xd42a20;
blue_hex  : Hex_Color : 0x0e638e;
yellow_hex: Hex_Color : 0xfac22b;
/**/

/*
// Origami Clouds Palette
black_hex : Hex_Color : 0x4f7969;
white_hex : Hex_Color : 0xdee3e2;
red_hex   : Hex_Color : 0xd86969;
blue_hex  : Hex_Color : 0x78b3d6;
pink_hex  : Hex_Color : 0xfccbcb;
*/

// 4 Color Palettes
/*
// Rising Sun GB Palette
black_hex : Hex_Color : 0x181322;
white_hex : Hex_Color : 0xcdc1a7;
red_hex   : Hex_Color : 0xa2423a;
blue_hex  : Hex_Color : 0x4b372c;
*/

/*
// Kankei 4 Palette
white_hex : Hex_Color : 0xffffff;
black_hex : Hex_Color : 0x060608;
red_hex   : Hex_Color : 0xf42e1f;
blue_hex  : Hex_Color : 0x2f256b;
*/

/*
// CGA MIBEND4 Palette
white_hex : u32 : 0xf7ecb9;
black_hex : u32 : 0x291f23;
red_hex   : u32 : 0xbd502f;
blue_hex  : u32 : 0x34d1af;
*/

black :: #run color_from_hex(black_hex);
white :: #run color_from_hex(white_hex);
red   :: #run color_from_hex(red_hex);
blue  :: #run color_from_hex(blue_hex);

color_from_hex :: ($h: u32) -> Color {
    color : Color;
    color.x = ((h >> 16) & 0xff) / 255.0;
    color.y = ((h >> 8) & 0xff) / 255.0;
    color.z = ((h >> 0) & 0xff) / 255.0;
    color.w = 1.0;

    return color;
}

//
//
//

render :: (map : Map)
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
        for map.units {
            draw_unit(it, shader);
        }

        // Draw Cursor
        if get_occupant(map, cursor.square) {
            draw_sprite(shader, rendering.spritesheet, 49 * 12 + 35, cursor.square, white);
        }
        else {
            if whose_turn() == .BLUE {
                draw_sprite(shader, rendering.spritesheet, 49 * 12 + 35, cursor.square, blue);
            }
            else {
                draw_sprite(shader, rendering.spritesheet, 49 * 12 + 35, cursor.square, red);
            }
        }

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
    if whose_turn() == team {
        if !moved {
            draw_sprite(shader, rendering.spritesheet, 1072, square, white);
        }
        if !exhausted {
            draw_sprite(shader, rendering.spritesheet, 1071, square, white);
        }
    }

    color : Color = ---;
    if #complete team == {
        case .NONE;  color = white;
        case .BLUE;  color = blue;
        case .RED;   color = red;
    }

    draw_sprite(shader, rendering.spritesheet, sprite_index, square, color);
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

//
// Menu
//

render_menu :: (using menu: Menu) {
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(black.x, black.y, black.z, 1);
    glClear(GL_COLOR_BUFFER_BIT);

    draw_menu_element :: (shader: Shader, font: Font, using element: *Menu_Element, height : float, color := white) {
        if kind == {
            case .GO;
                using cast(*Go_Element)element;
                draw_text_centered(shader, font, name, height, scale = 1.0, color = color);

            case .CHECKBOX;
                using cast(*Checkbox_Element)element;
                str := "Off";
                if value
                    str = "On";
                draw_text_centered(shader, font, tprint("%: %", name, str), height, scale = 1.0, color = color);

            case .SLIDER;
                using cast(*Slider_Element)element;
                draw_text_centered(shader, font, tprint("%: %", name, value.*), height, scale = 1.0, color = color);
        }
    }

    {
        shader := rendering.text_shader;
        use_shader(shader);
        defer disable_shaders();

        orthographic := orthographic_projection_matrix(0, xx window_width, 0, xx window_height, -1, 1);
        set_mat4(shader, "projection", orthographic);

        font, found := table_find(*rendering.fonts, "Header");

        draw_text_centered(shader, font, name, font.height * 10.0, scale = 1.0, color = red);

        base_height := font.height * 9.0;
        for elements {
            draw_menu_element(shader, font, it, base_height - it_index * font.height);
        }

        // Draw selected element over it.
        draw_menu_element(shader, font, elements[element_index], base_height - element_index * font.height, blue);
    }
}

//
// Game Over
//

render_game_over :: () {
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(black.x, black.y, black.z, 1);
    glClear(GL_COLOR_BUFFER_BIT);

    {
        shader := rendering.text_shader;
        use_shader(shader);
        defer disable_shaders();

        orthographic := orthographic_projection_matrix(0, xx window_width, 0, xx window_height, -1, 1);
        set_mat4(shader, "projection", orthographic);

        font, found := table_find(*rendering.fonts, "Header");

        draw_text_centered(shader, font, "Game Over", xx (window_height - font.height), scale = 1.0, color = red);
        draw_text_centered(shader, font, "<Select> to restart", xx (window_height - 2.0 * font.height), scale = 0.8, color = white);
    }
}
