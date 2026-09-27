-- Temporary card enhancements created by Kuregumo.
SMODS.Enhancement {
    key = 'wet',
    atlas = 'centers',
    prefix_config = { atlas = false },
    pos = { x = 0, y = 0 },
    config = {},
    in_pool = function(self, args) return false end,
    loc_txt = {
        name = 'Wet',
        text = { 'Kou prepares this card for Mei and Yui' }
    },
    calculate = function(self, card, context)
        if context.discard and context.other_card == card then
            BACHILATRO_clear_kuregumo_status(card)
        end
    end
}

SMODS.Enhancement {
    key = 'shocked',
    atlas = 'centers',
    prefix_config = { atlas = false },
    pos = { x = 1, y = 0 },
    config = {},
    in_pool = function(self, args) return false end,
    loc_txt = {
        name = 'Shocked',
        text = { '#1#' }
    },
    loc_vars = function(self, info_queue, card)
        local scoring = BACHILATRO_SWORD_PRESETS.kuregumo.status_effects.shocked
        local effect
        if BACHILATRO_kuregumo_is_upgraded() then
            effect = string.format(
                'Each scored card gives XMult equal to %g + %g per Shocked card in the deck.',
                scoring.upgraded_xmult_base,
                scoring.upgraded_xmult_per_deck_card
            )
        else
            effect = string.format(
                'Each scored card gives +%g Mult per Shocked card played this hand.',
                scoring.mult_per_shocked_card_played
            )
        end
        return { vars = { effect } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local scoring = BACHILATRO_SWORD_PRESETS.kuregumo.status_effects.shocked
            if BACHILATRO_kuregumo_is_upgraded() then
                local count = BACHILATRO_count_kuregumo_status('shocked')
                return {
                    x_mult = scoring.upgraded_xmult_base
                        + scoring.upgraded_xmult_per_deck_card * count
                }
            end

            local count = BACHILATRO_count_kuregumo_status('shocked', G.play.cards)
            return { mult = scoring.mult_per_shocked_card_played * count }
        elseif context.discard and context.other_card == card then
            BACHILATRO_clear_kuregumo_status(card)
        end
    end
}
