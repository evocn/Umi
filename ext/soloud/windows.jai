//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



// Collected enumerations
SOLOUD_ENUMS :: enum s32 {
    SOLOUD_AUTO                    :: 0;
    SOLOUD_SDL1                    :: 1;
    SOLOUD_SDL2                    :: 2;
    SOLOUD_PORTAUDIO               :: 3;
    SOLOUD_WINMM                   :: 4;
    SOLOUD_XAUDIO2                 :: 5;
    SOLOUD_WASAPI                  :: 6;
    SOLOUD_ALSA                    :: 7;
    SOLOUD_JACK                    :: 8;
    SOLOUD_OSS                     :: 9;
    SOLOUD_OPENAL                  :: 10;
    SOLOUD_COREAUDIO               :: 11;
    SOLOUD_OPENSLES                :: 12;
    SOLOUD_VITA_HOMEBREW           :: 13;
    SOLOUD_MINIAUDIO               :: 14;
    SOLOUD_NOSOUND                 :: 15;
    SOLOUD_NULLDRIVER              :: 16;
    SOLOUD_BACKEND_MAX             :: 17;
    SOLOUD_CLIP_ROUNDOFF           :: 1;
    SOLOUD_ENABLE_VISUALIZATION    :: 2;
    SOLOUD_LEFT_HANDED_3D          :: 4;
    SOLOUD_NO_FPU_REGISTER_CHANGE  :: 8;
    BASSBOOSTFILTER_WET            :: 0;
    BASSBOOSTFILTER_BOOST          :: 1;
    BIQUADRESONANTFILTER_LOWPASS   :: 0;
    BIQUADRESONANTFILTER_HIGHPASS  :: 1;
    BIQUADRESONANTFILTER_BANDPASS  :: 2;
    BIQUADRESONANTFILTER_WET       :: 0;
    BIQUADRESONANTFILTER_TYPE      :: 1;
    BIQUADRESONANTFILTER_FREQUENCY :: 2;
    BIQUADRESONANTFILTER_RESONANCE :: 3;
    ECHOFILTER_WET                 :: 0;
    ECHOFILTER_DELAY               :: 1;
    ECHOFILTER_DECAY               :: 2;
    ECHOFILTER_FILTER              :: 3;
    FLANGERFILTER_WET              :: 0;
    FLANGERFILTER_DELAY            :: 1;
    FLANGERFILTER_FREQ             :: 2;
    FREEVERBFILTER_WET             :: 0;
    FREEVERBFILTER_FREEZE          :: 1;
    FREEVERBFILTER_ROOMSIZE        :: 2;
    FREEVERBFILTER_DAMP            :: 3;
    FREEVERBFILTER_WIDTH           :: 4;
    LOFIFILTER_WET                 :: 0;
    LOFIFILTER_SAMPLERATE          :: 1;
    LOFIFILTER_BITDEPTH            :: 2;
    NOISE_WHITE                    :: 0;
    NOISE_PINK                     :: 1;
    NOISE_BROWNISH                 :: 2;
    NOISE_BLUEISH                  :: 3;
    ROBOTIZEFILTER_WET             :: 0;
    ROBOTIZEFILTER_FREQ            :: 1;
    ROBOTIZEFILTER_WAVE            :: 2;
    SFXR_COIN                      :: 0;
    SFXR_LASER                     :: 1;
    SFXR_EXPLOSION                 :: 2;
    SFXR_POWERUP                   :: 3;
    SFXR_HURT                      :: 4;
    SFXR_JUMP                      :: 5;
    SFXR_BLIP                      :: 6;
    SPEECH_KW_SAW                  :: 0;
    SPEECH_KW_TRIANGLE             :: 1;
    SPEECH_KW_SIN                  :: 2;
    SPEECH_KW_SQUARE               :: 3;
    SPEECH_KW_PULSE                :: 4;
    SPEECH_KW_NOISE                :: 5;
    SPEECH_KW_WARBLE               :: 6;
    VIC_PAL                        :: 0;
    VIC_NTSC                       :: 1;
    VIC_BASS                       :: 0;
    VIC_ALTO                       :: 1;
    VIC_SOPRANO                    :: 2;
    VIC_NOISE                      :: 3;
    VIC_MAX_REGS                   :: 4;
    WAVESHAPERFILTER_WET           :: 0;
    WAVESHAPERFILTER_AMOUNT        :: 1;
}

// Object handle typedefs
AlignedFloatBuffer :: *void;
TinyAlignedFloatBuffer :: *void;
Soloud :: *void;
AudioCollider :: *void;
AudioAttenuator :: *void;
AudioSource :: *void;
BassboostFilter :: *void;
BiquadResonantFilter :: *void;
Bus :: *void;
DCRemovalFilter :: *void;
EchoFilter :: *void;
Fader :: *void;
FFTFilter :: *void;
Filter :: *void;
FlangerFilter :: *void;
FreeverbFilter :: *void;
LofiFilter :: *void;
Monotone :: *void;
Noise :: *void;
Openmpt :: *void;
Queue :: *void;
RobotizeFilter :: *void;
Sfxr :: *void;
Speech :: *void;
TedSid :: *void;
Vic :: *void;
Vizsn :: *void;
Wav :: *void;
WaveShaperFilter :: *void;
WavStream :: *void;
File :: *void;

