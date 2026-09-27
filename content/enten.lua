--------------------------------------------------
-- ENTEN
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

    if BACHILATRO_has_chihiro() then
        return true
    end

    return blind.boss and not blind.disabled
end

SMODS.Consumable {
    key = 'enten',

    set = 'EnchantedBlade',

    loc_txt = {
        name = 'Enten',

        text = {
            "It yearns for its owner.",
            "{C:attention}KURO{}: Destroy #1# selected cards. (#6# Energy)",
            "{C:attention}AKA{}: #2# (#3# Energy)",
            "{C:attention}NISHIKI{}: #4#",
            "#5# (#7# Energy)"
        }
    },

    loc_vars = function(self, info_queue, card)
        local chihiro = BACHILATRO_has_chihiro()
        return {
            vars = {
                chihiro and '2 or 3' or '2',
                chihiro
                    and "Copy 2 selected Jokers this round."
                    or "Copy a selected Joker this round.",
                BACHILATRO_get_sword_ability_cost('enten', 'aka', chihiro),
                chihiro
                    and ('Any Blind: -' .. math.floor(BACHILATRO_get_sword_ability(
                        'enten', 'nishiki'
                    ).blind_effect.score_reduction * 100) .. '% score target')
                    or 'Boss Blind only',
                chihiro
                    and 'Boss Blind: also disable its effect'
                    or 'Disable its effect',
                BACHILATRO_get_sword_ability_cost('enten', 'kuro', chihiro),
                BACHILATRO_get_sword_ability_cost('enten', 'nishiki', chihiro)
            }
        }
    end,

    atlas = BACHILATRO_SWORD_PRESETS.enten.atlas,

    pos = BACHILATRO_SWORD_PRESETS.enten.pos,

    cost = BACHILATRO_SWORD_PRESETS.enten.cost,

    config = {
        extra_slots_used = 1
    },



    --------------------------------------------------
    -- COMPROBAR SI PUEDE USARSE
    --------------------------------------------------

    can_use = function(self, card)

        local efecto =
            card.ability.bachilatro_ability

        local energy =
            G.GAME.bachilatro_energy or 0

        if efecto == 1 then
            return energy >= BACHILATRO_get_sword_ability_cost('enten', 'kuro', BACHILATRO_has_chihiro())
                and BACHILATRO_kuro_selection_count() > 0

        elseif efecto == 2 then
            local highlighted = G.jokers and G.jokers.highlighted or {}
            local required = BACHILATRO_aka_selection_count()
            if energy < BACHILATRO_aka_cost() then return false end
            if BACHILATRO_is_shop_context(card)
                or not card.area
                or G.GAME.bachilatro_aka_used
                or #highlighted ~= required
            then return false end
            for _, target in ipairs(highlighted) do
                if not BACHILATRO_is_aka_target_valid(target) then
                    return false
                end
            end
            return true

        elseif efecto == 3 then
            return energy >= BACHILATRO_get_sword_ability_cost('enten', 'nishiki', BACHILATRO_has_chihiro())
                and BACHILATRO_can_use_nishiki(card)
        end

        return false
    end,



    --------------------------------------------------
    -- ENTEN PERMANECE DESPUÉS DE USARLA
    --------------------------------------------------

    keep_on_use = function(self, card)
        return true
    end,



    --------------------------------------------------
    -- USAR HABILIDAD
    --------------------------------------------------

    use = function(self, card, area, copier)

        local efecto =
            card.ability.bachilatro_ability

        card.ability.bachilatro_ability = nil

        if efecto ~= 1 and efecto ~= 2 and efecto ~= 3 then
            return
        end

        if efecto == 1 then
            local required = BACHILATRO_kuro_selection_count()
            if required == 0 then
                return
            end

            local selected_cards = {}
            for i = 1, required do
                selected_cards[i] = G.hand.highlighted[i]
            end

            G.hand:unhighlight_all()

            G.GAME.bachilatro_energy = math.max(
                0,
                (G.GAME.bachilatro_energy or 0) - BACHILATRO_get_sword_ability_cost('enten', 'kuro', BACHILATRO_has_chihiro())
            )
            BACHILATRO_refresh_energy_hud()

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    for i, selected_card in ipairs(selected_cards) do
                        selected_card:start_dissolve(
                            nil,
                            i == #selected_cards
                        )
                    end
                    return true
                end
            }))
        elseif efecto == 2 then
            local selected_jokers = G.jokers
                and G.jokers.highlighted or {}
            local required = BACHILATRO_aka_selection_count()
            local cost = BACHILATRO_aka_cost()

            if #selected_jokers ~= required
                or not card.area
                or card.area.config.type == 'shop'
                or G.GAME.bachilatro_aka_used
                or (G.GAME.bachilatro_energy or 0) < cost
            then
                return
            end

            for _, selected_joker in ipairs(selected_jokers) do
                if not BACHILATRO_is_aka_target_valid(selected_joker) then
                    return
                end
            end

            for _, joker in ipairs(G.jokers.cards) do
                joker.ability.bachilatro_aka_copy = nil
            end
            for _, selected_joker in ipairs(selected_jokers) do
                selected_joker.ability.bachilatro_aka_copy = true
            end
            G.GAME.bachilatro_aka_used = true
            G.jokers:unhighlight_all()

            G.GAME.bachilatro_energy = math.max(
                0,
                (G.GAME.bachilatro_energy or 0) - cost
            )
            BACHILATRO_refresh_energy_hud()

            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = 'AKA',
                colour = G.C.RED
            })
        elseif efecto == 3 then
            local blind = G.GAME.blind
            local chihiro = BACHILATRO_has_chihiro()
            if not BACHILATRO_can_use_nishiki(card)
                or (G.GAME.bachilatro_energy or 0) < BACHILATRO_get_sword_ability_cost('enten', 'nishiki', BACHILATRO_has_chihiro())
            then
                return
            end

            G.GAME.bachilatro_energy = math.max(
                0,
                (G.GAME.bachilatro_energy or 0) - BACHILATRO_get_sword_ability_cost('enten', 'nishiki', BACHILATRO_has_chihiro())
            )
            BACHILATRO_refresh_energy_hud()

            if chihiro then
                blind.chips = math.max(
                    1,
                    math.floor(blind.chips * (1 - BACHILATRO_get_sword_ability(BACHILATRO_get_sword_preset('enten'), 'nishiki').blind_effect.score_reduction))
                )
                blind.chip_text = number_format(blind.chips)
                SMODS.juice_up_blind()
            end

            if blind.boss then
                blind:disable()
            end
            play_sound('timpani')
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = 'NISHIKI',
                colour = G.C.BLUE
            })
        end

    end
}



