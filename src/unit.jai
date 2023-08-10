// Umi
// Unit
// Alex Hartford
// June 2023

MAX_CREW :: 29;
MAX_HULL :: 9;

Unit :: struct {
    // Properties
    name : string;          @Always
    description : string;
    sprite_index : int;

    max_hull: int;
    max_crew: int;
    movement : int;
    flags : Unit_Flags;

    primary: Ability;
    secondary: Ability;
    repair:    Ability = Ability.{name="Repair", sprite_index=380, targeting=.SELF, damage=-2};    @NoSerialize
    board:     Ability = Ability.{name="Board",  sprite_index=474, targeting=.BOARDING};           @NoSerialize
    interact:  Ability = Ability.{name="Interact", sprite_index=474, targeting=.ANY, special=.INTERACT}; @NoSerialize

    // Per-Level
    team : Team;            @PerLevel
    ai: AI_Behavior;        @PerLevel
    captain : Captain;      @PerLevel
    crew : int = 5;         @PerLevel

    using square : Square;  @PerLevel
    direction : Direction;  @PerLevel
    flashback : string;     @PerLevel

    // State
    id : int;               @NoSerialize
    hull : int;             @NoSerialize
    moved  : bool;          @NoSerialize
    exhausted : bool;       @NoSerialize

    sinking: int;           @NoSerialize
    dead   : bool;          @NoSerialize

    captains_in_the_hold : [..] Captain; @NoSerialize

    status : Status;        @NoSerialize
}

Unit_Flags :: enum_flags {
    PASS;
    IMMOVABLE;
    ARMORED;
    TURTLE;
    SWIFT;
}

summarize_unit_flags :: (using flags: Unit_Flags) -> string {
    builder: String_Builder;
    init_string_builder(*builder);

    ti := type_info(Unit_Flags);
    for ti.values {
        if cast(bool)(flags & cast(Unit_Flags)it) {
            new_string := tprint("%. ", cast(Unit_Flags)it);
            replace_chars(new_string, "_-", #char " ");
            to_lower_in_place(new_string);

            append(*builder, new_string);
        }
    }

    return builder_to_string(*builder);
}

AI_Behavior :: enum {
    NO_BEHAVIOR;
    PURSUE;
    PURSUE_AFTER_1;
    PURSUE_AFTER_2;
    PURSUE_AFTER_3;
    BOSS;
    ATTACK_IN_RANGE;
    ATTACK_IN_TWO;
    FLEE;
    TREASURE_THEN_FLEE;
}

//
//

kill :: (using unit: *Unit) {
    dead = true;
    array_reset(*captains_in_the_hold);
    play_sfx("dead");
}

sink :: (using unit: *Unit) {
    if sinking != 0 {
        kill(unit);
        return;
    }

    sinking = 2;
    play_sfx("dead");
}

damage_hull :: (using unit: *Unit, damage : int, armor_piercing := false) {
    if unit.flags & .ARMORED && !armor_piercing
        hull = hull - (damage - 1);
    else
        hull = hull - damage;

    hull = clamp(hull, 0, max_hull);
    if hull == 0 then sink(unit);
}

damage_crew :: (using unit: *Unit, damage : int) {
    crew = crew - damage;
    crew = clamp(crew, 0, 9);
    if crew == 0 then kill(unit);
}

query_units :: (units: [..] *Unit, query: (*Unit) -> bool) -> [] *Unit {
    result : [..] *Unit;
    result.allocator = temp;

    for units {
        if query(it)
            array_add(*result, it);
    }

    return result;
}

find_nearest_unit :: (using map: Map, unit: Unit, query: (*Unit) -> bool) -> *Unit {
    prospects := query_units(units, query);
    if !prospects
        return null;

    nearest : *Unit;
    shortest_distance := 100;
    for prospects {
        test_path, success := get_shortest_path(map, unit, it.square);
        defer array_reset(*test_path);
        if !success continue;

        if test_path.count < shortest_distance {
            shortest_distance = test_path.count;
            nearest = it;
        }
    }

    return nearest;
}
