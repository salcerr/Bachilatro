--------------------------------------------------
-- BOTONES DE HABILIDADES DE ENTEN
--------------------------------------------------



--------------------------------------------------
-- CREAR BOTÓN DE HABILIDAD
--------------------------------------------------

local function bachilatro_make_ability_button(
    card,
    label,
    button_key,
    update_func
)

    return {
        n = G.UIT.R,

        config = {
            ref_table = card,

            r = 0.08,
            padding = 0.1,

            align = "cm",

            minw = 1.6,
            minh = 0.6,

            hover = true,
            shadow = true,

            colour =
                G.C.UI.BACKGROUND_INACTIVE,

            one_press = true,

            button = button_key,
            func = update_func
        },

        nodes = {

            {
                n = G.UIT.T,

                config = {
                    text = label,

                    colour =
                        G.C.UI.TEXT_LIGHT,

                    scale = 0.38,

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
    if not preset then return { n = G.UIT.ROOT, config = { padding = 0, colour = G.C.CLEAR }, nodes = {} } end
    local ability_nodes = {}

    for _, ability in ipairs(preset.abilities or {}) do
        ability_nodes[#ability_nodes + 1] = bachilatro_make_ability_button(
            card,
            ability.label,
            ability.button_func,
            ability.can_use_func
        )
    end

    return {
        n = G.UIT.ROOT,
        config = { padding = 0, colour = G.C.CLEAR },
        nodes = {
            {
                n = G.UIT.C,
                config = { padding = 0.12, align = 'cl' },
                nodes = ability_nodes
            }
        }
    }
end



--------------------------------------------------
-- BOTÓN SELL
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

                    colour =
                        G.C.UI.BACKGROUND_INACTIVE,

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



                            --------------------------------------------------
                            -- SELL
                            --------------------------------------------------

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
                                            text =
                                                localize('b_sell'),

                                            colour =
                                                G.C.UI.TEXT_LIGHT,

                                            scale = 0.4,

                                            shadow = true
                                        }
                                    }

                                }
                            },



                            --------------------------------------------------
                            -- PRECIO
                            --------------------------------------------------

                            {
                                n = G.UIT.R,

                                config = {
                                    align = "cm"
                                },

                                nodes = {

                                    {
                                        n = G.UIT.T,

                                        config = {
                                            text =
                                                localize('$'),

                                            colour =
                                                G.C.WHITE,

                                            scale = 0.4,

                                            shadow = true
                                        }
                                    },



                                    {
                                        n = G.UIT.T,

                                        config = {

                                            ref_table = card,

                                            ref_value =
                                                'sell_cost_label',

                                            colour =
                                                G.C.WHITE,

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
-- CARD:HIGHLIGHT
-- BOTONES DE ENTEN
--------------------------------------------------

local bachilatro_legacy_card_highlight =
    Card.highlight


local function bachilatro_show_sword_ability_button(card)
    if card.children.use_button then
        card.children.use_button:remove()
    end

    card.children.use_button = UIBox{
        definition = G.UIDEF.bachilatro_sword_ability_buttons(card),
        config = {
            align = 'cl',
            offset = { x = 0.30, y = 0 },
            -- Keep the original Enten behavior: the UIBox is a child of the
            -- sword card, so its full button hitboxes follow that card's draw
            -- order and remain behind cards drawn above it (such as Jokers).
            parent = card
        }
    }
end


function Card:highlight(is_highlighted)

    if BACHILATRO_get_sword_preset_for_card(self) then

        self.highlighted =
            is_highlighted



        --------------------------------------------------
        -- MOSTRAR BOTONES
        --------------------------------------------------

        if self.highlighted
            and self.area
            and self.area.config.type ~= 'shop'
        then



            --------------------------------------------------
            -- BOTONES DE HABILIDADES
            --------------------------------------------------

            bachilatro_show_sword_ability_button(self)



            --------------------------------------------------
            -- BOTÓN SELL
            --------------------------------------------------

            self.children.bachilatro_sell_button =
                UIBox{

                    definition =
                        G.UIDEF.bachilatro_enten_sell_button(
                            self
                        ),

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



            --------------------------------------------------
            -- OCULTAR BOTONES
            --------------------------------------------------

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



    local result = bachilatro_legacy_card_highlight(
        self,
        is_highlighted
    )
    return result
end



--------------------------------------------------
-- CARD:DRAW
-- SELL DETRÁS DE ENTEN
--------------------------------------------------

local bachilatro_original_card_draw = Card.draw

function Card:draw(layer)
    local sell = self.children.bachilatro_sell_button
    if sell then
        self.children.bachilatro_sell_button = nil
        sell:draw()
        local result = bachilatro_original_card_draw(self, layer)
        self.children.bachilatro_sell_button = sell
        return result
    else
        return bachilatro_original_card_draw(self, layer)
    end
end


--------------------------------------------------
-- SELECCIÓN MULTIPLE DE JOKERS CONFIGURADA POR PRESET
--------------------------------------------------

if CardArea and CardArea.add_to_highlighted then
    local bachilatro_original_add_to_highlighted =
        CardArea.add_to_highlighted

    function CardArea:add_to_highlighted(card, silent)
        if G.jokers and self == G.jokers and self.config then
            local current = self.config.highlighted_limit or 1
            local previous_applied = self.bachilatro_selection_limit_applied
            local base = self.bachilatro_selection_limit_base

            if base == nil or current ~= previous_applied then
                base = current
            end

            local updated = BACHILATRO_sword_selection_limit(
                'jokers', base
            )
            self.bachilatro_selection_limit_base = base
            self.bachilatro_selection_limit_applied = updated
            self.config.highlighted_limit = updated
        end

        return bachilatro_original_add_to_highlighted(
            self, card, silent
        )
    end
end
