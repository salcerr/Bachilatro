-- YURA
-- Starting Joker of the Hishaku Deck. He wields Magatsumi through borrowed
-- flesh: while it lasts, the deck is drained every Blind. After the last
-- Blind of the phase he becomes Akemura Soga (see mechanics/swords/magatsumi_abilities.lua).

SMODS.Joker {
    key = 'yura',

    loc_txt = {
        name = 'Yura',
        text = {
            'Borrowed flesh, borrowed blade.',
            '{C:attention}+#1#{} hand size',
            'Each Blind, every card in your deck',
            'has a {C:green}#2#{} chance to lose a rank.',
            '{C:inactive}(Blind {C:attention}#3#{C:inactive}/#4#){}'
        }
    },

    atlas = BACHILATRO_YURA_ATLAS,
    prefix_config = { atlas = false },
    pos = { x = 0, y = 0 },
    rarity = BACHILATRO_WIELDER_PRESETS.yura.rarity,
    cost = BACHILATRO_WIELDER_PRESETS.yura.cost,
    blueprint_compat = false,

    in_pool = function(self, args)
        return false
    end,

    loc_vars = function(self, info_queue, card)
        local config = BACHILATRO_WIELDER_PRESETS.yura.ability
        local state = BACHILATRO_magatsumi_state()
        local done = state and state.blinds or 0
        return {
            vars = {
                config.hand_size,
                math.floor(config.rank_loss_chance * 100 + 0.5) .. '%',
                math.min(config.debuff_blinds, done),
                config.debuff_blinds
            }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(BACHILATRO_WIELDER_PRESETS.yura.ability.hand_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-BACHILATRO_WIELDER_PRESETS.yura.ability.hand_size)
    end
}
