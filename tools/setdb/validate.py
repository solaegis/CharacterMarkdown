"""Validate data/sets/*.json against schema.json plus cross-file invariants."""

from __future__ import annotations

import json
import sys

from .paths import DATA_DIR, SCHEMA_FILE

FILES = ["sets.json", "buffs.json", "traits.json", "mundus.json", "enchants.json"]

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
    for name in FILES:
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
        if len(doc.get("items", [])) < MIN_COUNTS[name]:
            errors.append(f"{name}: only {len(doc['items'])} items (floor {MIN_COUNTS[name]})")
        keys = [i.get("slug") or i.get("key") for i in doc.get("items", [])]
        dupes = sorted({k for k in keys if keys.count(k) > 1})
        if dupes:
            errors.append(f"{name}: duplicate keys {dupes[:10]}")

    if "sets.json" in docs:
        slugs = {s["slug"] for s in docs["sets.json"]["items"]}
        for s in docs["sets.json"]["items"]:
            for ref in ("perfected_of", "perfected_variant"):
                if s[ref] and s[ref] not in slugs:
                    errors.append(f"sets.json: {s['slug']}.{ref} -> unknown slug {s[ref]}")
            if not s["deprecated"] and not s["bonuses"]:
                errors.append(f"sets.json: {s['slug']} has no bonuses")

    for e in errors:
        print(f"✗ {e}", file=sys.stderr)
    if errors:
        return 1
    print(f"✓ validate: {len(FILES)} files OK", file=sys.stderr)
    return 0
