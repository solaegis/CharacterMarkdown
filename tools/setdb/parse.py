"""Stage 2: cached wiki pages -> data/sets/{sets,buffs,traits,mundus,enchants}.json.

Offline and deterministic: the same cache always produces byte-identical output,
so the committed JSON diffs cleanly across ESO patches.

Phase 1 scope: structure only. Each bonus line keeps its plain text, its
expanded wikitext and its link targets; `effects` stays empty until the
Phase 2 normaliser fills it.
"""

from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any
from urllib.parse import quote, unquote

from .normalize import normalize_sets
from .paths import DATA_DIR, REPORTS_DIR, SET_PAGES, SUPPORT_PAGES, WIKI_CACHE, slugify
from .reconcile import load_dump, reconcile
from .wikitext import (
    find_templates,
    link_targets,
    parse_tables,
    splice_fragments,
    split_top_level,
    to_plain,
)

UESP_BASE = "https://en.uesp.net/wiki/"
SCHEMA_VERSION = 1

# --- sets ------------------------------------------------------------------------

_BONUS_LABEL_RE = re.compile(r"^'''\s*(\d+)\s+(perfected\s+)?items?\s*'''\s*:\s*(.*)$", re.I)
_CLASS_LABEL_RE = re.compile(r"^'''\s*Class\s*'''\s*:\s*(.*)$", re.I)
_COMMENT_RE = re.compile(r"<!--.*?-->", re.S)

ARENA_WEAPON_LINKS = re.compile(
    r"^Online:(?:Perfected )?(?:Maelstrom|Asylum|Blackrose|Vateshran|Master's|Dragonstar Arena)"
    r" Weapons$|^Online:Weapon Sets$"
)
WEIGHT_TAGS = {"Light Armor": "light", "Medium Armor": "medium", "Heavy Armor": "heavy"}
WEAPON_TAGS = {
    "Any Weapon": "any",
    "One Handed Weapon": "one_handed",
    "Two Handed Weapon": "two_handed",
    "Bow": "bow",
    "Destruction Staff": "destruction_staff",
    "Restoration Staff": "restoration_staff",
    "Shield": "shield",
}
PVP_SOURCES = re.compile(r"Cyrodiil|Imperial City|Battleground|Trophy Vault|Alliance Point", re.I)
EXCLUDE_TITLE_RE = re.compile(r"^Online:Template ")


def _intro(wikitext: str) -> str:
    """Lead section: everything before the first heading."""
    m = re.search(r"^==", wikitext, re.M)
    return wikitext[: m.start()] if m else wikitext


def _sets_with(wikitext: str) -> tuple[list[str], dict[str, str]]:
    """Tags and named params of {{ESO Sets With}} (comments stripped first)."""
    tpls = find_templates(_COMMENT_RE.sub("", wikitext), "ESO Sets With")
    if not tpls:
        return [], {}
    tpl = tpls[0]
    tags = [t for t in tpl.positional() if t]
    named: dict[str, str] = {}
    for key, val in tpl.named().items():
        alliances = find_templates(val, "ESO Alliances")
        if alliances:
            val = "; ".join(to_plain(v) for v in alliances[0].named().values() if v)
        named[key] = to_plain(val, br="; ")
    return tags, named


def _mod_header(wikitext: str) -> list[str]:
    tpls = find_templates(wikitext, "Mod Header")
    return [p for p in tpls[0].positional() if p] if tpls else []


def _classify(
    intro_links: set[str], tags: list[str], named: dict[str, str], has_class: bool
) -> str:
    source = named.get("source", "")
    dlc = named.get("dlc", "")
    if "Online:Mythic Items" in intro_links or re.search(r"\bAntiquities\b", source):
        return "mythic"
    if "Online:Monster Helm Sets" in intro_links or "Head and Shoulders" in tags:
        return "monster"
    if has_class or "Online:Class Sets" in intro_links:
        return "class"
    if any(ARENA_WEAPON_LINKS.match(t) for t in intro_links):
        return "arena_weapon"
    if "Online:Arena Sets" in intro_links:
        return "arena"
    if "Online:Trial Sets" in intro_links:
        return "trial"
    if "Online:Dungeon Sets" in intro_links:
        return "dungeon"
    if (
        "Online:PVP Sets" in intro_links
        or PVP_SOURCES.search(source)
        or dlc == "Imperial City"
        or "Alliance Point Cost" in tags
        or "Tel Var Cost" in tags
    ):
        return "pvp"
    if "Crafting Site(s)" in tags:
        return "crafted"
    if "Online:Level Up Advisor" in intro_links:
        return "leveling"
    if "Online:Overland Sets" in intro_links:
        return "overland"
    return "special"


