#if OS == .WINDOWS {
    #load "windows.jai";
} else #if (OS == .LINUX) || (OS == .MACOS) {
    #load "unix.jai";
} else #if OS == .PS5 {
    #load "ps5.jai";
}
