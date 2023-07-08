// Tactics
// Audio
// Alex Hartford
// July 2023

load_audio_file :: (name : string) -> *Mixer_Sound_Data {
    data : *Mixer_Sound_Data = null;

    file_data, success := File.read_entire_file(name);
    if !success return data;

    has_extension :: (name: string, extension: string) -> bool {
        if name.count < extension.count  return false;
        test := name;
        advance(*test, name.count - extension.count);
        return test == extension;
    }

    if has_extension(name, "wav") {
        data = New(Mixer_Sound_Data);
        data.name = copy_string(name);
        data.buffer = file_data;

        format, samples, success2, extra := Wav_File.get_wav_header(data.buffer);
        if !success2 {
            log("Unable to parse '%' as wav.\n", data.full_path);
            return data;
        }

        if format.wFormatTag == Wav_File.WAVE_FORMAT_PCM {
            data.type = Mixer_Sound_Data.Type.LINEAR_SAMPLE_ARRAY;
            data.nchannels = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = samples.count/2;
        } else if format.wFormatTag == Wav_File.WAVE_FORMAT_DVI_ADPCM {
            data.type = Mixer_Sound_Data.Type.ADPCM_COMPRESSED;
            data.wSamplesPerBlock = extra.wSamplesPerBlock;
            data.nBlockAlign = format.nBlockAlign;

            data.nchannels = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = extra.wSamplesAccordingToFactChunk * data.nchannels;
        } else {
            assert(false);
        }

        data.samples = cast(*s16) samples.data;
        data.sampling_rate = cast(u32) format.nSamplesPerSec;
    } else if has_extension(name, "ogg") {
        data = New(Mixer_Sound_Data);
        data.name = copy_string(name);
        data.buffer = file_data;
        data.type = Mixer_Sound_Data.Type.OGG_COMPRESSED;
    }
    else {
        assert(false, "Unsupported audio format.\n");
    }

    return data;
}

play_sound :: (name : string) {
    pointer, ok := table_find(*sounds, name);
    if !ok {
        log_error("Trying to play sound % which is not loaded in the sounds table.\n", name);
        return;
    }
    play_sound(pointer);
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
        stream.user_volume_scale *= 0.2;
    }
}

play_sound :: (data: *Mixer_Sound_Data, perturb: bool = true) -> *Sound_Stream {
    stream := make_stream(sound_player, data);

    if stream {
        stream.sound_data = data;
    }

    if perturb && stream {
        stream.user_volume_scale = Random.random_get_within_range(0.7, 1.0);
        stream.desired_rate = Random.random_get_within_range(0.7, 1.22);
    }

    stream.repeat_end_position = cast(int)(data.sampling_rate * 234.475);  // @Temporary @Hack! We do not get the duration by default from an ogg file...
  
    return stream;
}

update_sound_player :: (dt: float) {
    // Move sound streams forward by dt.
    Thread.lock(*sound_player.sound_mutex);
    defer Thread.unlock(*sound_player.sound_mutex);

    pre_entity_update(sound_player);

    // @Incomplete We're not removing sound streams once they're consumed.
    for sound_player.streams {
        it.marked = true;
    }

    post_entity_update(sound_player, dt);
}
