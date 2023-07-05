// Workspace: Tactics Workspace
//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:216.
//
if !unserialize(*s.entity, handler) return false;
if !unserialize(*s.unit_flags, handler) return false;
if !unserialize(*s.team, handler) return false;
if !unserialize(*s.direction, handler) return false;
if !unserialize(*s.square, handler) return false;
if !unserialize(*s.movement, handler) return false;
if !unserialize(*s.range, handler) return false;
if !unserialize(*s.health, handler) return false;
if !unserialize(*s.max_health, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:77.
//
if !serialize(s.entity, "entity", builder) return false;
if !serialize(s.unit_flags, "unit_flags", builder) return false;
if !serialize(s.team, "team", builder) return false;
if !serialize(s.direction, "direction", builder) return false;
if !serialize(s.square, "square", builder) return false;
if !serialize(s.movement, "movement", builder) return false;
if !serialize(s.range, "range", builder) return false;
if !serialize(s.health, "health", builder) return false;
if !serialize(s.max_health, "max_health", builder) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:77.
//
if !serialize(s.kind, "kind", builder) return false;
if !serialize(s.serial, "serial", builder) return false;
if !serialize(s.name, "name", builder) return false;
if !serialize(s.flags, "flags", builder) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:216.
//
if !unserialize(*s.kind, handler) return false;
if !unserialize(*s.serial, handler) return false;
if !unserialize(*s.name, handler) return false;
if !unserialize(*s.flags, handler) return false;
