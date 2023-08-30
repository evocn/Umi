// Umi
// Main
// Alex Hartford
// August 2023

weather : Weather = .DAY;

Weather :: enum #complete {
    DAY;
    NIGHT;
    STORM;
}

parse_weather :: (str: string) -> Weather {
    if str == {
        case "day";   return .DAY;
        case "night"; return .NIGHT;
        case "storm"; return .STORM;
    }

    log_error("Bad weather string: %\n", str);
    return .DAY;
}
