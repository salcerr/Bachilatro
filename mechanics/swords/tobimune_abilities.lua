--------------------------------------------------
-- REGLAS Y HABILIDADES DE TOBIMUNE
-- KARASU: cambia una carta de la mano por una del mazo.
-- FUKURO: sube la probabilidad de una rareza de Joker en la tienda (por Ante).
-- SUZAKU: sube +1 de rank a cartas de la mano.
--------------------------------------------------

local ABILITY_KEYS = { 'karasu', 'fukuro', 'suzaku' }

local function upgraded(key)
    return BACHILATRO_sword_ability_is_upgraded('tobimune', key)
end

function BACHILATRO_tobimune_cost(key)
    return BACHILATRO_get_sword_ability_cost('tobimune', key, upgraded(key))
end

function BACHILATRO_tobimune_fukuro_chance()
    local fukuro = BACHILATRO_get_sword_ability('tobimune', 'fukuro')
    if upgraded('fukuro') then
        return fukuro.upgraded_shop_joker_chance or fukuro.shop_joker_chance
    end
    return fukuro.shop_joker_chance
end

function BACHILATRO_tobimune_suzaku_range()
    local selection = BACHILATRO_get_sword_ability('tobimune', 'suzaku').selection
    if upgraded('suzaku') then
        return selection.upgraded_min or selection.min,
            selection.upgraded_max or selection.max
    end
    return selection.min, selection.max
end

local function suzaku_targets()
    if not G.hand then return {} end
    local selected = #G.hand.highlighted
    local min, max = BACHILATRO_tobimune_suzaku_range()
    if selected >= min and selected <= max then return G.hand.highlighted end
    return {}
end

local function karasu_source()
    if G.hand and #G.hand.highlighted == 1 then return G.hand.highlighted[1] end
    return nil
end

local function can_use_tobimune(card, key)
    if not card or not G.GAME or G.OVERLAY_MENU then return false end
    if (G.GAME.bachilatro_energy or 0) < BACHILATRO_tobimune_cost(key) then
        return false
    end
    -- Fukuro se puede usar tambien en la tienda: tiene sentido usarla y rerollear.
    if key == 'fukuro' then return true end
    if BACHILATRO_is_shop_context(card) then return false end
    if key == 'karasu' then
        return karasu_source() ~= nil and G.deck ~= nil and #G.deck.cards > 0
    elseif key == 'suzaku' then
        return G.GAME.blind ~= nil and #suzaku_targets() > 0
    end
    return false
end

function BACHILATRO_can_use_tobimune_ability(card)
    local key = card and ABILITY_KEYS[card.ability.bachilatro_ability]
    return key ~= nil and can_use_tobimune(card, key)
end

--------------------------------------------------
-- KARASU
-- La carta de la mano baja al FONDO del mazo (CardArea:emplace inserta al
-- principio en el mazo), asi no se vuelve a robar enseguida.
--------------------------------------------------

function BACHILATRO_karasu_swap(sword, hand_card, deck_card)
    local cost = BACHILATRO_tobimune_cost('karasu')
    if not (sword and hand_card and deck_card and G.hand and G.deck)
        or hand_card.area ~= G.hand
        or deck_card.area ~= G.deck
        or (G.GAME.bachilatro_energy or 0) < cost
    then
        return
    end

    BACHILATRO_spend_energy(cost)
    G.hand:unhighlight_all()
    card_eval_status_text(sword, 'extra', nil, nil, nil, {
        message = 'KARASU',
        colour = G.C.BLACK
    })
    -- draw_card ya encola sus propios eventos
    draw_card(G.hand, G.deck, nil, 'down', nil, hand_card)
    draw_card(G.deck, G.hand, nil, 'up', true, deck_card)
end

--------------------------------------------------
-- FUKURO
--------------------------------------------------

function BACHILATRO_apply_fukuro(sword, rarity_key)
    local cost = BACHILATRO_tobimune_cost('fukuro')
    if not G.GAME or (G.GAME.bachilatro_energy or 0) < cost then return end

    BACHILATRO_spend_energy(cost)
    G.GAME.bachilatro_fukuro = { rarity = rarity_key }
    if sword then
        card_eval_status_text(sword, 'extra', nil, nil, nil, {
            message = 'FUKURO: ' .. string.upper(rarity_key),
            colour = G.C.PURPLE
        })
    end
end

local function fukuro_rarity_data()
    local fukuro = G.GAME and G.GAME.bachilatro_fukuro
    if not fukuro then return nil end
    local ability = BACHILATRO_get_sword_ability('tobimune', 'fukuro')
    for _, rarity in ipairs(ability.rarities) do
        if rarity.key == fukuro.rarity then return rarity end
    end
end

local function joker_matches_rarity(card, rarity)
    local center = card and card.config and card.config.center
    return center ~= nil
        and (center.rarity == rarity.key or center.rarity == rarity.index)
end