--------------------------------------------------
-- KURO
--------------------------------------------------

G.FUNCS.bachilatro_can_use_kuro = function(e)
    local has_card = e.config.ref_table ~= nil
    local has_required_selected = BACHILATRO_kuro_selection_count() > 0
    local has_energy = G.GAME
        and (G.GAME.bachilatro_energy or 0) >= BACHILATRO_get_sword_ability_cost('enten', 'kuro', BACHILATRO_has_chihiro())

    if has_card and has_required_selected and has_energy then
        e.config.button = 'bachilatro_enten_kuro'
        e.config.colour = HEX('707070')
    else
        e.config.button = nil
        e.config.colour = HEX('353535')
    end
end

G.FUNCS.bachilatro_can_use_aka = function(e)
    local highlighted = G.jokers and G.jokers.highlighted or {}
    local required = BACHILATRO_aka_selection_count()
    local can_use = e.config.ref_table
        and e.config.ref_table.area
        and not BACHILATRO_is_shop_context(e.config.ref_table)
        and G.GAME
        and (G.GAME.bachilatro_energy or 0) >= BACHILATRO_aka_cost()
        and not G.GAME.bachilatro_aka_used
        and #highlighted == required

    if can_use then
        for _, target in ipairs(highlighted) do
            if not BACHILATRO_is_aka_target_valid(target) then
                can_use = false
                break
            end
        end
    end

    if can_use then
        e.config.button = 'bachilatro_enten_aka'
        e.config.colour = HEX('707070')
    else
        e.config.button = nil
        e.config.colour = HEX('353535')
    end
end

G.FUNCS.bachilatro_can_use_nishiki = function(e)
    local can_use = e.config.ref_table
        and G.GAME
        and (G.GAME.bachilatro_energy or 0) >= BACHILATRO_get_sword_ability_cost('enten', 'nishiki', BACHILATRO_has_chihiro())
        and BACHILATRO_can_use_nishiki(e.config.ref_table)

    if can_use then
        e.config.button = 'bachilatro_enten_nishiki'
        e.config.colour = HEX('707070')
    else
        e.config.button = nil
        e.config.colour = HEX('353535')
    end
end

G.FUNCS.bachilatro_enten_kuro = function(e)

    local card =
        e.config.ref_table

    if not card then
        return
    end

    if (G.GAME.bachilatro_energy or 0)
        < BACHILATRO_get_sword_ability_cost('enten', 'kuro', BACHILATRO_has_chihiro())
        or BACHILATRO_kuro_selection_count() == 0
    then
        return
    end

    card.ability.bachilatro_ability = 1
    G.FUNCS.use_card(e)

end



--------------------------------------------------
-- AKA
--------------------------------------------------

G.FUNCS.bachilatro_enten_aka = function(e)

    local card =
        e.config.ref_table

    if not card then
        return
    end

    if (G.GAME.bachilatro_energy or 0)
        < BACHILATRO_aka_cost()
        or not card.area
        or BACHILATRO_is_shop_context(card)
        or G.GAME.bachilatro_aka_used
        or not G.jokers
        or #G.jokers.highlighted ~= BACHILATRO_aka_selection_count()
    then
        return
    end

    for _, target in ipairs(G.jokers.highlighted) do
        if not BACHILATRO_is_aka_target_valid(target) then
            return
        end
    end

    card.ability.bachilatro_ability = 2

    G.FUNCS.use_card(e)

end



--------------------------------------------------
-- NISHIKI
--------------------------------------------------

G.FUNCS.bachilatro_enten_nishiki = function(e)

    local card =
        e.config.ref_table

    if not card then
        return
    end

    if (G.GAME.bachilatro_energy or 0)
        < BACHILATRO_get_sword_ability_cost('enten', 'nishiki', BACHILATRO_has_chihiro())
        or not BACHILATRO_can_use_nishiki(card)
    then
        return
    end

    card.ability.bachilatro_ability = 3

    G.FUNCS.use_card(e)

end
