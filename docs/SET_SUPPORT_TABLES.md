# Support tables — ingest and spot-check

Marginal-value build math uses the existing set database plus these files:

| File | Role |
|---|---|
| `data/sets/caps.json` | Combat constants. Hand-maintained, cited to UESP where a page states the number; `value_calc.py` loads it. |
| `data/sets/passives.json` | Race / class / skill-line / guild passives, every rank (UESP fetch). |
| `data/sets/skills.json` | Every base skill and morph: buffs, debuffs, cost, resource, slotted stat grants (UESP fetch). No coefficients. |
| `data/sets/consumables.json` | Food and drink (UESP fetch) plus U51 potion drafts (hand-written, `verified: false`). |
| `data/sets/cp_stars.json` | CP effects at max rank (UESP fetch); ids/names/stages from `examples/templates/champion_points.yaml`. |

Do not regenerate `sets.json`, `traits.json`, `enchants.json`, or `mundus.json`.

Schema: `data/sets/schema.json` (`kind` + `$defs/effect`). Prompt: `docs/prompts/support_tables_system_prompt.md`.

## Refresh from UESP (primary path)

```bash
task setdb:support-fetch   # network; incremental by revid, cache in data/sets/raw/wiki/support_tables/
task setdb:support-parse   # offline; writes the four tables, merges buff sources, validates
```

`tools/setdb/support.py` walks every race, class, weapon, armor, world, guild and
Alliance War skill line on UESP. It also reads:

- `EXTRA_LINES`: Psijic Order (filed under Online-Factions), Alchemy, Provisioning and
  Enchanting.
- each CP star in `champion_points.yaml`;
- the foods in its `CONSUMABLES` list.

Companion class lines share the Class category with player lines, and UESP has no
companion category. They're dropped by the `COMPANION_LINES` denylist at fetch and again at
parse.

- Effects go through the set-bonus normalizer (`normalize.py`), so they use the same `$defs/effect` contract.
- Ranged rank values (`[27 / 28 / 29 / 30]`) take rank IV.
- Linear CP stars are multiplied out to their max-rank value.
- Pre-U51 Sorcery/Prophecy text maps to Brutality/Savagery.

A row is `verified: true` only when its numbers came from the cited page and the text
normalized fully. Skills count only the sentences that produced a kept stat grant, so
unrelated damage text doesn't hold them back.

Every draft row is listed with the parser's reason in `data/sets/reports/support_tables.md`.
Fix a pattern in `support.py` rather than hand-editing the JSON, because the next parse
overwrites hand edits. The hooks are `REWRITES`, `_GATES`, `_SOFT_GATES`, `SPECIAL_STATS`
(stats the set grammar has no rule for, e.g. potion duration and Disease/Poison resistance),
and `_CAPTURE_RE` (objective-capture windows).

## Querying

Advisors read the tables through
`.claude/skills/eso-build-advisor/scripts/query_support.py`. It hides `verified: false` rows
unless you pass `--include-drafts`:

```bash
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind passives --name "Magicka Mastery"
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind skills --buff minor_force
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind buff --name major_brutality
```

## Potions (U51)

Update 51 merged the Weapon/Spell Power traits. **Essence of Spell Power** and **Essence of
Weapon Power** no longer exist: they were replaced by **Essence of Heroism** (Major Brutality +
Major Savagery). The solaegis plans were updated to the new name.

The potion rows in `consumables.json` come from the hand-written `POTIONS` list in
`support.py`. They stay `verified: false`, with no restore amounts and no duration, until
UESP has per-potion pages or there's an in-game tooltip.

Buff sources are merged into `buffs.json` under `sources.skills`, `passives`, `consumables`,
and `cp`. `setdb parse` re-applies them from the tables on disk, so a set-database rebuild
keeps them.

## Claude drafts (fallback)

Use the prompt only for what UESP can't supply: U51 potions and `caps.json` citations.

1. Paste the system prompt into Claude. Attach `schema.json`, `buffs.json`, `caps.json`, and `champion_points.yaml`.
2. User message: `kind=caps` (or `passives`, `skills`, `consumables`, `cp_stars`, `buffs_sources`). One kind per call unless `kind=all`.
3. Save the `document` envelope over the matching `data/sets/<kind>.json`. For `caps`, keep the eight seed keys. For `buffs_sources`, merge each `add` list into `buffs.json` `items[].sources` under `skills`, `passives`, `consumables`, or `cp` — do not replace `buffs.json`.
4. Set `count` to `len(items)` if Claude drifted.
5. Validate:

```bash
task setdb:validate
```

