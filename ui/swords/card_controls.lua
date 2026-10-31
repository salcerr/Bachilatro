--------------------------------------------------
-- BOTONES DE HABILIDADES DE LAS ESPADAS
--------------------------------------------------



--------------------------------------------------
-- CREAR BOTON DE HABILIDAD
--------------------------------------------------

local function bachilatro_make_ability_button(card, label, button_key, update_func, compact)
    return {
        n = G.UIT.R,
        config = {
            ref_table = card,
            r = compact and 0.06 or 0.08,
            padding = compact and 0.04 or 0.1,
            align = "cm",
            minw = compact and 1.5 or 1.6,
            minh = compact and 0.38 or 0.6,
            hover = true,
            shadow = true,
            colour = G.C.UI.BACKGROUND_INACTIVE,
            one_press = true,
            button = button_key,
            func = update_func
        },
        nodes = {
            {
                n = G.UIT.T,
                config = {
                    text = label,
                    colour = G.C.UI.TEXT_LIGHT,
                    scale = compact and 0.3 or 0.38,
                    shadow = true
                }
            }
        }
    }
end



--------------------------------------------------
-- BOTONES CONFIGURADOS POR EL PRESET DE CADA ESPADA
--------------------------------------------------

function G.UIDEF.bachilatro_sword_ability_buttons(card)
    local preset = BACHILATRO_get_sword_preset_for_card(card)

    if not preset then
        return {
            n = G.UIT.ROOT,
            config = {
                padding = 0,
                colour = G.C.CLEAR
            },
            nodes = {}
        }
    end

    local ability_nodes = {}

    -- con mas de 4 tecnicas (Magatsumi) los botones se achican para que la
    -- columna entre en la altura de la carta
    local compact = #(preset.abilities or {}) > 4

    for _, ability in ipairs(preset.abilities or {}) do
        ability_nodes[#ability_nodes + 1] = bachilatro_make_ability_button(
            card,
            ability.label,
            ability.button_func,
            ability.can_use_func,
            compact
        )
    end

    return {
        n = G.UIT.ROOT,
        config = {
            padding = 0,
            colour = G.C.CLEAR
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    padding = compact and 0.04 or 0.12,
                    align = 'cl'
                },
                nodes = ability_nodes
            }
        }
    }
end



--------------------------------------------------
-- BOTON SELL
--------------------------------------------------

G.UIDEF.bachilatro_enten_ability_buttons = G.UIDEF.bachilatro_sword_ability_buttons

function G.UIDEF.bachilatro_enten_sell_button(card)
    return {
        n = G.UIT.ROOT,
        config = {
            padding = 0,
            colour = G.C.CLEAR
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    ref_table = card,
                    align = "cr",
                    padding = 0.1,
                    r = 0.08,
                    minw = 1.25,
                    hover = true,
                    shadow = true,
                    colour = G.C.UI.BACKGROUND_INACTIVE,
                    one_press = true,
                    button = 'sell_card',
                    func = 'can_sell_card'
                },
                nodes = {
                    {
                        n = G.UIT.B,
                        config = {
                            w = 0.1,
                            h = 0.6
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            align = "tm"
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                    maxw = 1.25
                                },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = localize('b_sell'),
                                            colour = G.C.UI.TEXT_LIGHT,
                                            scale = 0.4,
                                            shadow = true
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm"
                                },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = localize('$'),
                                            colour = G.C.WHITE,
                                            scale = 0.4,
                                            shadow = true
                                        }
                                    },
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            ref_table = card,
                                            ref_value = 'sell_cost_label',
                                            colour = G.C.WHITE,
                                            scale = 0.55,
                                            shadow = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end



--------------------------------------------------
-- DRAW DEL BOTON DE HABILIDADES (OVERRIDE DE INSTANCIA)
-- Se ejecuta en el pase final de Game:draw (attention_text).
-- Dibuja el UIBox y despues REDIBUJA la espada encima,
-- para lograr: Joker/Consumible < Botones < Espada.
--------------------------------------------------

local function bachilatro_draw_sword_ability_button(button, ...)
    UIBox.draw(button, ...)

    local card = button.bachilatro_sword_card

    if card
        and card.highlighted
        and card.states
        and card.states.visible
        and card.children
        and card.children.use_button == button
    then
        card:draw('card')
    end
end



--------------------------------------------------
-- CARD:HIGHLIGHT
-- BOTONES DE ENTEN / KUREGUMO
--------------------------------------------------

