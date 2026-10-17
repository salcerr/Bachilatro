-- Hiruhiko upgrades Kumeyuri while held and scales with destroyed cards.
BACHILATRO_WIELDER_PRESETS = BACHILATRO_WIELDER_PRESETS or {}
BACHILATRO_WIELDER_PRESETS.hiruhiko = {
    sword_key = 'kumeyuri',
    rarity = 2,
    cost = 8,
    ability = {
        xmult_start = 1.0,
        xmult_per_destroyed_card = 0.1
    }
}