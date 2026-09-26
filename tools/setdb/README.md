# tools/setdb — ESO set database pipeline

Builds `data/sets/*.json` (the source of truth for set recommendations) from the
UESP wiki. Design and roadmap: [docs/SET_DATABASE_PLAN.md](../../docs/SET_DATABASE_PLAN.md).

This lives outside `src/`, so it is never shipped in the addon zip.

```bash
task setdb:refresh    # fetch (network, incremental) + parse + validate
task setdb:build      # parse + normalize + validate from the local cache only
task setdb:import     # in-game dump: /cm sets:dump, /reloadui, then this
task setdb:test       # normalizer + reconciler tests
```

| Stage | Module | Input → output |
|---|---|---|
| fetch | `fetch.py`, `wiki.py` | `en.uesp.net/w/api.php` → `data/sets/raw/wiki/` (gitignored cache, keyed by revid) |
| parse | `parse.py`, `wikitext.py` | cache → `data/sets/{sets,buffs,traits,mundus,enchants}.json` + `reports/parse_report.md` |
| normalize | `normalize.py` | bonus text → typed `effects[]` + `coverage`; queue in `reports/unmodeled.md` |
| reconcile | `reconcile.py` | SavedVariables `/cm sets:dump` → set IDs, game-verified text (`reports/reconcile.md`) |
| validate | `validate.py` | JSON → `schema.json` + cross-file checks |

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
