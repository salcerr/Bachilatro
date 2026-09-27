-- Sojo studies Kuregumo over multiple ability uses; he does not upgrade it on pickup.
BACHILATRO_WIELDER_PRESETS = BACHILATRO_WIELDER_PRESETS or {}
BACHILATRO_WIELDER_PRESETS.sojo = {
    key = 'sojo',
    joker_key = 'j_bachilatro_sojo',
    sword_key = 'kuregumo',
    rarity = 3,
    cost = 7,
    ability = {
        xmult_start = 1.1,
        xmult_per_use = 0.01,
        study_required = BACHILATRO_SWORD_PRESETS.kuregumo.wielder.study_required
    }
}
