--------------------------------------------------
-- TOBIMUNE
--------------------------------------------------

SMODS.Consumable {
    key = 'tobimune',
    set = 'EnchantedBlade',

    loc_txt = {
        name = 'Tobimune',
        text = {
            'Black feathers answer its name.',
            '{C:attention}CROW{}: Swap 1 selected card with',
            'a card from your deck. {C:purple}(#1# Energy){}',
            '{C:attention}OWL{}: Choose a Joker rarity. This Ante,',
            'shop Jokers have a {C:green}#2#{} chance to be it. {C:purple}(#3# Energy){}',
            '{C:attention}SUZAKU{}: Raise #4# selected cards by {C:attention}1{} rank. {C:purple}(#5# Energy){}'
        }
    },

    loc_vars = function(self, info_queue, card)
        local suzaku_min, suzaku_max = BACHILATRO_tobimune_suzaku_range()
        local cards_text = suzaku_min == suzaku_max
            and tostring(suzaku_max)
            or ('up to ' .. suzaku_max)
        return {
            vars = {
                BACHILATRO_tobimune_cost('crow'),
                math.floor(BACHILATRO_tobimune_owl_chance() * 100 + 0.5) .. '%',
                BACHILATRO_tobimune_cost('owl'),
                cards_text,
                BACHILATRO_tobimune_cost('suzaku')
            }
        }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.tobimune.atlas,
    pos = BACHILATRO_SWORD_PRESETS.tobimune.pos,
    cost = BACHILATRO_SWORD_PRESETS.tobimune.cost,
    config = { extra_slots_used = 0 },

    can_use = function(self, card)
        return BACHILATRO_can_use_tobimune_ability(card)
    end,

    keep_on_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)
        BACHILATRO_use_tobimune_ability(card)
    end
}