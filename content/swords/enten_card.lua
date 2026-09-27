--------------------------------------------------
-- REGISTRO DE ENTEN
--------------------------------------------------

SMODS.Consumable {
    key = 'enten',
    set = 'EnchantedBlade',

    loc_txt = {
        name = 'Enten',
        text = {
            "It yearns for its owner.",
            "{C:attention}KURO{}: Destroy #1# selected cards. (#6# Energy)",
            "{C:attention}AKA{}: #2# (#3# Energy)",
            "{C:attention}NISHIKI{}: #4#",
            "#5# (#7# Energy)"
        }
    },

    loc_vars = function(self, info_queue, card)
        local chihiro = BACHILATRO_has_chihiro()
        return {
            vars = {
                chihiro and '2 or 3' or '2',
                chihiro
                    and "Copy 2 selected Jokers this round."
                    or "Copy a selected Joker this round.",
                BACHILATRO_get_sword_ability_cost('enten', 'aka', chihiro),
                chihiro
                    and ('Any Blind: -' .. math.floor(BACHILATRO_get_sword_ability(
                        'enten', 'nishiki'
                    ).blind_effect.score_reduction * 100) .. '% score target')
                    or 'Boss Blind only',
                chihiro
                    and 'Boss Blind: also disable its effect'
                    or 'Disable its effect',
                BACHILATRO_get_sword_ability_cost('enten', 'kuro', chihiro),
                BACHILATRO_get_sword_ability_cost('enten', 'nishiki', chihiro)
            }
        }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.enten.atlas,
    pos = BACHILATRO_SWORD_PRESETS.enten.pos,
    cost = BACHILATRO_SWORD_PRESETS.enten.cost,

    config = {
        extra_slots_used = 1
    },

    can_use = function(self, card)
        return BACHILATRO_can_use_enten_ability(card)
    end,

    keep_on_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        BACHILATRO_use_enten_ability(card)
    end
}
