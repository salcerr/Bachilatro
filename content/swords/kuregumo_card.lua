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
            '{C:attention}KOU{}: #1# (#2# Energy)',
            '{C:attention}MEI{}: #3# (#4# Energy)',
            '{C:attention}YUI{}: #5# (#6# Energy)'
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
            and 'Turn every card in the deck into Shocked.'
            or 'Turn Wet cards in hand into Shocked.'
        local yui_text = 'Blind target -'
            .. math.floor(reduction_per_card * 100)
            .. '% per Wet card in '
            .. (upgraded and 'deck.' or 'hand.')
        return {
            vars = {
                'Wet up to ' .. kou.selection.max .. ' selected cards.',
                BACHILATRO_get_sword_ability_cost('kuregumo', 'kou', upgraded),
                mei_text,
                BACHILATRO_get_sword_ability_cost('kuregumo', 'mei', upgraded),
                yui_text,
                BACHILATRO_get_sword_ability_cost('kuregumo', 'yui', upgraded),
            }
        }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.kuregumo.atlas,
    pos = BACHILATRO_SWORD_PRESETS.kuregumo.pos,
    cost = BACHILATRO_SWORD_PRESETS.kuregumo.cost,
    config = { extra_slots_used = 1 },

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
