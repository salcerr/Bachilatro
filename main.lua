--------------------------------------------------
-- CARGAR ARCHIVOS DEL MOD
--------------------------------------------------

SMODS.load_file('config/constants.lua')()
SMODS.load_file('config/swords/enten.lua')()
SMODS.load_file('config/wielders/chihiro.lua')()
SMODS.load_file('content/sword_framework.lua')()

SMODS.load_file('content/consumable_type.lua')()
SMODS.load_file('content/joker.lua')()

SMODS.Atlas {
    key = 'enten_art',
    path = 'Enten.png',
    px = 71,
    py = 95
}

SMODS.load_file('content/enten.lua')()

SMODS.load_file('ui/enten_ui.lua')()
SMODS.load_file('ui/energy_hud.lua')()
