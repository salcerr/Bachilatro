--------------------------------------------------
-- MAGATSUMI (Shinuchi Deck)
--
-- Fase Yura: la espada esta sellada. Al empezar cada Blind, cada carta del
--   mazo tiene una chance de bajar un rango (un 2 pasa a As).
-- Despertar: al superar el ultimo Blind de la fase, Yura se convierte en
--   Akemura Soga y la espada pasa a tener sus seis tecnicas.
-- Los efectos de las tecnicas que ocurren al jugar la mano viven en
--   Akemura (el unico que puede activar la hoja), ver BACHILATRO_akemura_calculate.
--------------------------------------------------

local ABILITY_KEYS = { 'kumo', 'tonbo', 'mukade', 'cho', 'hachi', 'kodoku' }
local AWAKENED = 'magatsumi_awakened'

local function yura_config()
    return BACHILATRO_WIELDER_PRESETS.yura.ability
end

local function ability(key)
    return BACHILATRO_get_sword_ability(AWAKENED, key)
end

local function ability_cost(key)
    return ability(key).cost
end

function BACHILATRO_magatsumi_state()
    return G.GAME and G.GAME.bachilatro_magatsumi
end

function BACHILATRO_magatsumi_blinds_left()
    local state = BACHILATRO_magatsumi_state()
    if not state then return 0 end
    return math.max(0, yura_config().debuff_blinds - state.blinds)
end

function BACHILATRO_magatsumi_cost(key)
    return ability_cost(key)
end

function BACHILATRO_magatsumi_retriggers(key)
    local data = ability(key)
    return data.retriggers or data.end_retriggers or 0
end

local function find_joker(center_key)
    if not G.jokers then return nil end
    for _, joker in ipairs(G.jokers.cards) do
        if joker.config and joker.config.center_key == center_key then
            return joker
        end
    end
    return nil
end

local function announce(card, message, colour)
    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = message,
        colour = colour or G.C.PURPLE
    })
end

--------------------------------------------------
-- RANGOS
-- Baja un rango. El 2 da la vuelta y pasa a As.
--------------------------------------------------

local function has_rank(card)
    if SMODS and SMODS.has_no_rank then return not SMODS.has_no_rank(card) end
    return card.ability.effect ~= 'Stone Card'
end

local function lower_rank(card)
    local suit = card.base and card.base.suit
    local id = card.base and card.base.id
    if suit and id then
        local new_id = id == 2 and 14 or id - 1
        local letters = { [10] = 'T', [11] = 'J', [12] = 'Q', [13] = 'K', [14] = 'A' }
        local key = string.sub(suit, 1, 1) .. '_' .. (letters[new_id] or tostring(new_id))
        if G.P_CARDS[key] then
            card:set_base(G.P_CARDS[key])
            return
        end
    end
    if SMODS and SMODS.modify_rank then
        local _ = SMODS.modify_rank(card, -1)
    end
end

--------------------------------------------------
-- DESTRUIR CARTAS (dispara remove_playing_cards)
--------------------------------------------------

local function destroy_playing_cards(cards)
    if #cards == 0 then return end
    if SMODS and SMODS.destroy_cards then
        SMODS.destroy_cards(cards, { bypass_eternal = true })
        return
    end
    for _, card in ipairs(cards) do card:start_dissolve() end
    if SMODS and SMODS.calculate_context then
        SMODS.calculate_context({ remove_playing_cards = true, removed = cards })
    end
end

--------------------------------------------------
-- FASE YURA: DRENAR EL MAZO
--------------------------------------------------

function BACHILATRO_magatsumi_drain_deck()
    local state = BACHILATRO_magatsumi_state()
    if not state or state.awakened then return end

    local chance = yura_config().rank_loss_chance
    local drained = 0
    for _, playing_card in ipairs(G.playing_cards or {}) do
        if has_rank(playing_card)
            and pseudorandom(pseudoseed('bachilatro_magatsumi_drain')) < chance
        then
            lower_rank(playing_card)
            drained = drained + 1
        end
    end

    local yura = find_joker('j_bachilatro_yura')
    if yura and drained > 0 then
        yura:juice_up(0.5, 0.5)
        announce(yura, '-' .. drained .. ' RANK', G.C.PURPLE)
    end
