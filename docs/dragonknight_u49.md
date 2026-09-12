# Dragonknight — Update 49 skill reference

Source of truth for solaegis build plans after the **Update 49** Dragonknight class refresh (March 2026). Prefer **current in-game UI names**. Do not recommend pre-U49 morph paths.

See also: [subclassing.md](subclassing.md), [plan_structure.md](plan_structure.md).

## Line ownership (post-U49)

### Ardent Flame

| Ability | Morphs | Notes |
| :--- | :--- | :--- |
| Dragonknight Standard | Standard of Might · Shifting Standard | Base + Might = support banner (WD/SD + damage reduction); Shifting Standard keeps DoT + Major Defile |
| Lava Whip | Flame Lash · Molten Whip | |
| Searing Strike | **Searing Claw** · Burning Embers | Searing Claw was Venomous Claw; flame DoT (stamina) |
| Core of Flame | Soul of Flame · Heart of Flame | Was Inhale / Deep Breath / Draw Essence |
| Hearthfire | Fire Keeper · Hearth and Home | Was Ash Cloud / Cinder Storm / Eruption |
| Inferno | Incinerate · Flames of Oblivion (see live UI) | Incinerate was Flames of Oblivion |

**Passives:** Combustion · Traumatic Burns (was Warmth) · Fan the Flames (was Searing Heat) · A Soul Ablaze (was Burning Heart)

### Draconic Power

| Ability | Morphs | Notes |
| :--- | :--- | :--- |
| Dragon Leap | Take Flight · Ferocious Leap | Flame damage |
| **Dragonfire Breath** | **Disintegrating Dragonfire** · Engulfing Dragonfire | Was Fiery Breath / Noxious Breath / Engulfing Flames |
| Dark Talons | (sibling morphs as in UI) | |
| Dragon Blood | **Blood of the Green Dragon** · Blood of the Elder Dragon | Was Green Dragon Blood / Coagulating Blood |
| Wing Buffet | Fleetstep Wings · Protect the Brood | Was Protective Scale / Protective Plate / Dragonfire Scale |
| Chains of Flame | Chains of Domination · Chains of Devastation | Was Fiery Grip morphs |

**Passives:** Burnished Scales (was Iron Skin) · World in Ruin · Elder Dragon · The Storm Voice (was Battle Roar)

### Earthen Heart

| Ability | Morphs | Notes |
| :--- | :--- | :--- |
| Magma Armor | (sibling morphs as in UI) | |
| Superheated Ward | (sibling morphs as in UI) | Was Stonefist |
| Molten Weapons | (sibling morphs as in UI) | |
| Obsidian Shield | Igneous Shield · (other morph as in UI) | |
| Petrify | Fossilize · Shattering Rocks | |
| **Earthspike Mantle** | **Earthshield Mantle** · Shatterspike Mantle | Was Spiked Armor / Hardened Armor / Volatile Armor |

**Passives:** Heart of Stone (was Scaled Armor) · Avalanche (was Eternal Mountain) · Blessing at the Peak (was Mountain's Blessing) · Mountain Giant (was Helping Hands)

## Old → new (do not use left column)

| Invalid (pre-U49) | Current |
| :--- | :--- |
| Fiery Breath | Dragonfire Breath |
| Noxious Breath | Disintegrating Dragonfire |
| Engulfing Flames | Engulfing Dragonfire |
| Spiked Armor | Earthspike Mantle |
| Hardened Armor | Earthshield Mantle |
| Volatile Armor | Shatterspike Mantle |
| Venomous Claw | Searing Claw |
| Green Dragon Blood | Blood of the Green Dragon |
| Coagulating Blood | Blood of the Elder Dragon |
| Protective Scale | Wing Buffet |
| Protective Plate | Fleetstep Wings |
| Dragonfire Scale | Protect the Brood |
| Fiery Grip | Chains of Flame |
| Unrelenting Grip | Chains of Domination |
| Inhale | Core of Flame |
| Ash Cloud | Hearthfire |
| Stonefist | Superheated Ward |
| Iron Skin | Burnished Scales |
| Warmth | Traumatic Burns |
| Searing Heat | Fan the Flames |
| Burning Heart | A Soul Ablaze |
| Battle Roar | The Storm Voice |

## Mechanics that break old plan prose

- **Poison → Flame:** Former DK poison morphs deal **Flame** and apply **Burning**, not Poisoned.
- **Combustion:** Refunds only when applying **Burning** with an **Ardent Flame** ability **slotted** (not on Poisoned from weapon poisons).
- **Standard of Might:** Support banner (Weapon/Spell Damage + reduced damage taken) while standing in it — **not** a planted DoT / Major Defile field. Use **Shifting Standard** if the plan wants the old damage banner.
- **Earthspike Mantle is Earthen Heart**, not Draconic Power. If Trinity **drops Earthen Heart** (e.g. Shadow subclass), target/post-50 bars must **not** keep Earthshield Mantle / Earthspike Mantle / Molten Weapons / other Earthen actives.

## Agent checklist

1. Use current morph names from the table above.
2. Attribute abilities to the correct line (especially breath vs mantle).
3. When a plan drops a line, scrub that line's skills from target bars and rotations.
4. Do not invent morph paths from deprecated base names.
