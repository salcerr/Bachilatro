--------------------------------------------------
-- CHIHIRO ROKUHIRA
--------------------------------------------------

SMODS.Joker {
    key = 'chihiro',

    loc_txt = {
        name = 'Chihiro Rokuhira',

        text = {
            "The bearer Enten was forged for.",
            'After defeating a Blind, gain {C:mult}+#1#{} Mult.',
            'Current: {C:mult}+#3#{} Mult (max {C:mult}+#2#{}).'
        }
    },

    atlas = 'Joker',
    prefix_config = { atlas = false },

    pos = {
        x = 0,
        y = 0
    },

    rarity = BACHILATRO_WIELDER_PRESETS.chihiro.rarity,
    cost = BACHILATRO_WIELDER_PRESETS.chihiro.cost,

    in_pool = function(self, args)
        return BACHILATRO_has_sword(
            BACHILATRO_WIELDER_PRESETS.chihiro.sword_key
        )
    end,

    config = {
        extra = {
            mult_mod = BACHILATRO_WIELDER_PRESETS.chihiro.ability.mult_per_blind,
            mult_cap = BACHILATRO_WIELDER_PRESETS.chihiro.ability.mult_cap,
            mult = 0
        }
    },

    loc_vars = function(self, info_queue, card)
        local current_mult = card and card.ability.extra.mult
            or self.config.extra.mult
        return {
            vars = {
                self.config.extra.mult_mod,
                self.config.extra.mult_cap,
                current_mult
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
            hold = 3,
            major = sword,
            backdrop_colour = G.C.BLUE,
            align = 'cm',
            offset = { x = 0, y = -0.5 },
            silent = true
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{
                    type = 'variable',
                    key = 'a_mult',
                    vars = { card.ability.extra.mult }
                },
                colour = G.C.MULT,
                mult_mod = card.ability.extra.mult
            }
        end

        if context.end_of_round
            and context.main_eval
            and not context.blueprint
            and not context.game_over
            and G.GAME.blind
            and card.ability.extra.mult < self.config.extra.mult_cap
        then
            card.ability.extra.mult = math.min(
                self.config.extra.mult_cap,
                card.ability.extra.mult + self.config.extra.mult_mod
            )
            return {
                message = 'Tempered',
                colour = G.C.MULT
            }
        end
    end
}
