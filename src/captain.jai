// Tactics
// Captain
// Alex Hartford
// July 2023

Captain :: enum {
    NONE;
    SAMURAI;
    // Boarding does double damage
    WARLORD;
    // Double dice results
    STRATEGIST;
    // Can use both abilities each round.
    KUKI;
    // Something really annoying.
    HOLY;
    // Passive buff to all adjacent units.
    OJII;
    // Two extra turns per round.
    YOUNG_TAKEDA;
    // Can inspire another vessel each round. (Probably best if it happens when you repair?)
    SHAMAN;
    // Double movement speed each round. Can split it up.
}

get_captain_name :: (captain: Captain) -> string {
    if #complete captain == {
        case .NONE;         return "";
        case .SAMURAI;      return "";
        case .WARLORD;      return "";
        case .STRATEGIST;   return "";
        case .KUKI;         return "kuki";
        case .HOLY;         return "";
        case .OJII;         return "ojii";
        case .YOUNG_TAKEDA; return "young takeda";
        case .SHAMAN;       return "";
    }
}