end

--------------------------------------------------
-- DESPERTAR: YURA -> AKEMURA
--------------------------------------------------

local function transform_joker(joker, center_key)
    local center = G.P_CENTERS[center_key]
    if not center then return end
    joker:remove_from_deck()
    joker:set_ability(center)
    joker.ability.eternal = true
    joker:add_to_deck()
    joker:juice_up(0.8, 0.8)
end

function BACHILATRO_magatsumi_awaken()
    local state = BACHILATRO_magatsumi_state()
    if not state or state.awakened then return end
    state.awakened = true

    local yura = find_joker('j_bachilatro_yura')
    local sword = BACHILATRO_find_sword('magatsumi')

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            if yura then transform_joker(yura, 'j_bachilatro_akemura') end
            if sword and G.P_CENTERS.c_bachilatro_magatsumi_awakened then
                sword:set_ability(G.P_CENTERS.c_bachilatro_magatsumi_awakened)
                sword.ability.bachilatro_ability = nil
                sword:juice_up(0.8, 0.8)
                attention_text({
                    text = 'MAGATSUMI AWAKENS!',
                    scale = 1.2,
                    hold = 2.5,
                    major = sword,
                    backdrop_colour = G.C.PURPLE,
                    align = 'cm',
                    offset = { x = 0, y = -0.5 },
                    silent = true
                })
            end
            return true
        end
    }))
end

function BACHILATRO_magatsumi_blind_beaten()
    local state = BACHILATRO_magatsumi_state()
    if not state or state.awakened then return end
    state.blinds = state.blinds + 1
    if state.blinds >= yura_config().debuff_blinds then
        BACHILATRO_magatsumi_awaken()
    end
end

--------------------------------------------------
-- BANDERAS DE "PROXIMA MANO"
--------------------------------------------------

function BACHILATRO_magatsumi_clear_next_hand_flags()
    local state = BACHILATRO_magatsumi_state()
    if not state then return end
    state.kumo = false
    state.mukade = false
    state.cho = false
    state.hachi = false
    state.kumo_card = nil
end

-- Tonbo fuerza una carta: se limpia al terminar el Blind por si quedo pendiente.
function BACHILATRO_magatsumi_clear_forced()
    if not G.playing_cards then return end
    for _, playing_card in ipairs(G.playing_cards) do
        if playing_card.ability then playing_card.ability.forced_selection = nil end
    end
end

local function restore_forced_selection()
    if not G.hand then return end
    for _, hand_card in ipairs(G.hand.cards) do
        if hand_card.ability.forced_selection and not hand_card.highlighted then
            G.hand:add_to_highlighted(hand_card, true)
        end
    end
end

--------------------------------------------------
-- REGLAS DE USO
--------------------------------------------------

local function in_hand_phase()
    return G.GAME and G.GAME.blind and G.GAME.blind.in_blind
        and G.STATES and G.STATE == G.STATES.SELECTING_HAND
end

-- Packs tipo tarot / spectral / etc. donde tiene sentido usar Kodoku
local function in_pack_phase()
    if not G.STATES or not G.STATE then return false end
    return G.STATE == G.STATES.TAROT_PACK
        or G.STATE == G.STATES.SPECTRAL_PACK
        or G.STATE == G.STATES.PLANET_PACK
        or G.STATE == G.STATES.STANDARD_PACK
        or G.STATE == G.STATES.BUFFOON_PACK
        or G.STATE == G.STATES.SMODS_BOOSTER_OPENED
end

