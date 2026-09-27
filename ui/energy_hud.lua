--------------------------------------------------
-- HUD DE SPIRIT ENERGY
--------------------------------------------------

local BACHILATRO_BAR_SEGMENTS = 10

local BACHILATRO_SEGMENT_VALUE =
    BACHILATRO_ENERGY_MAX / BACHILATRO_BAR_SEGMENTS



--------------------------------------------------
-- DEFINICIÓN DEL HUD
--------------------------------------------------

function G.UIDEF.bachilatro_energy_hud()

    local energy =
        G.GAME
        and G.GAME.bachilatro_energy
        or 0

    local segment_nodes = {}



    --------------------------------------------------
    -- CREAR SEGMENTOS
    --------------------------------------------------

    for i = BACHILATRO_BAR_SEGMENTS, 1, -1 do

        local threshold =
            i * BACHILATRO_SEGMENT_VALUE

        local filled =
            energy >= threshold - 0.001

        local almost =
            (not filled)
            and energy >
                (i - 1) * BACHILATRO_SEGMENT_VALUE

        local col



        if filled then

            col = HEX('4A9EFF')

        elseif almost then

            col = HEX('2E5A8C')

        else

            col = HEX('1A2740')

        end



        segment_nodes[#segment_nodes + 1] = {

            n = G.UIT.R,

            config = {

                align = 'cm',

                minw = 0.28,
                minh = 0.22,

                padding = 0.02,

                r = 0.04,

                colour = col,

                emboss =
                    filled and 0.03 or 0
            },

            nodes = {}
        }

    end



    --------------------------------------------------
    -- ROOT
    --------------------------------------------------

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

                    colour =
                        HEX('0F1A2B'),

                    emboss = 0.05
                },

                nodes = {



                    --------------------------------------------------
                    -- SPIRIT
                    --------------------------------------------------

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

                                    text = 'Spirit',

                                    scale = 0.22,

                                    colour =
                                        G.C.UI.TEXT_LIGHT,

                                    shadow = true
                                }
                            }

                        }
                    },



                    --------------------------------------------------
                    -- ENERGY
                    --------------------------------------------------

                    {

                        n = G.UIT.R,

                        config = {

                            align = 'cm',

                            padding = 0.01
                        },

                        nodes = {

                            {

                                n = G.UIT.T,

                                config = {

                                    text = 'Energy',

                                    scale = 0.22,

                                    colour =
                                        G.C.UI.TEXT_LIGHT,

                                    shadow = true
                                }
                            }

                        }
                    },



                    --------------------------------------------------
                    -- NÚMERO
                    --------------------------------------------------

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

                                    text =
                                        tostring(
                                            math.floor(
                                                energy + 0.5
                                            )
                                        ),

                                    scale = 0.38,

                                    colour =
                                        G.C.WHITE,

                                    shadow = true
                                }
                            }

                        }
                    },



                    --------------------------------------------------
                    -- BARRA
                    --------------------------------------------------

                    {

                        n = G.UIT.R,

                        config = {

                            align = 'cm',

                            padding = 0.03,

                            r = 0.06,

                            colour =
                                HEX('0A1220')
                        },

                        nodes = {

                            {

                                n = G.UIT.C,

                                config = {

                                    align = 'cm',

                                    padding = 0.02
                                },

                                nodes =
                                    segment_nodes
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



    if not G.GAME
        or not G.consumeables
    then
        return
    end



    G.bachilatro_energy_hud =
        UIBox{

            definition =
                G.UIDEF.bachilatro_energy_hud(),

            config = {

                align = 'cr',

                offset = {
                    x = 0.50,
                    y = 0.35
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

    if not G.GAME
        or not G.consumeables
    then
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
