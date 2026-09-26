---
name: eso-build-advisor
description: Review, create or fix Elder Scrolls Online character build plans using the repo's verified set database. Use when asked whether a build/plan is good, what sets/traits/enchants/mundus/CP a character should run, to compare sets ("X vs Y"), or to write/update an examples/**/<char>_plan.md from a character profile (<char>.md) or a /cm coach export. Grounds every recommendation in data/sets (llm_digest.jsonl, buffs/traits/mundus/enchants JSON) and computes marginal value with a calculator instead of guessing.
---

# ESO Build Advisor

Recommend gear and build changes for one character, backed by the set database and
calculated, not remembered. The rules of the game, the digest format and the output shape
are in the system prompt: **read `docs/prompts/build_advisor_system_prompt.md` first**
(the "Reading the digest", "Game rules" and "Method" sections). This skill adds the tools and
the repo workflow around it.

## Inputs

- **Character:** `examples/<account>/<na|eu>/<slug>.md` (full profile: stats, Equipment Details,
  bars, CP) or a `/cm coach` export. Live stats come from **Character Stats** / **Advanced Stats**.
- **Existing plan (if any):** `examples/<account>/<na|eu>/<slug>_plan.md`. Layout rules:
  `docs/plan_structure.md` (canonical layout, section order).
- **Data:** `data/sets/llm_digest.jsonl` (+ `buffs.json`, `traits.json`, `mundus.json`,
  `enchants.json`). If `data/sets/sets.json` is newer than the digest, run `task setdb:build`.

## Tools (run from the repo root)

**Find sets**, not by loading the 113k-token digest:

```bash
python3 .claude/skills/eso-build-advisor/scripts/query_sets.py --name "night mother" --name "order's wrath"
python3 .claude/skills/eso-build-advisor/scripts/query_sets.py --craftable --stat offensive_penetration --pieces 2 --brief
python3 .claude/skills/eso-build-advisor/scripts/query_sets.py --type monster --stat weapon_damage --weight M
python3 .claude/skills/eso-build-advisor/scripts/query_sets.py --craftable --text "Major Breach"
```

**Value a change** against the character's live stats. Always-on deltas go before `|`;
proc/debuff deltas go after it, at an uptime (`@0-1`):

```bash
python3 .claude/skills/eso-build-advisor/scripts/value_calc.py \
  --base "crit_pct=48.5,cd=88,pen=1930,power=2827,res=27399" \
  --option "drop Order's 5pc: crit_rating=-943,cd=-8" \
  --option "NMG 5pc: crit_rating=-943,cd=-8 | pen=5948@0.9" \
  --option "Bloodthirsty neck (half): power=175" --option "Robust neck: res=877"
```

- `power` = the higher of Weapon/Spell Damage; `res` = the matching max resource;
  `crit_pct` = the displayed crit % (it already includes rating); `cd` = Critical Damage %;
  `pen` = penetration; `dmg` = % damage done.
- Before crediting a buff, de-duplicate it: if the character already has Major/Minor X from
  skills, CP, passives or potions, a set granting X adds 0. Check `buffs.json` sources and the
  profile's Active Buffs.
- Report the % from the calculator and the key inputs. Try uptime 0.8 as well as 1.0 for
  procs, and say whether the conclusion survives.

## Workflow

1. **Read** the profile (stats, Equipment Details with set/trait/enchant per slot, bars, CP,
   Active Buffs, mundus) and the plan if one exists. Note the player's constraints (e.g.
   "craftable only", "solo farmer", roleplay identity). They override raw DPS.
2. **Audit the numbers in the plan** against the data. Every set bonus, trait value, glyph
   value and mundus value the plan quotes must match `query_sets.py` / the JSON tables.
3. **Diagnose:** which bonuses are live on each bar, buffs duplicated, stats over caps (crit
   damage 125%, pen vs 18,200) or badly under-invested (e.g. pen far below 18,200).
4. **Shortlist and value:** query candidates that respect the constraints and slot legality;
   run `value_calc.py` for each swap versus the current piece.
5. **Write:** edit the plan in place (or create it per `docs/plan_structure.md`). Keep the
   player's roleplay, collectibles and companion sections. Put the math inline where a
   decision is made, and update the checklist order (don't glyph pieces that are about to be
   replaced). Update the `docs/plan_structure.md` inventory row if the plan's sets change.
6. **Verify:** re-grep the plan for stale statements from the old recommendation (old set names,
   old counts), and run `python3 scripts/trim.py --dry-run <plan>`.

## Pitfalls (each of these was once wrong in a real plan)

- **Two-handed weapons (bow, staff, 2H) count as 2 set pieces.** Jewelry 3 + bow = 5 on the
  back bar. Only active-bar weapons count; armor and jewelry count on both bars.
- **Armor glyph values:** full on head/chest/legs; **40%** on shoulders/hands/waist/feet
  (Stamina glyph: 868 vs 347).
- **Set pieces are slot-specific:** a set's legs can't be "moved" to shoulders. Another piece
  must be obtained (drop, craft or set-collection reconstruct).
- **Identical lower bonuses:** many crafted sets share 2/3/4pc bonuses (e.g. Order's Wrath and
  Night Mother's Gaze), so a swap may only change the 5pc. Compare only what changes.
- **"Up to" bonuses scale** (Bloodthirsty: up to +350 WD vs enemies under 90% Health). Value
  them at roughly half, not full.
- **Group context:** debuffs like Major Breach are worth 0 when a group member already applies
  them. State the solo/group assumption.
- **Max resource isn't sustain.** Recovery is. Don't justify Max Stamina with "stamina pool".
- **Signature-line text (`tx`) wins over parsed effects:** drawbacks with no number
  (Oakensoul's bar-swap lock, ability-cost increases) only show up in the text.
- **"Craftable" means `type: crafted`** (it has crafting sites). Overland/dungeon/trial drops
  aren't craftable, even if a plan calls them that.
- **Numbers are CP160 gold.** The in-game tooltip on lower-quality gear shows less, so don't
  "correct" the data from a purple item's tooltip.

## Reporting back

Give the verdict first (agree / agree with fixes / disagree), then factual errors (with the data
that disproves them), then judgment calls (with calculator %), then what you changed. Keep
constants honest: the caps and conversions are general ESO knowledge, not yet part of the
verified dataset (Phase 5 `caps.json`), so flag them as re-check-after-patch.
