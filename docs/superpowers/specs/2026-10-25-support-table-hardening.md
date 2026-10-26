# Spec: Support-table hardening

**Date:** 2026-10-25
**Status:** Ready to implement
**Repo:** CharacterMarkdown only
**Handoff:** Implement this file. Do not regenerate the set database.

## Problem

`3489708` shipped UESP-backed `passives.json`, `skills.json`, `consumables.json`, `cp_stars.json`, a `caps.json` seed, and `tools/setdb/support.py`. Validate and unit tests pass. The advisor still cannot treat the pack as truth:

- Psijic Order and Alchemy were never fetched (no Accelerate / Race Against Time / Medicinal Use).
- Companion class lines landed in `skills.json` (Ardent Warrior, Beasts of the Hunt, …). The `(Companion)` title skip is not enough.
- All eight `caps.json` rows are `verified: false` with `uesp: null`.
- High-value CP/passive parses are draft because of grammar (Thaumaturge duplicates `damage_done_pct` with `condition: "effects"`).
- There is no `query_sets`-style helper for the new tables. The advisor skill does not look them up.

## Goal

An advisor run can look up Breton Magicka Mastery, Boundless Storm, Unnerving Boneyard, Race Against Time / Accelerate, Medicinal Use, Garlic Cod, Fighting Finesse, and Light Armor Concentration via a query tool, and will refuse to treat `verified: false` as a fact.

## Non-goals

- Full combat simulation or skill damage coefficients.
- Verifying every partial row in `data/sets/reports/support_tables.md` (314+ drafts).
- Rewriting solaegis `*_plan.md` files, except Spell Power → Essence of Heroism if a plan still names the old potion.
- Regenerating `sets.json`, `traits.json`, `enchants.json`, or `mundus.json`.
- Inventing numbers or marking `verified: true` from memory.

## Hard rules

- Work only in this repo. Fix `tools/setdb/support.py` (categories, denylist, REWRITES, `_GATES`, `_SOFT_GATES`) and re-parse.
- Do **not** hand-edit generated JSON except `data/sets/caps.json` citations and the existing U51 `POTIONS` list in `support.py`.
- `verified: true` only when the number came from the cited UESP page (or an in-game tooltip Lewis supplied) **and** the text normalized fully.
- After category changes: `task setdb:support-fetch` then `task setdb:support-parse`. Do not guess UESP category titles; query the API.

## Current baseline (2026-10-25)

| File | Rows | Verified |
|---|---:|---:|
| passives | 239 | 116 |
| skills | 680 | 590 |
| cp_stars | 118 | 74 (ids match `champion_points.yaml`) |
| consumables | 22 | 17 |
| caps | 8 | 0 |

Known-good already (keep these):

- Breton Magicka Mastery III: `ability_cost_pct -7` on Magicka, `verified: true`.
- Boundless Storm: `major_resolve` + `major_expedition`.
- Unnerving Boneyard: `major_breach` + `minor_vulnerability`.
- Inner Light: `major_savagery` + 5% Max Magicka.
- Foods in `docs/plan_structure.md` (Garlic Cod 5395/4936, Solitude Salmon 5395/4936, Pickled 5414/4938, Bewitched 4620/4250/4250/462).
- Light Armor Concentration rank 2: 939 pen, `stacks.per` = piece of Light Armor worn.
- Fighting Finesse max: `crit_damage_pct` 8.
- `value_calc.py` Masisi sample: **−5.13%** / **+6.21%**. Must not change unless a verified cap change is documented.

## Implementation

### 1. Coverage

`LINE_CATEGORIES` in `tools/setdb/support.py` walks Race / Class / Weapon / Armor / World / Alliance War / Guild (namespace 144). That missed Psijic Order and Alchemy.

