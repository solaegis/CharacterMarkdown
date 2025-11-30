# Complete ESO Formulas Reference Table

## Damage Calculation

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Base Ability Damage | `(Max Resource × 0.1065) + (Weapon/Spell Damage × 1.0)` | Resource = Mag/Stam based on highest stat (Update 33+) |
| Tooltip Damage | `Base Damage × Ability Coefficient` | Coefficient varies per skill |
| Final Non-Crit Damage | `Tooltip Damage × (1 + Total Damage Bonuses) × Mitigation Factor` | Before target mitigation |
| Total Damage Bonuses | `Flat% + Element% + Type% + Target Debuffs` | All additive within category |
| Critical Damage | `Final Damage × Critical Multiplier` | Applied after base calculation |
| Critical Multiplier | `1.5 + (Critical Damage Bonus / 100)` | Base is 1.5x (150%) |
| Average Damage | `(Non-Crit × (1 - Crit%)) + (Crit Damage × Crit%)` | Expected damage over time |
| Light Attack Damage | `(Max Stamina × 0.04) + (Weapon Damage × 1.0)` | Magicka builds use Mag/Spell Damage |
| Heavy Attack Damage | `(Max Stamina × 0.08) + (Weapon Damage × 2.0)` | Multiplier varies by weapon type |
| Bash Damage | `(Max Stamina × Coefficient) + (Weapon Damage × Coefficient) + Flat Bonuses` | Exact coefficients vary |
| Effective Max Resource | `Max Resource + (Weapon/Spell Damage × 10.5)` | Approximate equivalence for comparison |

## Healing Calculation

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Base Healing | `(Max Resource × 0.1065) + (Weapon/Spell Damage × 1.0)` | Same scaling as damage |
| Final Healing (Outgoing) | `Base Healing × Ability Coefficient × (1 + Healing Done%)` | Healer's perspective |
| Final Healing (Received) | `Outgoing Healing × (1 + Healing Taken%)` | Recipient's perspective |
| Critical Healing | `Final Healing × Critical Multiplier` | Base 1.5x multiplier |
| Critical Heal Multiplier | `1.5 + (Critical Healing Bonus / 100)` | Can be increased with bonuses |

## Mitigation & Defense

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Resistance to Mitigation | `Mitigation% = (Resistance / (Resistance + 660)) × 100` | Diminishing returns formula |
| Max Resistance Mitigation | `50%` at 33,000 resistance | Hard cap in PvE |
| Effective Resistance | `Base Resistance - Penetration` | Cannot go below 0 |
| Damage After Mitigation | `Incoming Damage × (1 - Mitigation%)` | Final damage calculation |
| Block Mitigation | `Blocked Damage = Incoming × (1 - Block Mit%)` | Base block = 50% |
| Total Mitigation (with buffs) | `Resistance Mit% + Protection% + Set Bonuses%` | Stacks additively |

## Critical Hits

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Critical Chance | `(Critical Rating / 219) - Target Crit Resistance` | 219 rating = 1% chance |
| Critical Resistance | `Bonus Damage Reduction = Crit Resist / (50 × (Level + VR))` | VR14: 3200 = full negation |
| Base Critical Damage | `150%` (1.5x multiplier) | Before bonuses |
| Critical Damage Cap | None | No hard cap on crit damage bonus |

## Penetration

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Effective Resistance | `Target Resistance - Your Penetration` | Cannot reduce below 0 |
| Minor Breach | `-2,974 resistance` | Debuff on target |
| Major Breach | `-5,948 resistance` | Debuff on target |
| Penetration + Breach | Additive | Stacks with penetration stat |

## Resource Management

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Recovery Per Tick (In Combat) | `(Base Recovery + Bonuses) / 2` | Ticks every 2 seconds |
| Recovery Per Tick (Out of Combat) | `Base Recovery + Bonuses` | Full rate, ticks every 2 seconds |
| Actual Ability Cost | `Base Cost × (1 - Cost Reduction%)` | Cost reduction stacks additively |
| Heavy Attack Resource Return | Varies by weapon | Must fully charge |
| Potion Sustain per Second | `(Flat Restore + Resourceful) / 45` | Argonian Resourceful = 4,620 |

