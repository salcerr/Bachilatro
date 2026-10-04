-- Coordinates shared run boundaries and asks each system to reset its state.
function SMODS.current_mod.reset_game_globals(run_start)
    if not run_start then return end

    BACHILATRO_reset_energy()
    G.GAME.bachilatro_kuregumo_study = 0
    G.GAME.bachilatro_kuregumo_upgraded = false
end

function SMODS.current_mod.calculate(self, context)
    if context.ante_change and context.ante_end then
        BACHILATRO_refill_energy()
    end

    if context.end_of_round and context.main_eval then
        BACHILATRO_clear_all_kuregumo_status()

        if G.jokers then
            for _, joker in ipairs(G.jokers.cards) do
                joker.ability.bachilatro_aka_copy = nil
            end
        end
        G.GAME.bachilatro_aka_used = nil
    end
end