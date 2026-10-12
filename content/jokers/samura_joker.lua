-- SEIICHI SAMURA
-- Upgrades Tobimune while held. Its only ability: if a Blind would be lost
-- after using Suzaku in it, the run survives and Samura is destroyed
-- (like Mr. Bones, but with no minimum score).

local previous_process_loc_text = SMODS.current_mod.process_loc_text
SMODS.current_mod.process_loc_text = function(...)
    if previous_process_loc_text then previous_process_loc_text(...) end
    G.localization.misc.dictionary.ph_bachilatro_samura = 'Saved by Samura'
end

SMODS.Joker {
    key = 'samura',

    loc_txt = {
        name = 'Seiichi Samura',
        text = {
            'The fastest of the six bearers.',
            'Prevents Death if {C:attention}Suzaku{} was used',
            'this Blind. {C:red}Self destructs{}.'
        }
    },

    atlas = BACHILATRO_SAMURA_ATLAS,
    prefix_config = { atlas = false },
    pos = { x = 0, y = 0 },
    rarity = BACHILATRO_WIELDER_PRESETS.samura.rarity,
    cost = BACHILATRO_WIELDER_PRESETS.samura.cost,
    blueprint_compat = false,
    eternal_compat = false,

    in_pool = function(self, args)
        return BACHILATRO_has_sword(BACHILATRO_WIELDER_PRESETS.samura.sword_key)
    end,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then return end
        local sword = BACHILATRO_find_sword(
            BACHILATRO_WIELDER_PRESETS.samura.sword_key
        )
        if not sword then return end

        sword:juice_up()
        attention_text({
            text = 'TOBIMUNE UPGRADED!',
            scale = 1.2,
            hold = 2,
            major = sword,
            backdrop_colour = G.C.RED,
            align = 'cm',
            offset = { x = 0, y = -0.5 },
            silent = true
        })
    end,

    calculate = function(self, card, context)
        if context.end_of_round
            and context.game_over
            and context.main_eval
            and not context.blueprint
            and G.GAME.bachilatro_suzaku_used_blind
        then
            -- consume la marca: con dos Samura solo uno se sacrifica
            G.GAME.bachilatro_suzaku_used_blind = nil
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('tarot1')
                    card:start_dissolve()
                    return true
                end
            }))
            return {
                message = localize('k_saved_ex'),
                saved = 'ph_bachilatro_samura',
                colour = G.C.RED
            }
        end
    end
}