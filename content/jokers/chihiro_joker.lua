-- CHIHIRO ROKUHIRA
SMODS.Joker {
    key = 'chihiro',

    loc_txt = {
        name = 'Chihiro Rokuhira',
        text = {
            "The bearer Enten was forged for.",
            'After defeating a Blind, gain {X:mult,C:white}X#1#{} Mult.',
            'Current: {X:mult,C:white}X#2#{} Mult.'
        }
    },

    atlas = BACHILATRO_CHIHIRO_ATLAS,
    prefix_config = { atlas = false },
    pos = { x = 0, y = 0 },
    rarity = BACHILATRO_WIELDER_PRESETS.chihiro.rarity,
    cost = BACHILATRO_WIELDER_PRESETS.chihiro.cost,

    in_pool = function(self, args)
        return BACHILATRO_has_sword(
            BACHILATRO_WIELDER_PRESETS.chihiro.sword_key
        )
    end,

    config = {
        extra = {
            xmult_mod = BACHILATRO_WIELDER_PRESETS.chihiro.ability.xmult_per_blind,
            xmult = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        local current_xmult = card and card.ability.extra.xmult
            or self.config.extra.xmult
        return {
            vars = {
                string.format('%.2f', self.config.extra.xmult_mod),
                string.format('%.2f', current_xmult)
            }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then return end
        local preset = BACHILATRO_WIELDER_PRESETS.chihiro
        local sword = BACHILATRO_find_sword(preset.sword_key)
        if not sword then return end

        sword:juice_up()
        attention_text({
            text = 'ENTEN UPGRADED!',
            scale = 1.2,
            hold = 2,
            major = sword,
            backdrop_colour = G.C.BLUE,
            align = 'cm',
            offset = { x = 0, y = -0.5 },
            silent = true
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.xmult > 1 then
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

        if context.end_of_round
            and context.main_eval
            and not context.blueprint
            and not context.game_over
            and G.GAME.blind
        then
            card.ability.extra.xmult = math.floor((
                card.ability.extra.xmult + self.config.extra.xmult_mod
            ) * 100 + 0.5) / 100
            return {
                message = localize{
                    type = 'variable',
                    key = 'a_xmult',
                    vars = { card.ability.extra.xmult }
                },
                colour = G.C.MULT,
                card = card
            }
        end
    end
}
