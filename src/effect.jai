// Tactics
// Effect
// Alex Hartford
// July 2023

Effect :: struct {
    kind     : Effect_Kind;
    strength : int = 1;
    duration : int = 1;
}

Effect_Kind :: enum {
    NONE;
    DEFEND;
    PIERCE;

    QUICKEN;
    SLOW;

    EMPOWER;
    WEAKEN;

    PARALYZE;
}

is_negative :: (using effect: Effect) -> bool {
    if #complete effect.kind == {
        case .PIERCE;   #through;
        case .SLOW;     #through;
        case .WEAKEN;   #through;
        case .PARALYZE; return true;

        case .NONE;     #through;
        case .DEFEND;   #through;
        case .QUICKEN;  #through;
        case .EMPOWER;  return false;
    }
}

get_effect :: (effects: [..] Effect, kind: Effect_Kind) -> *Effect {
    for effects {
        if it.kind == kind then return *it;
    }
    return null;
}

apply_effect :: (using unit: *Unit, effect: Effect) {
    if effect.duration <= 0 then return;

    if #complete effect.kind == {
        case .NONE; return;

        case .DEFEND; {
            if armor <= 0 || armor >= 9 then return;
            armor += effect.strength;
        }
        case .PIERCE; {
            if armor <= 0 || armor >= 9 then return;
            armor -= effect.strength;
        }
        case .QUICKEN; {
            if movement <= 0 || movement >= 9 then return;
            movement += effect.strength;
        }
        case .SLOW; {
            if movement <= 0 || movement >= 9 then return;
            movement -= effect.strength;
        }

        case .EMPOWER;
            if primary.damage > 0 {
                primary.damage = xx clamp(primary.damage + effect.strength, 1, 9);
            }
            if secondary.damage > 0 {
                secondary.damage = xx clamp(secondary.damage + effect.strength, 1, 9);
            }
        case .WEAKEN;
            if primary.damage > 1 {
                primary.flags |= .WEAKENED;
                primary.damage = xx clamp(primary.damage - effect.strength, 1, 9);
            }
            if secondary.damage > 1 {
                secondary.flags |= .WEAKENED;
                secondary.damage = xx clamp(secondary.damage - effect.strength, 1, 9);
            }

        case .PARALYZE;
    }
    array_add(*effects, effect);

    // @HACK!!! This is because the effect immediately wears off if we don't do this.
    effects[effects.count-1].duration += 1;
}

increment_effects :: (using unit: *Unit) {
    for * effects {
        increment_effect(unit, it);
        if it.duration == 0 {
            unapply_effect(unit, it);
            remove it;
        }
    }
}

increment_effect :: (unit: *Unit, using effect: *Effect) {
    if kind == {
        case .PARALYZE;
            unit.moved = true;
            unit.exhausted = true;

        case; // Nothing to increment here!
    }

    duration -= 1;
    assert(duration >= 0);
}

unapply_effect :: (using unit: *Unit, effect: *Effect) {
    if #complete effect.kind == {
        case .NONE; return;

        case .DEFEND;   armor = clamp(armor - effect.strength, 0, 9);
        case .PIERCE;   armor = clamp(armor + effect.strength, 0, 9);
        case .QUICKEN;  movement = clamp(movement - effect.strength, 0, 9);
        case .SLOW;     movement = clamp(movement + effect.strength, 0, 9);

            // @BUG: There is just a lot wrong here.
            // When you have a weaken of 2, both 1, 2, and 3 result in 1 damage, but when you want to bring it back up,
            // You don't know which one it is.
            // Just keep the state somewhere else.
        case .EMPOWER;
            if primary.flags & .EMPOWERED {
                primary.flags ^= .EMPOWERED;
                primary.damage = xx clamp(primary.damage - effect.strength, 1, 9);
            }
            if secondary.flags & .EMPOWERED {
                secondary.flags ^= .EMPOWERED;
                secondary.damage = xx clamp(secondary.damage - effect.strength, 1, 9);
            }
        case .WEAKEN;
            if primary.flags & .WEAKENED {
                primary.flags ^= .WEAKENED;
                primary.damage = xx clamp(primary.damage + effect.strength, 1, 9);
            }
            if secondary.flags & .WEAKENED {
                secondary.flags ^= .WEAKENED;
                secondary.damage = xx clamp(secondary.damage + effect.strength, 1, 9);
            }

        case .PARALYZE;
    }
}
