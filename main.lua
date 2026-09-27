--------------------------------------------------
-- CARGAR ARCHIVOS DEL MOD
--------------------------------------------------

SMODS.load_file('config/constants.lua')()
SMODS.load_file('config/swords/enten.lua')()
SMODS.load_file('config/swords/kuregumo.lua')()
SMODS.load_file('config/wielders/chihiro.lua')()
SMODS.load_file('config/wielders/sojo.lua')()
SMODS.load_file('content/sword_framework.lua')()
SMODS.load_file('mechanics/energy.lua')()
SMODS.load_file('mechanics/swords/enten.lua')()
SMODS.load_file('mechanics/swords/kuregumo.lua')()

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

SMODS.load_file('content/consumable_type.lua')()
SMODS.load_file('content/kuregumo_enhancements.lua')()
SMODS.load_file('content/joker.lua')()

SMODS.Atlas {
    key = 'enten_art',
    path = 'Enten.png',
    px = 71,
    py = 95
}

SMODS.load_file('content/enten.lua')()
SMODS.load_file('content/kuregumo.lua')()

SMODS.load_file('ui/enten_ui.lua')()
SMODS.load_file('ui/energy_hud.lua')()