local function kodoku_targets()
    local targets = {}
    if G.hand then
        for _, hand_card in ipairs(G.hand.highlighted or {}) do
            if has_rank(hand_card) then targets[#targets + 1] = hand_card end
        end
    end
    if G.pack_cards then
        for _, pack_card in ipairs(G.pack_cards.highlighted or {}) do
            if has_rank(pack_card) then targets[#targets + 1] = pack_card end
        end
    end
    return targets
end

-- `while_using` = true cuando el juego YA esta ejecutando el uso de la carta.
-- Ahi G.STATE deja de ser SELECTING_HAND (use_card lo cambia a PLAY_TAROT),
-- asi que la fase solo se revisa para habilitar el boton, no al usar.
local function can_use_magatsumi(card, key, while_using)
    local state = BACHILATRO_magatsumi_state()
    if not card or not state or not state.awakened then return false end
    if G.OVERLAY_MENU then return false end
    if (G.GAME.bachilatro_energy or 0) < ability_cost(key) then return false end

    -- Kodoku: mano o pack. El resto: solo durante la mano.
    if key == 'kodoku' then
        if not while_using and not (in_hand_phase() or in_pack_phase()) then
            return false
        end
        local selection = ability('kodoku').selection
        local targets = kodoku_targets()
        local count = #targets
        return count >= selection.min and count <= selection.max
    end

    if not while_using and not in_hand_phase() then return false end

    if key == 'kumo' or key == 'mukade' or key == 'cho' or key == 'hachi' then
        return not state[key]
    elseif key == 'tonbo' then
        if not G.hand or #G.hand.highlighted ~= 1 then return false end
        return G.hand.highlighted[1].config.center ~= G.P_CENTERS.m_glass
    end
    return false
end

function BACHILATRO_can_use_magatsumi_ability(card)
    local key = card and ABILITY_KEYS[card.ability.bachilatro_ability]
    return key ~= nil and can_use_magatsumi(card, key, true)
end

--------------------------------------------------
-- USO DE LAS TECNICAS
--------------------------------------------------

local function use_flag_ability(sword, key)
    BACHILATRO_spend_energy(ability_cost(key))
    BACHILATRO_magatsumi_state()[key] = true
    announce(sword, string.upper(key), G.C.PURPLE)
end

local function use_tonbo(sword)
    local target = G.hand.highlighted[1]
    BACHILATRO_spend_energy(ability_cost('tonbo'))
    target:set_ability(G.P_CENTERS.m_glass)
    -- misma marca que usa el Boss Blind Cerulean Bell: la carta queda
    -- seleccionada hasta que se juega o se descarta
    target.ability.forced_selection = true
    target:juice_up(0.5, 0.5)
    announce(sword, 'TONBO', G.C.PURPLE)
end

local function use_kodoku(sword)
    local targets = {}
    for i, target in ipairs(kodoku_targets()) do targets[i] = target end
    if #targets == 0 then return end

    if G.hand then G.hand:unhighlight_all() end
    if G.pack_cards and G.pack_cards.unhighlight_all then
        G.pack_cards:unhighlight_all()
    end
    BACHILATRO_spend_energy(ability_cost('kodoku'))
    announce(sword, 'KODOKU', G.C.PURPLE)

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
                lower_rank(target)
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
    G.E_MANAGER:add_event(Event({
        func = function()
            restore_forced_selection()
            return true
        end
    }))
end

function BACHILATRO_use_magatsumi_ability(card)
    local key = ABILITY_KEYS[card.ability.bachilatro_ability]
    card.ability.bachilatro_ability = nil
    if not key or not can_use_magatsumi(card, key, true) then return end

    if key == 'tonbo' then
        use_tonbo(card)
    elseif key == 'kodoku' then
        use_kodoku(card)
    else
        use_flag_ability(card, key)
    end
end

--------------------------------------------------
-- EFECTOS AL JUGAR LA MANO
-- Los llama el Joker Akemura desde su calculate.
--------------------------------------------------

local function rightmost(cards)
    local best = nil
    for _, candidate in ipairs(cards or {}) do
        if not best or candidate.T.x >= best.T.x then best = candidate end
    end
    return best
end

function BACHILATRO_akemura_calculate(joker, context)
    local state = BACHILATRO_magatsumi_state()
    if not state or not state.awakened or context.blueprint then return end

    -- HACHI (ultima carta que puntua) y CHO (las dos puntas): retriggers
    if context.repetition and context.cardarea == G.play and context.other_card then
        local repetitions = 0
        if state.hachi
            and context.other_card == rightmost(context.scoring_hand)
        then
            repetitions = repetitions + ability('hachi').retriggers
        end
        if state.cho and context.full_hand and #context.full_hand == 5
            and (context.other_card == context.full_hand[1]
                or context.other_card == context.full_hand[5])
        then
            repetitions = repetitions + ability('cho').end_retriggers
        end
        if repetitions > 0 then
            return {
                message = localize('k_again_ex'),
                repetitions = repetitions,
                card = joker
            }
        end
        return
    end

    -- Despues de puntuar: destruccion y vuelta a la mano
    if context.after then
        local full_hand = context.full_hand or {}

        if state.kumo and full_hand[1] then
            state.kumo_card = full_hand[1]
        end
        state.kumo = false
        state.hachi = false

        local to_destroy = {}
        if state.cho and #full_hand == 5 then
            to_destroy = { full_hand[2], full_hand[3], full_hand[4] }
            state.cho = false
        end
        if state.mukade then
            for _, hand_card in ipairs(G.hand.cards) do
                to_destroy[#to_destroy + 1] = hand_card
            end
            state.mukade = false
        end
        destroy_playing_cards(to_destroy)
    end
end

-- KUMO: la primera carta jugada vuelve a la mano DESPUES del descarte normal.
-- No sacamos la carta de G.play a mitad de camino (eso apilaba las cartas).
local original_draw_from_play_to_discard = G.FUNCS.draw_from_play_to_discard

if original_draw_from_play_to_discard then
    G.FUNCS.draw_from_play_to_discard = function(e)
        local state = BACHILATRO_magatsumi_state()
        local kept = state and state.kumo_card
        if state then state.kumo_card = nil end

        -- Primero que el juego mueva todo a descarte con normalidad
        original_draw_from_play_to_discard(e)

        if not kept or kept.destroyed or kept.shattered or kept.marked_to_be_destroyed then
            return
        end

        -- Despues la devolvemos a la mano
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                if not kept or kept.destroyed or kept.shattered then return true end

                if kept.area then
                    kept.area:remove_card(kept)
                end
                G.hand:emplace(kept)
                if G.hand.align_cards then G.hand:align_cards() end
                kept:juice_up(0.4, 0.4)
                play_sound('card1')
                return true
            end
        }))
    end
end

--------------------------------------------------
-- CALLBACKS DE LOS BOTONES
--------------------------------------------------

local function update_button(e, key, button_name)
    local can_use = can_use_magatsumi(e.config.ref_table, key)
    e.config.button = can_use and button_name or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

local function begin_use(e, ability_id, key)
    local card = e.config.ref_table
    if not can_use_magatsumi(card, key) then return end
    card.ability.bachilatro_ability = ability_id
    G.FUNCS.use_card(e)
end

for index, key in ipairs(ABILITY_KEYS) do
    G.FUNCS['bachilatro_can_use_' .. key] = function(e)
        update_button(e, key, 'bachilatro_magatsumi_' .. key)
    end
    G.FUNCS['bachilatro_magatsumi_' .. key] = function(e)
        begin_use(e, index, key)
    end
end

--------------------------------------------------
-- ENTRADA AL BLIND
-- Se llama desde round_lifecycle al elegir un Blind (setting_blind).
--------------------------------------------------

function BACHILATRO_magatsumi_on_blind_start()
    BACHILATRO_magatsumi_clear_next_hand_flags()
    BACHILATRO_magatsumi_drain_deck()
end