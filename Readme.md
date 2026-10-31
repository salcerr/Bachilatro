# Bachilatro

**A [Balatro](https://www.playbalatro.com/) content mod inspired by the manga *Kagurabachi*.**

Collect the legendary **Enchanted Blades**, spend **Energy** on their techniques, and find the Jokers of the people who wield them.

> **Early development** — content, numbers and art can still change. Tested mainly by the author so far.

**Version:** 0.1.0  
**Requires:** [Steamodded](https://github.com/Steamodded/smods) + [Lovely](https://github.com/ethangreen-dev/lovely-injector)

---

## Features

- **5 Enchanted Blades** as a new consumable type (Enten, Kuregumo, Tobimune, Kumeyuri, Magatsumi)
- Shared **Energy system** used by all blade techniques
- **6 wielder Jokers** (Chihiro, Sojo, Samura, Hiruhiko, Yura / Akemura)
- **1 Booster Pack** — Enchanted Blade Pack
- **2 Decks** — Rokuhira's Legacy Deck & Shinuchi Deck
- **2 Enhancements** — Wet & Shocked (used by Kuregumo)

---

## How it works

- Blades are consumables that **are not used up**. Select one and use its techniques with the buttons next to it.
- Each technique costs **Energy**. You start with **100 Energy**; it refills at the end of every Ante.
- **You can only have one blade per run.** Once you own one, no other blade appears in the shop. A shop also never offers a blade and an Enchanted Blade Pack at the same time.
- Each blade has a **wielder Joker**. It only appears in the shop while you own its blade, and holding it upgrades the blade’s techniques.

---

## The Blades

| Blade | Wielder | Techniques |
|-------|---------|------------|
| **Enten** | Chihiro Rokuhira | KURO, AKA, NISHIKI |
| **Kuregumo** | Genichi Sojo | KOU, MEI, YUI |
| **Tobimune** | Seiichi Samura | KARASU, FUKURO, SUZAKU |
| **Kumeyuri** | Hiruhiko | EN, YUU |
| **Magatsumi** | Yura / Akemura Soga | KUMO, TONBO, MUKADE, CHO, HACHI, KODOKU |

### Enten — Chihiro Rokuhira
- **KURO** — Destroy selected cards.
- **AKA** — Copy selected Jokers for the round.
- **NISHIKI** — Disable a Boss Blind’s effect. With Chihiro it also lowers the score target on any Blind.
- *Chihiro* gains X Mult every time you defeat a Blind.

### Kuregumo — Genichi Sojo
- **KOU** — Turn up to 3 selected cards **Wet**.
- **MEI** — Turn Wet cards **Shocked** (extra Mult). Shocked cards return to normal when discarded or when the Blind ends.
- **YUI** — Lower the Blind’s score target for every Wet card.
- *Sojo* gains X Mult with every use and “studies” the blade. When he has studied enough, Kuregumo is upgraded.

### Tobimune — Seiichi Samura
- **KARASU** — Swap a card in your hand with any card from your deck.
- **FUKURO** — Choose a Joker rarity. Shop Jokers are more likely to be that rarity until the Ante ends.
- **SUZAKU** — Raise the rank of selected cards by 1.
- *Samura* saves you from losing a Blind if you used Suzaku in it (and is destroyed doing so).

### Kumeyuri — Hiruhiko
- **EN** — Create temporary copies of a selected card. They vanish when the Blind ends.
- **YUU** — Move an enhancement, seal or edition from one card to another. With Hiruhiko it moves all of them and destroys the source card.
- *Hiruhiko* gains X Mult for every playing card destroyed.

### Magatsumi — Yura / Akemura Soga *(Shinuchi Deck only)*
Magatsumi never appears in the shop or in packs. It comes with the **Shinuchi Deck**, together with the Joker *Yura*.

1. **Sealed** — For 9 Blinds the blade has no techniques and drains your deck: at the start of every Blind each card has a chance to lose a rank.
2. **Awakening** — After the ninth Blind, Yura becomes **Akemura Soga** and Magatsumi awakens.
3. **Full power** — Your maximum Energy doubles and every Blind you defeat gives some back. The blade gains six techniques:
   - **KUMO** — The first card of your next hand returns to your hand instead of being discarded.
   - **TONBO** — Turn a card into Glass and force it to be played or discarded.
   - **MUKADE** — After your next hand, destroy every card left in your hand.
   - **CHO** — On a 5-card hand, destroy the middle 3 cards; the 2 end cards retrigger.
   - **HACHI** — The last scoring card of your next hand retriggers several times.
   - **KODOKU** — Lower the rank of up to 5 selected cards.

---

## Installation

1. Install [Lovely](https://github.com/ethangreen-dev/lovely-injector) and [Steamodded](https://github.com/Steamodded/smods).
2. Download this repository (or the latest Release) and unzip it.
3. Put the `Bachilatro` folder inside your mods folder:
   - **Windows:** `%AppData%/Balatro/Mods`
   - **Mac:** `~/Library/Application Support/Balatro/Mods`
4. Make sure the structure is `Mods/Bachilatro/main.lua` (not nested twice).
5. Launch the game.

It’s recommended to play modded runs on a separate profile.

---

## License

Code is licensed under the **GNU General Public License v3.0**.  
Art assets are **not** covered by this license and remain the property of their respective creators.

---

## Credits

- Mod by **salcer**
- Based on the manga **Kagurabachi** by Takeru Hokazono

---

## Disclaimer

Bachilatro is an unofficial, non-commercial fan project.  
It is not affiliated with or endorsed by the creators or publishers of *Kagurabachi* or *Balatro*.