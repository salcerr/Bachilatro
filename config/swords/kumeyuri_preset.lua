-- Kumeyuri preset: costs, selection rules and balance values live here.
-- Energy, preset lookup and ability-button plumbing are shared across blades.
-- Kumeyuri has only two techniques: its third one is not revealed in the manga yet.
BACHILATRO_SWORD_PRESETS = BACHILATRO_SWORD_PRESETS or {}

BACHILATRO_SWORD_PRESETS.kumeyuri = {
    consumable_key = 'c_bachilatro_kumeyuri',
    atlas = 'kumeyuri_art',
    pos = { x = 0, y = 0 },
    cost = 3,
    wielder = {
        joker_key = 'j_bachilatro_hiruhiko',
        -- Hiruhiko in your jokers = Yuu becomes Destructive Play, En makes more copies.
        upgrade_abilities = { 'en', 'yuu' }
    },
    abilities = {
        {
            key = 'en',
            label = 'EN',
            cost = 40,
            -- Temporary copies of the selected card (they vanish when the Blind ends).
            copies = 2,
            upgraded_copies = 4,
            can_use_func = 'bachilatro_can_use_en',
            button_func = 'bachilatro_kumeyuri_en',
            selection = { area = 'hand', min = 1, max = 1 }
        },
        {
            key = 'yuu',
            label = 'YUU',
            cost = 20,
            -- Normal: one random property moves from the right card to the left one.
            -- Upgraded (Destructive Play): all of them move and the right card is destroyed.
            can_use_func = 'bachilatro_can_use_yuu',
            button_func = 'bachilatro_kumeyuri_yuu',
            selection = { area = 'hand', min = 2, max = 2 }
        }
    }
}