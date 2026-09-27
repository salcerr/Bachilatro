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



--------------------------------------------------
-- INICIO DEL RUN
--------------------------------------------------

local bachilatro_original_start_run =
    Game.start_run


function Game:start_run(args)

    bachilatro_original_start_run(
        self,
        args
    )



    G.GAME.bachilatro_energy_max =
        G.GAME.bachilatro_energy_max
        or BACHILATRO_ENERGY_MAX



    G.GAME.bachilatro_energy =
        G.GAME.bachilatro_energy
        or G.GAME.mpm_energy
        or G.GAME.bachilatro_energy_max



    G.E_MANAGER:add_event(
        Event{

            trigger = 'after',

            delay = 0.15,

            blockable = false,

            func = function()

                BACHILATRO_create_energy_hud()

                return true
            end
        }
    )
end



--------------------------------------------------
-- FINALIZAR RUN
--------------------------------------------------

local bachilatro_original_delete_run =
    Game.delete_run


function Game:delete_run()

    BACHILATRO_remove_energy_hud()

    return bachilatro_original_delete_run(
        self
    )
end



--------------------------------------------------
-- ENERGÍA AL INICIAR RUN
--------------------------------------------------

function SMODS.current_mod.reset_game_globals(
    run_start
)

    if run_start then

        G.GAME.bachilatro_energy_max =
            BACHILATRO_ENERGY_MAX

        G.GAME.bachilatro_energy =
            BACHILATRO_ENERGY_MAX

    end
end



--------------------------------------------------
-- RECARGA AL CAMBIAR DE ANTE
--------------------------------------------------

function SMODS.current_mod.calculate(
    self,
    context
)

    --------------------------------------------------
    -- AKA: COPIAR LOS JOKERS ELEGIDOS ESTE ROUND
    --------------------------------------------------

    local aka_targets = {}
    local enten_card = nil

    if G.jokers then
        for _, joker in ipairs(G.jokers.cards) do
            if joker.ability.bachilatro_aka_copy then
                aka_targets[#aka_targets + 1] = joker
            end
        end
    end

    if #aka_targets > 0 and G.consumeables then
        for _, consumable in ipairs(G.consumeables.cards) do
            if consumable.config.center_key == 'c_bachilatro_enten' then
                enten_card = consumable
                break
            end
        end
    end

    local copied_effects = {}

    if #aka_targets > 0
        and enten_card
        and not context.using_consumeable
    then
        for _, aka_target in ipairs(aka_targets) do
            if BACHILATRO_is_aka_target_valid(aka_target) then
                local effect = SMODS.blueprint_effect(
                    enten_card,
                    aka_target,
                    context
                )
                if effect then
                    copied_effects[#copied_effects + 1] = effect
                end
            end
        end
    end

    local copied_effect = nil
    if #copied_effects == 1 then
        copied_effect = copied_effects[1]
    elseif #copied_effects > 1 then
        copied_effect = SMODS.merge_effects(unpack(copied_effects))
    end

    if context.ante_change
        and context.ante_end
    then

        G.GAME.bachilatro_energy_max =
            BACHILATRO_ENERGY_MAX

        G.GAME.bachilatro_energy =
            BACHILATRO_ENERGY_MAX

        BACHILATRO_refresh_energy_hud()

    end

    --------------------------------------------------
    -- TERMINAR AKA AL FINALIZAR EL ROUND
    --------------------------------------------------

    if context.end_of_round and context.main_eval then
        if G.jokers then
            for _, joker in ipairs(G.jokers.cards) do
                joker.ability.bachilatro_aka_copy = nil
            end
        end
        G.GAME.bachilatro_aka_used = nil
    end

    return copied_effect
end
