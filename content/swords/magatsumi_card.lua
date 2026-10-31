--------------------------------------------------
-- MAGATSUMI
-- Dos cartas: la espada sellada (fase Yura) y la despertada (Akemura).
-- Ninguna aparece en tienda ni en packs: solo el Shinuchi Deck la entrega.
--------------------------------------------------

SMODS.Consumable {
    key = 'magatsumi',
    set = 'EnchantedBlade',

    loc_txt = {
        name = 'Magatsumi',
        text = {
            'Shinuchi, the blade of captured sin.',
            'Only a fraction of its power answers',
            'to Yura. Its techniques are sealed.',
            '{C:inactive}Awakens in {C:attention}#1#{C:inactive} more Blinds.{}'
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { BACHILATRO_magatsumi_blinds_left() } }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.magatsumi.atlas,
    pos = BACHILATRO_SWORD_PRESETS.magatsumi.pos,
    cost = BACHILATRO_SWORD_PRESETS.magatsumi.cost,
    config = { extra_slots_used = 0 },

    in_pool = function(self, args)
        return false
    end,

    can_use = function(self, card)
        return false
    end,

    keep_on_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
    end
}

SMODS.Consumable {
    key = 'magatsumi_awakened',
    set = 'EnchantedBlade',

    loc_txt = {
        name = 'Magatsumi',
        text = {
            'Akemura unleashes its full power.',
            '{C:attention}KUMO{}: On your next hand, the first',
            'played card is caught in the web and',
            'returns to your hand. {C:purple}(#1# Energy){}',
            '{C:attention}TONBO{}: Turn 1 selected card into a',
            '{C:attention}Glass Card{}. It stays selected until',
            'you play or discard it. {C:purple}(#2# Energy){}',
            '{C:attention}MUKADE{}: After you play your next',
            'hand, destroy every card left in',
            'your hand. {C:purple}(#3# Energy){}',
            '{C:attention}CHO{}: On your next 5-card hand, the',
            'middle 3 are destroyed after scoring and',
            'the 2 end cards retrigger #4# time. {C:purple}(#5# Energy){}',
            '{C:attention}HACHI{}: On your next hand, the last',
            'scoring card retriggers #6# times. {C:purple}(#7# Energy){}',
            '{C:attention}KODOKU{}: Lower up to 5 selected cards',
            'by 1 rank. A 2 becomes an Ace. {C:purple}(#8# Energy){}'
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                BACHILATRO_magatsumi_cost('kumo'),
                BACHILATRO_magatsumi_cost('tonbo'),
                BACHILATRO_magatsumi_cost('mukade'),
                BACHILATRO_magatsumi_retriggers('cho'),
                BACHILATRO_magatsumi_cost('cho'),
                BACHILATRO_magatsumi_retriggers('hachi'),
                BACHILATRO_magatsumi_cost('hachi'),
                BACHILATRO_magatsumi_cost('kodoku')
            }
        }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.magatsumi_awakened.atlas,
    pos = BACHILATRO_SWORD_PRESETS.magatsumi_awakened.pos,
    cost = BACHILATRO_SWORD_PRESETS.magatsumi_awakened.cost,
    config = { extra_slots_used = 0 },

    in_pool = function(self, args)
        return false
    end,

    can_use = function(self, card)
        return BACHILATRO_can_use_magatsumi_ability(card)
    end,

    keep_on_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        BACHILATRO_use_magatsumi_ability(card)
    end
}
