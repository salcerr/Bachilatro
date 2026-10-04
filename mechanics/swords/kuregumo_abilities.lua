--------------------------------------------------
-- KUREGUMO STATUS, STUDY, AND ABILITY LOGIC
--------------------------------------------------

-- La mejora se gana con el Study de Sojo (flag permanente de la run), pero
-- solo esta ACTIVA mientras Sojo este en tus jokers y no este debilitado.
-- Si lo vendes, Kuregumo vuelve a la version normal; si lo recuperas, vuelve
-- la mejora.
function BACHILATRO_kuregumo_is_upgraded()
    return G.GAME and G.GAME.bachilatro_kuregumo_upgraded == true
        and BACHILATRO_sword_has_wielder('kuregumo') or false
end

-- Devuelve TODAS las cartas Shocked del mazo a su enhancement anterior.
-- Se llama al terminar el Blind: las cartas Shocked que nunca se robaron
-- (Mei mejorada afecta al mazo entero) no pasan por el descarte y se
-- quedaban Shocked para el siguiente Blind.
function BACHILATRO_clear_all_kuregumo_status()
    for _, playing_card in ipairs(G.playing_cards or {}) do
        BACHILATRO_clear_kuregumo_status(playing_card)
    end
end

local function kuregumo_center_key(status)
    return 'm_bachilatro_' .. status
end

function BACHILATRO_count_kuregumo_status(status, cards)
    local count = 0
    cards = cards or G.playing_cards or {}
    for _, playing_card in ipairs(cards) do
        if playing_card.config and playing_card.config.center_key == kuregumo_center_key(status) then
            count = count + 1
        end
    end
    return count
end

function BACHILATRO_clear_kuregumo_status(card)
    if not card or not card.config or not card.ability then return end
    local center_key = card.config.center_key
    local was_shocked = center_key == kuregumo_center_key('shocked')
    if not was_shocked then return end

    local restore_key = card.ability.bachilatro_shocked_from_center
        or card.ability.bachilatro_original_center
        or 'c_base'
    local original = G.P_CENTERS[restore_key] or G.P_CENTERS.c_base
    card:set_ability(original)
    card.ability.bachilatro_original_center = nil
    card.ability.bachilatro_shocked_from_center = nil
end

-- Expire Shocked only once that specific card actually enters the discard
-- pile. This runs after play scoring and also covers manually discarded cards.
local kuregumo_original_cardarea_emplace = CardArea.emplace
function CardArea:emplace(card, ...)
    local result = kuregumo_original_cardarea_emplace(self, card, ...)
    if G and self == G.discard then
        BACHILATRO_clear_kuregumo_status(card)
    end
    return result
end

local function apply_kuregumo_status(card, status)
    if not card or not card.config then return false end
    if card.config.center_key == kuregumo_center_key(status) then return false end

    local shocked_from_center
    if status == 'shocked' then
        -- Shocked is temporary: remember the enhancement it replaces so the
        -- card can return to Wet (or its previous enhancement) afterward.
        shocked_from_center = card.config.center_key
    end
    local center = G.P_CENTERS[kuregumo_center_key(status)]
    if not center then return false end

    card:set_ability(center)
    card.ability.bachilatro_original_center = nil
    card.ability.bachilatro_shocked_from_center = shocked_from_center
    return true
end

local function find_sojo()
    if not G.jokers then return nil end
    for _, joker in ipairs(G.jokers.cards) do
        if not joker.debuff and joker.config and joker.config.center
            and joker.config.center.key == 'j_bachilatro_sojo' then
            return joker
        end
    end
end

local function add_sojo_study(affected_count)
    local sojo = find_sojo()
    if not sojo or not G.GAME then return end

    local preset = BACHILATRO_WIELDER_PRESETS.sojo
    local extra = sojo.ability.extra
    extra.xmult = math.floor((extra.xmult + preset.ability.xmult_per_use) * 100 + 0.5) / 100

    local required = preset.ability.study_required
    local current = G.GAME.bachilatro_kuregumo_study or 0
    local study_gained = affected_count * preset.ability.study_per_affected_card
    if not G.GAME.bachilatro_kuregumo_upgraded then
        G.GAME.bachilatro_kuregumo_study = math.min(required, current + study_gained)
        if G.GAME.bachilatro_kuregumo_study >= required then
            G.GAME.bachilatro_kuregumo_upgraded = true
            local kuregumo = BACHILATRO_find_sword('kuregumo')
            if kuregumo then
                kuregumo:juice_up()
                attention_text({
                    text = 'KUREGUMO MASTERED!',
                    scale = 1.1,
                    hold = 2,
                    major = kuregumo,
                    backdrop_colour = G.C.RED,
                    align = 'cm',
                    silent = true
                })
            end
            play_sound('timpani')
        end
    end

    card_eval_status_text(sojo, 'extra', nil, nil, nil, {
        message = '+' .. string.format('%.2f', preset.ability.xmult_per_use) .. ' XMult',
        colour = G.C.MULT
    })
end

