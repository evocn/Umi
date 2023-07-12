// Workspace: Tactics Workspace
//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:95.
//
if !serialize(s.name, "name", builder) return false;
if !serialize(s.team, "team", builder) return false;
if !serialize(s.sprite_index, "sprite_index", builder) return false;
if !serialize(s.movement, "movement", builder) return false;
if !serialize(s.flags, "flags", builder) return false;
if !serialize(s.ability, "ability", builder) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:190.
//
if !unserialize(*s.ability_name, handler) return false;
if !unserialize(*s.ability_kind, handler) return false;
if !unserialize(*s.min_range, handler) return false;
if !unserialize(*s.max_range, handler) return false;
if !unserialize(*s.amount, handler) return false;
if !unserialize(*s.turns, handler) return false;
if !unserialize(*s.orientation, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:190.
//
if !unserialize(*s.name, handler) return false;
if !unserialize(*s.team, handler) return false;
if !unserialize(*s.sprite_index, handler) return false;
if !unserialize(*s.movement, handler) return false;
if !unserialize(*s.flags, handler) return false;
if !unserialize(*s.ability, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:95.
//
if !serialize(s.ability_name, "ability_name", builder) return false;
if !serialize(s.ability_kind, "ability_kind", builder) return false;
if !serialize(s.min_range, "min_range", builder) return false;
if !serialize(s.max_range, "max_range", builder) return false;
if !serialize(s.amount, "amount", builder) return false;
if !serialize(s.turns, "turns", builder) return false;
if !serialize(s.orientation, "orientation", builder) return false;
