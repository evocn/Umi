// Umi
// Status
// Alex Hartford
// July 2023

Status :: enum_flags {
    AFLAME;
    ADRIFT;
    ABANDONED;
}

apply_status_effects :: (unit: *Unit) {
    if unit.status & .AFLAME {
        hull_damage(unit, 1, armor_piercing = true);
    }
    if unit.status & .ADRIFT {
    }
    if unit.status & .ABANDONED {
        unit.moved = true;
        unit.exhausted = true;
    }
}
