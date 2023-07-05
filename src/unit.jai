// Everett
// Unit
// Alex Hartford
// June 2023

// @NOTE: These, and all gameplay entities, will have a physical location
// property (a square) which will define where the unit is on the game board.
// This will not be overwritten by the position/orientation, etc. fields, but
// those fields will be updated in relation to this field.

Unit :: struct {
    unit_flags : Unit_Flags;
    team : Team;

    direction : Direction;
    using square : Square;

    moved : bool;           @NoSerialize
    exhausted : bool;       @NoSerialize
    dead : bool;            @NoSerialize

    movement : int;
    range : int;

    health : int;
    max_health : int;
}

Team :: enum {
    NONE;
    BLUE;
    RED;
    GREEN;
}

Unit_Flags :: enum_flags {
    FLYING;
}
