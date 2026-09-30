-- Pack offering two different Enchanted Blades.
local function BACHILATRO_pack_sword_keys()
    local keys = {}
    for _, preset in pairs(BACHILATRO_SWORD_PRESETS) do
        local key = preset.consumable_key
        if key and G.P_CENTERS[key] then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

SMODS.Booster {
    key = 'enchanted_blade_pack',
    atlas = 'enchanted_blade_pack_art',
    loc_txt = {
        name = 'Enchanted Blade Pack',
        text = {
            'Choose 1 of up to 2',
            'Enchanted Blades.'
        },
        group_name = 'Enchanted Blades'
    },
    kind = 'EnchantedBlade',
    config = {
        extra = 2,
        choose = 1
    },
    cost = 4,
    weight = 0.5,

    create_card = function(self, card, i)
        if i == 1 then
            card.ability.bachilatro_blade_pack_picks = {}
        end

        local picked = card.ability.bachilatro_blade_pack_picks or {}
        local candidates = {}
        for _, key in ipairs(BACHILATRO_pack_sword_keys()) do
            if not picked[key] then
                candidates[#candidates + 1] = key
            end
        end

        if #candidates == 0 then
            candidates = BACHILATRO_pack_sword_keys()
        end

        local key = pseudorandom_element(
            candidates,
            pseudoseed('bachilatro_blade_pack_' .. tostring(i or 1))
        )
        picked[key] = true
        card.ability.bachilatro_blade_pack_picks = picked

        return {
            key = key,
            set = 'EnchantedBlade',
            area = G.pack_cards,
            skip_materialize = true,
            key_append = 'bachilatro_blade_pack'
        }
    end
}
