"""Validate data/sets/*.json against schema.json plus cross-file invariants."""

from __future__ import annotations

import json
import sys

from .paths import DATA_DIR, SCHEMA_FILE

FILES = ["sets.json", "buffs.json", "traits.json", "mundus.json", "enchants.json"]
# Claude-ingested support tables. Validated when present; no count floors.
OPTIONAL_FILES = [
    "caps.json",
    "passives.json",
    "skills.json",
    "consumables.json",
    "cp_stars.json",
]

# Sanity floors: a parse that drops below these has broken, not "found fewer".
MIN_COUNTS = {
    "sets.json": 650,
    "buffs.json": 60,
    "traits.json": 30,
    "mundus.json": 13,
    "enchants.json": 30,
}


def run() -> int:
    try:
        from jsonschema import Draft202012Validator
    except ImportError:
        print("jsonschema missing — run via `uv run --group setdb`", file=sys.stderr)
        return 2

    validator = Draft202012Validator(json.loads(SCHEMA_FILE.read_text()))
    errors: list[str] = []
    docs = {}
    required = list(FILES)
    present_optional = [n for n in OPTIONAL_FILES if (DATA_DIR / n).exists()]
    for name in required + present_optional:
        path = DATA_DIR / name
        if not path.exists():
            errors.append(f"{name}: missing")
            continue
        doc = json.loads(path.read_text())
        docs[name] = doc
        for err in sorted(validator.iter_errors(doc), key=lambda e: list(e.path))[:20]:
            loc = "/".join(str(p) for p in err.path)
            errors.append(f"{name}: {loc}: {err.message[:200]}")
        if doc.get("count") != len(doc.get("items", [])):
            errors.append(f"{name}: count {doc.get('count')} != {len(doc.get('items', []))} items")
        floor = MIN_COUNTS.get(name)
        if floor is not None and len(doc.get("items", [])) < floor:
            errors.append(f"{name}: only {len(doc['items'])} items (floor {floor})")
        keys = [i.get("slug") or i.get("key") for i in doc.get("items", [])]
        dupes = sorted({k for k in keys if keys.count(k) > 1})
        if dupes:
            errors.append(f"{name}: duplicate keys {dupes[:10]}")
        if name == "cp_stars.json":
            ids = [i.get("id") for i in doc.get("items", [])]
            id_dupes = sorted({i for i in ids if ids.count(i) > 1})
            if id_dupes:
                errors.append(f"{name}: duplicate ids {id_dupes[:10]}")

    if "sets.json" in docs:
        slugs = {s["slug"] for s in docs["sets.json"]["items"]}
        for s in docs["sets.json"]["items"]:
            for ref in ("perfected_of", "perfected_variant"):
                if s[ref] and s[ref] not in slugs:
                    errors.append(f"sets.json: {s['slug']}.{ref} -> unknown slug {s[ref]}")
            if not s["deprecated"] and not s["bonuses"]:
                errors.append(f"sets.json: {s['slug']} has no bonuses")

    if "buffs.json" in docs:
        buff_keys = {b["key"] for b in docs["buffs.json"]["items"]}
        for name in ("passives.json", "skills.json", "consumables.json", "cp_stars.json"):
            if name not in docs:
                continue
            for item in docs[name]["items"]:
                refs = list(item.get("buffs_granted") or [])
                refs.extend(item.get("debuffs_applied") or [])
                for rank in item.get("ranks") or []:
                    for effect in rank.get("effects") or []:
                        if effect.get("buff_ref"):
                            refs.append(effect["buff_ref"])
                for effect in item.get("effects") or []:
                    if effect.get("buff_ref"):
                        refs.append(effect["buff_ref"])
                unknown = sorted({r for r in refs if r not in buff_keys})
                if unknown:
                    label = item.get("key") or item.get("name")
                    errors.append(f"{name}: {label}: unknown buff_ref {unknown[:8]}")

    checked = required + present_optional
    for e in errors:
        print(f"✗ {e}", file=sys.stderr)
    if errors:
        return 1
    print(f"✓ validate: {len(checked)} files OK", file=sys.stderr)
    return 0
