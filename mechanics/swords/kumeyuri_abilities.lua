--------------------------------------------------
-- REGLAS Y HABILIDADES DE KUMEYURI
-- EN (Banquet): crea copias temporales de una carta de la mano.
-- YUU (Play): pasa una propiedad (enhancement, sello o edition) de la carta
--   derecha a la izquierda. Con Hiruhiko es Destructive Play: pasa todas y
--   destruye la carta de origen.
--------------------------------------------------

local ABILITY_KEYS = { 'en', 'yuu' }

local function upgraded(key)
    return BACHILATRO_sword_ability_is_upgraded('kumeyuri', key)
end

function BACHILATRO_kumeyuri_cost(key)
    return BACHILATRO_get_sword_ability_cost('kumeyuri', key, upgraded(key))
end

function BACHILATRO_kumeyuri_en_copies()
    local en = BACHILATRO_get_sword_ability('kumeyuri', 'en')
    if upgraded('en') then return en.upgraded_copies or en.copies end
    return en.copies
end

function BACHILATRO_kumeyuri_yuu_is_destructive()
    return upgraded('yuu')
end

--------------------------------------------------
-- DESTRUIR CARTAS
-- Usa SMODS.destroy_cards (dispara remove_playing_cards, que Hiruhiko escucha).
--------------------------------------------------

local function destroy_playing_cards(cards)
    if SMODS and SMODS.destroy_cards then
        SMODS.destroy_cards(cards, { bypass_eternal = true })
        return
    end
    for _, card in ipairs(cards) do card:start_dissolve() end
    if SMODS and SMODS.calculate_context then
        SMODS.calculate_context({ remove_playing_cards = true, removed = cards })
    end
end

-- Las copias de En son ilusiones: desaparecen al terminar el Blind.
-- Hiruhiko NO cuenta estas cartas como destruidas.
function BACHILATRO_destroy_kumeyuri_illusions()
    local illusions = {}
    for _, card in ipairs(G.playing_cards or {}) do
        if card.ability and card.ability.bachilatro_illusion then
            illusions[#illusions + 1] = card
        end
    end
    if #illusions > 0 then destroy_playing_cards(illusions) end
end

--------------------------------------------------
-- SELECCION
--------------------------------------------------

local function en_source()
    if G.hand and #G.hand.highlighted == 1 then return G.hand.highlighted[1] end
    return nil
end

-- Igual que Death: la carta de la DERECHA es el origen, la IZQUIERDA recibe.
local function yuu_pair()
    if not G.hand or #G.hand.highlighted ~= 2 then return nil, nil end
    local first, second = G.hand.highlighted[1], G.hand.highlighted[2]
    if first.T.x > second.T.x then return first, second end
    return second, first
end

-- Los estados de Kuregumo no se pueden pasar (guardan el enhancement anterior).
local NOT_TRANSFERABLE = {
    m_bachilatro_wet = true,
    m_bachilatro_shocked = true
}

local function has_enhancement(card)
    return card.config.center ~= G.P_CENTERS.c_base
end

-- Propiedades que el origen tiene y el destino NO tiene.
local function transferable_properties(origin, target)
    local list = {}
    if has_enhancement(origin)
        and not NOT_TRANSFERABLE[origin.config.center_key]
        and not has_enhancement(target)
    then
        list[#list + 1] = 'enhancement'
    end
    if origin.seal and not target.seal then list[#list + 1] = 'seal' end
    if origin.edition and not target.edition then list[#list + 1] = 'edition' end
    return list
end

local function can_use_kumeyuri(card, key)
    if not card or not G.GAME or G.OVERLAY_MENU then return false end
    if BACHILATRO_is_shop_context(card) then return false end
    if (G.GAME.bachilatro_energy or 0) < BACHILATRO_kumeyuri_cost(key) then
        return false
    end
    if key == 'en' then
        return en_source() ~= nil
    elseif key == 'yuu' then
        local origin, target = yuu_pair()
        return origin ~= nil and #transferable_properties(origin, target) > 0
    end
    return false
end

function BACHILATRO_can_use_kumeyuri_ability(card)
    local key = card and ABILITY_KEYS[card.ability.bachilatro_ability]
    return key ~= nil and can_use_kumeyuri(card, key)
end

--------------------------------------------------
-- EN
--------------------------------------------------

local function use_en(sword)
    local source = en_source()
    if not source then return end
    local copies = BACHILATRO_kumeyuri_en_copies()

    BACHILATRO_spend_energy(BACHILATRO_kumeyuri_cost('en'))
    G.hand:unhighlight_all()
    card_eval_status_text(sword, 'extra', nil, nil, nil, {
        message = 'EN',
        colour = G.C.PURPLE
    })

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            for _ = 1, copies do
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local copy = copy_card(source, nil, nil, G.playing_card)
                copy.ability.bachilatro_illusion = true
                copy:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, copy)
                G.hand:emplace(copy)
                copy.states.visible = nil
                G.E_MANAGER:add_event(Event({
                    func = function()
                        copy:start_materialize()
                        return true
                    end
                }))
            end
            return true
        end
    }))
