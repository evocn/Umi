// Tactics
// Unit
// Alex Hartford
// June 2023

Unit :: struct {
    // Properties
    name : string;         @Always
    description : string;
    sprite_index : int;

    max_health: int;
    base_armor: int;
    movement : int;
    flags : Unit_Flags;

    primary_active : bool;
    secondary_active : bool;

    primary: Ability;
    secondary: Ability;

    // Per-Level
    team : Team;           @PerLevel
    using square : Square; @PerLevel
    ai: AI_Behavior;       @PerLevel

    direction : Direction; @PerLevel

    // State
    id : int;              @NoSerialize
    health : int;          @NoSerialize
    armor  : int;          @NoSerialize
    moved  : bool;         @NoSerialize
    turned : bool;         @NoSerialize
    exhausted : bool;      @NoSerialize
    dead   : bool;         @NoSerialize

    effects: [..] Effect;  @NoSerialize
}

Unit_Flags :: enum_flags {
    PASS;
    IMPERVIOUS;
    IMMORTAL;
    SWIFT;
    IMMOVABLE;
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

// Pass: 321
// Impervious: 86
// Immortal: 687
// Land Stride: 89

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

turn :: (using unit: *Unit, left : bool) {
    if left {
        if #complete direction == {
            case .NORTH;    direction = .WEST;
            case .SOUTH;    direction = .EAST;
            case .EAST;     direction = .NORTH;
            case .WEST;     direction = .SOUTH;
        }
    }
    else {
        if #complete direction == {
            case .NORTH;    direction = .EAST;
            case .SOUTH;    direction = .WEST;
            case .EAST;     direction = .SOUTH;
            case .WEST;     direction = .NORTH;
        }
    }
}

//
//

kill :: (using unit: *Unit) {
    if flags & .IMMORTAL return;

    dead = true;
    play_sfx("dead");
}

attack :: (using unit: *Unit, damage : int) {
    if flags & .IMPERVIOUS return;

    health = health - (damage - armor);

    health = clamp(health, 0, max_health);
    if health == 0 then kill(unit);
}

heal :: (using unit: *Unit, damage : int) {
    health = clamp(health + damage, 0, max_health);
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

filter_out_immortal :: (units: *[] *Unit) {
    for units.* {
        if cast(bool)(it.flags & .IMMORTAL) remove it;
        if cast(bool)(it.flags & .IMPERVIOUS) remove it;
    }
}
