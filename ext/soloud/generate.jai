
#run generate_bindings();

generate_bindings :: () -> bool {
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        #if OS == .WINDOWS {
            output_filename          = "windows.jai";
        } else #if OS == .LINUX {
            output_filename          = "linux.jai";
        } else #if OS == .MACOS {
            // @ToDo: Determine dynamically? Customize?
            array_add(*system_include_paths, "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include");
            output_filename          = "macos.jai";
        } else {
            assert(false);
        }

        array_add(*libpaths,       ".");
        array_add(*libnames,      "soloud");
        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        array_add(*source_files,  "soloud_c.h");
        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");
        log_unsupported = true;
        generate_compile_time_struct_checks = true;
        strip_flags = 0;
        // strip_flags &= ~(Strip_Flags.CONSTRUCTORS | .DESTRUCTORS);
    }

    return generate_bindings(opts, output_filename);
}

#import "Basic";
#import "Bindings_Generator";
