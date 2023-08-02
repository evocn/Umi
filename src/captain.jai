// Umi
// Captain
// Alex Hartford
// July 2023

Captain :: enum {
    NONE;
    AKI;
    // Repair is doubled.
    OJII;
    // More movement?
    YOUNG_TAKEDA;
    // Boarding strength is doubled.
    TAKEDA;
    // Boarding strength is doubled.

    KUKI;
    // Something really annoying.

    SAMURAI;
    // Boarding does double damage
    PIRATE;
    // ???
    WARLORD;
    // Double dice results
    STRATEGIST;
    // Can use both abilities each round.
    HOLY;
    // Passive buff to all adjacent units.
    SHAMAN;
    // Double movement speed each round. Can split it up.
}

get_captain_name :: (captain: Captain) -> string {
    if #complete captain == {
        case .NONE;         return "";
        case .AKI;          return "aki";
        case .OJII;         return "ojii";
        case .YOUNG_TAKEDA; return "young takeda";
        case .TAKEDA;       return "takeda";

        case .KUKI;         return "kuki";

        case .SAMURAI;      return "";
        case .PIRATE;       return "";
        case .WARLORD;      return "";
        case .STRATEGIST;   return "";
        case .HOLY;         return "";
        case .SHAMAN;       return "";
    }
}
