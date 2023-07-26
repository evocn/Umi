// Workspace: Tactics Workspace
//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:227.
//
if !unserialize(*s.name, handler) return false;
if !unserialize(*s.team, handler) return false;
if !unserialize(*s.square, handler) return false;
if !unserialize(*s.ai, handler) return false;
if !unserialize(*s.direction, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:227.
//
if !unserialize(*s.name, handler) return false;
if !unserialize(*s.description, handler) return false;
if !unserialize(*s.sprite_index, handler) return false;
if !unserialize(*s.max_health, handler) return false;
if !unserialize(*s.base_armor, handler) return false;
if !unserialize(*s.movement, handler) return false;
if !unserialize(*s.flags, handler) return false;
if !unserialize(*s.primary_active, handler) return false;
if !unserialize(*s.secondary_active, handler) return false;
if !unserialize(*s.primary, handler) return false;
if !unserialize(*s.secondary, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:103.
//
if !serialize(s.name, "name", builder) return false;
if !serialize(s.sprite_index, "sprite_index", builder) return false;
if !serialize(s.targeting, "targeting", builder) return false;
if !serialize(s.min_range, "min_range", builder) return false;
if !serialize(s.max_range, "max_range", builder) return false;
if !serialize(s.damage, "damage", builder) return false;
if !serialize(s.bonus_damage, "bonus_damage", builder) return false;
if !serialize(s.effect, "effect", builder) return false;
if !serialize(s.push_orientation, "push_orientation", builder) return false;
if !serialize(s.special, "special", builder) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:227.
//
if !unserialize(*s.name, handler) return false;
if !unserialize(*s.sprite_index, handler) return false;
if !unserialize(*s.targeting, handler) return false;
if !unserialize(*s.min_range, handler) return false;
if !unserialize(*s.max_range, handler) return false;
if !unserialize(*s.damage, handler) return false;
if !unserialize(*s.bonus_damage, handler) return false;
if !unserialize(*s.effect, handler) return false;
if !unserialize(*s.push_orientation, handler) return false;
if !unserialize(*s.special, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:103.
//
if !serialize(s.kind, "kind", builder) return false;
if !serialize(s.strength, "strength", builder) return false;
if !serialize(s.duration, "duration", builder) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:227.
//
if !unserialize(*s.kind, handler) return false;
if !unserialize(*s.strength, handler) return false;
if !unserialize(*s.duration, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:103.
//
if !serialize(s.name, "name", builder) return false;
if !serialize(s.team, "team", builder) return false;
if !serialize(s.square, "square", builder) return false;
if !serialize(s.ai, "ai", builder) return false;
if !serialize(s.direction, "direction", builder) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/tactics/src//serialization.jai:103.
//
if !serialize(s.name, "name", builder) return false;
if !serialize(s.description, "description", builder) return false;
if !serialize(s.sprite_index, "sprite_index", builder) return false;
if !serialize(s.max_health, "max_health", builder) return false;
if !serialize(s.base_armor, "base_armor", builder) return false;
if !serialize(s.movement, "movement", builder) return false;
if !serialize(s.flags, "flags", builder) return false;
if !serialize(s.primary_active, "primary_active", builder) return false;
if !serialize(s.secondary_active, "secondary_active", builder) return false;
if !serialize(s.primary, "primary", builder) return false;
if !serialize(s.secondary, "secondary", builder) return false;
