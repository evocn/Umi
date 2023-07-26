// Tactics
// Ability
// Alex Hartford
// July 2023

/*
sword: 474
gloves: 90
warp: 231
heart: 529
shield: 233
*/

Ability :: struct {
    name : string;
    sprite_index : int = 474;

    targeting : Ability_Targeting_Mode;
    min_range : int = 1;
    max_range : int = 1;

    damage : s32;
    bonus_damage : s32;

    effect : Effect;
    push_orientation : Ability_Orientation = .NONE;
    special: Ability_Special = .NONE;

    flags : Ability_Flags; @NoSerialize
    used : bool;           @NoSerialize
}

Ability_Flags :: enum {
    EMPOWERED;
    WEAKENED;
}

Ability_Targeting_Mode :: enum {
    ENEMY;
    ALLY;
    ANY;
    PORT;
    STARBOARD;
    PORT_AND_STARBOARD;
    FORE;
    AFT;
    ORTHOGRAPHIC;
    AOE;
    EMPTY_SQUARE;
    SELF;
}

has_target :: (using ability: Ability) -> bool {
    if #complete targeting == {
        case .SELF;     #through;
        case .ENEMY;    #through;
        case .ALLY;     #through;
        case .PORT;     #through;
        case .STARBOARD;#through;
        case .PORT_AND_STARBOARD;#through;
        case .FORE;     #through;
        case .AFT;      #through;
        case .ORTHOGRAPHIC; #through;
        case .ANY;      return true;

        case .AOE;      #through;
        case .EMPTY_SQUARE; return false;
    }
}

Ability_Orientation :: enum {
    NONE;
    AWAY;
    TOWARD;
    LEFT;
    RIGHT;
}

Ability_Special :: enum {
    NONE;
    WARP;
    DANCE;
}

//
//

summarize_ability :: (using ability: Ability) -> string {
    builder: String_Builder;
    init_string_builder(*builder);

    if damage > 0 {
        print_to_builder(*builder, "%-% ", 1 + bonus_damage, damage + bonus_damage);
    }
    else if damage < 0 {
        print_to_builder(*builder, "%-% ", -1 * (bonus_damage + -1), -1 * (damage + bonus_damage));
    }

    if damage > 0 || (damage == 0 && bonus_damage > 0) {
        append(*builder, "damage. ");
    }
    else if damage < 0 || (damage == 0 && bonus_damage < 0) {
        append(*builder, "healing. ");
    }

    if effect.kind != .NONE {
        append(*builder, to_lower_copy(tprint("% %. ", effect.kind, effect.strength)));
    }

    if special != .NONE {
        append(*builder, to_lower_copy(tprint("%. ", special)));
    }

    if push_orientation != .NONE {
        append(*builder, to_lower_copy(tprint("push %. ", push_orientation)));
    }

    return builder_to_string(*builder);
}

resolve_ability :: (map: *Map, using ability: *Ability, user : *Unit, victim : *Unit, square: Square) {
    assert(user != null);
    assert(ability != null);

    if has_target(ability.*) {
        assert(victim != null);

        //log("% used the % ability on %.\n", user.name, name, victim.name);
        //log("% damage, applying the % effect for % turns at % strength, with % special effect.\n", damage, effect.kind, effect.duration, effect.strength, special);

        // damage
        if damage > 0 || (damage == 0 && bonus_damage > 0) {
            play_sfx("attack");

            tile := get_tile(map.*, victim.square);
            if tile.kind == .COVER return;
            else if tile.kind == .HALF_COVER {
                map.tiles[victim.square.col][victim.square.row].kind = .NONE;
                map.tiles[victim.square.col][victim.square.row].sprite_index = default_tile_sprite_index(.NONE);
                return;
            }

            attack_damage := clamp(roll_die(damage) + bonus_damage, 0, 9);

            attack(victim, attack_damage);
        }
        else if damage < 0 || (damage == 0 && bonus_damage < 0) {
            play_sfx("buff");

            heal_damage := -1 * clamp(roll_die(damage) + bonus_damage, 0, 9);

            heal(victim, heal_damage);
        }

        // push
        if push_orientation != .NONE {

            if victim.flags & .IMMOVABLE
                return;

            direction_of_push : Direction;
            {
                direction_to_target := get_best_unit_direction(user.square, victim.square);
                if #complete push_orientation == {
                    case .AWAY;
                    direction_of_push = direction_to_target;

                    case .TOWARD;
                    direction_of_push = flip(direction_to_target);

                    case .LEFT;
                    direction_of_push = rotate(direction_to_target, clockwise=false);

                    case .RIGHT;
                    direction_of_push = rotate(direction_to_target);

                    case .NONE; 
                    log_error("Invalid orientation of push.\n");
                    assert(false);
                }
            }

            target_square := move(victim.square, direction_of_push);
            if !on_grid(target_square, map.*) return;
            if is_impassible(get_tile(map, target_square)) return;
            if get_occupant(map, target_square) return;

            play_sfx("arrow");

            remove_occupant(map, victim.square);
            occupy(map, target_square, victim);
            victim.square = target_square;
            resolve_landing_effects(map, victim);
        }

        // apply effect
        apply_effect(victim, effect);

        // special
        if special == {
            case .DANCE;
                victim.moved = false;
                victim.exhausted = false;
                play_sfx("buff");

            case;
        }

        /*
        // @TODO!
        case .FIREBALL;
        */
    }

    else {
        //log("% used the % ability at %.\n", user.name, name, square);

        if special == {
            case .WARP;
                remove_occupant(map, user.square);
                occupy(map, square, user);
                user.square = square;
                resolve_landing_effects(map, user);

                play_sfx("warp");

            case;
        }
    }
}
