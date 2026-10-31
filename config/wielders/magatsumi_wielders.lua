-- Yura (proxy, debuff phase) and Akemura Soga (true bearer, full power).
-- Yura turns into Akemura after `debuff_blinds` Blinds are beaten.
BACHILATRO_WIELDER_PRESETS = BACHILATRO_WIELDER_PRESETS or {}

BACHILATRO_WIELDER_PRESETS.yura = {
    sword_key = 'magatsumi',
    rarity = 2,
    cost = 8,
    ability = {
        hand_size = 1,
        debuff_blinds = 9,
        -- Each Blind, every playing card has this chance to lose one rank
        -- (a 2 wraps around to an Ace, the inverse of Strength).
        rank_loss_chance = 0.25
    }
}

BACHILATRO_WIELDER_PRESETS.akemura = {
    sword_key = 'magatsumi_awakened',
    rarity = 3,
    cost = 10,
    ability = {
        energy_bonus = 100,
        energy_per_blind = 25
    }
}
