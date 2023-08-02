// Umi
// Color
// Alex Hartford
// July 2023

Color :: Vector4;
Hex_Color :: u32;

// Byrne 5 Palette
black_hex   : Hex_Color : 0x100706;
white_hex   : Hex_Color : 0xf6eef6;
bg_hex      : Hex_Color : 0xe8d8b3;
fg_hex      : Hex_Color : 0x1f3348;
color_1_hex : Hex_Color : 0x37532d;
color_2_hex : Hex_Color : 0x9a5246;
color_3_hex : Hex_Color : 0xcbaf5d;
color_4_hex : Hex_Color : 0x6a9185;
color_5_hex : Hex_Color : 0xb9886e;
color_6_hex : Hex_Color : 0x55392c;

color_none :: Color.{};
color_bg :: #run color_from_hex(bg_hex);
color_fg :: #run color_from_hex(fg_hex);
color_1  :: #run color_from_hex(color_1_hex);
color_2  :: #run color_from_hex(color_2_hex);
color_3  :: #run color_from_hex(color_3_hex);
color_4  :: #run color_from_hex(color_4_hex);
color_5  :: #run color_from_hex(color_5_hex);
color_6  :: #run color_from_hex(color_6_hex);

color_white :: #run color_from_hex(white_hex);
color_black :: #run color_from_hex(black_hex);

color_from_hex :: ($h: u32) -> Color {
    color : Color;
    color.x = ((h >> 16) & 0xff) / 255.0;
    color.y = ((h >> 8) & 0xff) / 255.0;
    color.z = ((h >> 0) & 0xff) / 255.0;
    color.w = 1.0;

    return color;
}

team_color :: (team: Team) -> Color {
    if #complete team == {
        case .NONE; return color_fg;
        case .YOU;  return color_1;
        case .THEM; return color_2;
    }
}

enemy_color :: (team: Team) -> Color {
    if #complete team == {
        case .NONE; return team_color(.NONE);
        case .YOU;  return team_color(.THEM);
        case .THEM; return team_color(.YOU);
    }
}

//
//
//

