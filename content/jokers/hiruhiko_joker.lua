-- HIRUHIKO
-- Upgrades Kumeyuri while held. Gains Mult for every playing card destroyed
-- (any source). Kumeyuri's En copies vanishing do NOT count.

SMODS.Joker {
    key = 'hiruhiko',

    loc_txt = {
        name = 'Hiruhiko',
        text = {
            'Lost his paper, kept his smile.',
            'Gains {X:mult,C:white}X#1#{} Mult for each',
            'playing card destroyed.',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}'
        }
    },

    atlas = BACHILATRO_HIRUHIKO_ATLAS,
    prefix_config = { atlas = false },
    pos = { x = 0, y = 0 },
    rarity = BACHILATRO_WIELDER_PRESETS.hiruhiko.rarity,
    cost = BACHILATRO_WIELDER_PRESETS.hiruhiko.cost,
    blueprint_compat = false,

    in_pool = function(self, args)
        return BACHILATRO_has_sword(BACHILATRO_WIELDER_PRESETS.hiruhiko.sword_key)
    end,

    config = {
        extra = {
            xmult = BACHILATRO_WIELDER_PRESETS.hiruhiko.ability.xmult_start
        }
    },

    loc_vars = function(self, info_queue, card)
        local preset = BACHILATRO_WIELDER_PRESETS.hiruhiko.ability
        local xmult = card and card.ability.extra.xmult or preset.xmult_start
        return { vars = {
            string.format('%.1f', preset.xmult_per_destroyed_card),
            string.format('%.1f', xmult)
        } }
    end,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then return end
        local sword = BACHILATRO_find_sword(
            BACHILATRO_WIELDER_PRESETS.hiruhiko.sword_key
        )
        if not sword then return end

        sword:juice_up()
        attention_text({
            text = 'KUMEYURI UPGRADED!',
            scale = 1.2,
            hold = 2,
            major = sword,
            backdrop_colour = G.C.PURPLE,
            align = 'cm',
            offset = { x = 0, y = -0.5 },
            silent = true
        })
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local destroyed = 0
            for _, removed in ipairs(context.removed or {}) do
                if not (removed.ability and removed.ability.bachilatro_illusion) then
                    destroyed = destroyed + 1
                end
            end
            if destroyed > 0 then
                local gain = BACHILATRO_WIELDER_PRESETS.hiruhiko.ability.xmult_per_destroyed_card
                card.ability.extra.xmult = card.ability.extra.xmult + gain * destroyed
                return {
                    message = localize{
                        type = 'variable',
                        key = 'a_xmult',
                        vars = { card.ability.extra.xmult }
                    },
                    colour = G.C.MULT
                }
            end
        end

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