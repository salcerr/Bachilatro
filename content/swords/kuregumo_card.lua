--------------------------------------------------
-- KUREGUMO / CLOUD GOUGER
--------------------------------------------------

SMODS.Consumable {
    key = 'kuregumo',
    set = 'EnchantedBlade',

    loc_txt = {
        name = 'Kuregumo',
        text = {
            'Its three techniques flow as one.',
            '{C:attention}KOU{}: Make up to #1# selected cards {C:blue}Wet{}. {C:purple}(#2# Energy){}',
            '{C:attention}MEI{}: Shock #3#. {C:purple}(#4# Energy){}',
            '{C:attention}YUI{}: Reduce Blind target by {C:chips}#5#{} per {C:blue}Wet{} card in #6#. {C:purple}(#7# Energy){}'
        }
    },

    loc_vars = function(self, info_queue, card)
        local preset = BACHILATRO_SWORD_PRESETS.kuregumo
        local upgraded = BACHILATRO_kuregumo_is_upgraded()
        local kou = BACHILATRO_get_sword_ability(preset, 'kou')
        local yui = BACHILATRO_get_sword_ability(preset, 'yui')
        local reduction_per_card = upgraded
            and yui.upgraded_score_reduction_per_wet_card
            or yui.score_reduction_per_wet_card
        local mei_text = upgraded
            and 'all cards in your deck'
            or 'Wet cards in your hand'
        return {
            vars = {
                kou.selection.max,
                BACHILATRO_get_sword_ability_cost('kuregumo', 'kou', upgraded),
                mei_text,
                BACHILATRO_get_sword_ability_cost('kuregumo', 'mei', upgraded),
                math.floor(reduction_per_card * 100) .. '%',
                upgraded and 'the deck' or 'your hand',
                BACHILATRO_get_sword_ability_cost('kuregumo', 'yui', upgraded),
            }
        }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.kuregumo.atlas,
    pos = BACHILATRO_SWORD_PRESETS.kuregumo.pos,
    cost = BACHILATRO_SWORD_PRESETS.kuregumo.cost,
    config = { extra_slots_used = 0 },

    can_use = function(self, card)
        return BACHILATRO_can_use_kuregumo_ability(card)
    end,

    keep_on_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        BACHILATRO_use_kuregumo_ability(card)
    end
}
