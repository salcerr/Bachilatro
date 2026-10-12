-- Tobimune preset: costs, selection rules and balance values live here.
-- Energy, preset lookup and ability-button plumbing are shared across blades.
BACHILATRO_SWORD_PRESETS = BACHILATRO_SWORD_PRESETS or {}

BACHILATRO_SWORD_PRESETS.tobimune = {
    consumable_key = 'c_bachilatro_tobimune',
    atlas = 'tobimune_art',
    pos = { x = 0, y = 0 },
    cost = 3,
    wielder = {
        joker_key = 'j_bachilatro_samura',
        upgrade_abilities = { 'crow', 'owl', 'suzaku' }
    },
    abilities = {
        {
            key = 'crow',
            label = 'CROW',
            cost = 40,
            upgraded_cost = 20,
            can_use_func = 'bachilatro_can_use_crow',
            button_func = 'bachilatro_tobimune_crow',
            selection = { area = 'hand', min = 1, max = 1 }
        },
        {
            key = 'owl',
            label = 'OWL',
            cost = 60,
            -- Chance that each Joker the shop generates comes from the chosen
            -- rarity until the Ante ends. `index` and `poll` are fallbacks for
            -- different ways create_card can be asked for a rarity.
            shop_joker_chance = 0.30,
            upgraded_shop_joker_chance = 0.60,
            rarities = {
                { key = 'Common',   index = 1, poll = 0.50, label = 'Common' },
                { key = 'Uncommon', index = 2, poll = 0.80, label = 'Uncommon' },
                { key = 'Rare',     index = 3, poll = 0.97, label = 'Rare' }
            },
            can_use_func = 'bachilatro_can_use_owl',
            button_func = 'bachilatro_tobimune_owl'
        },
        {
            key = 'suzaku',
            label = 'SUZAKU',
            cost = 40,
            rank_increase = 1,
            selection = { area = 'hand', min = 3, max = 3, upgraded_min = 1, upgraded_max = 5 },
            can_use_func = 'bachilatro_can_use_suzaku',
            button_func = 'bachilatro_tobimune_suzaku'
        }
    }
}