def _parse_bonuses(expanded: str) -> tuple[list[dict[str, Any]], str | None, list[str]]:
    bonuses: list[dict[str, Any]] = []
    set_class: str | None = None
    stray: list[str] = []
    for line in re.split(r"<br\s*/?>\s*\n?|\n", expanded):
        line = line.strip()
        if not line:
            continue
        m = _BONUS_LABEL_RE.match(line)
        if m:
            bonuses.append(
                {
                    "pieces": int(m.group(1)),
                    "perfected": bool(m.group(2)),
                    "text": to_plain(m.group(3)),
                    "wikitext": m.group(3).strip(),
                    "links": _dedupe(link_targets(m.group(3))),
                    "effects": [],
                }
            )
            continue
        cm = _CLASS_LABEL_RE.match(line)
        if cm:
            set_class = to_plain(cm.group(1))
            continue
        if bonuses:  # continuation of the previous bonus (multi-line text)
            b = bonuses[-1]
            b["wikitext"] += "\n" + line
            b["text"] = to_plain(b["wikitext"])
            b["links"] = _dedupe(b["links"] + link_targets(line))
        else:
            stray.append(line)
    return bonuses, set_class, stray


def _wiki_status(wikitext: str) -> list[str]:
    """Flags for pages UESP hasn't finished — their data is provisional."""
    status = []
    if find_templates(wikitext, "Pre-Release"):
        status.append("pre_release")
    if find_templates(wikitext, "Minimal") or find_templates(wikitext, "huh"):
        status.append("incomplete")
    return status


def deprecated_titles(page: dict[str, Any] | None) -> set[str]:
    """Sets listed under 'Removed Sets' on Online:Deprecated Item Sets."""
    if not page:
        return set()
    out = set()
    for tpl in find_templates(page["wikitext"], "ESO Set Table"):
        out |= {f"Online:{p}" for p in tpl.positional() if p}
    return out


def _dedupe(items: list[str]) -> list[str]:
    return list(dict.fromkeys(items))


