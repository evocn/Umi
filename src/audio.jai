// Umi
// Audio
// Alex Hartford
// July 2023

load_audio_file :: (name : string) -> *Mixer_Sound_Data {

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *audio_pool;

    data : *Mixer_Sound_Data = null;

    file_data, success := read_entire_file(name);
    if !success return null;

    has_extension :: (name: string, extension: string) -> bool {
        if name.count < extension.count  return false;
        test := name;
        advance(*test, name.count - extension.count);
        return test == extension;
    }

    if has_extension(name, "wav") {
        data = New(Mixer_Sound_Data, allocator=a);
        data.name = copy_string(name, allocator=a);
        data.buffer = copy_string(file_data, allocator=a);
        free(file_data.data);

        format, samples, success=, extra := get_wav_header(data.buffer);
        if !success {
            log_error("Unable to parse '%' as wav.\n", data.full_path);
            return data;
        }

        if format.wFormatTag == WAVE_FORMAT_PCM {
            data.type                     = .LINEAR_SAMPLE_ARRAY;
            data.nchannels                = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = samples.count/2;
        } else if format.wFormatTag == WAVE_FORMAT_DVI_ADPCM {
            data.type             = .ADPCM_COMPRESSED;
            data.wSamplesPerBlock = extra.wSamplesPerBlock;
            data.nBlockAlign      = format.nBlockAlign;

            data.nchannels = cast(u16) format.nChannels;
            // The value in the FACT chunk is number of samples by time.
            data.nsamples_times_nchannels = extra.wSamplesAccordingToFactChunk * data.nchannels;
        } else {
            assert(false);
        }

        data.samples       = cast(*s16) samples.data;
        data.sampling_rate = cast(u32) format.nSamplesPerSec;
    } else if has_extension(name, "ogg") {
        data = New(Mixer_Sound_Data, allocator=a);
        data.name   = copy_string(name, allocator=a);
        data.buffer = copy_string(file_data, allocator=a);
        free(file_data.data);
        data.type   = .OGG_COMPRESSED;
    } else {
        // Unsupported format.
    }

    return data;
}

play_sound :: (data: *Mixer_Sound_Data, perturb: bool = true) -> *Sound_Stream {
    stream := make_stream(sound_player, data);

    if stream {
        stream.sound_data = data;
    }

    if perturb && stream {
        stream.user_volume_scale = random_get_within_range(0.7, 1.0);
        stream.desired_rate = random_get_within_range(0.7, 1.22);
    }

    stream.repeat_end_position = (data.nsamples_times_nchannels / data.nchannels);

    return stream;
}

play_sfx :: (name : string) {
    sound, success := table_find(*sfx, name);
    if !success {
        log_error("Unable to find sfx in our table: %.\n", name);
        return;
    }

    stream := play_sound(sound);
    if stream {
        stream.category = .PROPS;
    }
}

play_music :: (name : string) {
    full_path := tprint("%/%.ogg", music_path, name);

    music = load_audio_file(full_path);

    if !music {
        log_error("Could not load music file: %\n", full_path);
        assert(false);
    }

    stream := play_sound(music, false);

    if stream {
        stream.flags   |= .REPEATING;
        stream.category = .MUSIC;
        //stream.user_volume_scale *= 1.0;
    }
}

// Move sound streams forward by dt.
update_sound_player :: (dt: float) {
    lock(*sound_player.sound_mutex);
    defer unlock(*sound_player.sound_mutex);

    pre_entity_update(sound_player);

    // @Incomplete We're not removing sound streams once they're consumed.
    for sound_player.streams {
        it.marked = true;
    }

    post_entity_update(sound_player, dt);
}

