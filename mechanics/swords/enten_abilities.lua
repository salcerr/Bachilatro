--------------------------------------------------
-- REGLAS Y HABILIDADES DE ENTEN
--------------------------------------------------

function BACHILATRO_is_aka_target_valid(joker)
    if not joker or joker.debuff or not joker.config or not joker.config.center then
        return false
    end

    local center = joker.config.center
    return center.blueprint_compat
        and center.key ~= 'j_blueprint'
        and center.key ~= 'j_brainstorm'
end

function BACHILATRO_all_aka_targets_valid(targets)
    for _, target in ipairs(targets) do
        if not BACHILATRO_is_aka_target_valid(target) then return false end
    end
    return true
end

function BACHILATRO_has_chihiro()
    return BACHILATRO_sword_has_wielder('enten')
end

function BACHILATRO_kuro_selection_count()
    local preset = BACHILATRO_get_sword_preset('enten')
    local ability = BACHILATRO_get_sword_ability(preset, 'kuro')
    if not G.hand or not ability then return 0 end

    local selected = #G.hand.highlighted
    local upgraded = BACHILATRO_sword_has_wielder(preset)
    local minimum = upgraded and (ability.selection.upgraded_min or ability.selection.min)
        or ability.selection.min
    local maximum = upgraded and (ability.selection.upgraded_max or ability.selection.max)
        or ability.selection.max or minimum
    if selected >= minimum and selected <= maximum then return selected end
    return 0
end

function BACHILATRO_aka_selection_count()
    local ability = BACHILATRO_get_sword_ability('enten', 'aka')
    if not ability then return 0 end
    return BACHILATRO_has_chihiro()
        and (ability.selection.upgraded_min or ability.selection.min)
        or ability.selection.min
end

function BACHILATRO_aka_cost()
    return BACHILATRO_get_sword_ability_cost(
        'enten', 'aka', BACHILATRO_has_chihiro()
    )
end

function BACHILATRO_can_use_nishiki(card)
    if card and card.area and card.area.config.type == 'shop' then
        return false
    end

    local blind = G.GAME and G.GAME.blind
    if not blind then return false end
    if BACHILATRO_has_chihiro() then return true end
    return blind.boss and not blind.disabled
end

function BACHILATRO_can_use_enten_ability(card)
    if not card or not G.GAME then return false end

    local ability = card.ability.bachilatro_ability
    local energy = G.GAME.bachilatro_energy or 0
    if ability == 1 then
        return energy >= BACHILATRO_get_sword_ability_cost(
            'enten', 'kuro', BACHILATRO_has_chihiro()
        ) and BACHILATRO_kuro_selection_count() > 0
    elseif ability == 2 then
        local highlighted = G.jokers and G.jokers.highlighted or {}
        local required = BACHILATRO_aka_selection_count()
        if energy < BACHILATRO_aka_cost()
            or BACHILATRO_is_shop_context(card)
            or not card.area
            or G.GAME.bachilatro_aka_used
            or #highlighted ~= required
        then
            return false
        end
        return BACHILATRO_all_aka_targets_valid(highlighted)
    elseif ability == 3 then
        return energy >= BACHILATRO_get_sword_ability_cost(
            'enten', 'nishiki', BACHILATRO_has_chihiro()
        ) and BACHILATRO_can_use_nishiki(card)
    end
    return false
end

function BACHILATRO_use_enten_ability(card)
    local ability = card.ability.bachilatro_ability
    card.ability.bachilatro_ability = nil
    if ability ~= 1 and ability ~= 2 and ability ~= 3 then return end

    if ability == 1 then
        local required = BACHILATRO_kuro_selection_count()
        if required == 0 then return end

        local selected_cards = {}
        for i = 1, required do
            selected_cards[i] = G.hand.highlighted[i]
        end
        G.hand:unhighlight_all()

        BACHILATRO_spend_energy(BACHILATRO_get_sword_ability_cost(
            'enten', 'kuro', BACHILATRO_has_chihiro()
        ))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for i, selected_card in ipairs(selected_cards) do
                    selected_card:start_dissolve(nil, i == #selected_cards)
                end
                return true
            end
        }))
    elseif ability == 2 then
        local selected_jokers = G.jokers and G.jokers.highlighted or {}
        local required = BACHILATRO_aka_selection_count()
        local cost = BACHILATRO_aka_cost()
        if #selected_jokers ~= required
            or not card.area
            or BACHILATRO_is_shop_context(card)
            or G.GAME.bachilatro_aka_used
            or (G.GAME.bachilatro_energy or 0) < cost
            or not BACHILATRO_all_aka_targets_valid(selected_jokers)
        then
            return
        end

        for _, joker in ipairs(G.jokers.cards) do
            joker.ability.bachilatro_aka_copy = nil
        end
        for _, selected_joker in ipairs(selected_jokers) do
            selected_joker.ability.bachilatro_aka_copy = true
        end
        G.GAME.bachilatro_aka_used = true
        G.jokers:unhighlight_all()

        BACHILATRO_spend_energy(cost)
        card_eval_status_text(card, 'extra', nil, nil, nil, {
            message = 'AKA',
            colour = G.C.RED
        })
    elseif ability == 3 then
        local blind = G.GAME.blind
        local chihiro = BACHILATRO_has_chihiro()
        local cost = BACHILATRO_get_sword_ability_cost('enten', 'nishiki', chihiro)
        if not BACHILATRO_can_use_nishiki(card)
            or (G.GAME.bachilatro_energy or 0) < cost
        then
            return
        end

        BACHILATRO_spend_energy(cost)
        if chihiro then
            local nishiki = BACHILATRO_get_sword_ability('enten', 'nishiki')
            blind.chips = math.max(
                1,
                math.floor(blind.chips * (1 - nishiki.blind_effect.score_reduction))
            )
            blind.chip_text = number_format(blind.chips)
            SMODS.juice_up_blind()
        end
        if blind.boss then blind:disable() end
        play_sound('timpani')
        card_eval_status_text(card, 'extra', nil, nil, nil, {
            message = 'NISHIKI',
            colour = G.C.BLUE
        })
    end
