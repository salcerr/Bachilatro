-- AKEMURA SOGA
-- Yura's final form. Only Akemura can activate Magatsumi, so the effects of
-- its techniques that happen while scoring live in BACHILATRO_akemura_calculate.
-- Doubles max Energy and absorbs vitality (Energy) every time a Blind is beaten.

SMODS.Joker {
    key = 'akemura',

    loc_txt = {
        name = 'Akemura Soga',
        text = {
            'The blade has found its true bearer.',
            'Max Energy {C:attention}#1#{}',
            '{C:attention}+#2#{} Energy per Blind beaten'
        }
    },

    atlas = BACHILATRO_AKEMURA_ATLAS,
    prefix_config = { atlas = false },
    pos = { x = 0, y = 0 },
    rarity = BACHILATRO_WIELDER_PRESETS.akemura.rarity,
    cost = BACHILATRO_WIELDER_PRESETS.akemura.cost,
    blueprint_compat = false,

    in_pool = function(self, args)
        return false
    end,

    loc_vars = function(self, info_queue, card)
        local config = BACHILATRO_WIELDER_PRESETS.akemura.ability
        return {
            vars = {
                BACHILATRO_ENERGY_MAX + config.energy_bonus,
                config.energy_per_blind
            }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.bachilatro_energy_max_bonus =
            BACHILATRO_WIELDER_PRESETS.akemura.ability.energy_bonus
        BACHILATRO_refill_energy()
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bachilatro_energy_max_bonus = 0
        G.GAME.bachilatro_energy = math.min(
            G.GAME.bachilatro_energy or 0,
            BACHILATRO_get_energy_max()
        )
        BACHILATRO_refresh_energy_hud()
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval
            and not context.game_over and not context.blueprint
        then
            local gain = BACHILATRO_WIELDER_PRESETS.akemura.ability.energy_per_blind
            BACHILATRO_gain_energy(gain)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = '+' .. gain .. ' ENERGY',
                colour = G.C.PURPLE
            })
        end

        return BACHILATRO_akemura_calculate(card, context)
    end
}
