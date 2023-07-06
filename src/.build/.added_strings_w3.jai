// Workspace: Tactics Workspace
//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:80.
//
if !serialize(s.name, "name", builder) return false;
if !serialize(s.team, "team", builder) return false;
if !serialize(s.sprite_index, "sprite_index", builder) return false;
if !serialize(s.unit_flags, "unit_flags", builder) return false;
if !serialize(s.movement, "movement", builder) return false;
if !serialize(s.range, "range", builder) return false;
if !serialize(s.max_health, "max_health", builder) return false;
if !serialize(s.square, "square", builder) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:158.
//
if !unserialize(*s.name, handler) return false;
if !unserialize(*s.team, handler) return false;
if !unserialize(*s.sprite_index, handler) return false;
if !unserialize(*s.unit_flags, handler) return false;
if !unserialize(*s.movement, handler) return false;
if !unserialize(*s.range, handler) return false;
if !unserialize(*s.max_health, handler) return false;
if !unserialize(*s.square, handler) return false;