## Ultimate Generation

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Light/Heavy Attack Ultimate | `3 Ultimate/second for 9 seconds` | 27 total per attack |
| Healing Ultimate Generation | Same as attacker if target has buff | Healer gains buff from healing |
| Nightblade (Siphoning) | `0.5 Ultimate/sec` (2 per 4 sec) | Class passive |
| Templar (Dawn's Wrath) | `0.5 Ultimate/sec` (3 per 6 sec) | Class passive |
| Dragonknight (Earthen Heart) | `0.5 Ultimate/sec` (3 per 6 sec) | Class passive |
| Nightblade (Catalyst) | `20 Ultimate per potion` | Every 45 seconds |
| Base Ultimate Generation | `0 without actions` | Must attack/heal/block/dodge |

## Status Effects

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Burning (per tick) | `(Spell Damage × 0.2) + (Max Magicka × 0.0213)` | 4 sec duration, 2 ticks |
| Poisoned (per tick) | `(Weapon Damage × 0.24) + (Max Stamina × 0.0256)` | 6 sec duration, 3 ticks |
| Hemorrhaging (per tick) | `(Weapon Damage × 0.24) + (Max Stamina × 0.0256)` | 4 sec duration, 2 ticks |
| Chilled (Frost) | Applies Minor Brittle (+10% crit damage taken) | Status effect |
| Concussed (Shock) | Applies Minor Vulnerability (+8% damage taken) | Status effect |

## Attribute Scaling

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Base Attributes (Level 1) | Mag/Stam: 1,000; Health: 1,100 | Starting values |
| Per Level Increase (no points) | Mag/Stam: +142; Health: +156 | Automatic gain |
| Per Attribute Point Spent | Mag/Stam: +111; Health: +122 | Active investment |
| Total Attribute Points | 64 points by CP 160 | Level 1-50 + bonus |
| Highest Offensive Stats (U33+) | `MAX(Mag, Stam) + MAX(Weapon Dmg, Spell Dmg)` | Dynamic scaling |

## Champion Points

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Offensive CP (Diminishing) | `Effectiveness% = CP / (CP + 30)` | 30 CP = 50% effectiveness |
| XP Per Champion Point | `400,000 XP` | Flat rate (CP 2.0) |
| CP Effectiveness Examples | 30 CP = 50%; 60 CP = 66.7%; 90 CP = 75% | Most offensive stars |

## Crafting Formulas

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Research Time | `Base Time × 2^(Traits Researched - 1)` | Doubles per trait on same item |
| Base Research Time | 6 hours | Reducible with passives |
| Improvement Success Rate | `Base Rate × Number of Tempers` | Per quality tier |
| Green Improvement | 20% per temper (5 for 100%) | Tier 2 |
| Blue Improvement | 15% per temper (7 for 100%) | Tier 3 |
| Purple Improvement | 10% per temper (10 for 100%) | Tier 4 |
| Gold Improvement | 5% per temper (20 for 100%) | Tier 5 |

## Experience & Leveling

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| XP Per Level (Approximate) | `Previous Level XP × 1.15` | ~15% increase per level |
| Total XP to Level 50 | ~1,000,000 XP | Approximate |
| Champion Point XP | 400,000 XP per CP | Flat rate post-CP 2.0 |

## Movement & Combat Actions

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Sprint Speed | `Base 100% + Sprint Speed Bonuses` | Stamina drain while active |
| Sprint Cost | `Base Cost/sec × (1 - Cost Reduction%)` | Continuous drain |
| Sneak Speed | `Reduced Base + Sneak Speed Bonuses` | Slower than normal movement |
| Block Move Speed | `Base 40% + Block Speed Bonuses` | While actively blocking |
| Dodge Roll Cost | `Base Cost × (1 - Cost Reduction%)` | ~3,000 stamina base |
| Break Free Cost | `Base Cost × (1 - Cost Reduction%)` | ~5,000 stamina base |
| Bash Cost | `Base Cost × (1 - Cost Reduction%)` | Interrupts casting |

## Buff/Debuff Stacking

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Same Major Buffs | Do NOT stack | Only highest duration applies |
| Different Major Buffs | DO stack | All apply simultaneously |
| Major + Minor (same type) | DO stack | Additive |
| Same Minor Buffs | Do NOT stack | Only highest duration applies |
| Unique Named Buffs | Stack with Major/Minor | All apply |

## Advanced Stats (From Screenshot)

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Block Cost Per Hit | `Base Cost × (1 - Cost Reduction%)` | 0 = 100% reduction |
| Block Mitigation Total | `Base 50% + Set/Passive Bonuses` | Can exceed 50% |
| Resistance (All Types) | `Mit% = Resist / (Resist + 660) × 100` | Same formula for all elements |
| PvP Resistance (High Mit%) | Battle Spirit + Set Bonuses | Can exceed 50% cap |

## Resource Coefficients

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Magicka → Damage Conversion | `Max Magicka × 0.1065` | ~10 Mag = 1 damage |
| Stamina → Damage Conversion | `Max Stamina × 0.1065` | ~10 Stam = 1 damage |
| Weapon/Spell Damage | `1:1 ratio` | Direct contribution |
| Damage Contribution Ratio | `b/a ≈ 10.5` | Resource vs Damage weight |

## Combat Caps

| Stat | Cap Value | Notes |
|------|-----------|-------|
| Critical Chance | 100% | Hard cap |
| Critical Damage | No cap | Unlimited scaling |
| Resistance Mitigation (PvE) | 50% (33,000 resistance) | Soft cap |
| Resistance Mitigation (PvP) | Higher with Battle Spirit | Modified |
| Block Mitigation | ~90% practical | With all bonuses |
| Movement Speed (Sprint) | 200% | Hard cap |
| Penetration Floor | 0 | Cannot reduce resistance below 0 |

## Additional Formulas

| Formula Name | Formula | Notes |
|-------------|---------|-------|
| Buff Duration Extension (Jorvuld's) | `Base Duration × 1.4` | +40% to eligible buffs |
| Battle Roar (DK) | `46 × Ultimate Generation/sec` | Resource return per ult cast |
| Channeled Focus (Templar) | `(-1,080 + Cost Reduction) + (120 × 36 ticks)` | Net resource over 18 sec |
| Overpenetration | Wasted penetration above target resistance | No benefit |

---

**Notes:**
- All formulas current as of Update 35+ (Hybrid scaling era)
- Some coefficients may vary slightly per ability
- PvP formulas modified by Battle Spirit
- Exact coefficients for some abilities not publicly documented
- Formulas subject to change with patches