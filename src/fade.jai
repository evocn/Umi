// Umi
// Fades
// Alex Hartford
// July 2023

fade : Fade;

Fade :: struct {
    kind : Fade_Kind;

    active : bool;

    length : float;
    time   : float;
    original_master : float;

    callback : #type ();

    easing : #type (float) -> float;
}

Fade_Kind :: enum {
    IN;
    OUT;
}

//
//

fade_get_t_value :: () -> float {
    t := fade.easing(fade.time / fade.length);
    if #complete fade.kind == {
        case .OUT; return t;
        case .IN;  return 1.0 - t;
    }
}

fade_start :: (kind : Fade_Kind, callback: (), length := 3.0, easing := identity) {
    fade.kind = kind;
    fade.length = length;
    fade.callback = callback;
    fade.easing = easing;
    fade.original_master = sound_player.master_volume;

    fade.time = 0.0;
    fade.active = true;
}

fade_update :: (dt : float) {
    using fade;
    time += dt;

    {
        // Adjust master volume
        t := time / length;
        if kind == {
            case .IN;
                sound_player.master_volume = lerp(0.0, original_master, t);

            case .OUT;
                sound_player.master_volume = lerp(original_master, 0.0, t);
        }
    }

    if time > length {
        sound_player.master_volume = original_master;

        fade.active = false;

        callback();
    }
}