local bachilatro_legacy_card_highlight = Card.highlight



--------------------------------------------------
-- MOSTRAR BOTONES DE HABILIDAD
--------------------------------------------------

local function bachilatro_show_sword_ability_button(card)
    if card.children.use_button then
        card.children.use_button:remove()
        card.children.use_button = nil
    end

    -- espada sellada (Magatsumi en la fase Yura): no tiene tecnicas
    local preset = BACHILATRO_get_sword_preset_for_card(card)
    if not preset or #(preset.abilities or {}) == 0 then return end

    local ability_button = UIBox{
        definition = G.UIDEF.bachilatro_sword_ability_buttons(card),
        config = {
            align = 'cl',
            offset = {
                x = 0.33,
                y = 0
            },
            parent = card
        }
    }

    -- marca propia: distingue estos botones de los use_button de Jokers/consumibles
    ability_button.bachilatro_sword_ability_button = true
    ability_button.bachilatro_sword_card = card

    -- pase final de Game:draw (despues de CardAreas y Cards)
    ability_button.attention_text = true

    -- despues de dibujarse, repinta la espada encima
    ability_button.draw = bachilatro_draw_sword_ability_button

    card.children.use_button = ability_button
end



function Card:highlight(is_highlighted)
    if BACHILATRO_get_sword_preset_for_card(self) then
        self.highlighted = is_highlighted

        if self.highlighted
            and self.area
            and self.area.config.type ~= 'shop'
        then
            bachilatro_show_sword_ability_button(self)

            self.children.bachilatro_sell_button = UIBox{
                definition = G.UIDEF.bachilatro_enten_sell_button(self),
                config = {
                    align = "cr",
                    offset = {
                        x = -0.35,
                        y = 0
                    },
                    parent = self
                }
            }
        else
            if self.children.use_button then
                self.children.use_button:remove()
                self.children.use_button = nil
            end

            if self.children.bachilatro_sell_button then
                self.children.bachilatro_sell_button:remove()
                self.children.bachilatro_sell_button = nil
            end
        end

        return
    end

    local result = bachilatro_legacy_card_highlight(self, is_highlighted)

    return result
end



--------------------------------------------------
-- CARD:DRAW
-- - Los botones de habilidad de espada NO se dibujan aca:
--   se dibujan en el pase final (ver override de instancia).
--   Solo se sacan de children mientras dibuja la carta.
-- - El Sell se sigue dibujando antes de la carta (queda
--   detras de ella), igual que antes.
-- - Los use_button de cartas normales no se tocan.
--------------------------------------------------

local bachilatro_original_card_draw = Card.draw

function Card:draw(layer)
    local children = self.children
    local sell = children.bachilatro_sell_button
    local ability_button = children.use_button

    if not (ability_button and ability_button.bachilatro_sword_ability_button) then
        ability_button = nil
    end

    if not sell and not ability_button then
        return bachilatro_original_card_draw(self, layer)
    end

    if ability_button then
        children.use_button = nil
    end

    if sell then
        children.bachilatro_sell_button = nil
        sell:draw()
    end

    local ok, result = pcall(bachilatro_original_card_draw, self, layer)

    -- se restauran SIEMPRE, incluso si el draw original fallo
    if sell then
        children.bachilatro_sell_button = sell
    end

    if ability_button then
        children.use_button = ability_button
    end

    if not ok then
        error(result, 0)
    end

    return result
end



--------------------------------------------------
-- SELECCION MULTIPLE DE JOKERS
-- CONFIGURADA POR PRESET
--------------------------------------------------

if CardArea and CardArea.add_to_highlighted then
    local bachilatro_original_add_to_highlighted = CardArea.add_to_highlighted

    function CardArea:add_to_highlighted(card, silent)
        if G.jokers and self == G.jokers and self.config then
            local current = self.config.highlighted_limit or 1
            local previous_applied = self.bachilatro_selection_limit_applied
            local base = self.bachilatro_selection_limit_base

            if base == nil or current ~= previous_applied then
                base = current
            end

            local updated = BACHILATRO_sword_selection_limit('jokers', base)

            self.bachilatro_selection_limit_base = base
            self.bachilatro_selection_limit_applied = updated
            self.config.highlighted_limit = updated
        end

        return bachilatro_original_add_to_highlighted(self, card, silent)
    end
end