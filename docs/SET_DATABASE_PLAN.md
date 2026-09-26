# Set Database Plan — Source of Truth for Build Recommendations

Goal: one normalized dataset covering every wearable ESO set (plus traits, enchants,
mundus, buffs and caps). Each bonus line is decomposed into typed, numeric effects so
a solver can plug them into stat formulas and rank holistic builds. Build Coach and
the example `*_plan.md` files consume it.

## Decisions (confirmed)

| Topic | Decision |
|---|---|
| Source | Hybrid: UESP wiki (MediaWiki API) as backbone + in-game API dump for number reconciliation |
| Outputs | Canonical JSON (truth) → generated XLSX/CSV (browse) → generated Lua table (addon) |
| Proc model | Typed effects + estimated uptime (0–1), hand-overridable |
| Scope | All wearable sets, traits & enchants, mundus/CP/buff baseline and stat caps |

### Recon findings (2026-09-26)

- `esolog.uesp.net` (the structured set-summary tables) sits behind a Cloudflare
  challenge (HTTP 403 to scripts). We will **not** scrape it, and we will not try to
  bypass the challenge. If we want it, ask UESP for an export or download it manually
  in a browser into `data/sets/raw/esolog/`.
- `en.uesp.net/w/api.php` answers normally. `Category:Online-Sets` has 500+ members
  (it also contains index pages such as "Class Sets", which we filter out).
- Set pages are well-structured:
  - Bonus lines sit inside `<onlyinclude>` as `'''N items''': text`, with value ranges like `34-1487` (we take the CP160 max).
  - `{{ESO Sets With|tag|tag|...|settype=All Weights|source=Infinite Archive}}` gives
    ready-made **effect tags, weights, set type and source**, which gives a free first-pass classification.
  - Link templates (`{{ESO Weapon Damage Link}}`) name stats reliably.

## Status

| Phase | State | Notes |
|---|---|---|
| 0 — Scaffold | ✅ done | `tools/setdb/`, `data/sets/schema.json`, `taskfiles/SetDB.yaml`, `uv` group `setdb` |
| 1 — Fetch & parse | ✅ done | 713 sets (8 deprecated, 12 provisional), 76 buffs, 38 traits, 13 mundus, 38 glyphs; 0 cross-check failures |
| 2 — Normalize effects | ✅ done | 3,956 effects. Stat lines 99.7% full (target 95%); signature lines 70.4% full (target 70%). Queue in `reports/unmodeled.md` |
| 3 — In-game reconciliation | next | `/cm sets:dump` |
| 4 — Uptime & curation | pending | Start with mythics (41.5% full) and class sets (28.6%) |
| 5–6 | pending | |

### Phase 2 notes

- **Grammar:** clause-level rules in `tools/setdb/normalize.py`. Each sentence yields:
  - payloads: stat changes, buffs and debuffs, proc damage, heals, shields, restores, CC, cost and duration modifiers
  - a trigger (45 kinds, some carrying a skill or skill line)
  - conditions (thresholds, distance, stance, combat, target status, damage type, skill)
  - modifiers (duration, cooldown, chance, stacks, per-X scaling, interval, radius, target count, delay)
- **Honesty check (why "full" can be trusted):** a bonus is `full` only if every number in
  every sentence was used as a value or modifier, and no sentence has an unknown trigger, a
  free-text condition, an unrecognized "while …", a timed effect with no trigger, damage
  with no trigger, or per-X scaling left unmodeled. Anything else is `partial` or `none`,
  and the untranslated sentence is kept as an `unmodeled` effect with its raw text.
- **Precision:** three random audits of "full" signature lines found systematic errors
  (wrong scope, missing negation, double-counted buff explanations, modifiers attached to
  the wrong payload). Each was fixed and pinned in `tools/setdb/test_normalize.py` (20 cases).
  The last audit had 13 of 20 lines exactly right, 2 with minor omissions (an extra CC, an
  unquantified heal) and 5 errors, all of which are now fixed. Expect some residual error in
  the long tail. Phase 3 (in-game dump) and Phase 4 overrides are the backstop.
- **Value conventions:** `value` is the signed change at CP160, taking the upper end of
  ranges like "34-1487". Reductions are negative (`ability_cost_pct: -8`,
  `damage_taken_pct: -10`). `unit` is `flat`, `pct` or `seconds`. Named buffs are
  `buff_grant` / `debuff_apply` with `buff_ref`, and their explanatory "increasing X by N"
  clause is not counted a second time.
