-- Coordinates shared run boundaries and asks each system to reset its state.
function SMODS.current_mod.reset_game_globals(run_start)
    if not run_start then return end

    BACHILATRO_reset_energy()
    G.GAME.bachilatro_kuregumo_study = 0
    G.GAME.bachilatro_kuregumo_upgraded = false
    G.GAME.bachilatro_fukuro = nil
    G.GAME.bachilatro_suzaku_used_blind = nil
end

function SMODS.current_mod.calculate(self, context)
    if context.ante_change and context.ante_end then
        BACHILATRO_refill_energy()
        -- Fukuro dura hasta que termina el Ante
        G.GAME.bachilatro_fukuro = nil
    end

    -- Suzaku solo cuenta para salvar de ESTE Blind
    if context.setting_blind then
        G.GAME.bachilatro_suzaku_used_blind = nil
    end

    if context.end_of_round and context.main_eval then
        BACHILATRO_clear_all_kuregumo_status()
        -- las copias de En (Kumeyuri) desaparecen al terminar el Blind
        BACHILATRO_destroy_kumeyuri_illusions()

        if G.jokers then
            for _, joker in ipairs(G.jokers.cards) do
                joker.ability.bachilatro_aka_copy = nil
            end
        end
        G.GAME.bachilatro_aka_used = nil
    end
end