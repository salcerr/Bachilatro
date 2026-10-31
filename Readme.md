# Bachilatro

A [Balatro](https://www.playbalatro.com/) mod inspired by the manga **Kagurabachi**: collect the legendary *Enchanted Blades*, spend Energy on their techniques and find the Jokers of the people who wield them.

> **This mod is in early development.** Content, numbers and art can change, and there may be bugs. Everything has been tested only by its author so far.

## What it adds

- **A new consumable type: Enchanted Blades** — 5 swords, each with its own techniques
- **An Energy system** shared by every blade
- **6 wielder Jokers**, one for each blade (Magatsumi has two)
- **1 booster pack**: the Enchanted Blade Pack
- **2 decks**: Rokuhira's Legacy Deck and Shinuchi Deck
- **2 enhancements**: Wet and Shocked (used by Kuregumo)

## How it works

- Blades are consumables that **are not used up**. Select one and press the buttons next to it to use a technique.
- Each technique costs **Energy**. You have **100 Energy**, and it refills at the end of every Ante.
- **You can only have one blade per run.** Once you own one, no other blade shows up in the shop. A shop also never offers a blade and an Enchanted Blade Pack at the same time.
- Each blade has a **wielder Joker**. It only appears in the shop while you own its blade, and holding it *upgrades* the blade's techniques.

## The blades

| Blade | Wielder | Techniques |
|---|---|---|
| **Enten** | Chihiro Rokuhira | KURO, AKA, NISHIKI |
| **Kuregumo** | Genichi Sojo | KOU, MEI, YUI |
| **Tobimune** | Seiichi Samura | KARASU, FUKURO, SUZAKU |
| **Kumeyuri** | Hiruhiko | EN, YUU |
| **Magatsumi** | Yura / Akemura Soga | KUMO, TONBO, MUKADE, CHO, HACHI, KODOKU |

### Enten — Chihiro Rokuhira
- **KURO**: destroy selected cards.
- **AKA**: copy selected Jokers for the round.
- **NISHIKI**: disable a Boss Blind's effect. With Chihiro it also lowers the score target on any Blind.
- *Chihiro* gains X Mult every time you defeat a Blind.

### Kuregumo — Genichi Sojo
- **KOU**: turn up to 3 selected cards **Wet**.
- **MEI**: turn Wet cards **Shocked**, which score extra Mult. Shocked cards go back to normal when they are discarded or the Blind ends.
- **YUI**: lower the Blind's score target for every Wet card.
- *Sojo* gains X Mult with every use and "studies" the blade. When he has studied enough, Kuregumo is upgraded.

### Tobimune — Seiichi Samura
- **KARASU**: swap a card in your hand with any card from your deck.
- **FUKURO**: choose a Joker rarity. Shop Jokers are more likely to be that rarity until the Ante ends.
- **SUZAKU**: raise the rank of selected cards by 1.
- *Samura* saves you from losing a Blind if you used Suzaku in it, and is destroyed doing so.

### Kumeyuri — Hiruhiko
- **EN**: create temporary copies of a selected card. They vanish when the Blind ends.
- **YUU**: move an enhancement, seal or edition from one card to another. With Hiruhiko it moves all of them and destroys the source card.
- *Hiruhiko* gains X Mult for every playing card destroyed.

### Magatsumi — Yura / Akemura Soga (Shinuchi Deck only)
Magatsumi never appears in the shop or in packs. It comes with the **Shinuchi Deck**, together with the Joker *Yura*.

1. **Sealed.** For **9 Blinds** the blade has no techniques and drains your deck: at the start of every Blind each card has a chance to lose a rank (a 2 becomes an Ace).
2. **Awakening.** After the ninth Blind, Yura becomes **Akemura Soga** and Magatsumi awakens.
3. **Full power.** Your maximum Energy doubles and every Blind you defeat gives you some back. The blade gets six techniques:
   - **KUMO**: the first card of your next hand returns to your hand instead of being discarded.
   - **TONBO**: turn a card into Glass and force it to be played or discarded.
   - **MUKADE**: after your next hand, destroy every card left in your hand.
   - **CHO**: on a 5-card hand, destroy the middle 3 cards; the 2 end cards retrigger.
   - **HACHI**: the last scoring card of your next hand retriggers several times.
   - **KODOKU**: lower the rank of up to 5 selected cards.

## Installation

Requires **[Steamodded](https://github.com/Steamodded/smods)** and **[Lovely](https://github.com/ethangreen-dev/lovely-injector)**.

1. Install Lovely and Steamodded if you don't have them yet.
2. Download this repository (or the latest release) and unzip it.
3. Put the `Bachilatro` folder inside your mods folder:
   - **Windows:** `%AppData%/Balatro/Mods`
   - **Mac:** `~/Library/Application Support/Balatro/Mods`
4. Make sure it is **not a nested folder** (`Mods/Bachilatro/main.lua` should exist, not `Mods/Bachilatro/Bachilatro/main.lua`).
5. Start the game.

Developed and tested on Balatro 1.0.1o with Lovely 0.10.0 on Windows.

It's recommended to play modded runs on a separate profile so they don't affect your vanilla progress.

## Credits

- Mod by **salcer**.
- Based on the manga **Kagurabachi** by Takeru Hokazono.

## Disclaimer

Bachilatro is an unofficial, non-commercial fan project. It is not affiliated with or endorsed by the creators or publishers of Kagurabachi or Balatro. Kagurabachi, its characters and its artwork belong to their respective owners, and so does Balatro.