-- GENICHI SOJO
SMODS.Joker {
    key = 'sojo',

    loc_txt = {
        name = 'Genichi Sojo',
        text = {
            'Study Kuregumo through its techniques.',
            'Each use gives {X:mult,C:white}X#1#{} Mult and',
            'each affected card gives {C:attention}#2#{} Study.',
            'At {C:attention}#3#{} Study, improve Kuregumo.',
            'Study: {C:attention}#4#/#3#{}',
            'Current: {X:mult,C:white}X#5#{} Mult.'
        }
    },

    atlas = 'Joker',
    prefix_config = { atlas = false },
    pos = { x = 0, y = 0 },
    rarity = BACHILATRO_WIELDER_PRESETS.sojo.rarity,
    cost = BACHILATRO_WIELDER_PRESETS.sojo.cost,
    blueprint_compat = false,

    in_pool = function(self, args)
        return BACHILATRO_has_sword(BACHILATRO_WIELDER_PRESETS.sojo.sword_key)
    end,

    config = {
        extra = {
            xmult = BACHILATRO_WIELDER_PRESETS.sojo.ability.xmult_start
        }
    },

    loc_vars = function(self, info_queue, card)
        local preset = BACHILATRO_WIELDER_PRESETS.sojo.ability
        local xmult = card and card.ability.extra.xmult or preset.xmult_start
        local study = G.GAME and G.GAME.bachilatro_kuregumo_study or 0
        return { vars = {
            string.format('%.2f', preset.xmult_per_use),
            preset.study_per_affected_card,
            preset.study_required,
            study,
            string.format('%.2f', xmult)
        } }
    end,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff or not G.GAME then return end
        G.GAME.bachilatro_kuregumo_study = G.GAME.bachilatro_kuregumo_study or 0
        G.GAME.bachilatro_kuregumo_upgraded = G.GAME.bachilatro_kuregumo_upgraded or false
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize{
                    type = 'variable',
                    key = 'a_xmult',
                    vars = { card.ability.extra.xmult }
                },
                colour = G.C.MULT,
                Xmult_mod = card.ability.extra.xmult
            }
        end
    end
}