- **Scope vocabulary:** `self`, `group`, `ally` (a healed or shielded target),
  `target` / `enemy_aoe` (damage and CC), and `target_debuff` (stat reductions on enemies).
- **Uptime:** `1.0` / `static` only for untriggered, unconditional, untimed effects. Everything
  else is `null` until the Phase 4 heuristics.

Changes from the original design, found during Phase 0 and 1:
- **Stdlib only, apart from `jsonschema`.** The fetcher is written directly against the
  MediaWiki API with no client library.
- **Expansion strategy.** Set bonus blocks are expanded by the server in batches.
  Supporting pages only get their computed fragments expanded (mundus values, the
  Divines `#expr`) because whole-page expansion breaks the tables.
- **New set types:** `arena_weapon` (Maelstrom, Asylum, Vateshran and similar weapons,
  distinct from 5-piece arena sets) and `leveling` (Level Up Advisor sets).
- **`wiki_status` flag.** New sets, such as the four Feast of Shadows sets, can be on the
  wiki before UESP fills them in. These are flagged rather than guessed at, and the
  in-game dump (Phase 3) will fill the gaps.
- **Cross-check.** Every page UESP files under "Sets with N-Piece Bonus" must parse an
  N-piece line, and every head-and-shoulders set must be typed `monster`. This replaced the
  "±2% of the index count" check, because it catches actual parse errors rather than only
  the total.
- **Stat caps and CP stars** are hand-curated constants, so they moved from Phase 1 to
  Phase 5. `docs/formulas.md` needs a review before it's used: for example, its
  mitigation formula `Resistance / (Resistance + 660)` is not ESO's.

## Architecture

The code is Python and uses the repo's existing `pyproject.toml`/`uv`. It lives under `tools/setdb/` and is outside the addon zip.

```
tools/setdb/
  fetch.py        # MediaWiki API → data/sets/raw/wiki/<slug>.json (cached, rate-limited)
  parse.py        # wikitext → RawSet (bonus lines, tags, type, source, weights, class)
  normalize.py    # bonus text → Effect[] via rule grammar (regex + template-aware)
  reconcile.py    # merge in-game dump numbers; flag diffs
  validate.py     # schema + sanity checks (JSON Schema)
  emit.py         # JSON → XLSX/CSV, JSON → src/data/SetData.lua
  solver/         # stat model + ranking (phase 5)
data/sets/
  raw/            # cached fetches (gitignored) + in-game dumps
  overrides/*.yaml# hand-curated fixes, uptimes, notes, pros/cons — NEVER overwritten
  sets.json       # canonical output (committed)
  schema.json
  sets.xlsx       # generated
```

Taskfile entries: `task setdb:fetch`, `setdb:build` (parse→normalize→reconcile→validate→emit),
`setdb:diff` (patch-to-patch changelog), `setdb:solve`.

## Data model

### Set record
```jsonc
{
  "id": 691,                     // in-game setId (from dump; join key)
  "name": "Aerie's Cry",
  "slug": "aeries_cry",
  "uesp": "https://en.uesp.net/wiki/Online:Aerie's_Cry",
  "type": "class",               // overland|dungeon|trial|arena|monster|mythic|crafted|pvp|class|special
  "source": "Infinite Archive",
  "class": "Warden",             // class sets only
  "slots": { "weights": ["light","medium","heavy"], "weapons": "any", "jewelry": true },
  "max_pieces": 5,               // 1 mythic, 2 monster, 2/5 arena weapons, etc.
  "perfected_of": null,          // links perfected ↔ normal variants
  "craft_traits_required": null, // crafted sets
  "patch_seen": "U49",
  "tags": ["Physical/Spell Penetration", "Light Attack Bonus", ...],   // from {{ESO Sets With}}
  "bonuses": [ { "pieces": 2, "text": "...", "effects": [ ... ] }, ... ],
  "roles": ["dps"],              // derived + override
  "pros": [], "cons": [],        // override-curated, plus auto-generated from effects
  "confidence": "auto|reviewed"
}
```

