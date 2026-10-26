# Support tables — ingest and spot-check

Marginal-value build math uses the existing set database plus these files:

| File | Role |
|---|---|
| `data/sets/caps.json` | Combat constants. Hand-maintained seed; `value_calc.py` loads it. |
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
Alliance War skill line on UESP, plus each CP star from `champion_points.yaml` and the
foods in its `CONSUMABLES` list.

- Effects go through the set-bonus normalizer (`normalize.py`), so they use the same `$defs/effect` contract.
- Ranged rank values (`[27 / 28 / 29 / 30]`) take rank IV.
- Linear CP stars are multiplied out to their max-rank value.
- Pre-U51 Sorcery/Prophecy text maps to Brutality/Savagery.

A row is `verified: true` only when its numbers came from the cited page and the text
normalized fully. Skills count only the sentences that produced a kept stat grant, so
unrelated damage text doesn't hold them back.

Every draft row is listed with the parser's reason in `data/sets/reports/support_tables.md`.
Fix a pattern in `support.py` (`REWRITES`, `_GATES`, `_SOFT_GATES`) rather than hand-editing
the JSON, because the next parse overwrites hand edits.

Buff sources are merged into `buffs.json` under `sources.skills`, `passives`, `consumables`,
and `cp`. `setdb parse` re-applies them from the tables on disk, so a set-database rebuild
keeps them.

## Claude drafts (fallback)

Use the prompt for what UESP can't supply: `caps.json` citations, U51 potions, or a
`buffs_sources` delta for a skill UESP hasn't documented yet.

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

## Spot-check (before treating numbers as truth)

In-game, English client, CP160 gold where it applies:

- **Caps:** dummy resist 18,200; crit rating → %; a 2H/bow/staff is 2 set pieces; small-piece stamina glyph is 40% of the full glyph.
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

The parse report lists every gap. As of the first fetch (2026-10-25):

| Gap | Status |
|---|---|
| Passives | ~half `verified: false`. Mostly proc or scaling text ("based on your total Armor", per-Crux) that the set grammar can't decompose. |
| Arcanist skills | `resource: null`: cost uses the highest max resource. |
| U51 potions | `uesp: null`, `duration_s: null`. Names and trait mixes come from third-party U51 summaries. |
| Discipline Artisan (CP) | No UESP page, so it has no effects. |
