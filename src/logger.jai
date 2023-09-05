// Umi
// Logger
// Alex Hartford
// August 2023

log_file : File;

umi_logger :: (message: string, data: *void, info: Log_Info) {
    final_message := message;
    if message && message[message.count-1] != #char "\n"
        final_message = tprint("%\n", message);

    write_string(final_message);

    // Write to the log file as well.
    success := file_write(*log_file, final_message);
    if !success {
        print("Couldn't write to our log file!\n");
    }
}


//
// If we ever want to pass log data, here's what it looks like:
/*
Logger_Data :: struct {
    prefix : string;
}

Serialization_Logger :: Logger_Data.{prefix="[Serialization]"};
*/
