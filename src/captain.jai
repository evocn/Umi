// Umi
// Captain
// Alex Hartford
// July 2023

Captain :: enum {
    NONE;
    AKI;
    OJII;
    YOUNG_TAKEDA;
    TAKEDA;
    // Boarding does double damage

    ARUKAHIME;

    HARUHACHI;

    MOTONARI;
    YOSHITAKA;
    // Double dice results
    LIMAHONG;
    // ???

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

        case .ARUKAHIME;    return "arukahime";
        case .HARUHACHI;    return "haruhachi";

        case .MOTONARI;     return "motonari";
        case .YOSHITAKA;    return "yoshitaka";
        case .LIMAHONG;     return "limahong";

        case .STRATEGIST;   return "";
        case .HOLY;         return "";
        case .SHAMAN;       return "";
    }
}

get_captain_description :: (captain: Captain) -> string {
    if #complete captain == {
        case .NONE;         return "";
        case .AKI;          return "Repairs are twice as effective.";
        case .OJII;         return "+2 Movement.";
        case .YOUNG_TAKEDA; return "Has potential.";
        case .TAKEDA;       return "Boarding strength is doubled.";

        case .ARUKAHIME;    return "Bow attacks deal double.";
        case .HARUHACHI;    return "+2 on Artillery attacks.";

        case .YOSHITAKA;    return "";
        case .MOTONARI;     return "";
        case .LIMAHONG;     return "";

        case .STRATEGIST;   return "";
        case .HOLY;         return "";
        case .SHAMAN;       return "";
    }
}

get_captains_in_hold_string :: (hold: [..] Captain) -> string {
    builder : String_Builder;
    defer free_buffers(*builder);

    append(*builder, "Hold:");

    for hold {
        name := tprint(" %", it);
        append(*builder, copy_string(name));
    }
    append(*builder, ".");

    return builder_to_string(*builder);
}
