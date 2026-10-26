# tools/setdb — ESO set database pipeline

Builds `data/sets/*.json` (the source of truth for set recommendations) from the
UESP wiki. Design and roadmap: [docs/SET_DATABASE_PLAN.md](../../docs/SET_DATABASE_PLAN.md).

This lives outside `src/`, so it is never shipped in the addon zip.

```bash
task setdb:refresh    # fetch (network, incremental) + parse + validate
task setdb:build      # parse + normalize + validate from the local cache only
task setdb:import     # in-game dump: /cm sets:dump, /reloadui, then this
task setdb:test       # normalizer, reconciler, digest, patch and support-table tests
```

| Stage | Module | Input → output |
|---|---|---|
| fetch | `fetch.py`, `wiki.py` | `en.uesp.net/w/api.php` → `data/sets/raw/wiki/` (gitignored cache, keyed by revid) |
| parse | `parse.py`, `wikitext.py` | cache → `data/sets/{sets,buffs,traits,mundus,enchants}.json` + `reports/parse_report.md` |
| normalize | `normalize.py` | bonus text → typed `effects[]` + `coverage`; queue in `reports/unmodeled.md` |
| reconcile | `reconcile.py` | SavedVariables `/cm sets:dump` → set IDs, game-verified text (`reports/reconcile.md`) |
| patches | `patches.py` | game-patch overlays for changes UESP hasn't caught up with; listed in each file's `source.patches` |
| support | `support.py` | skill-line, skill, CP-star and food pages → `data/sets/{passives,skills,consumables,cp_stars}.json`, buff `sources` merged into `buffs.json`, `reports/support_tables.md` |
| validate | `validate.py` | JSON → `schema.json` + cross-file checks (also optional `caps.json`, `passives.json`, `skills.json`, `consumables.json`, `cp_stars.json` when present) |

Support tables have their own fetch/parse pair, separate from the set pipeline:

```bash
task setdb:support-fetch   # network, incremental (~600 pages first run)
task setdb:support-parse   # offline: parse + merge buff sources + validate
```

`caps.json` stays hand-maintained, and so do the U51 potion rows: UESP has no per-potion
pages for the merged traits yet. The Claude prompt in
`docs/prompts/support_tables_system_prompt.md` covers those gaps. See
`docs/SET_SUPPORT_TABLES.md`.

## Patch overlays

When a game update lands before UESP's pages do, `patches.py` rewrites the parsed records
after normalization. Each patch only touches records that still carry the pre-patch wiki
text, so it becomes a no-op once the wiki is updated (then delete it). A build prints
`patched <file>.json: <id>` for every patch that changed something.

- **`u51`** (Update 51, 2026-09-28):
  - Sorcery folds into Brutality (Weapon and Spell Damage) and Prophecy into Savagery (Weapon and Spell Critical).
  - Set grants are remapped, and a grant that duplicates an identical one is dropped. The raw `text`/`tx` still reads "Brutality and Sorcery".
  - The Warrior is hybrid. The Apprentice gives Experience and Inspiration only, so its `value` is `null`.
  - Illuminate and Exploitation are not merged: those passives got new buffs.

## Fetch behaviour

- Only `en.uesp.net`'s MediaWiki API is used. `esolog.uesp.net` sits behind a Cloudflare
  challenge, and we don't scrape it.
- The client identifies itself in the User-Agent, sends at most 1 request per second, and
  retries with backoff (UESP sometimes drops a connection partway through a response).
- A cold fetch takes about 75 requests (~90 s). A warm run only checks revids (~40 requests)
  and re-downloads just the pages that changed.
- For set pages, the `<onlyinclude>` bonus block is expanded by the server, 50 pages per call.
  For supporting pages, only computed fragments (`{{#expr}}`, `{{ESO MundusStoneValue}}`,
  and similar) are expanded, then spliced back into the raw wikitext. Expanding a whole
  page mangles its tables.

## Output guarantees

- The output is deterministic: the same cache gives byte-identical JSON, so diffs across
  patches only show real changes.
- Every bonus has `effects[]` and `coverage` (`full` / `partial` / `none`). `full` means it
  passed every honesty check; spot audits still find occasional long-tail errors (see the
  plan). `partial` is a lower bound; `none` means only the raw text is available. Changing
  the grammar? Add the case to `test_normalize.py` first.
- Pages that UESP hasn't finished are marked `wiki_status: ["incomplete" | "pre_release"]`.
  Sets removed from the game are marked `deprecated: true`. Filter both out before
  recommending anything.