def parse_sets(
    pages: list[dict[str, Any]], deprecated: set[str]
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    sets: list[dict[str, Any]] = []
    report: dict[str, Any] = {
        "index_pages": [],
        "excluded": [],
        "stray_lines": {},
        "labels": Counter(),
    }
    titles = {p["title"] for p in pages}

    for page in pages:
        title = page["title"]
        if EXCLUDE_TITLE_RE.match(title):
            report["excluded"].append(title)
            continue
        if not page["expanded"]:
            report["index_pages"].append(title)
            continue

        bonuses, set_class, stray = _parse_bonuses(page["expanded"])
        if stray:
            report["stray_lines"][title] = stray
        for b in bonuses:
            report["labels"][f"{b['pieces']}{'p' if b['perfected'] else ''}"] += 1

        tags, named = _sets_with(page["wikitext"])
        intro_links = set(link_targets(_intro(page["wikitext"])))
        name = title.split(":", 1)[1]
        name = re.sub(r" \(set\)$", "", name)

        perfected_of = None
        perfected_variant = None
        if name.startswith("Perfected "):
            base = "Online:" + title.split(":", 1)[1][len("Perfected ") :]
            perfected_of = slugify(base) if base in titles else None
        elif f"Online:Perfected {title.split(':', 1)[1]}" in titles:
            perfected_variant = slugify(f"Perfected {name}")

        weapons = [WEAPON_TAGS[t] for t in tags if t in WEAPON_TAGS]
        sets.append(
            {
                "id": None,  # in-game setId, filled by Phase 3 reconciliation
                "slug": slugify(name),
                "name": name,
                "uesp": UESP_BASE + quote(title.replace(" ", "_"), safe=":/'(),"),
                "wiki": {"pageid": page["pageid"], "revid": page["revid"]},
                "type": _classify(intro_links, tags, named, set_class is not None),
                "class": set_class,
                "source": named.get("source") or None,
                "dlc": named.get("dlc") or None,
                "added_in": _mod_header(page["wikitext"]),
                "deprecated": title in deprecated
                or bool(find_templates(page["wikitext"], "Deprecated")),
                "wiki_status": _wiki_status(page["wikitext"]),
                "slots": {
                    "settype": named.get("settype") or None,
                    "weights": [WEIGHT_TAGS[t] for t in tags if t in WEIGHT_TAGS],
                    "weapons": weapons,
                    "jewelry": "Jewelry" in tags,
                    "head_shoulders": "Head and Shoulders" in tags,
                },
                "max_pieces": max((b["pieces"] for b in bonuses), default=0),
                "perfected_of": perfected_of,
                "perfected_variant": perfected_variant,
                "tags": tags,
                "bonuses": bonuses,
                "roles": [],
                "pros": [],
                "cons": [],
                "confidence": "auto",
            }
        )

    sets.sort(key=lambda s: s["slug"])
    dupes = [s for s, n in Counter(x["slug"] for x in sets).items() if n > 1]
    if dupes:
        raise SystemExit(f"slug collision(s): {dupes}")
    return sets, report


# --- buffs -----------------------------------------------------------------------

_TIER_ROW_RE = re.compile(
    r"^\|(?:\s*rowspan=\d+\s*\|)?\s*(?:'')?(Minor|Major)(?:'')?\s*\|\|(?:\s*rowspan=\d+\s*\|)?\s*(.*)$"
)
_GROUP_RE = re.compile(r"^===\s*(.+?)\s*===\s*$")
_SECTION_RE = re.compile(r"^==\s*([^=].*?)\s*==\s*$")
_VALUE_RES = [
    re.compile(r"\bby\s+(\d+(?:\.\d+)?)(%?)"),
    re.compile(r"\b(\d+(?:\.\d+)?)(%)\s+(?:less|more)\b"),
    re.compile(r"\b(?:Generates|Drains|restores)\s+(\d+(?:\.\d+)?)()"),
]


def parse_buffs(page: dict[str, Any]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    section = ""
    group = ""
    entry: dict[str, Any] | None = None
    source_kind: str | None = None
    misc_name: str | None = None

    for raw in page["wikitext"].split("\n"):
        line = raw.strip()
        if m := _SECTION_RE.match(line):
            section = m.group(1)
            entry = None
            continue
        if section not in ("Buffs", "Debuffs", "Miscellaneous Buffs"):
            continue
        if section == "Miscellaneous Buffs":
            if line.startswith("!") and not line.startswith("!Buff Name"):
                misc_name = to_plain(line[1:])
            elif misc_name and line.startswith("|") and not line.startswith("|-"):
                desc = to_plain(line[1:])
                out.append(_buff_record(misc_name, None, "misc", desc, {}))
                misc_name = None
            continue
        if m := _GROUP_RE.match(line):
            group = m.group(1)
            continue
        if m := _TIER_ROW_RE.match(line):
            kind = "buff" if section == "Buffs" else "debuff"
            desc = to_plain(m.group(2))
            # "N/A" rows are placeholders for tiers that don't exist in game
            entry = (
                None if desc == "N/A" else _buff_record(group, m.group(1).lower(), kind, desc, {})
            )
            if entry:
                out.append(entry)
            source_kind = None
            continue
        if entry is None:
            continue
        if line.startswith("!") and not line.startswith("!!"):
            source_kind = to_plain(line[1:]).lower() or None
            continue
        if source_kind and line.startswith("|") and not line.startswith(("|-", "|rowspan")):
            names = [to_plain(x) for x in split_top_level(line[1:], ",")]
            entry["sources"].setdefault(source_kind, []).extend(n for n in names if n)
            source_kind = None
    return out


def _buff_record(
    group: str, tier: str | None, kind: str, desc: str, sources: dict[str, list[str]]
) -> dict[str, Any]:
    value = unit = None
    for rx in _VALUE_RES:
        if m := rx.search(desc):
            value, unit = float(m.group(1)), ("pct" if m.group(2) else "flat")
            value = int(value) if value.is_integer() else value
            break
    name = f"{tier.capitalize()} {group}" if tier else group
    return {
        "key": slugify(name),
        "name": name,
        "group": group,
        "tier": tier,
        "kind": kind,
        "description": desc,
        "value": value,
        "unit": unit,
        "sources": sources,
    }


# --- traits ----------------------------------------------------------------------

TRAIT_SECTIONS = {
    "Weapon Traits": "weapon",
    "Armor Traits": "armor",
    "Jewelry Traits": "jewelry",
    "Common Traits": "common",
}
QUALITIES = ["normal", "fine", "superior", "epic", "legendary"]


def _resolved(page: dict[str, Any]) -> str:
    return splice_fragments(page["wikitext"], page.get("fragments", {}))


def _header_index(grid: list[list[Any]], name: str) -> int | None:
    for i, cell in enumerate(grid[0] if grid else []):
        if to_plain(cell.text) == name:
            return i
    return None


def parse_traits(page: dict[str, Any]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for table in parse_tables(_resolved(page)):
        category = TRAIT_SECTIONS.get(table.heading)
        if not category:
            continue
        grid = table.grid()
        i_desc = _header_index(grid, "Description")
        seen: Counter[str] = Counter()
        for row in grid:
            if not row or not row[0].header or "[[" not in row[0].text:
                continue
            q = next((t for c in row for t in find_templates(c.text, "ESO Quality Colors")), None)
            if q is None:
                continue
            trait = to_plain(row[0].text)
            desc_cell = row[i_desc] if i_desc is not None and i_desc < len(row) else None
            desc_lines = to_plain(desc_cell.text, br="\n").split("\n") if desc_cell else [""]
            # Weapon table: "Description" has colspan=2 — the second column is 1H/2H
            variant = None
            if (
                i_desc is not None
                and i_desc + 1 < len(row)
                and grid[0][i_desc + 1] is grid[0][i_desc]
                and row[i_desc + 1] is not row[i_desc]  # single-desc rows span both columns
            ):
                v = to_plain(row[i_desc + 1].text)
                variant = v if v and "{{" not in row[i_desc + 1].text else None
            # Multi-row traits without a variant column (Triune): pair rows with desc lines
            n = seen[trait]
            seen[trait] += 1
            desc = (
                desc_lines[min(n, len(desc_lines) - 1)] if variant is None else " ".join(desc_lines)
            )
            if variant is None and len(desc_lines) > 1:
                variant = f"part{n + 1}"
            values = [_num(v) for v in q.positional()]
            out.append(
                {
                    "key": slugify(f"{category} {trait}" + (f" {variant}" if variant else "")),
                    "trait": trait,
                    "category": category,
                    "variant": variant,
                    "description": desc.strip() or None,
                    "legendary": values[-1] if values else None,
                    "by_quality": dict(zip(QUALITIES, values, strict=False)),
                }
            )
    return out


def _num(text: str) -> float | int | str | list[Any]:
    t = to_plain(text).replace(",", "").strip()
    if " / " in t:  # multi-effect values, e.g. Steed "238 / 10%"
        return [_num(part) for part in t.split(" / ")]
    m = re.fullmatch(r"(\d+(?:\.\d+)?)\s*%?", t)
    if not m:
        return t
    v = float(m.group(1))
    return int(v) if v.is_integer() else round(v, 4)


# --- mundus ----------------------------------------------------------------------


def parse_mundus(page: dict[str, Any]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for table in parse_tables(_resolved(page)):
        grid = table.grid()
        i_eff = _header_index(grid, "Effect")
        i_val = _header_index(grid, "Value")
        if i_eff is None or i_val is None:
            continue
        i_div = next((i for i, c in enumerate(grid[0]) if "Divines" in c.text), None)
        for row in grid[1:]:
            if len(row) <= max(i_eff, i_val) or not row[0].header:
                continue
            stone = to_plain(row[0].text)
            out.append(
                {
                    "key": slugify(stone),
                    "stone": stone,
                    "effect": to_plain(row[i_eff].text),
                    "value": _num(row[i_val].text),
                    "full_divines_value": _num(row[i_div].text) if i_div is not None else None,
                }
            )
    return out


# --- enchants --------------------------------------------------------------------

GLYPH_SECTIONS = {"Weapon Glyphs": "weapon", "Armor Glyphs": "armor", "Jewelry Glyphs": "jewelry"}


def parse_enchants(
    index: dict[str, Any], glyph_pages: dict[str, dict[str, Any]]
) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for table in parse_tables(index["wikitext"]):
        slot = GLYPH_SECTIONS.get(table.heading)
        if not slot:
            continue
        grid = table.grid()
        i_eff = _header_index(grid, "Effect")
        for row in grid:
            if not row or row[0].header:
                continue
            targets = [t for t in link_targets(row[0].text) if t.startswith("Online:Glyph of ")]
            if not targets:
                continue
            title = targets[0]
            effect = to_plain(row[i_eff].text) if i_eff is not None and i_eff < len(row) else None
            out.append(
                {
                    "key": slugify(title),
                    "glyph": title.split(":", 1)[1],
                    "slot": slot,
                    "effect": effect,
                    # X, Y, Z in `effect`, in order (e.g. absorb: damage, restore)
                    "cp160_legendary": _glyph_cp160(glyph_pages.get(title)),
                }
            )
    return out


def _glyph_cp160(page: dict[str, Any] | None) -> list[float | int | str] | None:
    """Legendary-quality values from the 'Truly Superb' (CP160) row."""
    if not page:
        return None
    for table in parse_tables(_resolved(page)):
        for row in table.rows:
            if row and "Truly Superb" in row[0].text:
                vals = [
                    _num(t.positional()[-1])
                    for c in row
                    for t in find_templates(c.text, "ESO Quality Color")
                    if t.positional() and t.positional()[0] == "l"
                ]
                return vals or None
    return None


# --- driver ----------------------------------------------------------------------


def _load_dir(path: Path) -> list[dict[str, Any]]:
    return [json.loads(f.read_text()) for f in sorted(path.glob("*.json"))]


def _write(name: str, payload: Any) -> Path:
    path = DATA_DIR / name
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=1) + "\n")
    return path


def _envelope(
    kind: str, items: list[dict[str, Any]], sources: list[dict[str, Any]]
) -> dict[str, Any]:
    return {
        "schema_version": SCHEMA_VERSION,
        "kind": kind,
        "source": {
            "wiki": "en.uesp.net",
            "max_revid": max((s["revid"] for s in sources), default=None),
            "pages": len(sources),
        },
        "count": len(items),
        "items": items,
    }


def run() -> int:
    set_pages = _load_dir(SET_PAGES)
    if not set_pages:
        print("no cached pages — run `fetch` first", file=sys.stderr)
        return 1
    support = {p["title"]: p for p in _load_dir(SUPPORT_PAGES)}
    glyph_pages = {p["title"]: p for p in _load_dir(SUPPORT_PAGES / "glyphs")}
    categories = json.loads((WIKI_CACHE / "categories.json").read_text())

    dep_page = next((p for p in set_pages if p["title"] == "Online:Deprecated Item Sets"), None)
    deprecated = deprecated_titles(dep_page)

    sets, rep = parse_sets(set_pages, deprecated)
    buffs = parse_buffs(support["Online:Buffs"])
    dump = load_dump()
    recon = reconcile(sets, dump) if dump else None
    norm = normalize_sets(sets, buffs)
    traits = parse_traits(support["Online:Traits"])
    mundus = parse_mundus(support["Online:Mundus Stones"])
    enchants = parse_enchants(support["Online:Glyphs"], glyph_pages)

    _write("sets.json", _envelope("sets", sets, [p for p in set_pages if p["expanded"]]))
    _write("buffs.json", _envelope("buffs", buffs, [support["Online:Buffs"]]))
    _write("traits.json", _envelope("traits", traits, [support["Online:Traits"]]))
    _write("mundus.json", _envelope("mundus", mundus, [support["Online:Mundus Stones"]]))
    _write(
        "enchants.json",
        _envelope("enchants", enchants, [support["Online:Glyphs"], *glyph_pages.values()]),
    )

    checks = cross_check(sets, categories)
    write_report(sets, rep, checks, buffs, traits, mundus, enchants)
    write_unmodeled_report(norm)
    write_reconcile_report(recon)
    if recon:
        print(
            f"  game dump: {recon['matched']} sets matched, "
            f"{recon['lines_verified']} lines verified, {len(recon['mismatches'])} mismatches, "
            f"{len(recon['structure_diffs'])} structure diffs, "
            f"{len(recon['game_only'])} game-only, {len(recon['wiki_only'])} wiki-only",
            file=sys.stderr,
        )
    cov = norm["coverage"]
    print(
        f"✓ parse: {len(sets)} sets, {len(buffs)} buffs, {len(traits)} traits, "
        f"{len(mundus)} mundus, {len(enchants)} glyphs "
        f"({len(checks['failures'])} cross-check failures)",
        file=sys.stderr,
    )
    for bucket in ("stat", "signature"):
        c = cov.get(bucket, {})
        total = sum(c.values()) or 1
        print(
            f"  effects[{bucket}]: {c.get('full', 0) / total:.1%} full, "
            f"{c.get('partial', 0) / total:.1%} partial, {c.get('none', 0) / total:.1%} none "
            f"({total} lines)",
            file=sys.stderr,
        )
    return 0


def cross_check(sets: list[dict[str, Any]], categories: dict[str, Any]) -> dict[str, Any]:
    """Every page UESP files under 'with N-Piece Bonus' must yield an N-piece line."""
    by_title = {
        unquote(s["uesp"].removeprefix(UESP_BASE)).replace("_", " "): s for s in sets if s["uesp"]
    }
    failures: list[str] = []
    for cat, members in categories["checks"].items():
        m = re.search(r"with (\d+)-Piece Bonus", cat)
        for title in members:
            s = by_title.get(title)
            if s is None:
                failures.append(f"{title}: in {cat} but not parsed as a set")
            elif m and not any(b["pieces"] == int(m.group(1)) for b in s["bonuses"]):
                failures.append(f"{title}: in {cat} but no {m.group(1)}-piece bonus parsed")
            elif "Head and Shoulders" in cat and s["type"] != "monster":
                failures.append(f"{title}: head/shoulders set typed as {s['type']}")
    no_bonus = [s["name"] for s in sets if not s["bonuses"] and not s["deprecated"]]
    failures += [f"{n}: no bonus lines" for n in no_bonus]
    return {"failures": failures}


def write_report(sets, rep, checks, buffs, traits, mundus, enchants) -> None:  # noqa: ANN001
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    types = Counter(s["type"] for s in sets)
    lines = [
        "# Set DB — parse report",
        "",
        "Generated by `task setdb:parse`. Do not edit.",
        "",
        "## Totals",
        "",
        f"- Sets: **{len(sets)}** ({sum(s['deprecated'] for s in sets)} deprecated)",
        f"- Buffs/debuffs: {len(buffs)} · Traits: {len(traits)} · Mundus: {len(mundus)} · "
        f"Glyphs: {len(enchants)}",
        f"- Index pages skipped: {len(rep['index_pages'])} · Excluded: {len(rep['excluded'])}",
        "",
        "## Sets by type",
        "",
        "| Type | Count |",
        "|---|---|",
        *[f"| {t} | {n} |" for t, n in sorted(types.items(), key=lambda x: -x[1])],
        "",
        "## Bonus lines by piece count",
        "",
        ", ".join(f"{k}: {v}" for k, v in sorted(rep["labels"].items(), key=lambda x: x[0])),
        "",
        "## Cross-check failures",
        "",
        *([f"- {f}" for f in checks["failures"]] or ["None."]),
        "",
        "## `special` (unclassified) sets — review",
        "",
        *(
            [
                f"- [{s['name']}]({s['uesp']}) — source: {s['source'] or '?'}; tags: "
                f"{', '.join(s['tags'][:6]) or 'none'}"
                for s in sets
                if s["type"] == "special" and not s["deprecated"] and not s["wiki_status"]
            ]
            or ["None."]
        ),
        "",
        "## Provisional wiki pages (pre-release / incomplete) — re-fetch after UESP fills them",
        "",
        *(
            [
                f"- [{s['name']}]({s['uesp']}) — {', '.join(s['wiki_status'])}; type: {s['type']}"
                for s in sets
                if s["wiki_status"]
            ]
            or ["None."]
        ),
        "",
        "## Deprecated (removed from game)",
        "",
        ", ".join(s["name"] for s in sets if s["deprecated"]) or "None.",
        "",
        "## Stray lines (text before the first bonus label)",
        "",
        *([f"- {t}: `{' / '.join(v)[:160]}`" for t, v in rep["stray_lines"].items()] or ["None."]),
        "",
        "## Buffs without a parsed value",
        "",
        ", ".join(b["name"] for b in buffs if b["value"] is None and b["kind"] != "misc")
        or "None.",
        "",
        "## Skipped index pages",
        "",
        ", ".join(rep["index_pages"]),
        "",
    ]
    (REPORTS_DIR / "parse_report.md").write_text("\n".join(lines))


def write_unmodeled_report(norm: dict[str, Any]) -> None:
    """Curation queue: every bonus line not fully modeled, signature lines first."""
    lines = [
        "# Set DB — unmodeled / partial bonus lines",
        "",
        "Generated by `task setdb:parse`. Do not edit. Deprecated sets excluded.",
        "",
        "## Coverage",
        "",
        "| Bucket | Full | Partial | None | Lines |",
        "|---|---|---|---|---|",
    ]
    for bucket, c in sorted(norm["coverage"].items()):
        total = sum(c.values()) or 1
        lines.append(
            f"| {bucket} | {c['full'] / total:.1%} | {c['partial'] / total:.1%} | "
            f"{c['none'] / total:.1%} | {total} |"
        )
    lines += [
        "",
        "`stat` = lines below the set's max piece count; `signature` = the max-piece line "
        "(5pc / monster 2pc / mythic 1pc / arena weapon) and perfected lines.",
        "",
        f"## Detected skills ({len(norm['skills'])})",
        "",
        ", ".join(norm["skills"]),
        "",
        "## Queue",
        "",
    ]
    for it in sorted(norm["issues"], key=lambda i: (i["coverage"] != "none", i["type"], i["slug"])):
        lines.append(f"### {it['set']} ({it['pieces']}pc, {it['type']}) — {it['coverage']}")
        lines.append("")
        lines.append(f"> {it['text']}")
        lines.append("")
        lines += [f"- {p}" for p in it["issues"]]
        lines.append("")
    (REPORTS_DIR / "unmodeled.md").write_text("\n".join(lines))


def write_reconcile_report(recon: dict[str, Any] | None) -> None:
    path = REPORTS_DIR / "reconcile.md"
    if recon is None:
        path.write_text(
            "# Set DB — game reconciliation\n\nNo game dump imported. In game: `/cm sets:dump`, "
            "`/reloadui`; then `task setdb:import` and `task setdb:build`.\n"
        )
        return
    meta = recon["meta"]
    lines = [
        "# Set DB — game reconciliation",
        "",
        "Generated by `task setdb:parse`. Do not edit.",
        "",
        f"- Dump: API {meta.get('apiVersion')}, game {meta.get('gameVersion')}, "
        f"{meta.get('server')}, language {meta.get('language')}",
        f"- Sets matched: **{recon['matched']}** · game-only: {len(recon['game_only'])} · "
        f"wiki-only: {len(recon['wiki_only'])} · "
        f"filled from game: {len(recon['filled_from_game'])}",
        f"- Bonus lines verified: **{recon['lines_verified']}** (of which "
        f"{recon['lines_character_scaled']} have character-scaled proc/heal numbers) · "
        f"mismatches: {len(recon['mismatches'])} · "
        f"structure diffs: {len(recon['structure_diffs'])}",
        "",
        "The game renders each set at its default drop quality, so level-scaled values sit",
        "at a fixed ratio (tier) to the wiki's CP160 gold values. Median tier by set type:",
        "",
        "| Type | Tier |",
        "|---|---|",
        *[f"| {t} | {v} |" for t, v in recon["tiers"].items()],
    ]
    for title, key in (
        ("Mismatches (wiki kept; check against the game)", "mismatches"),
        ("Structure differences (different number of values, or missing lines)", "structure_diffs"),
        ("Sets whose values sit on more than one tier", "mixed_tier_sets"),
        ("Filled from game text (wiki page provisional)", "filled_from_game"),
        ("In game, not on the wiki (added from the dump)", "game_only"),
        ("On the wiki, not in the game dump", "wiki_only"),
    ):
        items = recon[key]
        lines += ["", f"## {title} ({len(items)})", ""]
        lines += [f"- {x}" for x in items] or ["None."]
    path.write_text("\n".join(lines) + "\n")
