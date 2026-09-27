-- Shared lookups and rules for the data stored in sword presets.
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

function BACHILATRO_get_sword_preset_for_card(card)
    local center_key = card and card.config and card.config.center_key
    if not center_key then return nil end
    for _, preset in pairs(BACHILATRO_SWORD_PRESETS) do
        if preset.consumable_key == center_key then return preset end
    end
    return nil
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

function BACHILATRO_sword_ability_is_upgraded(preset, ability_key)
    if type(preset) == 'string' then
        preset = BACHILATRO_get_sword_preset(preset)
    end
    if not preset or not preset.wielder
        or not BACHILATRO_sword_has_wielder(preset)
    then
        return false
    end

    for _, upgraded_ability in ipairs(preset.wielder.upgrade_abilities or {}) do
        if upgraded_ability == ability_key then return true end
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
        if BACHILATRO_has_sword(key) then
            for _, ability in ipairs(preset.abilities or {}) do
                local selection = ability.selection
                if selection and selection.area == area then
                    local required = selection.max or selection.min
                    if BACHILATRO_sword_ability_is_upgraded(preset, ability.key) then
                        required = selection.upgraded_max
                            or selection.upgraded_min
                            or required
                    end
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