### Effect (the unit the solver consumes)
```jsonc
{
  "stat": "offensive_penetration",   // from the controlled vocabulary below
  "value": 1487, "unit": "flat",     // flat|pct
  "scope": "self",                   // self|group|target_debuff|enemy_aoe
  "kind": "static",                  // static|conditional|proc|buff_grant|debuff_apply|damage|heal|shield|resource_restore
  "condition": null,                 // e.g. {"type":"health_below","pct":50} | {"type":"vs_marked_target"} | {"type":"skill_line","value":"Animal Companions"}
  "trigger": null,                   // {"on":"light_attack|crit|block|dodge|cast|dmg_taken|...","chance":0.1,"cooldown_s":3}
  "duration_s": null,
  "stacks": null,                    // {"max":10,"per_stack":...}
  "damage": null,                    // {"type":"physical","tick":856,"interval_s":3,"delay_s":3,"aoe":false}
  "buff_ref": null,                  // "major_brutality" — resolves via buffs table (no double counting)
  "uptime_est": 1.0,                 // heuristic default, override wins
  "uptime_source": "static|heuristic|override|sim",
  "raw": "Adds 34-1487 Offensive Penetration"
}
```

**Stat vocabulary** (subset): `max_health|max_magicka|max_stamina`, `health|magicka|stamina_recovery`,
`weapon_damage`, `spell_damage` (with `weapon_spell_damage` expanded to both), `weapon_crit|spell_crit` (rating),
`crit_damage_pct`, `offensive_penetration`, `physical|spell_resistance`, `crit_resistance`,
`healing_done_pct`, `healing_taken_pct`, `damage_done_pct`, `damage_taken_pct`, `dot_damage_pct`, `direct_damage_pct`,
`light_attack_damage`, `heavy_attack_damage`, `cost_reduction_pct`, `block_cost_pct`, `ult_gen`, `movement_speed_pct`,
`shield_strength_pct`, `ability_line_bonus` (with condition), `unmodeled`.

