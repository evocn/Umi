// Tactics
// Slice
// Alex Hartford
// July 2023

screen_slice : Slice;

Slice :: struct {
    active : bool;

    length : float;
    time   : float;

    result : Resolution;
}

//
//

slice_start :: (result: Resolution, length := 3.0) {
    screen_slice.length = length;
    screen_slice.active = true;
    screen_slice.result = result;
}

slice_update :: (dt : float) {
    using screen_slice;
    time += dt;

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
