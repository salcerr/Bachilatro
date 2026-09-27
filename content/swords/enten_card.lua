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
            "{C:attention}KURO{}: Destroy #1# selected cards. {C:blue}(#2# Energy){}",
            "{C:attention}AKA{}: #3# {C:blue}(#4# Energy){}",
            "{C:attention}NISHIKI{}: #5#",
            "#6# {C:blue}(#7# Energy){}"
        }
    },

    loc_vars = function(self, info_queue, card)
        local preset = BACHILATRO_SWORD_PRESETS.enten
        local kuro_upgraded = BACHILATRO_sword_ability_is_upgraded(preset, 'kuro')
        local aka_upgraded = BACHILATRO_sword_ability_is_upgraded(preset, 'aka')
        local nishiki_upgraded = BACHILATRO_sword_ability_is_upgraded(preset, 'nishiki')
        local kuro = BACHILATRO_get_sword_ability(preset, 'kuro')
        local aka = BACHILATRO_get_sword_ability(preset, 'aka')
        local kuro_min = kuro.selection.min
        local kuro_max = kuro_upgraded
            and (kuro.selection.upgraded_max or kuro.selection.max or kuro_min)
            or (kuro.selection.max or kuro_min)
        local kuro_text = kuro_min == kuro_max
            and tostring(kuro_min)
            or (kuro_min .. ' or ' .. kuro_max)
        local aka_count = aka_upgraded
            and (aka.selection.upgraded_min or aka.selection.min)
            or aka.selection.min
        local aka_text = aka_count == 1
            and 'Copy a selected Joker this round.'
            or ('Copy ' .. aka_count .. ' selected Jokers this round.')
        return {
            vars = {
                kuro_text,
                BACHILATRO_get_sword_ability_cost('enten', 'kuro', kuro_upgraded),
                aka_text,
                BACHILATRO_get_sword_ability_cost('enten', 'aka', aka_upgraded),
                nishiki_upgraded
                    and ('Any Blind: -' .. math.floor(BACHILATRO_get_sword_ability(
                        'enten', 'nishiki'
                    ).blind_effect.score_reduction * 100) .. '% score target')
                    or 'Boss Blind only',
                nishiki_upgraded
                    and 'Boss Blind: also disable its effect'
                    or 'Disable its effect',
                BACHILATRO_get_sword_ability_cost('enten', 'nishiki', nishiki_upgraded)
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
