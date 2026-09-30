-- Starts each run with one randomly chosen Enchanted Blade.
SMODS.Back {
    key = 'rokuhira_legacy',
    atlas = 'rokuhira_legacy_deck_art',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = "Rokuhira's Legacy Deck",
        text = {
            'Start each run with',
            '1 random Enchanted Blade.'
        }
    },
    unlocked = true,
    discovered = true,

    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0,
            func = function()
                SMODS.add_card({
                    set = 'EnchantedBlade',
                    area = G.consumeables,
                    key_append = 'rokuhira_legacy'
                })
                return true
            end
        }))
    end
}