-- Cuando la tienda genera un Joker y Fukuro esta activa, con cierta probabilidad
-- se pide un Joker de la rareza elegida. Se prueba pidiendola de tres formas
-- (clave, indice, valor de sorteo) y se verifica la rareza REAL de la carta
-- resultante, asi no dependemos de como interprete create_card el parametro.
local bachilatro_original_create_card = create_card

function create_card(_type, area, legendary, _rarity, skip_materialize,
                     soulable, forced_key, key_append)
    local rarity = fukuro_rarity_data()
    if rarity
        and _type == 'Joker'
        and key_append == 'sho'
        and _rarity == nil
        and not legendary
        and not forced_key
        and G.shop_jokers
        and area == G.shop_jokers
        and pseudorandom(pseudoseed('bachilatro_fukuro' .. G.GAME.round_resets.ante))
            < BACHILATRO_tobimune_fukuro_chance()
    then
        for _, requested in ipairs({ rarity.key, rarity.index, rarity.poll }) do
            local card = bachilatro_original_create_card(
                _type, area, legendary, requested, skip_materialize,
                soulable, forced_key, key_append
            )
            if joker_matches_rarity(card, rarity) then return card end
            if card then card:remove() end
        end
    end

    return bachilatro_original_create_card(
        _type, area, legendary, _rarity, skip_materialize,
        soulable, forced_key, key_append
    )
end

--------------------------------------------------
-- SUZAKU
--------------------------------------------------

local function manual_rank_up(card)
    local suit_prefix = string.sub(card.base.suit, 1, 1) .. '_'
    local rank = card.base.id == 14 and 2 or math.min(card.base.id + 1, 14)
    local letters = { [10] = 'T', [11] = 'J', [12] = 'Q', [13] = 'K', [14] = 'A' }
    card:set_base(G.P_CARDS[suit_prefix .. (letters[rank] or tostring(rank))])
end

local function raise_rank(card)
    if SMODS and SMODS.modify_rank then
        local _ = SMODS.modify_rank(card, 1)    else
        manual_rank_up(card)
    end
end

local function use_suzaku(sword)
    local targets = {}
    for i, target in ipairs(suzaku_targets()) do targets[i] = target end
    if #targets == 0 then return end

    G.hand:unhighlight_all()
    BACHILATRO_spend_energy(BACHILATRO_tobimune_cost('suzaku'))
    G.GAME.bachilatro_suzaku_used_blind = true
    card_eval_status_text(sword, 'extra', nil, nil, nil, {
        message = 'SUZAKU',
        colour = G.C.RED
    })

    -- Mismo ritmo que Strength: voltear todas, cambiar todas, voltear de vuelta.
    for i, target in ipairs(targets) do
        local percent = 1.15 - (i - 0.999) / (#targets - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('card1', percent)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    delay(0.2)
    for _, target in ipairs(targets) do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                raise_rank(target)
                return true
            end
        }))
    end
    for i, target in ipairs(targets) do
        local percent = 0.85 + (i - 0.999) / (#targets - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('tarot2', percent, 0.6)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
end

--------------------------------------------------
-- USO DE LA ESPADA
--------------------------------------------------

function BACHILATRO_use_tobimune_ability(card)
    local key = ABILITY_KEYS[card.ability.bachilatro_ability]
    card.ability.bachilatro_ability = nil
    if not key or not can_use_tobimune(card, key) then return end

    if key == 'karasu' then
        BACHILATRO_open_karasu_picker(card, karasu_source())
    elseif key == 'fukuro' then
        BACHILATRO_open_fukuro_picker(card)
    else
        use_suzaku(card)
    end
end

--------------------------------------------------
-- CALLBACKS DE LOS BOTONES
--------------------------------------------------

local function update_button(e, key, button_name)
    local can_use = can_use_tobimune(e.config.ref_table, key)
    e.config.button = can_use and button_name or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

local function begin_use(e, ability_id, key)
    local card = e.config.ref_table
    if not can_use_tobimune(card, key) then return end
    card.ability.bachilatro_ability = ability_id
    G.FUNCS.use_card(e)
end

G.FUNCS.bachilatro_can_use_karasu = function(e)
    update_button(e, 'karasu', 'bachilatro_tobimune_karasu')
end
G.FUNCS.bachilatro_can_use_fukuro = function(e)
    update_button(e, 'fukuro', 'bachilatro_tobimune_fukuro')
end
G.FUNCS.bachilatro_can_use_suzaku = function(e)
    update_button(e, 'suzaku', 'bachilatro_tobimune_suzaku')
end

G.FUNCS.bachilatro_tobimune_karasu = function(e) begin_use(e, 1, 'karasu') end
G.FUNCS.bachilatro_tobimune_fukuro = function(e) begin_use(e, 2, 'fukuro') end
G.FUNCS.bachilatro_tobimune_suzaku = function(e) begin_use(e, 3, 'suzaku') end