end

--------------------------------------------------
-- CALLBACKS DE LOS BOTONES DE ENTEN
--------------------------------------------------

G.FUNCS.bachilatro_can_use_kuro = function(e)
    local can_use = e.config.ref_table
        and BACHILATRO_kuro_selection_count() > 0
        and G.GAME
        and (G.GAME.bachilatro_energy or 0) >= BACHILATRO_get_sword_ability_cost(
            'enten', 'kuro', BACHILATRO_has_chihiro()
        )
    e.config.button = can_use and 'bachilatro_enten_kuro' or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

G.FUNCS.bachilatro_can_use_aka = function(e)
    local highlighted = G.jokers and G.jokers.highlighted or {}
    local required = BACHILATRO_aka_selection_count()
    local card = e.config.ref_table
    local can_use = card
        and card.area
        and not BACHILATRO_is_shop_context(card)
        and G.GAME
        and (G.GAME.bachilatro_energy or 0) >= BACHILATRO_aka_cost()
        and not G.GAME.bachilatro_aka_used
        and #highlighted == required
        and BACHILATRO_all_aka_targets_valid(highlighted)
    e.config.button = can_use and 'bachilatro_enten_aka' or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

G.FUNCS.bachilatro_can_use_nishiki = function(e)
    local card = e.config.ref_table
    local can_use = card
        and G.GAME
        and (G.GAME.bachilatro_energy or 0) >= BACHILATRO_get_sword_ability_cost(
            'enten', 'nishiki', BACHILATRO_has_chihiro()
        )
        and BACHILATRO_can_use_nishiki(card)
    e.config.button = can_use and 'bachilatro_enten_nishiki' or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

local function bachilatro_begin_enten_use(e, ability, is_valid)
    local card = e.config.ref_table
    if not card or not is_valid(card) then return end
    card.ability.bachilatro_ability = ability
    G.FUNCS.use_card(e)
end

G.FUNCS.bachilatro_enten_kuro = function(e)
    bachilatro_begin_enten_use(e, 1, function()
        return (G.GAME.bachilatro_energy or 0) >= BACHILATRO_get_sword_ability_cost(
            'enten', 'kuro', BACHILATRO_has_chihiro()
        ) and BACHILATRO_kuro_selection_count() > 0
    end)
end

G.FUNCS.bachilatro_enten_aka = function(e)
    bachilatro_begin_enten_use(e, 2, function(card)
        return (G.GAME.bachilatro_energy or 0) >= BACHILATRO_aka_cost()
            and card.area
            and not BACHILATRO_is_shop_context(card)
            and not G.GAME.bachilatro_aka_used
            and G.jokers
            and #G.jokers.highlighted == BACHILATRO_aka_selection_count()
            and BACHILATRO_all_aka_targets_valid(G.jokers.highlighted)
    end)
end

G.FUNCS.bachilatro_enten_nishiki = function(e)
    bachilatro_begin_enten_use(e, 3, function(card)
        return (G.GAME.bachilatro_energy or 0) >= BACHILATRO_get_sword_ability_cost(
            'enten', 'nishiki', BACHILATRO_has_chihiro()
        ) and BACHILATRO_can_use_nishiki(card)
    end)
end

--------------------------------------------------
-- EFECTO DE COPIA DE AKA
--------------------------------------------------

local bachilatro_original_calculate_joker = Card.calculate_joker

function Card:calculate_joker(context, ...)
    local effect, triggered = bachilatro_original_calculate_joker(self, context, ...)
    if not context
        or context.blueprint
        or context.no_blueprint
        or context.using_consumeable
        or not self.ability
        or not self.ability.bachilatro_aka_copy
        or not BACHILATRO_is_aka_target_valid(self)
        or not G.consumeables
    then
        return effect, triggered
    end

    local enten = BACHILATRO_find_sword('enten')
    if not enten then return effect, triggered end

    local old_blueprint_card = context.blueprint_card
    context.blueprint_card = enten
    local copied_effect = SMODS.blueprint_effect(enten, self, context)
    context.blueprint_card = old_blueprint_card
    if not copied_effect then return effect, triggered end

    local visual_effect = copied_effect
    while type(visual_effect) == 'table' do
        visual_effect.card = enten
        visual_effect.juice_card = enten
        visual_effect.message_card = enten
        visual_effect = visual_effect.extra
    end

    local effects = {}
    if effect then effects[#effects + 1] = effect end
    effects[#effects + 1] = copied_effect
    return #effects == 1 and effects[1] or SMODS.merge_effects(effects), triggered
end
