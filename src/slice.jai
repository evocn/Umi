// Umi
// Slice
// Alex Hartford
// July 2023

screen_slice : Slice;

USER_DICE_ROLLED_AT :: 0.2;
USER_DICE_STOPS_ROLLING :: 0.2;
VICTIM_DICE_ROLLED_AT :: 0.3;
VICTIM_DICE_STOPS_ROLLING :: 0.4;

USER_DAMAGE_DEALT_AT :: 0.5;
VICTIM_DAMAGE_DEALT_AT :: 0.7;

Slice :: struct {
    active : bool;

    length : float;
    time   : float;
    progress : float;

    result : Resolution;
    display: Combat_Display;
}

Combat_Display :: struct {
    user_hull : int;
    user_crew : int;

    user_damage_dealt : bool;

    victim_hull : int;
    victim_crew : int;

    victim_damage_dealt : bool;
}

//
//

slice_start :: (result: Resolution, length := 3.0) {
    screen_slice.length = length;
    screen_slice.active = true;
    screen_slice.result = result;

    screen_slice.display.user_hull = result.user_initial_hull;
    screen_slice.display.user_crew = result.user_initial_crew;

    screen_slice.display.victim_hull = result.victim_initial_hull;
    screen_slice.display.victim_crew = result.victim_initial_crew;
}

slice_update :: (dt : float) {
    using screen_slice;
    time += dt;

    progress = screen_slice.time / screen_slice.length;

    if progress > USER_DAMAGE_DEALT_AT && !display.user_damage_dealt &&
       (result.victim_initial_hull != result.victim_final_hull || result.victim_initial_crew != result.victim_final_crew) 
    {
        display.user_damage_dealt = true;
        display.victim_hull = result.victim_final_hull;
        display.victim_crew = result.victim_final_crew;
        play_sfx("attack");
    }

    if progress > VICTIM_DAMAGE_DEALT_AT && !display.victim_damage_dealt &&
       (result.user_initial_hull != result.user_final_hull || result.user_initial_crew != result.user_final_crew) 
    {
        display.victim_damage_dealt = true;
        display.user_hull = result.user_final_hull;
        display.user_crew = result.user_final_crew;
        play_sfx("attack");
    }

    if time > length {
        screen_slice = .{};
    }
}

//
//

get_slice_picture_name :: () -> string {
    kind := screen_slice.result.ability.targeting;
    if #complete kind == {
        case .ENEMY;        return "slice";
        case .ALLY;         return "slice";
        case .ANY;          return "slice";
        case .BOARDING;     return "slice";
        case .ORTHOGRAPHIC; return "slice";
        case .AOE;          return "slice";
        case .EMPTY_SQUARE; return "slice";
        case .SELF;         return "slice";
    }
}
