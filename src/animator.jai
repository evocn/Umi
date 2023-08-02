// Umi
// Animator
// Alex Hartford
// July 2023

// The goal of this module is to have a simple animator.
// The idea: dt goes in, ints get modified.
// One channel for now.

Key_Frame :: struct {
    time : float;
    value: float;
}

Animator :: struct {
    // State
    running : bool;
    time : float;
    frame : int;

    // Parameters
    end : float;
    key_frames : [..] Key_Frame;
    animating: *int;

    // Properties
    interpolation_function : (float) -> float = identity;
    looping := false;
    // speed := 1.0;
}

start :: (using animator : *Animator) {
    running = true;
}

pause :: (using animator : *Animator) {
    running = false;
}

stop :: (using animator : *Animator) {
    restart(animator);
    pause(animator);
}

restart :: (using animator : *Animator) {
    animating.* = cast(int)key_frames[0].value;
    time = 0.0;
    frame = 0;
    start(animator);
}

update :: (using animator : *Animator, dt: float) {
    if !running return;

    time += dt;

    if time > end {
        if looping {
            restart(animator);
        }
        else {
            running = false;
            return;
        }
    }

    if frame >= key_frames.count - 1 then return;

    current_frame := key_frames[frame];
    next_frame := key_frames[frame + 1];

    // Affect the animated value
    t := interpolation_function((time + current_frame.time) / (next_frame.time - current_frame.time));
    animating.* = cast(int)lerp(current_frame.value, next_frame.value, t);

    should_switch_frames := next_frame.time < time;
    if should_switch_frames
        frame += 1;
}

//
// Easing functions
//

identity :: (t: float) -> float {
    return t;
}

flip :: (t: float) -> float {
    return 1 - t;
}

smooth_start :: (t: float) -> float {
    return t * t * t;
}

smooth_stop :: (t: float) -> float {
    return flip(smooth_start(flip(t)));
}

smooth_start_stop :: (t: float) -> float {
    return lerp(smooth_start(t), smooth_stop(t), t);
}

stair :: (t: float) -> float {
    return cast(float)cast(int)t;
}

