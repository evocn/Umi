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

    damages_hull : bool;
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
    INTERACT;
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

        if damages_hull {
            append(*builder, "hull ");
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
    should_display : bool;

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
    victim_initial_hull: int;
    victim_final_hull: int;
    victim_initial_crew: int;
    victim_final_crew: int;
    victim_status : Status;
}

BOARDING_AGGRESSOR_DIE := 4;
BOARDING_AGGRESSOR_BONUS := -1;
EXPONENT_COEFFICIENT := 1.0;

get_multiplier :: (differential: int) -> float {
    factor := -cast(float)differential * EXPONENT_COEFFICIENT;
    zero_to_one := 1 / (1 + pow(E, factor));
    multiplier := 0.5 + zero_to_one;
    return multiplier;
}

get_damage :: (attacker_strength : int, victim_strength : int) -> int {
    differential := attacker_strength - victim_strength;

    multiplier := get_multiplier(differential);

    damage := cast(int)(attacker_strength / 2.0 * multiplier);

    return damage;
}

resolve_ability :: (map: *Map, using ability: *Ability, user : *Unit, victim : *Unit, square: Square, dialogue: *Dialogue) -> Resolution {
    assert(user != null);
    assert(ability != null);

    result: Resolution;
    result.ability = ability;
    result.user = user;
    result.user_initial_hull = user.hull;
    result.user_initial_crew = user.crew;

    if has_target(ability.*) {
        result.victim = victim;
        result.victim_initial_hull = victim.hull;
        result.victim_initial_crew = victim.crew;

        assert(victim != null);

        //log("% used the % ability on %.\n", user.name, name, victim.name);
        //log("% damage, applying the % effect for % turns at % strength, with % special effect.\n", damage, effect.kind, effect.duration, effect.strength, special);

        // damage
        if targeting == .BOARDING {
            result.should_display = true;

            die_result := roll_die(BOARDING_AGGRESSOR_DIE) + BOARDING_AGGRESSOR_BONUS;

            calculated_user_crew := user.crew + die_result + bonus_damage;
            calculated_victim_crew := victim.crew + bonus_damage;
            differential := calculated_user_crew - calculated_victim_crew;

            damage_to_victim := get_damage(calculated_user_crew, calculated_victim_crew);
            damage_to_victim = clamp(damage_to_victim, 0, MAX_CREW);

            damage_to_user := get_damage(calculated_victim_crew, calculated_user_crew);
            damage_to_user = clamp(damage_to_user, 0, MAX_CREW);

            print("user crew (initial) : %\n", user.crew);
            print("user crew (adjusted): %\n", calculated_user_crew);
            print("victim crew         : %\n", calculated_victim_crew);
            print("differential        : %\n", differential);

            print("damage to user      : %\n", damage_to_user);
            print("damage to victim    : %\n", damage_to_victim);

            damage_crew(victim, damage_to_victim);
            damage_crew(user, damage_to_user);

                result.user_die_result = die_result;
                result.user_die_bonus = damage_to_victim - die_result;

                if victim.dead result.victim_died = true;
                if user.dead result.user_died = true;
        }
        else if damage > 0 || (damage == 0 && bonus_damage > 0) {
            result.should_display = true;

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

            attack_damage = clamp(attack_damage, 0, MAX_CREW);

            if damages_hull {
                damage_hull(victim, attack_damage);
            }
            else {
                damage_crew(victim, attack_damage);
            }

            if victim.dead result.victim_died = true;
        }
        else if damage < 0 || (damage == 0 && bonus_damage < 0) {
            result.should_display = true;

            die_result := roll_die(damage);
            heal_amount := die_result + abs(bonus_damage);

            result.user_die_result = die_result;
            result.user_die_bonus = heal_amount - die_result;

            heal_amount = clamp(heal_amount, 0, MAX_CREW);

            if damages_hull {
                damage_hull(victim, -1 * heal_amount);
            }
            else {
                damage_crew(victim, -1 * heal_amount);
            }

            if victim.dead result.victim_died = true; // unlikely...
        }

        // push
        if push_orientation != .NONE && !(victim.flags & .IMMOVABLE) {
            result.should_display = true;

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
            case .INTERACT;
            {
                if user.team == victim.team {
                    result.should_display = true;

                    crew_receiver := user;
                    crew_giver := victim;

                    if user.sinking {
                        crew_receiver = victim;
                        crew_giver = user;
                    }

                    // Transfer
                    MAX_CREW_TRANSFER :: 3;

                    max_crew_giver_can_give := clamp(crew_giver.crew, 0, MAX_CREW_TRANSFER);
                    max_crew_receiver_can_take := clamp(crew_receiver.max_crew - crew_receiver.crew, 0, MAX_CREW_TRANSFER);

                    print("%, %\n", max_crew_giver_can_give, max_crew_receiver_can_take);

                    how_many_to_take := min(max_crew_giver_can_give, max_crew_receiver_can_take);
                    crew_receiver.crew = crew_receiver.crew + how_many_to_take;
                    crew_giver.crew = crew_giver.crew - how_many_to_take;

                    if crew_giver.crew == 0 {
                        if crew_giver.captain != .NONE {
                            if crew_receiver.captain == .NONE {
                                crew_receiver.captain = crew_giver.captain;
                            }
                            else {
                                array_add(*crew_receiver.captains_in_the_hold, crew_giver.captain);
                                for crew_giver.captains_in_the_hold {
                                    array_add(*crew_receiver.captains_in_the_hold, it);
                                }
                            }
                        }

                        kill(crew_giver);
                    }
                }
                else {
                    result.should_display = false;
                    // Parley
                    if user.captain == victim.parley_captain {
                        success := load_dialogue_file(dialogue, tprint("%.dialogue", victim.parley));
                        if !success {
                            log_error("Parley: Unable to load dialogue file %.\n", victim.parley);
                        }
                        else {
                            switch_mode(.DIALOGUE);
                        }

                        victim.team = .YOU;
                    }
                }
            }
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
    result.user_final_hull = user.hull;

    if victim {
        result.victim_final_crew = victim.crew;
        result.victim_final_hull = victim.hull;
    }

    return result;
}
