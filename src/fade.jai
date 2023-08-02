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

    callback : #type (string);
    argument : string;

    // @CONSIDER: Different curve types, instead of plain-old linear fade.
}

Fade_Kind :: enum {
    IN;
    OUT;
}

//
//

fade_start :: (kind : Fade_Kind, callback: #type (string), argument: string, length := 3.0) {
    fade.kind = kind;
    fade.length = length;
    fade.original_master = sound_player.master_volume;

    fade.callback = callback;
    fade.argument = argument;

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

        callback(argument);

        fade.active = false;
    }
}
