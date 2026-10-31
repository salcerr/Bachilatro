-- Magatsumi: deck-only sword (Hishaku Deck). It never appears in shops or packs.
-- Two presets, because the card is replaced when Akemura awakens:
--   magatsumi           = sealed (Yura phase), no techniques.
--   magatsumi_awakened  = full power, one technique per insect.
BACHILATRO_SWORD_PRESETS = BACHILATRO_SWORD_PRESETS or {}

BACHILATRO_SWORD_PRESETS.magatsumi = {
    consumable_key = 'c_bachilatro_magatsumi',
    atlas = 'magatsumi_art',
    pos = { x = 0, y = 0 },
    cost = 3,
    deck_only = true,
    abilities = {}
}

BACHILATRO_SWORD_PRESETS.magatsumi_awakened = {
    consumable_key = 'c_bachilatro_magatsumi_awakened',
    atlas = 'magatsumi_art',
    pos = { x = 0, y = 0 },
    cost = 3,
    deck_only = true,
    abilities = {
        {
            -- Spider: the first card of the next hand is held in place and returns to hand.
            key = 'kumo',
            label = 'KUMO',
            cost = 40,
            can_use_func = 'bachilatro_can_use_kumo',
            button_func = 'bachilatro_magatsumi_kumo'
        },
        {
            -- Dragonfly: ruptures a card (Glass) and forces it into the next play.
            key = 'tonbo',
            label = 'TONBO',
            cost = 40,
            selection = { area = 'hand', min = 1, max = 1 },
            can_use_func = 'bachilatro_can_use_tonbo',
            button_func = 'bachilatro_magatsumi_tonbo'
        },
        {
            -- Centipede: omni-directional shockwave, destroys the cards left in hand.
            key = 'mukade',
            label = 'MUKADE',
            cost = 60,
            can_use_func = 'bachilatro_can_use_mukade',
            button_func = 'bachilatro_magatsumi_mukade'
        },
        {
            -- Butterfly: amplified slash. Next 5-card hand: middle 3 are cut,
            -- the two end cards retrigger.
            key = 'cho',
            label = 'CHO',
            cost = 80,
            end_retriggers = 1,
            can_use_func = 'bachilatro_can_use_cho',
            button_func = 'bachilatro_magatsumi_cho'
        },
        {
            -- Bee: piercing thrust. Next hand: its last scoring card retriggers a lot.
            key = 'hachi',
            label = 'HACHI',
            cost = 60,
            retriggers = 3,
            can_use_func = 'bachilatro_can_use_hachi',
            button_func = 'bachilatro_magatsumi_hachi'
        },
        {
            -- Malediction: drains vitality, lowering ranks.
            key = 'kodoku',
            label = 'KODOKU',
            cost = 40,
            rank_decrease = 1,
            selection = { area = 'hand', min = 1, max = 5 },
            can_use_func = 'bachilatro_can_use_kodoku',
            button_func = 'bachilatro_magatsumi_kodoku'
        }
    }
}
