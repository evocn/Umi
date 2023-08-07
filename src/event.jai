// Umi
// Events
// Alex Hartford
// August 2023

// This system should be a small shim.
// Its objective is to provide some little piece of dynamic behavior, saved per-level,
// Which allows a level to keep some information it wants to use.

// Functionally:
// * Cause a dialogue to occur
// * Cause reinforcements to come
// * Do something to all units on given tiles

// This event happens:
// * At the start of a given turn.

Event_Kind :: enum {
    DIALOGUE;
    REINFORCEMENTS;
    ENVIRONMENTAL;
}

Event :: struct {
    kind: Event_Kind;
    turn: int;
}

Dialogue_Event :: struct {
    using #as base_event: Event;
    dialogue_name : string;
}

Reinforcement_Event :: struct {
    using #as base_event: Event;
}

Environmental_Event :: struct {
    using #as base_event: Event;
}

activate_event :: (event: *Event, map: *Map, dialogue: *Dialogue) {
    if #complete event.kind == {
        case .DIALOGUE;
            using cast(*Dialogue_Event)event;
            success := load_dialogue_file(dialogue, tprint("%.dialogue", dialogue_name));
            if !success {
                log_error("Event: Unable to load dialogue file %.\n", dialogue_name);
                return;
            }
            switch_mode(.DIALOGUE);

        case .REINFORCEMENTS;
            using cast(*Reinforcement_Event)event;

        case .ENVIRONMENTAL;
            using cast(*Environmental_Event)event;

    }
}