- Query the UESP API for the real category or page titles of `Online:Psijic Order` and `Online:Alchemy`. Add those. Provisioning / Enchanting only if they share the category and parse cheaply.
- Keep the `(Companion)` title skip. Add a denylist of companion class line names already in `skills.json` (Ardent Warrior, Beasts of the Hunt, Blazing Might, Brilliant Shield, Deadly Assassin, Empathic Fighter, Guardian's Commitment, Healing Grace, Lightning Caller, Living Shade, Mischievous Caster, Playful Schemer, Quill Knight, Remedy of Atonement, Revitalizing Researcher, Scholar of Apocrypha, Soul Thief, Verdant Growth, Warrior's Banishment, Winter's Bite). Also skip `Category:Online-Skill Lines-Companion` if it exists.
- After parse, these must exist: Race Against Time, Accelerate, Channeled Acceleration (or current morph names), Undo, Medicinal Use, plus the known-good rows above.
- Tests in `tools/setdb/test_support.py`: Accelerate → Minor Force; Medicinal Use duration ranks.

### 2. Companion noise

`skills.json` must contain **zero** of those companion lines. Do not add an `actor` field unless a leftover cannot be excluded at fetch. If you add it, extend `data/sets/schema.json` and default advisor queries to player-only.

### 3. Caps

`data/sets/caps.json` keys: `crit_rating_per_pct` (219), `resist_per_mitigation_pct` (660), `mitigation_cap` (50 pct), `crit_damage_cap` (125), `resource_per_power` (10.5), `pve_dummy_resist` (18200), `armor_glyph_small_piece_pct` (40), `two_hander_set_pieces` (2).

- For each key, find a real `https://en.uesp.net/wiki/Online:…` page that **states that number**. If it does, set `uesp` and `verified: true`. If it does not, keep `verified: false` and record the page you checked in `notes`.
- Update `docs/SET_SUPPORT_TABLES.md` so remaining false caps are an explicit in-game checklist for Lewis.

`value_calc.py` already loads this file. Do not change the formula unless a cited cap changes.

### 4. High-value grammar only

Do not clear the whole draft report. Add REWRITES / gates / CP text fixes so these become `verified: true` with **one** correct effect (no duplicate stats, no `condition: {type: text}`):

- **Thaumaturge:** `dot_damage_pct` 6 at max only (today also emits `damage_done_pct`).
- **Deadly Aim / Biting Aura / Weapons Expert / Backstabber:** typed condition (single-target / AoE / LA-HA / flanking), not free text.
- **Timed Major/Minor grants** with an activation gate (Spear Wall, Hemorrhage, Hasty Retreat): attach the gate as `trigger` or `condition`.
- **Argonian Resistance:** consume Max Health and Disease/Poison resist, or explicitly unmodel resist (no leftover digit).
- **Continuous Attack:** keep capture-window WD/SD; do not leave `static` 10% WD that looks always-on. Resource / Gallop may stay unmodeled.
- **Armor per-piece:** test that Concentration rank 2 is 939 with `per: piece of Light Armor worn`.

Leave XP, swim speed, keep-range, and other non-combat drafts as `verified: false`.

### 5. U51 potions

Keep the hand-drafted `POTIONS` list in `support.py`. Do not invent restore amounts.

- Document that Essence of Spell Power and Essence of Weapon Power were replaced by **Essence of Heroism** (Major Brutality + Major Savagery). Advisor and new plan text must not recommend Spell Power as a live potion.
- Potion `verified` stays false until a UESP page or in-game tooltip exists.

### 6. Query tool

Add `.claude/skills/eso-build-advisor/scripts/query_support.py` modeled on `query_sets.py`:

- `--kind passives|skills|consumables|cp|buff` (`buff` reads `buffs.json` sources)
- `--name` substring, `--line`, `--stat`, `--buff`
- Default: hide `verified: false` unless `--include-drafts`
- One compact line: name, line, verified, buffs, effects (`stat=value` + stacks)

Wire it in `.claude/skills/eso-build-advisor/SKILL.md` and `docs/prompts/build_advisor_system_prompt.md`:

- Before crediting a set’s Major/Minor X, query `--kind buff` and the live bar / passives / food / CP.
- Quote only `verified: true` numbers. If a needed row is draft, quote `raw` and say so.
- Food picks query `consumables` by name; do not recall Garlic Cod / Bewitched from memory.

### 7. Refresh and verify

```bash
task setdb:support-fetch
task setdb:support-parse
task setdb:test
task setdb:validate
python3 .claude/skills/eso-build-advisor/scripts/value_calc.py \
  --base "crit_pct=48.5,cd=88,pen=1930,power=2827,res=27399" \
  --option "no Order's 5pc: crit_rating=-943,cd=-8" \
  --option "NMG 5pc: crit_rating=-943,cd=-8 | pen=5948@1.0"
```

Masisi sample must stay **−5.13% / +6.21%** unless a verified cap change is documented.

Acceptance (default query, no `--include-drafts`, all `verified: true` unless noted):

```bash
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind passives --name "Magicka Mastery"
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind passives --name Concentration
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind passives --name "Medicinal Use"
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind skills --name "Boundless Storm"
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind skills --name "Unnerving Boneyard"
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind skills --name Accelerate
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind consumables --name "Garlic Cod"
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind cp --name "Fighting Finesse"
python3 .claude/skills/eso-build-advisor/scripts/query_support.py --kind skills --line "Ardent Warrior"
```

Expect: Magicka Mastery −7%; Concentration 939 per light piece; Medicinal Use exists; Boundless Storm `major_resolve`; Unnerving Boneyard `major_breach`; Accelerate `minor_force`; Garlic Cod 5395/4936; Fighting Finesse `crit_damage_pct` 8; Ardent Warrior no rows. Thaumaturge / Medicinal Use / Accelerate must not need `--include-drafts`.

Update `docs/SET_SUPPORT_TABLES.md` Known gaps from the new parse report. Leave `docs/prompts/support_tables_system_prompt.md` as a fallback for potions/caps only.

## Suggested order

1. Tests for Accelerate, Medicinal Use, Concentration stacks, Thaumaturge (red).
2. Categories + companion denylist; fetch + parse.
3. Grammar rewrites; parse again.
4. Caps citations.
5. `query_support.py` + skill/prompt wiring.
6. Acceptance commands + docs.

## Related

- Pipeline: `docs/SET_SUPPORT_TABLES.md`, `tools/setdb/README.md`
- Draft queue: `data/sets/reports/support_tables.md`
- Cursor plan (same content): `.cursor/plans` / Support table hardening
