# Rilis Toxil — Craftable gear approach comparison

> **Character:** [rilis_toxil.md](../solaegis/na/rilis_toxil.md) · **Plan:** [rilis_toxil_plan.md](../solaegis/na/rilis_toxil_plan.md)
> **Constraint:** 100% craftable (@masisi). No overland / dungeon / trial sets.
> **Baseline live (export):** L50 / CP 1039 · Spell Power **2,283** · Spell Crit **6,288 (28.7%)** · Magicka **28,483** · still in Trainee scraps.
> **Bonus values:** CP160 gold (UESP / eso-decoded datamine, Aug 2026). Crit % ≈ rating ÷ **219.125**.

**Decision status:** **Locked — Approach 1** (5 Order's Wrath + 5 Law of Julianos). Plan updated 2026-08-13.

---

## Approaches under test

| ID | Pairing | Craftable? | Notes |
| :--- | :--- | :---: | :--- |
| **1** | **5 Order's Wrath + 5 Law of Julianos** | Yes | Recommended — modern craftable crit package |
| **2** | **5 Law of Julianos + 5 Magnus's Gift** | Yes | Sustain / cheaper bridge |
| **3** | Same sets as **1**, different slot split | Yes | **Identical set bonuses** to Approach 1 |
| ~~Ref A~~ | ~~5 Julianos + 5 Mother's Sorrow~~ | **No** | Old plan target — Deshaan overland; excluded |
| ~~Ref B~~ | ~~5 Hexos' Ward + 5 Julianos~~ | **No** | Deadlands overland; medium armor body; solo shield proc |
| ~~Ref C~~ | ~~5 Hexos' Ward + 5 Order's Wrath~~ | **No** | Same Hexos constraint; keeps OW crit-damage package |

---

## Per-set bonuses (CP160 gold, 5-piece)

### Law of Julianos (crafted — Boreal Forge, Wrothgar · 6 traits)

| Pieces | Bonus |
| :---: | :--- |
| 2 | +657 Critical Chance |
| 3 | +1,096 Maximum Magicka |
| 4 | +657 Critical Chance |
| 5 | +300 Weapon and Spell Damage |

**5pc total:** **1,314 crit** (~6.0%) · **1,096 Magicka** · **300 Spell Damage**

### Order's Wrath (crafted — Steadfast Hammer and Saw, High Isle · 6–7 traits)

| Pieces | Bonus |
| :---: | :--- |
| 2 | +657 Critical Chance |
| 3 | +129 Weapon and Spell Damage |
| 4 | +657 Critical Chance |
| 5 | +943 Critical Chance **and** **+8% Critical Damage / Critical Healing** |

**5pc total:** **2,257 crit** (~10.3%) · **129 Spell Damage** · **+8% crit damage**

### Magnus's Gift (crafted — Greenshade / Rivenspire / Shadowfen · 4 traits)

| Pieces | Bonus |
| :---: | :--- |
| 2 | +1,096 Maximum Magicka |
| 3 | +129 Magicka Recovery |
| 4 | +129 Weapon and Spell Damage |
| 5 | **15% chance** to negate Magicka ability cost on cast |

**5pc total:** **1,096 Magicka** · **129 Mag Recovery** · **129 Spell Damage** · **15% free-cast proc**

### Mother's Sorrow (reference only — Deshaan overland · not craftable)

| Pieces | Bonus |
| :---: | :--- |
| 2 | +1,096 Maximum Magicka |
| 3 | +657 Critical Chance |
| 4 | +657 Critical Chance |
| 5 | +1,528 Critical Chance |

**5pc total:** **2,842 crit** (~13.0%) · **1,096 Magicka**

### Hexos' Ward (reference only — Deadlands overland · not craftable)

| Pieces | Bonus |
| :---: | :--- |
| 2 | +657 Critical Chance |
| 3 | +129 Weapon and Spell Damage |
| 4 | +657 Critical Chance |
| 5 | Direct Critical Damage → damage shield absorbing up to **12,305** for **6s** (ICD **7s**) |

**5pc total:** **1,314 crit** (~6.0%) · **129 Spell Damage** · **solo shield proc**

**Constraints for Rilis:**

- **Not craftable** — farm Deadlands / Fargrave or buy from guild traders (violates craftable-only rule).
- Armor pieces are **Medium only** (House Hexos style). Jewelry and weapons have no weight.
- To keep **7× Light** passives: put Hexos on **necklace + both rings + both staves** (5), and craft **Order's Wrath or Julianos** on all light body. Do **not** wear Hexos medium body on a mag light build.

---

## Combined set-bonus scoreboard (5 + 5)

Traits, enchants, food, potions, CP, and skills held constant. This table is **set bonuses only**.

| Metric | **1 — OW + Julianos** | **2 — Julianos + Magnus** | **3 — OW + Jul (alt)** | Ref A — Jul + MS | Ref B — Hexos + Jul | Ref C — Hexos + OW |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: |
| **Critical Chance (rating)** | **3,571** | 1,314 | **3,571** | **4,156** | 2,628 | **3,571** |
| **Critical Chance (~%)** | **~16.3%** | ~6.0% | **~16.3%** | **~19.0%** | ~12.0% | **~16.3%** |
| **Spell Damage** | **429** | **429** | **429** | 300 | **429** | 258 |
| **Max Magicka** | 1,096 | **2,192** | 1,096 | **2,192** | 1,096 | 0 |
| **Magicka Recovery** | 0 | **129** | 0 | 0 | 0 | 0 |
| **Crit Damage / Healing** | **+8%** | +0% | **+8%** | +0% | +0% | **+8%** |
| **Proc / special** | — | **15% free Magicka cast** | — | — | **12.3k shield / 7s** on direct crit | **12.3k shield / 7s** on direct crit |
| **@masisi craftable** | Yes | Yes | Yes | **No** | **No** | **No** |
| **Full light body** | Yes | Yes | Yes | Yes (light overland) | Yes if Hexos = jewelry+staves only | Yes if Hexos = jewelry+staves only |

### Hexos vs Approach 1 (craftable pick)

| | Hexos + Julianos (Ref B) | Hexos + Order's Wrath (Ref C) | Approach 1 (OW + Julianos) |
| :--- | :--- | :--- | :--- |
| Crit chance | Weaker (~12%) | **Tied** (~16.3%) | **Tied** (~16.3%) |
| Crit damage amp | None | **+8%** | **+8%** |
| Spell Damage | Tied (429) | Weaker (258) | **429** |
| Magicka from sets | 1,096 | **0** | 1,096 |
| Survivability | **Strong** (12.3k shield) | **Strong** (12.3k shield) | None from sets |
| Acquisition | Deadlands farm / trader | Deadlands farm / trader | **@masisi craft** |
| Fits Rilis rule? | No | No | **Yes** |

**Verdict:** Hexos is a **solo-tankiness** set, not a DPS upgrade over Order's Wrath. Ref C matches Approach 1's crit chance and crit-damage amp but loses **171 Spell Damage** and **1,096 Magicka**, and requires farming. Ref B is middle-of-the-road crit with the shield but still not craftable. For Rilis's craftable-only rule, Hexos stays a **reference / optional later purchase**, not a plan target.

### Ranking by role

| Goal | Winner | Why |
| :--- | :--- | :--- |
| **Raw overland DPS / skull & siphon crits** | **1 / 3** | Highest *craftable* crit package + **+8% crit damage** |
| **Sustain / spam comfort** | **2** | Double Magicka from sets, Mag Recovery, free-cast proc |
| **Solo shield / face-tank world bosses** | Hexos refs (excluded) | 12.3k shield on direct crit; use only if rule is relaxed |
| **Closest craftable to old Jul + Mother's Sorrow** | **1 / 3** | Trades ~2.7% crit chance for **+8% crit damage** and **+129 Spell Damage** |
| **Cheapest / lowest trait gate** | **2** | Magnus is 4 traits; good purple interim |
| **Slot logistics only** | **3** | Same stats as 1 — pick whichever inventory/transmute path is easier |

---

## Suggested slotting

### Approach 1 (recommended)

| Slot | Set | Weight | Trait | Enchant | Quality |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Head | Order's Wrath | Light | Divines | Max Magicka | Gold |
| Shoulders | Order's Wrath | Light | Divines | Max Magicka | Gold |
| Chest | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Hands | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Waist | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Legs | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Feet | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Necklace | Order's Wrath | Jewelry | Arcane | Spell Damage | Gold |
| Ring 1 | Order's Wrath | Jewelry | Arcane | Max Magicka | Gold |
| Ring 2 | Order's Wrath | Jewelry | Arcane | Max Magicka | Gold |
| Front Staff | Law of Julianos | Lightning Destro | Infused | Shock Damage | Gold |
| Back Staff | Law of Julianos | Restoration | Infused | Absorb Magicka | Gold |

Counts: **OW 5** (head, shoulders, jewelry) · **Julianos 7** (5 body + 2 staves) → both full 5pc bonuses.

### Approach 2

| Slot | Set | Weight | Trait | Enchant | Quality |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Head | Magnus's Gift | Light | Divines | Max Magicka | Gold |
| Shoulders | Magnus's Gift | Light | Divines | Max Magicka | Gold |
| Chest | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Hands | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Waist | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Legs | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Feet | Law of Julianos | Light | Divines | Max Magicka | Gold |
| Necklace | Magnus's Gift | Jewelry | Arcane | Spell Damage | Gold |
| Ring 1 | Magnus's Gift | Jewelry | Arcane | Max Magicka | Gold |
| Ring 2 | Magnus's Gift | Jewelry | Arcane | Max Magicka | Gold |
| Front Staff | Law of Julianos | Lightning Destro | Infused | Shock Damage | Gold |
| Back Staff | Law of Julianos | Restoration | Infused | Absorb Magicka | Gold |

### Approach 3 (same sets as 1 — example alt split)

| Slot | Set |
| :--- | :--- |
| Head, Shoulders, Chest, Hands, Legs | Order's Wrath |
| Waist, Feet, Necklace, Ring 1, Ring 2, Front Staff, Back Staff | Law of Julianos |

Set bonuses identical to Approach 1. Use only if transmute/motif/inventory path is easier.

---

## Masisi craft readiness (from [masisi.md](../solaegis/na/masisi.md))

| Profession | Gate | Status |
| :--- | :--- | :--- |
| Clothing (light) | OW / Jul / Magnus | **OK** — light slots at 8/9 or 9/9 |
| Woodworking (staves) | Lightning 9/9 · Restoration 8/9 | **OK** for Julianos (6) |
| Jewelry | Ring 9/9 · Necklace 8/9 | **OK** for OW / Magnus |
| Stations | Julianos: **Boreal Forge** (Wrothgar) · OW: **Steadfast Hammer and Saw** (High Isle) · Magnus: base-game set stations | — |

Rilis has **452 Transmute Crystals** for trait fixes after craft.

---

## Rough sheet deltas (illustrative)

Not a full parse. Relative to **set bonuses alone**, vs Approach 2 as the low-crit craftable baseline:

| | Approach 1 / 3 vs Approach 2 |
| :--- | :--- |
| Crit chance | **+~10.3%** (from Order's Wrath block) |
| Crit damage | **+8%** |
| Max Magicka (from sets) | **−1,096** |
| Magicka Recovery (from sets) | **−129** |
| Spell Damage (from sets) | **Even** (both 429) |
| Sustain proc | Lose Magnus 15% free cast |

Vs excluded Jul + Mother's Sorrow:

| | Approach 1 / 3 vs Jul+MS |
| :--- | :--- |
| Crit chance | **−~2.7%** |
| Crit damage | **+8%** |
| Spell Damage | **+129** |
| Max Magicka (from sets) | **−1,096** |
| Craftable | **Yes** vs No |

For Ricochet Skull / Detonating Siphon / Blockade crits, **+8% crit damage** usually outweighs ~2.7% crit chance on a mag necro already stacking Death Knell + Thief mundus + Fighting Finesse.

---

## Decision log

| Date | Decision | Notes |
| :--- | :--- | :--- |
| 2026-08-13 | Constraint locked | Craftable only (reject Mother's Sorrow) |
| 2026-08-13 | Approaches scored | See scoreboard above |
| 2026-08-13 | Hexos' Ward compared | Deadlands overland — solo shield; excluded under craftable-only (see Ref B / Ref C) |
| 2026-08-13 | **Approach 1 locked** | Order's Wrath + Julianos written into `rilis_toxil_plan.md` |
| 2026-08-13 | Plan synced to L50 export | Phase 0–1 marked done; Phase 2 @masisi paste block + companion/polish open work |

**Locked:** **Approach 1** — Order's Wrath + Law of Julianos, slotting as in the Approach 1 table. Mundus: keep **Apprentice** until gold is on, then test **Thief**.

---

## Sources

- [Order's Wrath — eso-decoded](https://esodecoded.com/sets/orders-wrath)
- [Law of Julianos — eso-decoded](https://esodecoded.com/sets/law-of-julianos) / [UESP](https://en.uesp.net/wiki/Online:Law_of_Julianos)
- [Magnus' Gift — eso-decoded](https://esodecoded.com/sets/magnus-gift)
- [Mother's Sorrow — eso-decoded](https://esodecoded.com/sets/mothers-sorrow) (reference only)
- [Hexos' Ward — eso-decoded](https://esodecoded.com/sets/hexos-ward) / [UESP](https://en.uesp.net/wiki/Online:Hexos%27_Ward) (reference only)
