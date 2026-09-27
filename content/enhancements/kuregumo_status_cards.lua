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
        local effect = BACHILATRO_kuregumo_is_upgraded()
            and 'Each scored card gives XMult equal to 1 + 0.01 per Shocked card in the deck.'
            or 'Each scored card gives +Mult equal to the number of Shocked cards played this hand.'
        return { vars = { effect } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            if BACHILATRO_kuregumo_is_upgraded() then
                local count = BACHILATRO_count_kuregumo_status('shocked')
                return { x_mult = 1 + 0.01 * count }
            end

            local count = BACHILATRO_count_kuregumo_status('shocked', G.play.cards)
            return { mult = count }
        elseif context.discard and context.other_card == card then
            BACHILATRO_clear_kuregumo_status(card)
        end
    end
}
