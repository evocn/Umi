// Tactics
// Unit
// Alex Hartford
// June 2023

Unit :: struct {
    // Properties
    name : string;
    team : Team;
    sprite_index : int;
    unit_flags : Unit_Flags;

    movement : int;
    min_range : int;
    max_range : int;

    // State
    // Initialized
    using square : Square;

    moved : bool;       @NoSerialize
    exhausted : bool;   @NoSerialize
    dead : bool;        @NoSerialize
}

Team :: enum {
    NONE;
    BLUE;
    RED;
}

Unit_Flags :: enum_flags {
    FLYING;
    PASS;
}
