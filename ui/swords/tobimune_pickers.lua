--------------------------------------------------
-- SELECTORES DE TOBIMUNE
-- CROW: vista del mazo (solo cartas sin robar) donde se elige una carta.
-- OWL: tres botones, uno por rareza de Joker.
--------------------------------------------------

local bachilatro_crow_pending = nil

local SUIT_ORDER = { Spades = 1, Hearts = 2, Clubs = 3, Diamonds = 4 }

local function crow_group(card)
    if card.config.center == G.P_CENTERS.m_stone then return 5 end
    return SUIT_ORDER[card.base.suit] or 6
end

local function crow_sort(a, b)
    local group_a, group_b = crow_group(a), crow_group(b)
    if group_a ~= group_b then return group_a < group_b end
    return (a.base.id or 0) > (b.base.id or 0)
end

local function crow_choose(deck_card)
    local pending = bachilatro_crow_pending
    bachilatro_crow_pending = nil
    -- diferido: no se destruye el overlay en medio del click de una carta
    G.E_MANAGER:add_event(Event({
        func = function()
            G.FUNCS.exit_overlay_menu()
            if pending then
                BACHILATRO_crow_swap(pending.sword, pending.hand_card, deck_card)
            end
            return true
        end
    }))
end

local function crow_row_area(count)
    return CardArea(
        G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
        6.5 * G.CARD_W, 0.6 * G.CARD_H,
        {
            card_limit = count,
            type = 'title_2',
            view_deck = true,
            highlight_limit = 0,
            card_w = G.CARD_W * 0.7,
            draw_layers = { 'card' }
        }
    )
end

function BACHILATRO_open_crow_picker(sword, hand_card)
    if not (sword and hand_card and G.deck and #G.deck.cards > 0) then return end
    bachilatro_crow_pending = { sword = sword, hand_card = hand_card }

    local groups = {}
    local ordered = {}
    for _, deck_card in ipairs(G.deck.cards) do ordered[#ordered + 1] = deck_card end
    table.sort(ordered, crow_sort)
    for _, deck_card in ipairs(ordered) do
        local group = crow_group(deck_card)
        groups[group] = groups[group] or {}
        table.insert(groups[group], deck_card)
    end

    local rows = {}
    for group = 1, 6 do
        local cards = groups[group]
        if cards then
            local area = crow_row_area(#cards)
            rows[#rows + 1] = {
                n = G.UIT.R,
                config = { align = 'cm', padding = 0.07, no_fill = true },
                nodes = { { n = G.UIT.O, config = { object = area } } }
            }
            for _, deck_card in ipairs(cards) do
                -- clon solo para mostrar; el click apunta a la carta real
                local copy = copy_card(deck_card, nil, 0.7)
                copy.bachilatro_crow_source = deck_card
                copy.click = function(self)
                    crow_choose(self.bachilatro_crow_source)
                end
                copy.T.x = area.T.x + area.T.w / 2
                copy.T.y = area.T.y
                copy:hard_set_T()
                area:emplace(copy)
            end
        end
    end

    G.FUNCS.overlay_menu({
        definition = create_UIBox_generic_options({
            contents = {
                {
                    n = G.UIT.R,
                    config = { align = 'cm', padding = 0.1 },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = 'CROW: choose a card from your deck',
                                scale = 0.5,
                                colour = G.C.UI.TEXT_LIGHT,
                                shadow = true
                            }
                        }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = 'cm' },
                    nodes = { { n = G.UIT.C, config = { align = 'cm' }, nodes = rows } }
                }
            }
        })
    })
end

--------------------------------------------------
-- OWL
--------------------------------------------------

function BACHILATRO_open_owl_picker(sword)
    local owl = BACHILATRO_get_sword_ability('tobimune', 'owl')
    local chance = math.floor(BACHILATRO_tobimune_owl_chance() * 100 + 0.5)
    local buttons = {
        {
            n = G.UIT.R,
            config = { align = 'cm', padding = 0.1 },
            nodes = {
                {
                    n = G.UIT.T,
                    config = {
                        text = 'OWL: shop Jokers have a ' .. chance .. '% chance to be...',
                        scale = 0.5,
                        colour = G.C.UI.TEXT_LIGHT,
                        shadow = true
                    }
                }
            }
        }
    }

    for _, rarity in ipairs(owl.rarities) do
        buttons[#buttons + 1] = {
            n = G.UIT.R,
            config = {
                ref_table = { sword = sword, rarity = rarity.key },
                align = 'cm',
                padding = 0.1,
                r = 0.1,
                minw = 3.5,
                minh = 0.8,
                hover = true,
                shadow = true,
                colour = G.C.RARITY and G.C.RARITY[rarity.index]
                    or G.C.UI.BACKGROUND_INACTIVE,
                button = 'bachilatro_owl_pick'
            },
            nodes = {
                {
                    n = G.UIT.T,
                    config = {
                        text = rarity.label,
                        scale = 0.5,
                        colour = G.C.UI.TEXT_LIGHT,
                        shadow = true
                    }
                }
            }
        }
    end

    G.FUNCS.overlay_menu({
        definition = create_UIBox_generic_options({ contents = buttons })
    })
end

G.FUNCS.bachilatro_owl_pick = function(e)
    local data = e.config.ref_table
    G.FUNCS.exit_overlay_menu()
    if data then BACHILATRO_apply_owl(data.sword, data.rarity) end
end
