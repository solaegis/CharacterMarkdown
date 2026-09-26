"""Stage 1: download set + supporting pages from the UESP wiki into data/sets/raw/.

Incremental: a page is re-fetched only when its latest revid differs from the
cached one, so routine re-runs cost a handful of `prop=info` requests.

Each cached page is JSON: {title, pageid, revid, timestamp, wikitext, ...} plus
`expanded` (set pages: the template-expanded <onlyinclude> bonus block) or
`fragments` (support pages: {raw template: expanded value} for computed values).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

from .paths import SET_PAGES, SUPPORT_PAGES, WIKI_CACHE, slugify
from .wiki import WikiClient
from .wikitext import extract_onlyinclude, iter_templates, link_targets

SET_CATEGORY = "Category:Online-Sets"
ONLINE_NS = 144

# Categories used only for cross-checking the parse (piece-count coverage)
CHECK_CATEGORIES = [
    "Category:Online-Sets with 1-Piece Bonus",
    "Category:Online-Sets with 2-Piece Bonus",
    "Category:Online-Sets with 3-Piece Bonus",
    "Category:Online-Sets with 5-Piece Bonus",
    "Category:Online-Sets with 10-Piece Bonus",
    "Category:Online-Sets with 12-Piece Bonus",
    "Category:Online-Sets with Head and Shoulders",
]

SUPPORT_TITLES = [
    "Online:Buffs",
    "Online:Traits",
    "Online:Mundus Stones",
    "Online:Glyphs",
]

# Marker between concatenated blocks in one expandtemplates call. Must survive
# expansion untouched and never occur in wiki content.
_SPLIT = "\n@@SETDB-SPLIT-{}@@\n"
_SPLIT_RE = re.compile(r"\n?@@SETDB-SPLIT-(\d+)@@\n?")
EXPAND_MAX_CHARS = 60_000
EXPAND_MAX_PAGES = 50
COMPUTED_TEMPLATES = {"ESO MundusStoneValue", "ESO DivinesGearValue"}


def _load(path: Path) -> dict[str, Any] | None:
    try:
        return json.loads(path.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def _save(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(record, ensure_ascii=False, indent=1) + "\n")


def sync_pages(
    client: WikiClient, titles: list[str], dest: Path, block: str
) -> tuple[list[dict[str, Any]], int]:
    """Bring `dest` in line with the wiki for `titles`. Returns (records, n_fetched).

    block="onlyinclude": expand the bonus block into `expanded` (set pages).
    block="fragments": expand only computed fragments ({{#expr}}, value templates)
    into `fragments` {raw: expanded}; the parser splices them back into the raw
    wikitext. Expanding whole support pages mangles their tables.
    """
    key = "expanded" if block == "onlyinclude" else "fragments"
    latest = client.latest_revids(titles)
    records: dict[str, dict[str, Any]] = {}
    stale: list[str] = []
    for title, revid in latest.items():
        cached = _load(dest / f"{slugify(title)}.json")
        if cached and cached.get("revid") == revid and key in cached:
            records[title] = cached
        else:
            stale.append(title)

    fetched = client.page_contents(stale) if stale else []
    units: list[tuple[dict[str, Any], str]] = []
    for rec in fetched:
        if block == "onlyinclude":
            src = extract_onlyinclude(rec["wikitext"])
            rec["expanded"] = ""
            if src:
                units.append((rec, src))
        else:
            rec["fragments"] = {}
            units += [(rec, frag) for frag in computed_fragments(rec["wikitext"])]
    for (rec, src), out in zip(units, _expand_batched(client, [u[1] for u in units]), strict=True):
        if block == "onlyinclude":
            rec["expanded"] = out
        else:
            rec["fragments"][src] = out
    for rec in fetched:
        _save(dest / f"{slugify(rec['title'])}.json", rec)
        records[rec["title"]] = rec

    # Drop cache files for pages that left the category / were deleted
    keep = {f"{slugify(t)}.json" for t in latest}
    for f in dest.glob("*.json"):
        if f.name not in keep:
            f.unlink()
    return [records[t] for t in sorted(records)], len(fetched)


def computed_fragments(wikitext: str) -> list[str]:
    """Outermost templates whose value is computed server-side."""
    out: list[str] = []
    for tpl in iter_templates(wikitext):
        if tpl.name.startswith("#expr") or tpl.name in COMPUTED_TEMPLATES:
            frag = wikitext[tpl.start : tpl.end]
            if not any(frag in o for o in out):
                out.append(frag)
    return out


def _expand_batched(client: WikiClient, sources: list[str]) -> list[str]:
    results: list[str] = [""] * len(sources)
    batch: list[int] = []
    size = 0

    def flush() -> None:
        nonlocal batch, size
        if not batch:
            return
        text = "".join(_SPLIT.format(i) + sources[i] for i in batch)
        pieces = _SPLIT_RE.split(client.expand_templates(text))
        # split() -> ['', idx, body, idx, body, ...]
        bodies = {int(pieces[i]): pieces[i + 1] for i in range(1, len(pieces) - 1, 2)}
        for i in batch:
            if i not in bodies:
                raise RuntimeError(f"expansion lost block {i}: {sources[i][:80]!r}")
            results[i] = bodies[i].strip()
        batch, size = [], 0

    for i, src in enumerate(sources):
        if batch and (size + len(src) > EXPAND_MAX_CHARS or len(batch) >= EXPAND_MAX_PAGES):
            flush()
        batch.append(i)
        size += len(src)
    flush()
    return results


def glyph_titles(glyphs_page: dict[str, Any]) -> list[str]:
    return sorted(
        {t for t in link_targets(glyphs_page["wikitext"]) if t.startswith("Online:Glyph of ")}
    )


def run() -> int:
    client = WikiClient()
    print("• enumerating", SET_CATEGORY, file=sys.stderr)
    titles = client.category_members(SET_CATEGORY, namespace=ONLINE_NS)
    print(f"  {len(titles)} pages", file=sys.stderr)

    sets, n_sets = sync_pages(client, titles, SET_PAGES, block="onlyinclude")
    print(f"  sets: {len(sets)} cached, {n_sets} (re)fetched", file=sys.stderr)

    support, n_sup = sync_pages(client, SUPPORT_TITLES, SUPPORT_PAGES, block="fragments")
    glyphs_page = next(r for r in support if r["title"] == "Online:Glyphs")
    glyphs = glyph_titles(glyphs_page)
    _, n_gly = sync_pages(client, glyphs, SUPPORT_PAGES / "glyphs", block="fragments")
    print(
        f"  support: {len(support)} pages + {len(glyphs)} glyphs, {n_sup + n_gly} (re)fetched",
        file=sys.stderr,
    )

    checks = {c: sorted(client.category_members(c, namespace=ONLINE_NS)) for c in CHECK_CATEGORIES}
    _save(WIKI_CACHE / "categories.json", {"set_category": titles, "checks": checks})

    print(f"✓ fetch done ({client.request_count} API requests)", file=sys.stderr)
    return 0
