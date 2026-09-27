-- Enten preset: content and balance values belong to this sword, while energy,
-- preset lookup, and ability-button plumbing are shared across enchanted blades.
BACHILATRO_SWORD_PRESETS = BACHILATRO_SWORD_PRESETS or {}

BACHILATRO_SWORD_PRESETS.enten = {
    key = 'enten',
    consumable_key = 'c_bachilatro_enten',
    atlas = 'enten_art',
    pos = { x = 0, y = 0 },
    cost = 3,
    usage = { mode = 'held' },
    wielder = {
        joker_key = 'j_bachilatro_chihiro',
        relation = 'original_owner',
        upgrade_abilities = { 'aka', 'nishiki', 'kuro' }
    },
    abilities = {
        {
            key = 'kuro',
            label = 'KURO',
            cost = 40,
            upgraded_cost = 40,
            can_use_func = 'bachilatro_can_use_kuro',
            button_func = 'bachilatro_enten_kuro',
            selection = { area = 'hand', min = 2, max = 2, upgraded_max = 3 }
        },
        {
            key = 'aka',
            label = 'AKA',
            cost = 40,
            upgraded_cost = 60,
            can_use_func = 'bachilatro_can_use_aka',
            button_func = 'bachilatro_enten_aka',
            selection = { area = 'jokers', min = 1, upgraded_min = 2 },
            use_once_per_round = true,
            allowed_targets = 'blueprint_compatible_except_blueprint_and_brainstorm'
        },
        {
            key = 'nishiki',
            label = 'NISHIKI',
            cost = 60,
            upgraded_cost = 60,
            can_use_func = 'bachilatro_can_use_nishiki',
            button_func = 'bachilatro_enten_nishiki',
            blind_effect = {
                score_reduction = 0.20,
                reduction_requires_wielder = true,
                disables_boss_blind = true,
                any_blind_requires_wielder = true
            }
        }
    }
}

