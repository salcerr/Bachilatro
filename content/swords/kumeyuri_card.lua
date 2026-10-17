--------------------------------------------------
-- KUMEYURI
--------------------------------------------------

SMODS.Consumable {
    key = 'kumeyuri',
    set = 'EnchantedBlade',

    loc_txt = {
        name = 'Kumeyuri',
        text = {
            'Sake poured by geisha spirits.',
            '{C:attention}EN{}: Create {C:attention}#1#{} copies of 1 selected card.',
            'They vanish when the Blind ends. {C:purple}(#2# Energy){}',
            '{C:attention}YUU{}: Select 2 cards. #3#',
            '#4# {C:purple}(#5# Energy){}'
        }
    },

    loc_vars = function(self, info_queue, card)
        local destructive = BACHILATRO_kumeyuri_yuu_is_destructive()
        return {
            vars = {
                BACHILATRO_kumeyuri_en_copies(),
                BACHILATRO_kumeyuri_cost('en'),
                destructive and 'All properties' or 'One random property',
                destructive and 'move right to left; right card dies.'
                    or 'moves from the right card to the left.',
                BACHILATRO_kumeyuri_cost('yuu')
            }
        }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.kumeyuri.atlas,
    pos = BACHILATRO_SWORD_PRESETS.kumeyuri.pos,
    cost = BACHILATRO_SWORD_PRESETS.kumeyuri.cost,
    config = { extra_slots_used = 0 },

    can_use = function(self, card)
        return BACHILATRO_can_use_kumeyuri_ability(card)
    end,

    keep_on_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        BACHILATRO_use_kumeyuri_ability(card)
    end
}