local function selected_hand_cards()
    local ability = BACHILATRO_get_sword_ability('kuregumo', 'kou')
    if not G.hand or not ability then return {} end
    local selected = G.hand.highlighted or {}
    if #selected < ability.selection.min or #selected > ability.selection.max then
        return {}
    end
    return selected
end

local function wet_cards_in_hand()
    local wet = {}
    if not G.hand then return wet end
    for _, playing_card in ipairs(G.hand.cards) do
        if playing_card.config and playing_card.config.center_key == kuregumo_center_key('wet') then
            wet[#wet + 1] = playing_card
        end
    end
    return wet
end

local function can_use_kuregumo(card, ability_key)
    if not card or not G.GAME or BACHILATRO_is_shop_context(card) then return false end
    local ability = BACHILATRO_get_sword_ability('kuregumo', ability_key)
    if not ability or (G.GAME.bachilatro_energy or 0) < ability.cost then return false end

    if ability_key == 'kou' then
        return #selected_hand_cards() > 0
    elseif ability_key == 'mei' then
        return BACHILATRO_kuregumo_is_upgraded() or #wet_cards_in_hand() > 0
    elseif ability_key == 'yui' then
        return G.GAME.blind and #wet_cards_in_hand() > 0
    end
    return false
end

function BACHILATRO_can_use_kuregumo_ability(card)
    local ability = card and card.ability.bachilatro_ability
    if ability == 1 then return can_use_kuregumo(card, 'kou') end
    if ability == 2 then return can_use_kuregumo(card, 'mei') end
    if ability == 3 then return can_use_kuregumo(card, 'yui') end
    return false
end

function BACHILATRO_use_kuregumo_ability(card)
    local selected_ability = card.ability.bachilatro_ability
    card.ability.bachilatro_ability = nil
    local ability_key = ({ 'kou', 'mei', 'yui' })[selected_ability]
    if not ability_key or not can_use_kuregumo(card, ability_key) then return end

    local ability = BACHILATRO_get_sword_ability('kuregumo', ability_key)
    local affected = {}

    if ability_key == 'kou' then
        for _, playing_card in ipairs(selected_hand_cards()) do
            if apply_kuregumo_status(playing_card, 'wet') then
                affected[#affected + 1] = playing_card
            end
        end
        G.hand:unhighlight_all()
    elseif ability_key == 'mei' then
        local targets
        if BACHILATRO_kuregumo_is_upgraded() then
            targets = G.playing_cards or {}
        else
            targets = wet_cards_in_hand()
        end
        for _, playing_card in ipairs(targets) do
            if apply_kuregumo_status(playing_card, 'shocked') then
                affected[#affected + 1] = playing_card
            end
        end
    elseif ability_key == 'yui' then
        local upgraded = BACHILATRO_kuregumo_is_upgraded()
        local candidates = upgraded and (G.playing_cards or {}) or (G.hand and G.hand.cards or {})
        local wet_count = 0
        for _, playing_card in ipairs(candidates) do
            if playing_card.config and playing_card.config.center_key == kuregumo_center_key('wet') then
                wet_count = wet_count + 1
                affected[#affected + 1] = playing_card
            end
        end
        local blind = G.GAME.blind
        local percent_per_card = upgraded
            and ability.upgraded_score_reduction_per_wet_card
            or ability.score_reduction_per_wet_card
        local reduction = percent_per_card * wet_count
        blind.chips = math.max(1, math.floor(blind.chips * (1 - reduction)))
        blind.chip_text = number_format(blind.chips)
        SMODS.juice_up_blind()
    end

    BACHILATRO_spend_energy(ability.cost)
    add_sojo_study(#affected)
    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = string.upper(ability_key),
        colour = G.C.RED
    })
end

local function begin_kuregumo_use(e, ability_id, ability_key)
    local card = e.config.ref_table
    if not can_use_kuregumo(card, ability_key) then return end
    card.ability.bachilatro_ability = ability_id
    G.FUNCS.use_card(e)
end

G.FUNCS.bachilatro_can_use_kou = function(e)
    local can_use = can_use_kuregumo(e.config.ref_table, 'kou')
    e.config.button = can_use and 'bachilatro_kuregumo_kou' or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

G.FUNCS.bachilatro_can_use_mei = function(e)
    local can_use = can_use_kuregumo(e.config.ref_table, 'mei')
    e.config.button = can_use and 'bachilatro_kuregumo_mei' or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

G.FUNCS.bachilatro_can_use_yui = function(e)
    local can_use = can_use_kuregumo(e.config.ref_table, 'yui')
    e.config.button = can_use and 'bachilatro_kuregumo_yui' or nil
    e.config.colour = can_use and HEX('707070') or HEX('353535')
end

G.FUNCS.bachilatro_kuregumo_kou = function(e)
    begin_kuregumo_use(e, 1, 'kou')
end

G.FUNCS.bachilatro_kuregumo_mei = function(e)
    begin_kuregumo_use(e, 2, 'mei')
end

G.FUNCS.bachilatro_kuregumo_yui = function(e)
    begin_kuregumo_use(e, 3, 'yui')
end