/*
* Soloud
*/
Soloud_destroy :: (aSoloud: *Soloud) -> void #foreign soloud;
Soloud_create :: () -> *Soloud #foreign soloud;
Soloud_init :: (aSoloud: *Soloud) -> s32 #foreign soloud;
Soloud_initEx :: (aSoloud: *Soloud, aFlags: u32, aBackend: u32, aSamplerate: u32, aBufferSize: u32, aChannels: u32) -> s32 #foreign soloud;
Soloud_deinit :: (aSoloud: *Soloud) -> void #foreign soloud;
Soloud_getVersion :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_getErrorString :: (aSoloud: *Soloud, aErrorCode: s32) -> *u8 #foreign soloud;
Soloud_getBackendId :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_getBackendString :: (aSoloud: *Soloud) -> *u8 #foreign soloud;
Soloud_getBackendChannels :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_getBackendSamplerate :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_getBackendBufferSize :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_setSpeakerPosition :: (aSoloud: *Soloud, aChannel: u32, aX: float, aY: float, aZ: float) -> s32 #foreign soloud;
Soloud_getSpeakerPosition :: (aSoloud: *Soloud, aChannel: u32, aX: *float, aY: *float, aZ: *float) -> s32 #foreign soloud;
Soloud_play :: (aSoloud: *Soloud, aSound: *AudioSource) -> u32 #foreign soloud;
Soloud_playEx :: (aSoloud: *Soloud, aSound: *AudioSource, aVolume: float, aPan: float, aPaused: s32, aBus: u32) -> u32 #foreign soloud;
Soloud_playClocked :: (aSoloud: *Soloud, aSoundTime: float64, aSound: *AudioSource) -> u32 #foreign soloud;
Soloud_playClockedEx :: (aSoloud: *Soloud, aSoundTime: float64, aSound: *AudioSource, aVolume: float, aPan: float, aBus: u32) -> u32 #foreign soloud;
Soloud_play3d :: (aSoloud: *Soloud, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float) -> u32 #foreign soloud;
Soloud_play3dEx :: (aSoloud: *Soloud, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float, aVelX: float, aVelY: float, aVelZ: float, aVolume: float, aPaused: s32, aBus: u32) -> u32 #foreign soloud;
Soloud_play3dClocked :: (aSoloud: *Soloud, aSoundTime: float64, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float) -> u32 #foreign soloud;
Soloud_play3dClockedEx :: (aSoloud: *Soloud, aSoundTime: float64, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float, aVelX: float, aVelY: float, aVelZ: float, aVolume: float, aBus: u32) -> u32 #foreign soloud;
Soloud_playBackground :: (aSoloud: *Soloud, aSound: *AudioSource) -> u32 #foreign soloud;
Soloud_playBackgroundEx :: (aSoloud: *Soloud, aSound: *AudioSource, aVolume: float, aPaused: s32, aBus: u32) -> u32 #foreign soloud;
Soloud_seek :: (aSoloud: *Soloud, aVoiceHandle: u32, aSeconds: float64) -> s32 #foreign soloud;
Soloud_stop :: (aSoloud: *Soloud, aVoiceHandle: u32) -> void #foreign soloud;
Soloud_stopAll :: (aSoloud: *Soloud) -> void #foreign soloud;
Soloud_stopAudioSource :: (aSoloud: *Soloud, aSound: *AudioSource) -> void #foreign soloud;
Soloud_countAudioSource :: (aSoloud: *Soloud, aSound: *AudioSource) -> s32 #foreign soloud;
Soloud_setFilterParameter :: (aSoloud: *Soloud, aVoiceHandle: u32, aFilterId: u32, aAttributeId: u32, aValue: float) -> void #foreign soloud;
Soloud_getFilterParameter :: (aSoloud: *Soloud, aVoiceHandle: u32, aFilterId: u32, aAttributeId: u32) -> float #foreign soloud;
Soloud_fadeFilterParameter :: (aSoloud: *Soloud, aVoiceHandle: u32, aFilterId: u32, aAttributeId: u32, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_oscillateFilterParameter :: (aSoloud: *Soloud, aVoiceHandle: u32, aFilterId: u32, aAttributeId: u32, aFrom: float, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_getStreamTime :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float64 #foreign soloud;
Soloud_getStreamPosition :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float64 #foreign soloud;
Soloud_getPause :: (aSoloud: *Soloud, aVoiceHandle: u32) -> s32 #foreign soloud;
Soloud_getVolume :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float #foreign soloud;
Soloud_getOverallVolume :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float #foreign soloud;
Soloud_getPan :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float #foreign soloud;
Soloud_getSamplerate :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float #foreign soloud;
Soloud_getProtectVoice :: (aSoloud: *Soloud, aVoiceHandle: u32) -> s32 #foreign soloud;
Soloud_getActiveVoiceCount :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_getVoiceCount :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_isValidVoiceHandle :: (aSoloud: *Soloud, aVoiceHandle: u32) -> s32 #foreign soloud;
Soloud_getRelativePlaySpeed :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float #foreign soloud;
Soloud_getPostClipScaler :: (aSoloud: *Soloud) -> float #foreign soloud;
Soloud_getGlobalVolume :: (aSoloud: *Soloud) -> float #foreign soloud;
Soloud_getMaxActiveVoiceCount :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_getLooping :: (aSoloud: *Soloud, aVoiceHandle: u32) -> s32 #foreign soloud;
Soloud_getLoopPoint :: (aSoloud: *Soloud, aVoiceHandle: u32) -> float64 #foreign soloud;
Soloud_setLoopPoint :: (aSoloud: *Soloud, aVoiceHandle: u32, aLoopPoint: float64) -> void #foreign soloud;
Soloud_setLooping :: (aSoloud: *Soloud, aVoiceHandle: u32, aLooping: s32) -> void #foreign soloud;
Soloud_setMaxActiveVoiceCount :: (aSoloud: *Soloud, aVoiceCount: u32) -> s32 #foreign soloud;
Soloud_setInaudibleBehavior :: (aSoloud: *Soloud, aVoiceHandle: u32, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Soloud_setGlobalVolume :: (aSoloud: *Soloud, aVolume: float) -> void #foreign soloud;
Soloud_setPostClipScaler :: (aSoloud: *Soloud, aScaler: float) -> void #foreign soloud;
Soloud_setPause :: (aSoloud: *Soloud, aVoiceHandle: u32, aPause: s32) -> void #foreign soloud;
Soloud_setPauseAll :: (aSoloud: *Soloud, aPause: s32) -> void #foreign soloud;
Soloud_setRelativePlaySpeed :: (aSoloud: *Soloud, aVoiceHandle: u32, aSpeed: float) -> s32 #foreign soloud;
Soloud_setProtectVoice :: (aSoloud: *Soloud, aVoiceHandle: u32, aProtect: s32) -> void #foreign soloud;
Soloud_setSamplerate :: (aSoloud: *Soloud, aVoiceHandle: u32, aSamplerate: float) -> void #foreign soloud;
Soloud_setPan :: (aSoloud: *Soloud, aVoiceHandle: u32, aPan: float) -> void #foreign soloud;
Soloud_setPanAbsolute :: (aSoloud: *Soloud, aVoiceHandle: u32, aLVolume: float, aRVolume: float) -> void #foreign soloud;
Soloud_setPanAbsoluteEx :: (aSoloud: *Soloud, aVoiceHandle: u32, aLVolume: float, aRVolume: float, aLBVolume: float, aRBVolume: float, aCVolume: float, aSVolume: float) -> void #foreign soloud;
Soloud_setVolume :: (aSoloud: *Soloud, aVoiceHandle: u32, aVolume: float) -> void #foreign soloud;
Soloud_setDelaySamples :: (aSoloud: *Soloud, aVoiceHandle: u32, aSamples: u32) -> void #foreign soloud;
Soloud_fadeVolume :: (aSoloud: *Soloud, aVoiceHandle: u32, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_fadePan :: (aSoloud: *Soloud, aVoiceHandle: u32, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_fadeRelativePlaySpeed :: (aSoloud: *Soloud, aVoiceHandle: u32, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_fadeGlobalVolume :: (aSoloud: *Soloud, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_schedulePause :: (aSoloud: *Soloud, aVoiceHandle: u32, aTime: float64) -> void #foreign soloud;
Soloud_scheduleStop :: (aSoloud: *Soloud, aVoiceHandle: u32, aTime: float64) -> void #foreign soloud;
Soloud_oscillateVolume :: (aSoloud: *Soloud, aVoiceHandle: u32, aFrom: float, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_oscillatePan :: (aSoloud: *Soloud, aVoiceHandle: u32, aFrom: float, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_oscillateRelativePlaySpeed :: (aSoloud: *Soloud, aVoiceHandle: u32, aFrom: float, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_oscillateGlobalVolume :: (aSoloud: *Soloud, aFrom: float, aTo: float, aTime: float64) -> void #foreign soloud;
Soloud_setGlobalFilter :: (aSoloud: *Soloud, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Soloud_setVisualizationEnable :: (aSoloud: *Soloud, aEnable: s32) -> void #foreign soloud;
Soloud_calcFFT :: (aSoloud: *Soloud) -> *float #foreign soloud;
Soloud_getWave :: (aSoloud: *Soloud) -> *float #foreign soloud;
Soloud_getApproximateVolume :: (aSoloud: *Soloud, aChannel: u32) -> float #foreign soloud;
Soloud_getLoopCount :: (aSoloud: *Soloud, aVoiceHandle: u32) -> u32 #foreign soloud;
Soloud_getInfo :: (aSoloud: *Soloud, aVoiceHandle: u32, aInfoKey: u32) -> float #foreign soloud;
Soloud_createVoiceGroup :: (aSoloud: *Soloud) -> u32 #foreign soloud;
Soloud_destroyVoiceGroup :: (aSoloud: *Soloud, aVoiceGroupHandle: u32) -> s32 #foreign soloud;
Soloud_addVoiceToGroup :: (aSoloud: *Soloud, aVoiceGroupHandle: u32, aVoiceHandle: u32) -> s32 #foreign soloud;
Soloud_isVoiceGroup :: (aSoloud: *Soloud, aVoiceGroupHandle: u32) -> s32 #foreign soloud;
Soloud_isVoiceGroupEmpty :: (aSoloud: *Soloud, aVoiceGroupHandle: u32) -> s32 #foreign soloud;
Soloud_update3dAudio :: (aSoloud: *Soloud) -> void #foreign soloud;
Soloud_set3dSoundSpeed :: (aSoloud: *Soloud, aSpeed: float) -> s32 #foreign soloud;
Soloud_get3dSoundSpeed :: (aSoloud: *Soloud) -> float #foreign soloud;
Soloud_set3dListenerParameters :: (aSoloud: *Soloud, aPosX: float, aPosY: float, aPosZ: float, aAtX: float, aAtY: float, aAtZ: float, aUpX: float, aUpY: float, aUpZ: float) -> void #foreign soloud;
Soloud_set3dListenerParametersEx :: (aSoloud: *Soloud, aPosX: float, aPosY: float, aPosZ: float, aAtX: float, aAtY: float, aAtZ: float, aUpX: float, aUpY: float, aUpZ: float, aVelocityX: float, aVelocityY: float, aVelocityZ: float) -> void #foreign soloud;
Soloud_set3dListenerPosition :: (aSoloud: *Soloud, aPosX: float, aPosY: float, aPosZ: float) -> void #foreign soloud;
Soloud_set3dListenerAt :: (aSoloud: *Soloud, aAtX: float, aAtY: float, aAtZ: float) -> void #foreign soloud;
Soloud_set3dListenerUp :: (aSoloud: *Soloud, aUpX: float, aUpY: float, aUpZ: float) -> void #foreign soloud;
Soloud_set3dListenerVelocity :: (aSoloud: *Soloud, aVelocityX: float, aVelocityY: float, aVelocityZ: float) -> void #foreign soloud;
Soloud_set3dSourceParameters :: (aSoloud: *Soloud, aVoiceHandle: u32, aPosX: float, aPosY: float, aPosZ: float) -> void #foreign soloud;
Soloud_set3dSourceParametersEx :: (aSoloud: *Soloud, aVoiceHandle: u32, aPosX: float, aPosY: float, aPosZ: float, aVelocityX: float, aVelocityY: float, aVelocityZ: float) -> void #foreign soloud;
Soloud_set3dSourcePosition :: (aSoloud: *Soloud, aVoiceHandle: u32, aPosX: float, aPosY: float, aPosZ: float) -> void #foreign soloud;
Soloud_set3dSourceVelocity :: (aSoloud: *Soloud, aVoiceHandle: u32, aVelocityX: float, aVelocityY: float, aVelocityZ: float) -> void #foreign soloud;
Soloud_set3dSourceMinMaxDistance :: (aSoloud: *Soloud, aVoiceHandle: u32, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Soloud_set3dSourceAttenuation :: (aSoloud: *Soloud, aVoiceHandle: u32, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Soloud_set3dSourceDopplerFactor :: (aSoloud: *Soloud, aVoiceHandle: u32, aDopplerFactor: float) -> void #foreign soloud;
Soloud_mix :: (aSoloud: *Soloud, aBuffer: *float, aSamples: u32) -> void #foreign soloud;
Soloud_mixSigned16 :: (aSoloud: *Soloud, aBuffer: *s16, aSamples: u32) -> void #foreign soloud;

/*
* BassboostFilter
*/
BassboostFilter_destroy :: (aBassboostFilter: *BassboostFilter) -> void #foreign soloud;
BassboostFilter_getParamCount :: (aBassboostFilter: *BassboostFilter) -> s32 #foreign soloud;
BassboostFilter_getParamName :: (aBassboostFilter: *BassboostFilter, aParamIndex: u32) -> *u8 #foreign soloud;
BassboostFilter_getParamType :: (aBassboostFilter: *BassboostFilter, aParamIndex: u32) -> u32 #foreign soloud;
BassboostFilter_getParamMax :: (aBassboostFilter: *BassboostFilter, aParamIndex: u32) -> float #foreign soloud;
BassboostFilter_getParamMin :: (aBassboostFilter: *BassboostFilter, aParamIndex: u32) -> float #foreign soloud;
BassboostFilter_setParams :: (aBassboostFilter: *BassboostFilter, aBoost: float) -> s32 #foreign soloud;
BassboostFilter_create :: () -> *BassboostFilter #foreign soloud;

/*
* BiquadResonantFilter
*/
BiquadResonantFilter_destroy :: (aBiquadResonantFilter: *BiquadResonantFilter) -> void #foreign soloud;
BiquadResonantFilter_getParamCount :: (aBiquadResonantFilter: *BiquadResonantFilter) -> s32 #foreign soloud;
BiquadResonantFilter_getParamName :: (aBiquadResonantFilter: *BiquadResonantFilter, aParamIndex: u32) -> *u8 #foreign soloud;
BiquadResonantFilter_getParamType :: (aBiquadResonantFilter: *BiquadResonantFilter, aParamIndex: u32) -> u32 #foreign soloud;
BiquadResonantFilter_getParamMax :: (aBiquadResonantFilter: *BiquadResonantFilter, aParamIndex: u32) -> float #foreign soloud;
BiquadResonantFilter_getParamMin :: (aBiquadResonantFilter: *BiquadResonantFilter, aParamIndex: u32) -> float #foreign soloud;
BiquadResonantFilter_create :: () -> *BiquadResonantFilter #foreign soloud;
BiquadResonantFilter_setParams :: (aBiquadResonantFilter: *BiquadResonantFilter, aType: s32, aFrequency: float, aResonance: float) -> s32 #foreign soloud;

/*
* Bus
*/
Bus_destroy :: (aBus: *Bus) -> void #foreign soloud;
Bus_create :: () -> *Bus #foreign soloud;
Bus_setFilter :: (aBus: *Bus, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Bus_play :: (aBus: *Bus, aSound: *AudioSource) -> u32 #foreign soloud;
Bus_playEx :: (aBus: *Bus, aSound: *AudioSource, aVolume: float, aPan: float, aPaused: s32) -> u32 #foreign soloud;
Bus_playClocked :: (aBus: *Bus, aSoundTime: float64, aSound: *AudioSource) -> u32 #foreign soloud;
Bus_playClockedEx :: (aBus: *Bus, aSoundTime: float64, aSound: *AudioSource, aVolume: float, aPan: float) -> u32 #foreign soloud;
Bus_play3d :: (aBus: *Bus, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float) -> u32 #foreign soloud;
Bus_play3dEx :: (aBus: *Bus, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float, aVelX: float, aVelY: float, aVelZ: float, aVolume: float, aPaused: s32) -> u32 #foreign soloud;
Bus_play3dClocked :: (aBus: *Bus, aSoundTime: float64, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float) -> u32 #foreign soloud;
Bus_play3dClockedEx :: (aBus: *Bus, aSoundTime: float64, aSound: *AudioSource, aPosX: float, aPosY: float, aPosZ: float, aVelX: float, aVelY: float, aVelZ: float, aVolume: float) -> u32 #foreign soloud;
Bus_setChannels :: (aBus: *Bus, aChannels: u32) -> s32 #foreign soloud;
Bus_setVisualizationEnable :: (aBus: *Bus, aEnable: s32) -> void #foreign soloud;
Bus_annexSound :: (aBus: *Bus, aVoiceHandle: u32) -> void #foreign soloud;
Bus_calcFFT :: (aBus: *Bus) -> *float #foreign soloud;
Bus_getWave :: (aBus: *Bus) -> *float #foreign soloud;
Bus_getApproximateVolume :: (aBus: *Bus, aChannel: u32) -> float #foreign soloud;
Bus_getActiveVoiceCount :: (aBus: *Bus) -> u32 #foreign soloud;
Bus_setVolume :: (aBus: *Bus, aVolume: float) -> void #foreign soloud;
Bus_setLooping :: (aBus: *Bus, aLoop: s32) -> void #foreign soloud;
Bus_set3dMinMaxDistance :: (aBus: *Bus, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Bus_set3dAttenuation :: (aBus: *Bus, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Bus_set3dDopplerFactor :: (aBus: *Bus, aDopplerFactor: float) -> void #foreign soloud;
Bus_set3dListenerRelative :: (aBus: *Bus, aListenerRelative: s32) -> void #foreign soloud;
Bus_set3dDistanceDelay :: (aBus: *Bus, aDistanceDelay: s32) -> void #foreign soloud;
Bus_set3dCollider :: (aBus: *Bus, aCollider: *AudioCollider) -> void #foreign soloud;
Bus_set3dColliderEx :: (aBus: *Bus, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Bus_set3dAttenuator :: (aBus: *Bus, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Bus_setInaudibleBehavior :: (aBus: *Bus, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Bus_setLoopPoint :: (aBus: *Bus, aLoopPoint: float64) -> void #foreign soloud;
Bus_getLoopPoint :: (aBus: *Bus) -> float64 #foreign soloud;
Bus_stop :: (aBus: *Bus) -> void #foreign soloud;

/*
* DCRemovalFilter
*/
DCRemovalFilter_destroy :: (aDCRemovalFilter: *DCRemovalFilter) -> void #foreign soloud;
DCRemovalFilter_create :: () -> *DCRemovalFilter #foreign soloud;
DCRemovalFilter_setParams :: (aDCRemovalFilter: *DCRemovalFilter) -> s32 #foreign soloud;
DCRemovalFilter_setParamsEx :: (aDCRemovalFilter: *DCRemovalFilter, aLength: float) -> s32 #foreign soloud;
DCRemovalFilter_getParamCount :: (aDCRemovalFilter: *DCRemovalFilter) -> s32 #foreign soloud;
DCRemovalFilter_getParamName :: (aDCRemovalFilter: *DCRemovalFilter, aParamIndex: u32) -> *u8 #foreign soloud;
DCRemovalFilter_getParamType :: (aDCRemovalFilter: *DCRemovalFilter, aParamIndex: u32) -> u32 #foreign soloud;
DCRemovalFilter_getParamMax :: (aDCRemovalFilter: *DCRemovalFilter, aParamIndex: u32) -> float #foreign soloud;
DCRemovalFilter_getParamMin :: (aDCRemovalFilter: *DCRemovalFilter, aParamIndex: u32) -> float #foreign soloud;

/*
* EchoFilter
*/
EchoFilter_destroy :: (aEchoFilter: *EchoFilter) -> void #foreign soloud;
EchoFilter_getParamCount :: (aEchoFilter: *EchoFilter) -> s32 #foreign soloud;
EchoFilter_getParamName :: (aEchoFilter: *EchoFilter, aParamIndex: u32) -> *u8 #foreign soloud;
EchoFilter_getParamType :: (aEchoFilter: *EchoFilter, aParamIndex: u32) -> u32 #foreign soloud;
EchoFilter_getParamMax :: (aEchoFilter: *EchoFilter, aParamIndex: u32) -> float #foreign soloud;
EchoFilter_getParamMin :: (aEchoFilter: *EchoFilter, aParamIndex: u32) -> float #foreign soloud;
EchoFilter_create :: () -> *EchoFilter #foreign soloud;
EchoFilter_setParams :: (aEchoFilter: *EchoFilter, aDelay: float) -> s32 #foreign soloud;
EchoFilter_setParamsEx :: (aEchoFilter: *EchoFilter, aDelay: float, aDecay: float, aFilter: float) -> s32 #foreign soloud;

/*
* FFTFilter
*/
FFTFilter_destroy :: (aFFTFilter: *FFTFilter) -> void #foreign soloud;
FFTFilter_create :: () -> *FFTFilter #foreign soloud;
FFTFilter_getParamCount :: (aFFTFilter: *FFTFilter) -> s32 #foreign soloud;
FFTFilter_getParamName :: (aFFTFilter: *FFTFilter, aParamIndex: u32) -> *u8 #foreign soloud;
FFTFilter_getParamType :: (aFFTFilter: *FFTFilter, aParamIndex: u32) -> u32 #foreign soloud;
FFTFilter_getParamMax :: (aFFTFilter: *FFTFilter, aParamIndex: u32) -> float #foreign soloud;
FFTFilter_getParamMin :: (aFFTFilter: *FFTFilter, aParamIndex: u32) -> float #foreign soloud;

/*
* FlangerFilter
*/
FlangerFilter_destroy :: (aFlangerFilter: *FlangerFilter) -> void #foreign soloud;
FlangerFilter_getParamCount :: (aFlangerFilter: *FlangerFilter) -> s32 #foreign soloud;
FlangerFilter_getParamName :: (aFlangerFilter: *FlangerFilter, aParamIndex: u32) -> *u8 #foreign soloud;
FlangerFilter_getParamType :: (aFlangerFilter: *FlangerFilter, aParamIndex: u32) -> u32 #foreign soloud;
FlangerFilter_getParamMax :: (aFlangerFilter: *FlangerFilter, aParamIndex: u32) -> float #foreign soloud;
FlangerFilter_getParamMin :: (aFlangerFilter: *FlangerFilter, aParamIndex: u32) -> float #foreign soloud;
FlangerFilter_create :: () -> *FlangerFilter #foreign soloud;
FlangerFilter_setParams :: (aFlangerFilter: *FlangerFilter, aDelay: float, aFreq: float) -> s32 #foreign soloud;

/*
* FreeverbFilter
*/
FreeverbFilter_destroy :: (aFreeverbFilter: *FreeverbFilter) -> void #foreign soloud;
FreeverbFilter_getParamCount :: (aFreeverbFilter: *FreeverbFilter) -> s32 #foreign soloud;
FreeverbFilter_getParamName :: (aFreeverbFilter: *FreeverbFilter, aParamIndex: u32) -> *u8 #foreign soloud;
FreeverbFilter_getParamType :: (aFreeverbFilter: *FreeverbFilter, aParamIndex: u32) -> u32 #foreign soloud;
FreeverbFilter_getParamMax :: (aFreeverbFilter: *FreeverbFilter, aParamIndex: u32) -> float #foreign soloud;
FreeverbFilter_getParamMin :: (aFreeverbFilter: *FreeverbFilter, aParamIndex: u32) -> float #foreign soloud;
FreeverbFilter_create :: () -> *FreeverbFilter #foreign soloud;
FreeverbFilter_setParams :: (aFreeverbFilter: *FreeverbFilter, aMode: float, aRoomSize: float, aDamp: float, aWidth: float) -> s32 #foreign soloud;

/*
* LofiFilter
*/
LofiFilter_destroy :: (aLofiFilter: *LofiFilter) -> void #foreign soloud;
LofiFilter_getParamCount :: (aLofiFilter: *LofiFilter) -> s32 #foreign soloud;
LofiFilter_getParamName :: (aLofiFilter: *LofiFilter, aParamIndex: u32) -> *u8 #foreign soloud;
LofiFilter_getParamType :: (aLofiFilter: *LofiFilter, aParamIndex: u32) -> u32 #foreign soloud;
LofiFilter_getParamMax :: (aLofiFilter: *LofiFilter, aParamIndex: u32) -> float #foreign soloud;
LofiFilter_getParamMin :: (aLofiFilter: *LofiFilter, aParamIndex: u32) -> float #foreign soloud;
LofiFilter_create :: () -> *LofiFilter #foreign soloud;
LofiFilter_setParams :: (aLofiFilter: *LofiFilter, aSampleRate: float, aBitdepth: float) -> s32 #foreign soloud;

/*
* Monotone
*/
Monotone_destroy :: (aMonotone: *Monotone) -> void #foreign soloud;
Monotone_create :: () -> *Monotone #foreign soloud;
Monotone_setParams :: (aMonotone: *Monotone, aHardwareChannels: s32) -> s32 #foreign soloud;
Monotone_setParamsEx :: (aMonotone: *Monotone, aHardwareChannels: s32, aWaveform: s32) -> s32 #foreign soloud;
Monotone_load :: (aMonotone: *Monotone, aFilename: *u8) -> s32 #foreign soloud;
Monotone_loadMem :: (aMonotone: *Monotone, aMem: *u8, aLength: u32) -> s32 #foreign soloud;
Monotone_loadMemEx :: (aMonotone: *Monotone, aMem: *u8, aLength: u32, aCopy: s32, aTakeOwnership: s32) -> s32 #foreign soloud;
Monotone_loadFile :: (aMonotone: *Monotone, aFile: *File) -> s32 #foreign soloud;
Monotone_setVolume :: (aMonotone: *Monotone, aVolume: float) -> void #foreign soloud;
Monotone_setLooping :: (aMonotone: *Monotone, aLoop: s32) -> void #foreign soloud;
Monotone_set3dMinMaxDistance :: (aMonotone: *Monotone, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Monotone_set3dAttenuation :: (aMonotone: *Monotone, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Monotone_set3dDopplerFactor :: (aMonotone: *Monotone, aDopplerFactor: float) -> void #foreign soloud;
Monotone_set3dListenerRelative :: (aMonotone: *Monotone, aListenerRelative: s32) -> void #foreign soloud;
Monotone_set3dDistanceDelay :: (aMonotone: *Monotone, aDistanceDelay: s32) -> void #foreign soloud;
Monotone_set3dCollider :: (aMonotone: *Monotone, aCollider: *AudioCollider) -> void #foreign soloud;
Monotone_set3dColliderEx :: (aMonotone: *Monotone, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Monotone_set3dAttenuator :: (aMonotone: *Monotone, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Monotone_setInaudibleBehavior :: (aMonotone: *Monotone, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Monotone_setLoopPoint :: (aMonotone: *Monotone, aLoopPoint: float64) -> void #foreign soloud;
Monotone_getLoopPoint :: (aMonotone: *Monotone) -> float64 #foreign soloud;
Monotone_setFilter :: (aMonotone: *Monotone, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Monotone_stop :: (aMonotone: *Monotone) -> void #foreign soloud;

/*
* Noise
*/
Noise_destroy :: (aNoise: *Noise) -> void #foreign soloud;
Noise_create :: () -> *Noise #foreign soloud;
Noise_setOctaveScale :: (aNoise: *Noise, aOct0: float, aOct1: float, aOct2: float, aOct3: float, aOct4: float, aOct5: float, aOct6: float, aOct7: float, aOct8: float, aOct9: float) -> void #foreign soloud;
Noise_setType :: (aNoise: *Noise, aType: s32) -> void #foreign soloud;
Noise_setVolume :: (aNoise: *Noise, aVolume: float) -> void #foreign soloud;
Noise_setLooping :: (aNoise: *Noise, aLoop: s32) -> void #foreign soloud;
Noise_set3dMinMaxDistance :: (aNoise: *Noise, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Noise_set3dAttenuation :: (aNoise: *Noise, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Noise_set3dDopplerFactor :: (aNoise: *Noise, aDopplerFactor: float) -> void #foreign soloud;
Noise_set3dListenerRelative :: (aNoise: *Noise, aListenerRelative: s32) -> void #foreign soloud;
Noise_set3dDistanceDelay :: (aNoise: *Noise, aDistanceDelay: s32) -> void #foreign soloud;
Noise_set3dCollider :: (aNoise: *Noise, aCollider: *AudioCollider) -> void #foreign soloud;
Noise_set3dColliderEx :: (aNoise: *Noise, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Noise_set3dAttenuator :: (aNoise: *Noise, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Noise_setInaudibleBehavior :: (aNoise: *Noise, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Noise_setLoopPoint :: (aNoise: *Noise, aLoopPoint: float64) -> void #foreign soloud;
Noise_getLoopPoint :: (aNoise: *Noise) -> float64 #foreign soloud;
Noise_setFilter :: (aNoise: *Noise, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Noise_stop :: (aNoise: *Noise) -> void #foreign soloud;

/*
* Openmpt
*/
Openmpt_destroy :: (aOpenmpt: *Openmpt) -> void #foreign soloud;
Openmpt_create :: () -> *Openmpt #foreign soloud;
Openmpt_load :: (aOpenmpt: *Openmpt, aFilename: *u8) -> s32 #foreign soloud;
Openmpt_loadMem :: (aOpenmpt: *Openmpt, aMem: *u8, aLength: u32) -> s32 #foreign soloud;
Openmpt_loadMemEx :: (aOpenmpt: *Openmpt, aMem: *u8, aLength: u32, aCopy: s32, aTakeOwnership: s32) -> s32 #foreign soloud;
Openmpt_loadFile :: (aOpenmpt: *Openmpt, aFile: *File) -> s32 #foreign soloud;
Openmpt_setVolume :: (aOpenmpt: *Openmpt, aVolume: float) -> void #foreign soloud;
Openmpt_setLooping :: (aOpenmpt: *Openmpt, aLoop: s32) -> void #foreign soloud;
Openmpt_set3dMinMaxDistance :: (aOpenmpt: *Openmpt, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Openmpt_set3dAttenuation :: (aOpenmpt: *Openmpt, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Openmpt_set3dDopplerFactor :: (aOpenmpt: *Openmpt, aDopplerFactor: float) -> void #foreign soloud;
Openmpt_set3dListenerRelative :: (aOpenmpt: *Openmpt, aListenerRelative: s32) -> void #foreign soloud;
Openmpt_set3dDistanceDelay :: (aOpenmpt: *Openmpt, aDistanceDelay: s32) -> void #foreign soloud;
Openmpt_set3dCollider :: (aOpenmpt: *Openmpt, aCollider: *AudioCollider) -> void #foreign soloud;
Openmpt_set3dColliderEx :: (aOpenmpt: *Openmpt, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Openmpt_set3dAttenuator :: (aOpenmpt: *Openmpt, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Openmpt_setInaudibleBehavior :: (aOpenmpt: *Openmpt, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Openmpt_setLoopPoint :: (aOpenmpt: *Openmpt, aLoopPoint: float64) -> void #foreign soloud;
Openmpt_getLoopPoint :: (aOpenmpt: *Openmpt) -> float64 #foreign soloud;
Openmpt_setFilter :: (aOpenmpt: *Openmpt, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Openmpt_stop :: (aOpenmpt: *Openmpt) -> void #foreign soloud;

/*
* Queue
*/
Queue_destroy :: (aQueue: *Queue) -> void #foreign soloud;
Queue_create :: () -> *Queue #foreign soloud;
Queue_play :: (aQueue: *Queue, aSound: *AudioSource) -> s32 #foreign soloud;
Queue_getQueueCount :: (aQueue: *Queue) -> u32 #foreign soloud;
Queue_isCurrentlyPlaying :: (aQueue: *Queue, aSound: *AudioSource) -> s32 #foreign soloud;
Queue_setParamsFromAudioSource :: (aQueue: *Queue, aSound: *AudioSource) -> s32 #foreign soloud;
Queue_setParams :: (aQueue: *Queue, aSamplerate: float) -> s32 #foreign soloud;
Queue_setParamsEx :: (aQueue: *Queue, aSamplerate: float, aChannels: u32) -> s32 #foreign soloud;
Queue_setVolume :: (aQueue: *Queue, aVolume: float) -> void #foreign soloud;
Queue_setLooping :: (aQueue: *Queue, aLoop: s32) -> void #foreign soloud;
Queue_set3dMinMaxDistance :: (aQueue: *Queue, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Queue_set3dAttenuation :: (aQueue: *Queue, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Queue_set3dDopplerFactor :: (aQueue: *Queue, aDopplerFactor: float) -> void #foreign soloud;
Queue_set3dListenerRelative :: (aQueue: *Queue, aListenerRelative: s32) -> void #foreign soloud;
Queue_set3dDistanceDelay :: (aQueue: *Queue, aDistanceDelay: s32) -> void #foreign soloud;
Queue_set3dCollider :: (aQueue: *Queue, aCollider: *AudioCollider) -> void #foreign soloud;
Queue_set3dColliderEx :: (aQueue: *Queue, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Queue_set3dAttenuator :: (aQueue: *Queue, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Queue_setInaudibleBehavior :: (aQueue: *Queue, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Queue_setLoopPoint :: (aQueue: *Queue, aLoopPoint: float64) -> void #foreign soloud;
Queue_getLoopPoint :: (aQueue: *Queue) -> float64 #foreign soloud;
Queue_setFilter :: (aQueue: *Queue, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Queue_stop :: (aQueue: *Queue) -> void #foreign soloud;

/*
* RobotizeFilter
*/
RobotizeFilter_destroy :: (aRobotizeFilter: *RobotizeFilter) -> void #foreign soloud;
RobotizeFilter_getParamCount :: (aRobotizeFilter: *RobotizeFilter) -> s32 #foreign soloud;
RobotizeFilter_getParamName :: (aRobotizeFilter: *RobotizeFilter, aParamIndex: u32) -> *u8 #foreign soloud;
RobotizeFilter_getParamType :: (aRobotizeFilter: *RobotizeFilter, aParamIndex: u32) -> u32 #foreign soloud;
RobotizeFilter_getParamMax :: (aRobotizeFilter: *RobotizeFilter, aParamIndex: u32) -> float #foreign soloud;
RobotizeFilter_getParamMin :: (aRobotizeFilter: *RobotizeFilter, aParamIndex: u32) -> float #foreign soloud;
RobotizeFilter_setParams :: (aRobotizeFilter: *RobotizeFilter, aFreq: float, aWaveform: s32) -> void #foreign soloud;
RobotizeFilter_create :: () -> *RobotizeFilter #foreign soloud;

/*
* Sfxr
*/
Sfxr_destroy :: (aSfxr: *Sfxr) -> void #foreign soloud;
Sfxr_create :: () -> *Sfxr #foreign soloud;
Sfxr_resetParams :: (aSfxr: *Sfxr) -> void #foreign soloud;
Sfxr_loadParams :: (aSfxr: *Sfxr, aFilename: *u8) -> s32 #foreign soloud;
Sfxr_loadParamsMem :: (aSfxr: *Sfxr, aMem: *u8, aLength: u32) -> s32 #foreign soloud;
Sfxr_loadParamsMemEx :: (aSfxr: *Sfxr, aMem: *u8, aLength: u32, aCopy: s32, aTakeOwnership: s32) -> s32 #foreign soloud;
Sfxr_loadParamsFile :: (aSfxr: *Sfxr, aFile: *File) -> s32 #foreign soloud;
Sfxr_loadPreset :: (aSfxr: *Sfxr, aPresetNo: s32, aRandSeed: s32) -> s32 #foreign soloud;
Sfxr_setVolume :: (aSfxr: *Sfxr, aVolume: float) -> void #foreign soloud;
Sfxr_setLooping :: (aSfxr: *Sfxr, aLoop: s32) -> void #foreign soloud;
Sfxr_set3dMinMaxDistance :: (aSfxr: *Sfxr, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Sfxr_set3dAttenuation :: (aSfxr: *Sfxr, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Sfxr_set3dDopplerFactor :: (aSfxr: *Sfxr, aDopplerFactor: float) -> void #foreign soloud;
Sfxr_set3dListenerRelative :: (aSfxr: *Sfxr, aListenerRelative: s32) -> void #foreign soloud;
Sfxr_set3dDistanceDelay :: (aSfxr: *Sfxr, aDistanceDelay: s32) -> void #foreign soloud;
Sfxr_set3dCollider :: (aSfxr: *Sfxr, aCollider: *AudioCollider) -> void #foreign soloud;
Sfxr_set3dColliderEx :: (aSfxr: *Sfxr, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Sfxr_set3dAttenuator :: (aSfxr: *Sfxr, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Sfxr_setInaudibleBehavior :: (aSfxr: *Sfxr, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Sfxr_setLoopPoint :: (aSfxr: *Sfxr, aLoopPoint: float64) -> void #foreign soloud;
Sfxr_getLoopPoint :: (aSfxr: *Sfxr) -> float64 #foreign soloud;
Sfxr_setFilter :: (aSfxr: *Sfxr, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Sfxr_stop :: (aSfxr: *Sfxr) -> void #foreign soloud;

/*
* Speech
*/
Speech_destroy :: (aSpeech: *Speech) -> void #foreign soloud;
Speech_create :: () -> *Speech #foreign soloud;
Speech_setText :: (aSpeech: *Speech, aText: *u8) -> s32 #foreign soloud;
Speech_setParams :: (aSpeech: *Speech) -> s32 #foreign soloud;
Speech_setParamsEx :: (aSpeech: *Speech, aBaseFrequency: u32, aBaseSpeed: float, aBaseDeclination: float, aBaseWaveform: s32) -> s32 #foreign soloud;
Speech_setVolume :: (aSpeech: *Speech, aVolume: float) -> void #foreign soloud;
Speech_setLooping :: (aSpeech: *Speech, aLoop: s32) -> void #foreign soloud;
Speech_set3dMinMaxDistance :: (aSpeech: *Speech, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Speech_set3dAttenuation :: (aSpeech: *Speech, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Speech_set3dDopplerFactor :: (aSpeech: *Speech, aDopplerFactor: float) -> void #foreign soloud;
Speech_set3dListenerRelative :: (aSpeech: *Speech, aListenerRelative: s32) -> void #foreign soloud;
Speech_set3dDistanceDelay :: (aSpeech: *Speech, aDistanceDelay: s32) -> void #foreign soloud;
Speech_set3dCollider :: (aSpeech: *Speech, aCollider: *AudioCollider) -> void #foreign soloud;
Speech_set3dColliderEx :: (aSpeech: *Speech, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Speech_set3dAttenuator :: (aSpeech: *Speech, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Speech_setInaudibleBehavior :: (aSpeech: *Speech, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Speech_setLoopPoint :: (aSpeech: *Speech, aLoopPoint: float64) -> void #foreign soloud;
Speech_getLoopPoint :: (aSpeech: *Speech) -> float64 #foreign soloud;
Speech_setFilter :: (aSpeech: *Speech, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Speech_stop :: (aSpeech: *Speech) -> void #foreign soloud;

/*
* TedSid
*/
TedSid_destroy :: (aTedSid: *TedSid) -> void #foreign soloud;
TedSid_create :: () -> *TedSid #foreign soloud;
TedSid_load :: (aTedSid: *TedSid, aFilename: *u8) -> s32 #foreign soloud;
TedSid_loadToMem :: (aTedSid: *TedSid, aFilename: *u8) -> s32 #foreign soloud;
TedSid_loadMem :: (aTedSid: *TedSid, aMem: *u8, aLength: u32) -> s32 #foreign soloud;
TedSid_loadMemEx :: (aTedSid: *TedSid, aMem: *u8, aLength: u32, aCopy: s32, aTakeOwnership: s32) -> s32 #foreign soloud;
TedSid_loadFileToMem :: (aTedSid: *TedSid, aFile: *File) -> s32 #foreign soloud;
TedSid_loadFile :: (aTedSid: *TedSid, aFile: *File) -> s32 #foreign soloud;
TedSid_setVolume :: (aTedSid: *TedSid, aVolume: float) -> void #foreign soloud;
TedSid_setLooping :: (aTedSid: *TedSid, aLoop: s32) -> void #foreign soloud;
TedSid_set3dMinMaxDistance :: (aTedSid: *TedSid, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
TedSid_set3dAttenuation :: (aTedSid: *TedSid, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
TedSid_set3dDopplerFactor :: (aTedSid: *TedSid, aDopplerFactor: float) -> void #foreign soloud;
TedSid_set3dListenerRelative :: (aTedSid: *TedSid, aListenerRelative: s32) -> void #foreign soloud;
TedSid_set3dDistanceDelay :: (aTedSid: *TedSid, aDistanceDelay: s32) -> void #foreign soloud;
TedSid_set3dCollider :: (aTedSid: *TedSid, aCollider: *AudioCollider) -> void #foreign soloud;
TedSid_set3dColliderEx :: (aTedSid: *TedSid, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
TedSid_set3dAttenuator :: (aTedSid: *TedSid, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
TedSid_setInaudibleBehavior :: (aTedSid: *TedSid, aMustTick: s32, aKill: s32) -> void #foreign soloud;
TedSid_setLoopPoint :: (aTedSid: *TedSid, aLoopPoint: float64) -> void #foreign soloud;
TedSid_getLoopPoint :: (aTedSid: *TedSid) -> float64 #foreign soloud;
TedSid_setFilter :: (aTedSid: *TedSid, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
TedSid_stop :: (aTedSid: *TedSid) -> void #foreign soloud;

/*
* Vic
*/
Vic_destroy :: (aVic: *Vic) -> void #foreign soloud;
Vic_create :: () -> *Vic #foreign soloud;
Vic_setModel :: (aVic: *Vic, model: s32) -> void #foreign soloud;
Vic_getModel :: (aVic: *Vic) -> s32 #foreign soloud;
Vic_setRegister :: (aVic: *Vic, reg: s32, value: u8) -> void #foreign soloud;
Vic_getRegister :: (aVic: *Vic, reg: s32) -> u8 #foreign soloud;
Vic_setVolume :: (aVic: *Vic, aVolume: float) -> void #foreign soloud;
Vic_setLooping :: (aVic: *Vic, aLoop: s32) -> void #foreign soloud;
Vic_set3dMinMaxDistance :: (aVic: *Vic, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Vic_set3dAttenuation :: (aVic: *Vic, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Vic_set3dDopplerFactor :: (aVic: *Vic, aDopplerFactor: float) -> void #foreign soloud;
Vic_set3dListenerRelative :: (aVic: *Vic, aListenerRelative: s32) -> void #foreign soloud;
Vic_set3dDistanceDelay :: (aVic: *Vic, aDistanceDelay: s32) -> void #foreign soloud;
Vic_set3dCollider :: (aVic: *Vic, aCollider: *AudioCollider) -> void #foreign soloud;
Vic_set3dColliderEx :: (aVic: *Vic, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Vic_set3dAttenuator :: (aVic: *Vic, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Vic_setInaudibleBehavior :: (aVic: *Vic, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Vic_setLoopPoint :: (aVic: *Vic, aLoopPoint: float64) -> void #foreign soloud;
Vic_getLoopPoint :: (aVic: *Vic) -> float64 #foreign soloud;
Vic_setFilter :: (aVic: *Vic, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Vic_stop :: (aVic: *Vic) -> void #foreign soloud;

/*
* Vizsn
*/
Vizsn_destroy :: (aVizsn: *Vizsn) -> void #foreign soloud;
Vizsn_create :: () -> *Vizsn #foreign soloud;
Vizsn_setText :: (aVizsn: *Vizsn, aText: *u8) -> void #foreign soloud;
Vizsn_setVolume :: (aVizsn: *Vizsn, aVolume: float) -> void #foreign soloud;
Vizsn_setLooping :: (aVizsn: *Vizsn, aLoop: s32) -> void #foreign soloud;
Vizsn_set3dMinMaxDistance :: (aVizsn: *Vizsn, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Vizsn_set3dAttenuation :: (aVizsn: *Vizsn, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Vizsn_set3dDopplerFactor :: (aVizsn: *Vizsn, aDopplerFactor: float) -> void #foreign soloud;
Vizsn_set3dListenerRelative :: (aVizsn: *Vizsn, aListenerRelative: s32) -> void #foreign soloud;
Vizsn_set3dDistanceDelay :: (aVizsn: *Vizsn, aDistanceDelay: s32) -> void #foreign soloud;
Vizsn_set3dCollider :: (aVizsn: *Vizsn, aCollider: *AudioCollider) -> void #foreign soloud;
Vizsn_set3dColliderEx :: (aVizsn: *Vizsn, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Vizsn_set3dAttenuator :: (aVizsn: *Vizsn, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Vizsn_setInaudibleBehavior :: (aVizsn: *Vizsn, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Vizsn_setLoopPoint :: (aVizsn: *Vizsn, aLoopPoint: float64) -> void #foreign soloud;
Vizsn_getLoopPoint :: (aVizsn: *Vizsn) -> float64 #foreign soloud;
Vizsn_setFilter :: (aVizsn: *Vizsn, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Vizsn_stop :: (aVizsn: *Vizsn) -> void #foreign soloud;

/*
* Wav
*/
Wav_destroy :: (aWav: *Wav) -> void #foreign soloud;
Wav_create :: () -> *Wav #foreign soloud;
Wav_load :: (aWav: *Wav, aFilename: *u8) -> s32 #foreign soloud;
Wav_loadMem :: (aWav: *Wav, aMem: *u8, aLength: u32) -> s32 #foreign soloud;
Wav_loadMemEx :: (aWav: *Wav, aMem: *u8, aLength: u32, aCopy: s32, aTakeOwnership: s32) -> s32 #foreign soloud;
Wav_loadFile :: (aWav: *Wav, aFile: *File) -> s32 #foreign soloud;
Wav_loadRawWave8 :: (aWav: *Wav, aMem: *u8, aLength: u32) -> s32 #foreign soloud;
Wav_loadRawWave8Ex :: (aWav: *Wav, aMem: *u8, aLength: u32, aSamplerate: float, aChannels: u32) -> s32 #foreign soloud;
Wav_loadRawWave16 :: (aWav: *Wav, aMem: *s16, aLength: u32) -> s32 #foreign soloud;
Wav_loadRawWave16Ex :: (aWav: *Wav, aMem: *s16, aLength: u32, aSamplerate: float, aChannels: u32) -> s32 #foreign soloud;
Wav_loadRawWave :: (aWav: *Wav, aMem: *float, aLength: u32) -> s32 #foreign soloud;
Wav_loadRawWaveEx :: (aWav: *Wav, aMem: *float, aLength: u32, aSamplerate: float, aChannels: u32, aCopy: s32, aTakeOwnership: s32) -> s32 #foreign soloud;
Wav_getLength :: (aWav: *Wav) -> float64 #foreign soloud;
Wav_setVolume :: (aWav: *Wav, aVolume: float) -> void #foreign soloud;
Wav_setLooping :: (aWav: *Wav, aLoop: s32) -> void #foreign soloud;
Wav_set3dMinMaxDistance :: (aWav: *Wav, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
Wav_set3dAttenuation :: (aWav: *Wav, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
Wav_set3dDopplerFactor :: (aWav: *Wav, aDopplerFactor: float) -> void #foreign soloud;
Wav_set3dListenerRelative :: (aWav: *Wav, aListenerRelative: s32) -> void #foreign soloud;
Wav_set3dDistanceDelay :: (aWav: *Wav, aDistanceDelay: s32) -> void #foreign soloud;
Wav_set3dCollider :: (aWav: *Wav, aCollider: *AudioCollider) -> void #foreign soloud;
Wav_set3dColliderEx :: (aWav: *Wav, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
Wav_set3dAttenuator :: (aWav: *Wav, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
Wav_setInaudibleBehavior :: (aWav: *Wav, aMustTick: s32, aKill: s32) -> void #foreign soloud;
Wav_setLoopPoint :: (aWav: *Wav, aLoopPoint: float64) -> void #foreign soloud;
Wav_getLoopPoint :: (aWav: *Wav) -> float64 #foreign soloud;
Wav_setFilter :: (aWav: *Wav, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
Wav_stop :: (aWav: *Wav) -> void #foreign soloud;

/*
* WaveShaperFilter
*/
WaveShaperFilter_destroy :: (aWaveShaperFilter: *WaveShaperFilter) -> void #foreign soloud;
WaveShaperFilter_setParams :: (aWaveShaperFilter: *WaveShaperFilter, aAmount: float) -> s32 #foreign soloud;
WaveShaperFilter_create :: () -> *WaveShaperFilter #foreign soloud;
WaveShaperFilter_getParamCount :: (aWaveShaperFilter: *WaveShaperFilter) -> s32 #foreign soloud;
WaveShaperFilter_getParamName :: (aWaveShaperFilter: *WaveShaperFilter, aParamIndex: u32) -> *u8 #foreign soloud;
WaveShaperFilter_getParamType :: (aWaveShaperFilter: *WaveShaperFilter, aParamIndex: u32) -> u32 #foreign soloud;
WaveShaperFilter_getParamMax :: (aWaveShaperFilter: *WaveShaperFilter, aParamIndex: u32) -> float #foreign soloud;
WaveShaperFilter_getParamMin :: (aWaveShaperFilter: *WaveShaperFilter, aParamIndex: u32) -> float #foreign soloud;

/*
* WavStream
*/
WavStream_destroy :: (aWavStream: *WavStream) -> void #foreign soloud;
WavStream_create :: () -> *WavStream #foreign soloud;
WavStream_load :: (aWavStream: *WavStream, aFilename: *u8) -> s32 #foreign soloud;
WavStream_loadMem :: (aWavStream: *WavStream, aData: *u8, aDataLen: u32) -> s32 #foreign soloud;
WavStream_loadMemEx :: (aWavStream: *WavStream, aData: *u8, aDataLen: u32, aCopy: s32, aTakeOwnership: s32) -> s32 #foreign soloud;
WavStream_loadToMem :: (aWavStream: *WavStream, aFilename: *u8) -> s32 #foreign soloud;
WavStream_loadFile :: (aWavStream: *WavStream, aFile: *File) -> s32 #foreign soloud;
WavStream_loadFileToMem :: (aWavStream: *WavStream, aFile: *File) -> s32 #foreign soloud;
WavStream_getLength :: (aWavStream: *WavStream) -> float64 #foreign soloud;
WavStream_setVolume :: (aWavStream: *WavStream, aVolume: float) -> void #foreign soloud;
WavStream_setLooping :: (aWavStream: *WavStream, aLoop: s32) -> void #foreign soloud;
WavStream_set3dMinMaxDistance :: (aWavStream: *WavStream, aMinDistance: float, aMaxDistance: float) -> void #foreign soloud;
WavStream_set3dAttenuation :: (aWavStream: *WavStream, aAttenuationModel: u32, aAttenuationRolloffFactor: float) -> void #foreign soloud;
WavStream_set3dDopplerFactor :: (aWavStream: *WavStream, aDopplerFactor: float) -> void #foreign soloud;
WavStream_set3dListenerRelative :: (aWavStream: *WavStream, aListenerRelative: s32) -> void #foreign soloud;
WavStream_set3dDistanceDelay :: (aWavStream: *WavStream, aDistanceDelay: s32) -> void #foreign soloud;
WavStream_set3dCollider :: (aWavStream: *WavStream, aCollider: *AudioCollider) -> void #foreign soloud;
WavStream_set3dColliderEx :: (aWavStream: *WavStream, aCollider: *AudioCollider, aUserData: s32) -> void #foreign soloud;
WavStream_set3dAttenuator :: (aWavStream: *WavStream, aAttenuator: *AudioAttenuator) -> void #foreign soloud;
WavStream_setInaudibleBehavior :: (aWavStream: *WavStream, aMustTick: s32, aKill: s32) -> void #foreign soloud;
WavStream_setLoopPoint :: (aWavStream: *WavStream, aLoopPoint: float64) -> void #foreign soloud;
WavStream_getLoopPoint :: (aWavStream: *WavStream) -> float64 #foreign soloud;
WavStream_setFilter :: (aWavStream: *WavStream, aFilterId: u32, aFilter: *Filter) -> void #foreign soloud;
WavStream_stop :: (aWavStream: *WavStream) -> void #foreign soloud;

#scope_file

#import "Basic"; // For assert

soloud :: #library "./soloud";
