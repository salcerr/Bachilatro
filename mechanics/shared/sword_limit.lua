--------------------------------------------------
-- LIMITE DE ESPADAS (maximo UNA por partida)
--------------------------------------------------
-- Reglas:
--  1. Si el jugador ya tiene una espada, no aparecen espadas ni el
--     Enchanted Blade Pack en la tienda.
--  2. Una misma tienda nunca tiene a la vez una espada y el pack.
--  3. Una misma tienda tiene como maximo UNA espada (si no, el jugador
--     podria comprar Enten y Kuregumo en la misma visita).
--
-- Se implementa envolviendo las funciones globales que generan la tienda
-- (create_card_for_shop y get_pack) y reintentando mientras el resultado
-- viole la regla. Asi no dependemos de in_pool, que con el pool vacio
-- devolveria una carta de reemplazo (j_joker) en vez de otra categoria.

local BLADE_SET = 'EnchantedBlade'
local BLADE_PACK_KEY = 'p_bachilatro_enchanted_blade_pack'
local MAX_RETRIES = 50

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function is_sword_card(card)
    return card and card.config and card.config.center
        and card.config.center.set == BLADE_SET or false
end

local function is_blade_pack(center_or_card)
    if not center_or_card then return false end
    local center = center_or_card.config and center_or_card.config.center
        or center_or_card
    return center.key == BLADE_PACK_KEY
end

-- El jugador tiene alguna espada en sus consumibles.
function BACHILATRO_player_has_any_sword()
    if not G.consumeables then return false end
    for _, card in ipairs(G.consumeables.cards) do
        if is_sword_card(card) then return true end
    end
    return false
end

-- La tienda actual (cartas ya colocadas) contiene una espada.
function BACHILATRO_shop_has_sword()
    if not G.shop_jokers then return false end
    for _, card in ipairs(G.shop_jokers.cards) do
        if is_sword_card(card) then return true end
    end
    return false
end

-- La tienda actual (packs ya colocados) contiene el Enchanted Blade Pack.
function BACHILATRO_shop_has_blade_pack()
    if not G.shop_booster then return false end
    for _, card in ipairs(G.shop_booster.cards) do
        if is_blade_pack(card) then return true end
    end
    return false
end

-- ¿Se puede agregar otra espada a la tienda?
local function sword_blocked_in_shop()
    return BACHILATRO_player_has_any_sword()
        or BACHILATRO_shop_has_sword()
        or BACHILATRO_shop_has_blade_pack()
end

-- ¿Se puede agregar el Enchanted Blade Pack a la tienda?
local function blade_pack_blocked_in_shop()
    return BACHILATRO_player_has_any_sword()
        or BACHILATRO_shop_has_sword()
end

--------------------------------------------------
-- HOOK: cartas de la tienda (jokers / consumibles / etc.)
--------------------------------------------------

local bachilatro_original_create_card_for_shop = create_card_for_shop

function create_card_for_shop(area)
    local card = bachilatro_original_create_card_for_shop(area)

    local tries = 0
    while card and is_sword_card(card)
        and sword_blocked_in_shop() and tries < MAX_RETRIES
    do
        card:remove()
        card = bachilatro_original_create_card_for_shop(area)
        tries = tries + 1
    end

    return card
end

--------------------------------------------------
-- HOOK: packs de la tienda
--------------------------------------------------

local bachilatro_original_get_pack = get_pack

function get_pack(_key, _type)
    local center = bachilatro_original_get_pack(_key, _type)

    local tries = 0
    while center and is_blade_pack(center)
        and blade_pack_blocked_in_shop() and tries < MAX_RETRIES
    do
        center = bachilatro_original_get_pack(_key, _type)
        tries = tries + 1
    end

    return center
end