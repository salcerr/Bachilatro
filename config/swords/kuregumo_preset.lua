-- Kuregumo preset: sword-specific costs and selection rules live here.
BACHILATRO_SWORD_PRESETS = BACHILATRO_SWORD_PRESETS or {}

BACHILATRO_SWORD_PRESETS.kuregumo = {
    key = 'kuregumo',
    consumable_key = 'c_bachilatro_kuregumo',
    atlas = 'enten_art', -- temporary placeholder until Kuregumo art is added
    pos = { x = 0, y = 0 },
    cost = 3,
    usage = { mode = 'held' },
    wielder = {
        joker_key = 'j_bachilatro_sojo',
        relation = 'studies_sword',
        study_required = 20
    },
    abilities = {
        {
            key = 'kou',
            label = 'KOU',
            cost = 20,
            can_use_func = 'bachilatro_can_use_kou',
            button_func = 'bachilatro_kuregumo_kou',
            selection = { area = 'hand', min = 1, max = 3 }
        },
        {
            key = 'mei',
            label = 'MEI',
            cost = 40,
            can_use_func = 'bachilatro_can_use_mei',
            button_func = 'bachilatro_kuregumo_mei'
        },
        {
            key = 'yui',
            label = 'YUI',
            cost = 40,
            score_reduction_per_wet_card = 0.03,
            upgraded_score_reduction_per_wet_card = 0.04,
            can_use_func = 'bachilatro_can_use_yui',
            button_func = 'bachilatro_kuregumo_yui'
        }
    },
    status_effects = {
        shocked = {
            mult_per_shocked_card_played = 1,
            upgraded_xmult_base = 1,
            upgraded_xmult_per_deck_card = 0.01
        }
    }
}
