--------------------------------------------------
-- ENERGÍA COMPARTIDA ENTRE ESPADAS
--------------------------------------------------

function BACHILATRO_spend_energy(amount)
    if not G.GAME then return end

    G.GAME.bachilatro_energy = math.max(
        0,
        (G.GAME.bachilatro_energy or 0) - amount
    )
    BACHILATRO_refresh_energy_hud()
end

function BACHILATRO_reset_energy()
    G.GAME.bachilatro_energy_max = BACHILATRO_ENERGY_MAX
    G.GAME.bachilatro_energy = BACHILATRO_ENERGY_MAX
end

function BACHILATRO_refill_energy()
    if not G.GAME then return end
    G.GAME.bachilatro_energy_max = BACHILATRO_ENERGY_MAX
    G.GAME.bachilatro_energy = BACHILATRO_ENERGY_MAX
    BACHILATRO_refresh_energy_hud()
end

local bachilatro_original_start_run = Game.start_run

function Game:start_run(args)
    bachilatro_original_start_run(self, args)

    G.GAME.bachilatro_energy_max = G.GAME.bachilatro_energy_max
        or BACHILATRO_ENERGY_MAX
    G.GAME.bachilatro_energy = G.GAME.bachilatro_energy
        or G.GAME.mpm_energy
        or G.GAME.bachilatro_energy_max

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        blockable = false,
        func = function()
            BACHILATRO_create_energy_hud()
            return true
        end
    }))
end

local bachilatro_original_delete_run = Game.delete_run

function Game:delete_run()
    BACHILATRO_remove_energy_hud()
    return bachilatro_original_delete_run(self)
end
