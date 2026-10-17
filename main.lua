--------------------------------------------------
-- CARGAR ARCHIVOS DEL MOD
--------------------------------------------------

SMODS.load_file('config/constants.lua')()
SMODS.load_file('config/swords/enten_preset.lua')()
SMODS.load_file('config/swords/kuregumo_preset.lua')()
SMODS.load_file('config/swords/tobimune_preset.lua')()
SMODS.load_file('config/swords/kumeyuri_preset.lua')()
SMODS.load_file('config/wielders/chihiro_preset.lua')()
SMODS.load_file('config/wielders/sojo_preset.lua')()
SMODS.load_file('config/wielders/samura_preset.lua')()
SMODS.load_file('config/wielders/hiruhiko_preset.lua')()
SMODS.load_file('core/sword_presets.lua')()
SMODS.load_file('mechanics/shared/energy_system.lua')()
SMODS.load_file('mechanics/swords/enten_abilities.lua')()
SMODS.load_file('mechanics/swords/kuregumo_abilities.lua')()
SMODS.load_file('mechanics/swords/tobimune_abilities.lua')()
SMODS.load_file('mechanics/swords/kumeyuri_abilities.lua')()
SMODS.load_file('mechanics/shared/round_lifecycle.lua')()
SMODS.load_file('mechanics/shared/sword_limit.lua')()

-- Use Chihiro's custom art once assets/1x/Chihiro.png is provided.
BACHILATRO_CHIHIRO_ATLAS = 'Joker'
if NFS.getInfo(SMODS.current_mod.path .. '/assets/1x/Chihiro.png') then
    SMODS.Atlas {
        key = 'chihiro_art',
        path = 'Chihiro.png',
        px = 71,
        py = 95
    }
    BACHILATRO_CHIHIRO_ATLAS = 'bachilatro_chihiro_art'
end

BACHILATRO_SOJO_ATLAS = 'Joker'
if NFS.getInfo(SMODS.current_mod.path .. '/assets/1x/Sojo.png') then
    SMODS.Atlas {
        key = 'sojo_art',
        path = 'Sojo.png',
        px = 71,
        py = 95
    }
    BACHILATRO_SOJO_ATLAS = 'bachilatro_sojo_art'
end

BACHILATRO_SAMURA_ATLAS = 'Joker'
if NFS.getInfo(SMODS.current_mod.path .. '/assets/1x/Samura.png') then
    SMODS.Atlas {
        key = 'samura_art',
        path = 'Samura.png',
        px = 71,
        py = 95
    }
    BACHILATRO_SAMURA_ATLAS = 'bachilatro_samura_art'
end

BACHILATRO_HIRUHIKO_ATLAS = 'Joker'
if NFS.getInfo(SMODS.current_mod.path .. '/assets/1x/Hiruhiko.png') then
    SMODS.Atlas {
        key = 'hiruhiko_art',
        path = 'Hiruhiko.png',
        px = 71,
        py = 95
    }
    BACHILATRO_HIRUHIKO_ATLAS = 'bachilatro_hiruhiko_art'
end

SMODS.Atlas {
    key = 'kuregumo_status',
    path = 'KuregumoStatuses.png',
    px = 71,
    py = 95
}

SMODS.load_file('content/consumable_types/enchanted_blade_type.lua')()
SMODS.load_file('content/enhancements/kuregumo_status_cards.lua')()
SMODS.load_file('content/jokers/chihiro_joker.lua')()
SMODS.load_file('content/jokers/sojo_joker.lua')()
SMODS.load_file('content/jokers/samura_joker.lua')()
SMODS.load_file('content/jokers/hiruhiko_joker.lua')()

SMODS.Atlas {
    key = 'enten_art',
    path = 'Enten.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'kuregumo_art',
    path = 'Kuregumo.png',
    px = 71,
    py = 95
}

SMODS.load_file('content/swords/enten_card.lua')()
SMODS.load_file('content/swords/kuregumo_card.lua')()

SMODS.Atlas {
    key = 'tobimune_art',
    path = 'Tobimune.png',
    px = 71,
    py = 95
}
SMODS.load_file('content/swords/tobimune_card.lua')()

-- Si falta assets/1x/Kumeyuri.png usa el arte de Enten para no romper el mod.
SMODS.Atlas {
    key = 'kumeyuri_art',
    path = NFS.getInfo(SMODS.current_mod.path .. '/assets/1x/Kumeyuri.png')
        and 'Kumeyuri.png' or 'Enten.png',
    px = 71,
    py = 95
}
SMODS.load_file('content/swords/kumeyuri_card.lua')()

SMODS.Atlas {
    key = 'enchanted_blade_pack_art',
    path = 'EnchantedBladePack.png',
    px = 71,
    py = 95
}
SMODS.load_file('content/boosters/enchanted_blade_pack.lua')()
SMODS.Atlas {
    key = 'rokuhira_legacy_deck_art',
    path = 'RokuhiraLegacyDeck.png',
    px = 71,
    py = 95
}
SMODS.load_file('content/decks/rokuhira_legacy_deck.lua')()

SMODS.load_file('ui/swords/card_controls.lua')()
SMODS.load_file('ui/swords/tobimune_pickers.lua')()
SMODS.load_file('ui/energy_hud.lua')()