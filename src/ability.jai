// Tactics
// Ability
// Alex Hartford
// July 2023

Ability_Kind :: enum {
    ATTACK;
    PUSH;
    WARP;
    SHIELD_BUFF;
    SPEED_BUFF;
    AUGMENT_BUFF;
    DANCE;
    PARALYZE;
    MIND_CONTROL;
    SWEEPING_EDGE;
    LINE;
    FIREBALL;
}

Ability_Orientation :: enum {
    AWAY;
    TOWARD;
    LEFT;
    RIGHT;
}

Ability :: struct {
    ability_name : string;
    ability_kind : Ability_Kind;
    min_range : int;
    max_range : int;
    amount : int;
    turns  : int;
    orientation : Ability_Orientation;

    used : bool;        @NoSerialize
}