Each named buff and debuff (Major/Minor X, plus uniques such as Aggressive Horn and Pillager's Profit) is **referenced
by `buff_ref`**. It is not inlined as a stat. That way the solver knows Major Brutality from a set does nothing
when the class kit already grants it, which is the most common way naive set-rankers go wrong.

### Supporting tables (same file or siblings)
- `buffs.json`: every Major/Minor buff and debuff, with its value and whether it stacks.
- `traits.json`: every armor, weapon and jewelry trait at gold quality, including divines-per-piece and infused scaling.
- `enchants.json`: glyphs by slot type, at CP160 gold.
- `mundus.json`: each stone's base value and how divines modifies it.
- `caps.json`: target resistance (PvE 18200 dummy baseline), crit damage cap (125%), and the base crit and
  crit-rating conversion. Every constant records the patch it was verified on.
- `cp_stars.json`: slottable stars, with a stat and value where one exists. The repo already models the CP trees in
  `ChampionDiagram.lua`, so we reuse those names.

## Pipeline phases

### Phase 0 — Scaffold (½ day)
- Add `tools/setdb/`, the `data/sets/` layout, the schema, the Taskfile entries, and a gitignore for `raw/`.
- Set up a polite fetch client: a User-Agent that names the project and a contact, at most 1 request per second,
  on-disk cache keyed by `revid` so re-runs only fetch changed pages (`prop=revisions` batch check).

### Phase 1 — Fetch & parse (1–2 days)
1. Enumerate the pages in `Category:Online-Sets` (paginated with `cmcontinue`) and cross-check them against the
   index pages (`Online:Sets`, `Online:Monster Helms`, `Online:Mythic Items`, `Online:Class Sets`, ...).
   Drop anything with no `<onlyinclude>` bonus block.
2. Parse each page into the bonus lines, the `{{ESO Sets With}}` tags and `settype`/`source`, the class, the
   perfected link, and the weight/slot restrictions from "Pieces".
3. Fetch the trait, glyph, mundus, and Major/Minor buff pages into their own tables.
4. **Exit check**: the set count lands within ±2% of the UESP index page count, and every page has ≥1 bonus line.

### Phase 2 — Normalize effects (3–5 days, the core work)
- Build a rule grammar with an ordered list of `(regex, builder)` rules and run it against the bonus text after
  the templates are expanded to canonical stat names. Most of the value comes from about 40 rules:
  - Flat stat: `Adds (\d+)(?:-(\d+))? <stat>` produces a static effect with the upper value.
  - Named buff: `grants? (Major|Minor) (\w+)` produces a `buff_grant` with `buff_ref`.
  - Proc damage: `deal(?:ing)? (\d+) <type> Damage` together with the trigger, chance and cooldown clauses.
  - Conditionals: "while below X% Health", "against enemies with…", "while you have a … active".
- Lines that no rule fully consumes get `stat: unmodeled`, keep their `raw` text, and go into
  `reports/unmodeled.md`. They are the triage queue.
- **Exit check**: ≥95% of 2- to 4-piece lines and ≥70% of 5-piece or unique lines are fully modeled. The remaining
  lines are listed explicitly.

### Phase 3 — In-game reconciliation (1 day, needs you in-game)
- Add a dev-only `/cm sets:dump` subcommand that loops over the setId range with
  `GetItemSetInfo`, builds a representative item link per set, and reads
  `GetItemLinkSetBonusInfo(link, false, i)` for every bonus. It writes names, piece counts and the
  exact CP160 bonus text to SavedVariables.
- `reconcile.py` joins the two sources on normalized name, assigns `id`, and flags every number that differs
  from the wiki. The in-game value wins, and the wiki value is kept in `notes`.
- This makes the dataset patch-exact, and the wiki still supplies what the API lacks (source, notes, tags).
- `/cm sets:dump` is a subcommand and has no Window.lua impact.

### Phase 4 — Uptime & pros/cons curation (ongoing, start with the meta ~80 sets)
- Estimate heuristic uptime from the trigger: `min(1, duration / max(cooldown, 1/proc_rate))`, with
  proc_rate taken from an assumed rotation profile (≈1 LA + 1 skill per second, crit chance from the
  build).
- Keep overrides in `overrides/<slug>.yaml` for uptime, the role, pros and cons, and notes such as
  "needs a light attack weave" or "no value on a pet build". These files are never regenerated.
- Auto-generate some pros and cons from effects: "grants Major Slayer (redundant if the group already has it)",
  "conditional below 50% HP (low PvE uptime)", "proc CD 10s".

### Phase 5 — Stat model & solver (3–5 days)
- `solver/stats.py`: build a full stat sheet from base values, gear, traits, enchants, mundus, CP, buffs and
  passives. Buffs are deduplicated by `buff_ref`, and values are clamped at the caps.
- `solver/damage.py`: an expected-DPS proxy:
  `dmg ∝ (1 + max_resource/10.5·k + power) × (1 + dmg_done%) × crit_mult × pen_mult`, plus the
  proc DPS that the damage effects add. A tank score (resists, max HP, block) and a healer score
  (healing done, recovery, group buffs) are separate objectives.
- A **marginal-value** metric per set in a given build context is the number the spreadsheet surfaces:
  score(build with set) − score(build with next-best alternative).
- Search: enumerate (5+5+2 monster), (5+5+1 mythic+…), (5+4+2 +perfected-weapon), and so on, over the
  slot-legal combinations. Prune early with per-role top-N sets.
- Integration: Build Coach and the example plan docs take recommendations from here instead of hand
  reasoning. The generated `src/data/SetData.lua` carries a trimmed subset (id, name, type, roles,
  top effects) so the in-game data stays under the memory budget in `docs/MEMORY_MANAGEMENT.md`.

### Phase 6 — Maintenance
- `task setdb:diff` after each ESO update produces a changelog of changed, added and removed bonuses, and
  marks the affected sets `confidence: auto` for re-review.
- A CI job validates `sets.json` against the schema. It does no network fetches.

## Spreadsheet layout (generated)
- **Sets** sheet: one row per set. Columns: name, type, source, weights, class, roles, max pieces,
  ranked tags, pros, cons, UESP link, confidence.
- **Effects** sheet: one row per effect. Columns: set, pieces, stat, value, unit, kind, condition,
  trigger, uptime, effective value (value × uptime), buff_ref, raw. This is the sheet to filter and
  pivot, for example on "all sources of Minor Force".
- **Traits / Enchants / Mundus / Buffs / Caps** sheets.
- **Unmodeled** sheet: the curation queue.

## Risks
- **Wiki text drift or inconsistency**: Phase 3 reconciliation covers this, and the in-game numbers are
  treated as truth.
- **Bonuses too complex to model** (pets, conditional mechanics): keep `unmodeled` honest and rank them by
  curated override, not by fake numbers.
- **Double counting of buffs**: handled by the `buff_ref` indirection plus dedup in the solver.
- **UESP load and ToS**: the wiki API is permitted for this. We cache by revid and make about 600 requests
  once, then only deltas. esolog stays off-limits unless UESP gives an export.

## Open items to confirm later
- The rotation or assumed proc-rate profile per role for the uptime heuristics.
- Whether PvP sets get a separate objective (Battle Spirit adjusted) in the solver.
