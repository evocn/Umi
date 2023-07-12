// Tactics
// Combat
// Alex Hartford
// July 2023

resolve_ability :: (map: *Map, user : *Unit, victim : *Unit, ability: *Ability, direction : Direction) {
    assert(user != null);
    assert(victim != null);
    //assert(ability != null);
    log("% attacked %!\n", user.name, victim.name);

    tile := get_tile(map.*, victim.square);
    if tile.kind == .COVER return;
    else if tile.kind == .HALF_COVER {
        map.tiles[victim.square.col][victim.square.row].kind = .NONE;
        map.tiles[victim.square.col][victim.square.row].sprite_index = default_tile_sprite_index(.NONE);
        return;
    }

    if cast(bool)(victim.flags & .IMMORTAL | .IMPERVIOUS) return;

    kill(victim);
}