end

--------------------------------------------------
-- YUU
--------------------------------------------------

local function move_property(origin, target, property)
    if property == 'enhancement' then
        target:set_ability(origin.config.center)
        origin:set_ability(G.P_CENTERS.c_base)
    elseif property == 'seal' then
        target:set_seal(origin.seal, true)
        origin:set_seal(nil, true)
    elseif property == 'edition' then
        local edition = origin.edition.key or { [origin.edition.type] = true }
        target:set_edition(edition, true, true)
        origin:set_edition(nil, true, true)
    end
end

local function use_yuu(sword)
    local origin, target = yuu_pair()
    if not origin then return end
    local properties = transferable_properties(origin, target)
    if #properties == 0 then return end

    local destructive = BACHILATRO_kumeyuri_yuu_is_destructive()
    local chosen = properties
    if not destructive then
        chosen = { pseudorandom_element(properties, pseudoseed('bachilatro_yuu')) }
    end

    BACHILATRO_spend_energy(BACHILATRO_kumeyuri_cost('yuu'))
    G.hand:unhighlight_all()
    card_eval_status_text(sword, 'extra', nil, nil, nil, {
        message = 'YUU',
        colour = G.C.PURPLE
    })

    local pair = { origin, target }

    for i, card in ipairs(pair) do
        local percent = 1.15 - (i - 0.999) / (#pair - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                card:flip()
                play_sound('card1', percent)
                card:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    delay(0.2)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
            for _, property in ipairs(chosen) do
                move_property(origin, target, property)
            end
            return true
        end
    }))
    for i, card in ipairs(pair) do
        local percent = 0.85 + (i - 0.999) / (#pair - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                card:flip()
                play_sound('tarot2', percent, 0.6)
                card:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    if destructive then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                destroy_playing_cards({ origin })
                return true
            end
        }))
    end
end

--------------------------------------------------
-- USO DE LA ESPADA
--------------------------------------------------

function BACHILATRO_use_kumeyuri_ability(card)
    local key = ABILITY_KEYS[card.ability.bachilatro_ability]
    card.ability.bachilatro_ability = nil
    if not key or not can_use_kumeyuri(card, key) then return end

    if key == 'en' then
        use_en(card)
    else
        use_yuu(card)
    end
end

--------------------------------------------------
-- CALLBACKS DE LOS BOTONES
--------------------------------------------------

local function update_button(e, key, button_name)
    local can_use = can_use_kumeyuri(e.config.ref_table, key)
    e.config.button = can_use and button_name or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

local function begin_use(e, ability_id, key)
    local card = e.config.ref_table
    if not can_use_kumeyuri(card, key) then return end
    card.ability.bachilatro_ability = ability_id
    G.FUNCS.use_card(e)
end

G.FUNCS.bachilatro_can_use_en = function(e)
    update_button(e, 'en', 'bachilatro_kumeyuri_en')
end
G.FUNCS.bachilatro_can_use_yuu = function(e)
    update_button(e, 'yuu', 'bachilatro_kumeyuri_yuu')
end

G.FUNCS.bachilatro_kumeyuri_en = function(e) begin_use(e, 1, 'en') end
G.FUNCS.bachilatro_kumeyuri_yuu = function(e) begin_use(e, 2, 'yuu') end