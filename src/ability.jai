// Umi
// Ability
// Alex Hartford
// July 2023

Ability :: struct {
    name : string;
    sprite_index : int = 474;

    targeting : Ability_Targeting_Mode;
    min_range : int = 1;
    max_range : int = 1;

    damage : s32;
    bonus_damage : s32;

    status : Status;
    push_orientation : Ability_Orientation = .NONE;
    special: Ability_Special = .NONE;

    active : bool = true;

    used : bool;           @NoSerialize
}

Ability_Targeting_Mode :: enum {
    ENEMY;
    ALLY;
    ANY;
    BOARDING;
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
        case .ORTHOGRAPHIC; #through;
        case .BOARDING; #through;
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
    RAM;
}

//
//

summarize_ability :: (using ability: Ability) -> string {
    builder: String_Builder;
    init_string_builder(*builder);

    if targeting == .BOARDING {
        return "board enemy ship.";
    }
    else {
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
    }

    if status != 0 {
        append(*builder, to_lower_copy(tprint("%. ", status)));
    }

    if special != .NONE {
        append(*builder, to_lower_copy(tprint("%. ", special)));
    }

    if push_orientation != .NONE {
        append(*builder, to_lower_copy(tprint("push %. ", push_orientation)));
    }

    return builder_to_string(*builder);
}

Resolution :: struct {
    ability: *Ability;
    user: *Unit;
    victim: *Unit;

    user_died : bool;
    user_die_result: int;
    user_die_bonus : int;
    user_initial_hull: int;
    user_final_hull: int;
    user_initial_crew: int;
    user_final_crew: int;
    user_status : Status;

    victim_died : bool;
    victim_die_result: int;
    victim_die_bonus : int;
    victim_initial_hull: int;
    victim_final_hull: int;
    victim_initial_crew: int;
    victim_final_crew: int;
    victim_status : Status;
}

BOARD_AGGRESSOR_BONUS :: 1;

resolve_ability :: (map: *Map, using ability: *Ability, user : *Unit, victim : *Unit, square: Square) -> Resolution {
    assert(user != null);
    assert(ability != null);

    result: Resolution;
    result.ability = ability;
    result.user = user;
    result.user_initial_hull = user.health;
    result.user_initial_crew = user.crew;

    if has_target(ability.*) {
        result.victim = victim;
        result.victim_initial_hull = victim.health;
        result.victim_initial_crew = victim.crew;

        assert(victim != null);

        //log("% used the % ability on %.\n", user.name, name, victim.name);
        //log("% damage, applying the % effect for % turns at % strength, with % special effect.\n", damage, effect.kind, effect.duration, effect.strength, special);

        // damage
        if targeting == .BOARDING {
            {
                die_result := roll_die(user.crew);
                damage_to_victim := die_result + BOARD_AGGRESSOR_BONUS + bonus_damage;
                result.user_die_result = die_result;
                if user.captain == .WARLORD {
                    damage_to_victim += 2;
                }
                if victim.flags & .TURTLE {
                    damage_to_victim -= 2;
                }
                result.user_die_bonus = damage_to_victim - die_result;

                damage_to_victim = clamp(damage_to_victim, 0, 9);
                crew_damage(victim, damage_to_victim);
                if victim.dead result.victim_died = true;
            }

            {
                die_result := roll_die(user.crew);
                damage_to_assailant := die_result + bonus_damage;
                result.victim_die_result = die_result;
                if victim.captain == .WARLORD {
                    damage_to_assailant += 2;
                }
                if user.flags & .TURTLE {
                    damage_to_assailant -= 2;
                }
                result.victim_die_bonus = damage_to_assailant - die_result;

                damage_to_assailant = clamp(damage_to_assailant, 0, 9);
                crew_damage(user, damage_to_assailant);
                if user.dead result.user_died = true;
            }
        }
        else if damage > 0 || (damage == 0 && bonus_damage > 0) {
            tile := get_tile(map.*, victim.square);
            if tile.kind == .COVER return result;
            else if tile.kind == .HALF_COVER {
                map.tiles[victim.square.col][victim.square.row].kind = .NONE;
                map.tiles[victim.square.col][victim.square.row].sprite_index = default_tile_sprite_index(.NONE);
                return result;
            }

            die_result := roll_die(damage);
            attack_damage := die_result + bonus_damage;
            result.user_die_result = die_result;
            result.user_die_bonus = attack_damage - die_result;

            attack_damage = clamp(attack_damage, 0, 9);
            hull_damage(victim, attack_damage);
            if victim.dead result.victim_died = true;
        }
        else if damage < 0 || (damage == 0 && bonus_damage < 0) {
            die_result := roll_die(damage);
            heal_amount := die_result + abs(bonus_damage);

            result.user_die_result = die_result;
            result.user_die_bonus = heal_amount - die_result;

            heal_amount = clamp(heal_amount, 0, 9);
            crew_damage(victim, -1 * heal_amount);
            if victim.dead result.victim_died = true; // unlikely...
        }

        // push
        if push_orientation != .NONE && !(victim.flags & .IMMOVABLE) {
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
            if on_grid(target_square, map.*) 
            && !is_impassible(get_tile(map, target_square))
            && !get_occupant(map, target_square)
            {
                remove_occupant(map, victim.square);
                occupy(map, target_square, victim);
                victim.square = target_square;
                resolve_landing_effects(map, victim);
            }
        }

        // apply status effect
        victim.status |= status;
        result.victim_status = status;

        // special
        if special == {
            case .DANCE;
                victim.moved = false;
                victim.exhausted = false;
            case .RAM;
                remove_occupant(map, user.square);
                ram_destination := move(square, get_best_unit_direction(square, user.square));

                occupy(map, ram_destination, user);
                user.square = ram_destination;
                resolve_landing_effects(map, user);

                // @TODO: Damage in return for ramming?

            case;
        }
    }

    else {
        //log("% used the % ability at %.\n", user.name, name, square);

        if special == {
            case .WARP;
                remove_occupant(map, user.square);
                occupy(map, square, user);
                user.square = square;
                resolve_landing_effects(map, user);

            case;
        }
    }

    result.user_final_crew = user.crew;
    result.user_final_hull = user.health;

    if victim {
        result.victim_final_crew = victim.crew;
        result.victim_final_hull = victim.health;
    }

    return result;
}
