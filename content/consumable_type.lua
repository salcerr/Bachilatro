--------------------------------------------------
-- TIPO DE CONSUMABLE: ENCHANTED BLADE
--------------------------------------------------

SMODS.ConsumableType {
    key = 'EnchantedBlade',

    primary_colour = HEX('4A6FA5'),
    secondary_colour = HEX('1E3A5F'),

    collection_rows = { 4, 4 },

    shop_rate = 0,

    loc_txt = {
        name = 'Enchanted Blade',

        collection = 'Enchanted Blade Cards',

        undiscovered = {
            name = 'Not Discovered',

            text = {
                'Find this card in an',
                'unseeded run to',
                'learn what it does'
            }
        }
    }
}