Unknown `buff_ref` / `buffs_granted` slugs fail validation. Fix the slug or skip the row.

6. Read `_warnings`. Anything `verified: false` stays a draft until a UESP URL or in-game tooltip matches.

## Caps citations

| Key | Value | Status | Source |
|---|---:|---|---|
| `mitigation_cap` | 50% | verified | Online:Spell Resistance / Physical Resistance (33,000 → 50%) |
| `crit_damage_cap` | 125% | verified | Online:Critical Damage |
| `pve_dummy_resist` | 18,200 | verified | Online:Build Editor (default vet dungeon boss resistance) |
| `armor_glyph_small_piece_pct` | 40% | verified | Online:Glyph of Stamina |
| `two_hander_set_pieces` | 2 | verified | Online:Patch/4.0.0 |
| `crit_rating_per_pct` | 219 | **in-game check** | UESP gives 21,912 rating = 100% (219.12), but not 219 |
| `resist_per_mitigation_pct` | 660 | **in-game check** | Spell Resistance implies 660; Online:Penetration's 36.4% at 18,200 implies 500 |
| `resource_per_power` | 10.5 | **in-game check** | no UESP page states it |

**In-game checklist for Lewis** (English client, CP160):

1. **Crit rating:** add a known amount of Weapon/Spell Critical rating, e.g. a 1,314 Minor
   Savagery. The displayed crit % should rise by rating ÷ 219.
2. **Mitigation per resistance:** note "Damage reduction" (or the resistance tooltip) at two
   armor values. Check whether 1% costs 660 or 500 resistance.
3. **Resource per power:** compare a skill tooltip after +1,050 Max Magicka against +100 Spell
   Damage. The two should match if the ratio is 10.5.

Flip `verified` and set `uesp` only from a citation or a tooltip you supply. Keep the
Masisi calculator sample at −5.13% / +6.21% unless a cited cap changes.

## Spot-check (before treating numbers as truth)

In-game, English client, CP160 gold where it applies:

- **Caps:** the three unverified rows above.
- **Passives:** one race (e.g. Breton Magicka Mastery III = −7% Magicka cost) and one armor line.
- **Skills:** one morph’s Major/Minor grant vs the slotted bar (Boundless Storm → Major Resolve).
- **Consumables:** Garlic Cod / Solitude Salmon-Millet / Bewitched Sugar Skulls tooltip vs the JSON.
- **CP:** one slottable Warfare star at max vs `champion_points.yaml` name and `id`.

`docs/formulas.md` is not the source of truth. It still says crit damage is uncapped and uses `R/(R+660)` for mitigation. Prefer `caps.json` once a row is `verified: true`.

## Calculator

`.claude/skills/eso-build-advisor/scripts/value_calc.py` reads `data/sets/caps.json` at import. Missing file or missing key falls back to the previous hardcoded defaults. After changing caps, re-run a known option and confirm the % matches the last plan write-up.

```bash
python3 .claude/skills/eso-build-advisor/scripts/value_calc.py \
  --base "crit_pct=48.5,cd=88,pen=1930,power=2827,res=27399" \
  --option "no Order's 5pc: crit_rating=-943,cd=-8" \
  --option "NMG 5pc: crit_rating=-943,cd=-8 | pen=5948@1.0"
```

Pass `--caps /path/to/caps.json` to test a draft without overwriting the seed.

## Known gaps

The parse report lists every gap: 355 partial lines. As of the hardening pass (2026-10-25):

| Table | Rows | Verified |
|---|---:|---:|
| passives | 262 | 129 |
| skills | 630 | 599 |
| cp_stars | 118 | 75 |
| consumables | 22 | 17 |
| caps | 8 | 5 |

| Gap | Status |
|---|---|
| Passives | About half are drafts. Mostly proc or scaling text ("based on your total Armor", per-Crux, Vampire stages) the set grammar can't decompose, plus non-combat lines (XP, crafting research, swim speed, keep range). The non-combat ones stay drafts on purpose. |
| Continuous Attack | The capture window is typed (`proc`, `on: capture_objective`, 600 s). The row stays a draft for its "Health, Magicka, and Stamina" clause and Gallop. |
| Crafting passives | Medicinal Use is typed (`potion_duration_pct`). Most Provisioning/Enchanting passives are unmodeled drafts. |
| Arcanist skills | `resource: null`: cost uses the highest max resource. |
| U51 potions | `uesp: null`, `duration_s: null`. Names and trait mixes come from third-party U51 summaries. |
| Discipline Artisan (CP) | No UESP page, so it has no effects. |
