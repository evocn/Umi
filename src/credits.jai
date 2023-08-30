// Umi
// Credits
// Alex Hartford
// August 2023

resolve_credits_input :: () {
    using input;

    if pressed(*button_1) {
        return_to_prior_mode();
        play_woodblock_sound();
    }
    if pressed(*button_2) {
        return_to_prior_mode();
        play_woodblock_sound();
    }
    if pressed(*button_menu) {
        return_to_prior_mode();
        play_woodblock_sound();
    }
}
