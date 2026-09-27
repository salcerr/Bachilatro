--------------------------------------------------
-- CARGAR ARCHIVOS DEL MOD
--------------------------------------------------

SMODS.load_file('config/constants.lua')()
SMODS.load_file('config/swords/enten_preset.lua')()
SMODS.load_file('config/swords/kuregumo_preset.lua')()
SMODS.load_file('config/wielders/chihiro_preset.lua')()
SMODS.load_file('config/wielders/sojo_preset.lua')()
SMODS.load_file('core/sword_presets.lua')()
SMODS.load_file('mechanics/shared/energy_system.lua')()
SMODS.load_file('mechanics/swords/enten_abilities.lua')()
SMODS.load_file('mechanics/swords/kuregumo_abilities.lua')()

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

SMODS.load_file('content/consumable_types/enchanted_blade_type.lua')()
SMODS.load_file('content/enhancements/kuregumo_status_cards.lua')()
SMODS.load_file('content/jokers/wielder_jokers.lua')()

SMODS.Atlas {
    key = 'enten_art',
    path = 'Enten.png',
    px = 71,
    py = 95
}

SMODS.load_file('content/swords/enten_card.lua')()
SMODS.load_file('content/swords/kuregumo_card.lua')()

SMODS.load_file('ui/swords/card_controls.lua')()
SMODS.load_file('ui/energy_hud.lua')()
