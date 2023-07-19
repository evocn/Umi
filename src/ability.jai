// Tactics
// Ability
// Alex Hartford
// July 2023

Ability_Kind :: enum {
    NONE;
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
    orientation : Ability_Orientation;

    used : bool;        @NoSerialize
}

//
//

resolve_ability :: (map: *Map, user : *Unit, victim : *Unit, square: Square) {
    assert(user != null);
    assert(victim != null || user.ability.ability_kind == .WARP);

    log("% used the % ability on %.\n", user.name, user.ability.ability_kind, victim.name);

    if #complete user.ability.ability_kind == {
        case .NONE;

        case .ATTACK;

        tile := get_tile(map.*, victim.square);
        if tile.kind == .COVER return;
        else if tile.kind == .HALF_COVER {
            map.tiles[victim.square.col][victim.square.row].kind = .NONE;
            map.tiles[victim.square.col][victim.square.row].sprite_index = default_tile_sprite_index(.NONE);
            return;
        }

        if (victim.flags & .IMMORTAL) ||
           (victim.flags & .IMPERVIOUS) || 
           (victim.effects & .SHIELD)
            return;

        kill(victim);

        //

        case .PUSH;

        direction_of_push : Direction;
        {
            direction_to_target := get_best_unit_direction(user.square, victim.square);
            if #complete user.ability.orientation == {
                case .AWAY;
                direction_of_push = direction_to_target;

                case .TOWARD;
                direction_of_push = flip(direction_to_target);

                case .LEFT;
                direction_of_push = rotate(direction_to_target, clockwise=false);

                case .RIGHT;
                direction_of_push = rotate(direction_to_target);
            }
        }

        target_square := move(victim.square, direction_of_push);
        if !on_grid(target_square) return;

        remove_occupant(map, victim.square);
        occupy(map, target_square, victim);
        victim.square = target_square;
        resolve_landing_effects(map, victim);

        //

        case .WARP;
        remove_occupant(map, user.square);
        occupy(map, square, user);
        user.square = square;
        resolve_landing_effects(map, user);

        //

        case .SHIELD_BUFF;
        victim.effects |= .SHIELD;
        
        //

        case .SPEED_BUFF;
        victim.effects |= .SPEED;

        //

        case .AUGMENT_BUFF;
        victim.effects |= .AUGMENT;

        case .DANCE;
        victim.moved = false;
        victim.exhausted = false;

        //

        case .PARALYZE;
        victim.effects |= .PARALYZED;

        //

        // @TODO!
        case .MIND_CONTROL;
        case .SWEEPING_EDGE;
        case .LINE;
        case .FIREBALL;
    }
}
