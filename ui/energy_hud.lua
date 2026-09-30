--------------------------------------------------
-- HUD DE SPIRIT ENERGY
--------------------------------------------------

local function BACHILATRO_energy_colour(energy, maximum)
    local base = G.C.PURPLE or HEX('A782D1')
    local ratio = math.max(0, math.min(1, energy / maximum))
    local brightness = 0.45 + 0.55 * ratio

    return {
        base[1] * brightness,
        base[2] * brightness,
        base[3] * brightness,
        base[4] or 1
    }
end

--------------------------------------------------
-- DEFINICIÓN DEL HUD
--------------------------------------------------

function G.UIDEF.bachilatro_energy_hud()
    local maximum = BACHILATRO_ENERGY_MAX or 100
    local energy = G.GAME and G.GAME.bachilatro_energy or 0
    local shown_energy = math.max(0, math.min(maximum, math.floor(energy + 0.5)))
    local current_colour = BACHILATRO_energy_colour(shown_energy, maximum)

    return {
        n = G.UIT.ROOT,
        config = {
            align = 'cm',
            colour = G.C.CLEAR,
            padding = 0.04
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = 'cm',
                    padding = 0.08,
                    r = 0.1,
                    colour = HEX('0F1A2B'),
                    emboss = 0.05
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {
                            align = 'cm',
                            padding = 0.02
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = 'Spirit Energy',
                                    scale = 0.22,
                                    colour = G.C.UI.TEXT_LIGHT,
                                    shadow = true
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = {
                            align = 'cm',
                            padding = 0.04
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = tostring(shown_energy),
                                    scale = 0.38,
                                    colour = current_colour,
                                    shadow = true
                                }
                            },
                            {
                                n = G.UIT.T,
                                config = {
                                    text = '/' .. tostring(maximum),
                                    scale = 0.24,
                                    colour = HEX('B8B9C2'),
                                    shadow = true
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
-- CREAR HUD
--------------------------------------------------

function BACHILATRO_create_energy_hud()
    if G.bachilatro_energy_hud then
        G.bachilatro_energy_hud:remove()
        G.bachilatro_energy_hud = nil
    end

    if not G.GAME or not G.consumeables then
        return
    end

    G.bachilatro_energy_hud = UIBox {
        definition = G.UIDEF.bachilatro_energy_hud(),
        config = {
            align = 'cr',
            offset = {
                x = 0.20,
                y = -0.25
            },
            major = G.consumeables,
            bond = 'Weak'
        }
    }
end

--------------------------------------------------
-- ACTUALIZAR HUD
--------------------------------------------------

function BACHILATRO_refresh_energy_hud()
    if not G.GAME or not G.consumeables then
        return
    end

    BACHILATRO_create_energy_hud()
end

--------------------------------------------------
-- ELIMINAR HUD
--------------------------------------------------

function BACHILATRO_remove_energy_hud()
    if G.bachilatro_energy_hud then
        G.bachilatro_energy_hud:remove()
        G.bachilatro_energy_hud = nil
    end
end