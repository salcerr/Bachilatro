-- Starts the run with Yura and the sealed Magatsumi, "Shinuchi".
-- For 9 Blinds the blade only drains your deck; then Yura becomes Akemura
-- Soga and the sword unlocks its full power.
SMODS.Back {
    key = 'shinuchi',
    atlas = 'shinuchi_deck_art',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Shinuchi Deck',
        text = {
            'Start with {C:attention}Yura{} and the sealed',
            '{C:attention}Magatsumi{}, the blade of captured sin.',
            'It drains your deck for {C:attention}9{} Blinds.',
            'Survive them to awaken its power.'
        }
    },
    unlocked = true,
    discovered = true,

    apply = function(self, back)
        G.GAME.bachilatro_magatsumi = { blinds = 0, awakened = false }

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0,
            func = function()
                local yura = SMODS.add_card({
                    key = 'j_bachilatro_yura',
                    area = G.jokers
                })
                if yura then
                    if yura.set_eternal then
                        yura:set_eternal(true)
                    else
                        yura.ability.eternal = true
                    end
                end

                SMODS.add_card({
                    key = 'c_bachilatro_magatsumi',
                    area = G.consumeables
                })
                return true
            end
        }))
    end
}
