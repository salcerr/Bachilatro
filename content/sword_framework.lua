-- Small shared layer for sword presets. Sword-specific behavior stays in its
-- preset/callbacks; optional fields permit nonstandard modes (e.g. proxy use).
BACHILATRO_SWORD_PRESETS = BACHILATRO_SWORD_PRESETS or {}

function BACHILATRO_get_sword_preset(key)
    return BACHILATRO_SWORD_PRESETS[key]
end

function BACHILATRO_get_sword_ability(preset, ability_key)
    if type(preset) == 'string' then
        preset = BACHILATRO_get_sword_preset(preset)
    end
    if not preset then return nil end
    for _, ability in ipairs(preset.abilities or {}) do
        if ability.key == ability_key then return ability end
    end
end

function BACHILATRO_get_sword_ability_cost(preset, ability_key, upgraded)
    local ability = BACHILATRO_get_sword_ability(preset, ability_key)
    if not ability then return nil end
    return upgraded and (ability.upgraded_cost or ability.cost) or ability.cost
end

function BACHILATRO_sword_has_wielder(preset)
    if type(preset) == 'string' then
        preset = BACHILATRO_get_sword_preset(preset)
    end
    if not preset or not preset.wielder or not G.jokers then return false end
    for _, joker in ipairs(G.jokers.cards) do
        if not joker.debuff and joker.config and joker.config.center
            and joker.config.center.key == preset.wielder.joker_key then
            return true
        end
    end
    return false
end


function BACHILATRO_has_sword(key)
    return BACHILATRO_find_sword(key) ~= nil
end


function BACHILATRO_find_sword(key)
    local preset = BACHILATRO_get_sword_preset(key)
    if not preset or not G.consumeables then return nil end
    for _, card in ipairs(G.consumeables.cards) do
        if card.config and card.config.center_key == preset.consumable_key then
            return card
        end
    end
    return nil
end



function BACHILATRO_sword_selection_limit(area, base_limit)
    local limit = base_limit or 1
    for key, preset in pairs(BACHILATRO_SWORD_PRESETS) do
        if BACHILATRO_has_sword(key)
            and BACHILATRO_sword_has_wielder(preset) then
            for _, ability in ipairs(preset.abilities or {}) do
                local selection = ability.selection
                if selection and selection.area == area then
                    local required = selection.upgraded_max
                        or selection.upgraded_min
                        or selection.max
                        or selection.min
                    limit = math.max(limit, required or 1)
                end
            end
        end
    end
    return limit
end


function BACHILATRO_is_shop_context(card)
    if G.STATES and G.STATE == G.STATES.SHOP then return true end
    return card and card.area and card.area.config
        and card.area.config.type == 'shop' or false
end
