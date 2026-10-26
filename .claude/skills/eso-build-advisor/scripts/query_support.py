#!/usr/bin/env python3
"""Query the support tables (passives, skills, food/potions, CP, buff sources).

Examples:
  query_support.py --kind passives --name "Magicka Mastery"     # race/class/skill-line passive
  query_support.py --kind skills --name "Boundless Storm"       # morph buffs + cost
  query_support.py --kind skills --buff minor_force             # who grants Minor Force
  query_support.py --kind consumables --name "Garlic Cod"       # food numbers
  query_support.py --kind cp --stat crit_damage_pct             # CP stars by stat
  query_support.py --kind buff --name major_brutality           # every source of a buff
  query_support.py --kind passives --line Breton --include-drafts --raw

Rows with `verified: false` are hidden unless --include-drafts. A draft's numbers
are not facts: quote its raw tooltip text and say it's unverified.
Filters AND together; --name, --stat and --buff accept repeats (OR within).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

FILES = {
    "passives": "passives.json",
    "skills": "skills.json",
    "consumables": "consumables.json",
    "cp": "cp_stars.json",
    "buff": "buffs.json",
}


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for p in here.parents:
        if (p / "data" / "sets" / "schema.json").exists():
            return p
    raise SystemExit("data/sets not found — run from the CharacterMarkdown repo")


def load(kind: str) -> list[dict]:
    path = repo_root() / "data" / "sets" / FILES[kind]
    if not path.exists():
        raise SystemExit(f"{path} missing — run `task setdb:support-parse`")
    return json.loads(path.read_text())["items"]


def item_effects(item: dict, all_ranks: bool = False) -> list[dict]:
    if "ranks" in item:
        ranks = item["ranks"] if all_ranks else item["ranks"][-1:]
        return [e for r in ranks for e in r["effects"]]
    return item.get("effects", [])


def item_line(kind: str, item: dict) -> str:
    if kind == "passives":
        return item["line"]
    if kind == "skills":
        return item["skill_line"] + (f"/{item['class']}" if item.get("class") else "")
    if kind == "cp":
        return item["constellation"] + (" slottable" if item["slottable"] else "")
    return item.get("category", "")


def item_buffs(item: dict) -> list[str]:
    out = list(item.get("buffs_granted", [])) + [f"-{d}" for d in item.get("debuffs_applied", [])]
    for e in item_effects(item, all_ranks=True):
        if e.get("buff_ref") and e["buff_ref"] not in out:
            out.append(e["buff_ref"])
    return out


def compact(obj) -> str:
    return json.dumps(obj, separators=(",", ":"))


def fmt_effect(e: dict) -> str:
    if e["kind"] in ("buff_grant", "debuff_apply"):
        head = e["buff_ref"]
    elif e["kind"] == "unmodeled":
        return "unmodeled"
    else:
        value = e.get("value")
        unit = "%" if e.get("unit") == "pct" else ""
        head = f"{e['stat']}={value:+g}{unit}" if isinstance(value, (int, float)) else e["stat"]
    tags = []
    if e["kind"] not in ("static", "buff_grant"):
        tags.append(e["kind"])
    if e.get("scope") and e["scope"] != "self":
        tags.append(e["scope"])
    if e.get("stacks"):
        per = e["stacks"].get("per")
        tags.append(f"per {per}" if per else "stacks:" + compact(e["stacks"]))
    if e.get("condition"):
        tags.append("if:" + compact(e["condition"]))
    if e.get("trigger"):
        tags.append("on:" + e["trigger"].get("on", "?"))
    if e.get("duration_s"):
        tags.append(f"{e['duration_s']:g}s")
    return head + (f" [{' '.join(tags)}]" if tags else "")


def print_item(kind: str, item: dict, args: argparse.Namespace) -> None:
    status = "verified" if item["verified"] else "DRAFT"
    parts = [item["name"], item_line(kind, item), status]
    if kind == "skills":
        cost = item.get("cost")
        parts.append(f"{cost} {item['resource']}" if cost is not None else "cost ?")
        if item.get("base"):
            parts.append(f"morph of {item['base']}")
    if kind == "consumables" and item.get("duration_s"):
        parts.append(f"{item['duration_s'] / 60:g} min")
    if kind == "cp":
        parts.append(f"id {item['id']}, max {item['max_points']}")
    buffs = item_buffs(item)
    if buffs:
        parts.append("buffs: " + ",".join(buffs))
    if "ranks" in item and args.all_ranks:
        for r in item["ranks"]:
            effects = "; ".join(fmt_effect(e) for e in r["effects"]) or "—"
            parts.append(f"r{r['rank']}: {effects}")
    else:
        stat_effects = [e for e in item_effects(item) if e["kind"] not in ("buff_grant", "debuff_apply")]
        label = f"r{item['ranks'][-1]['rank']} " if "ranks" in item else ""
        parts.append(label + ("; ".join(fmt_effect(e) for e in stat_effects) or "—"))
    print(" | ".join(parts))
    raw = next((e["raw"] for e in item_effects(item) if e.get("raw")), None)
    if raw and (args.raw or not item["verified"]):
        print(f"    “{raw}”")
    if args.raw and item.get("notes"):
        print(f"    notes: {item['notes']}")
    if args.raw and item.get("uesp"):
        print(f"    {item['uesp']}")


def query_buffs(args: argparse.Namespace) -> int:
    names = [n.lower() for n in args.name or []] + [b.lower() for b in args.buff or []]
    hits = [
        b
        for b in load("buff")
        if not names or any(n in b["key"] or n in b["name"].lower() for n in names)
    ]
    for b in hits[: args.limit]:
        value = b.get("value")
        unit = "%" if b.get("unit") == "pct" else ""
        head = f"{b['name']} ({b['key']}, {b['kind']})"
        if isinstance(value, (int, float)):
            head += f" {value:g}{unit}"
        print(f"## {head}: {b.get('description', '')}")
        for kind, srcs in sorted(b["sources"].items()):
            shown = ", ".join(srcs[:12]) + (f", … +{len(srcs) - 12}" if len(srcs) > 12 else "")
            print(f"  {kind} ({len(srcs)}): {shown}")
    if not hits:
        print("no matches", file=sys.stderr)
        return 1
    return 0


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--kind", required=True, choices=sorted(FILES))
    ap.add_argument("--name", action="append", help="substring of the row name (repeatable)")
    ap.add_argument("--line", help="substring of skill line / race / class / CP constellation")
    ap.add_argument("--stat", action="append", help="has an effect on this stat (repeatable)")
    ap.add_argument("--buff", action="append", help="grants/applies this buff key, e.g. minor_force (repeatable)")
    ap.add_argument("--include-drafts", action="store_true", help="also show verified: false rows")
    ap.add_argument("--all-ranks", action="store_true", help="passives: every rank, not just the max")
    ap.add_argument("--raw", action="store_true", help="print tooltip text, notes and UESP link")
    ap.add_argument("--limit", type=int, default=40)
    args = ap.parse_args(argv)

    if args.kind == "buff":
        return query_buffs(args)

    names = [n.lower() for n in args.name or []]
    stats = set(args.stat or [])
    buffs = set(args.buff or [])
    hits, hidden = [], 0
    for item in load(args.kind):
        if names and not any(n in item["name"].lower() for n in names):
            continue
        if args.line and args.line.lower() not in item_line(args.kind, item).lower():
            continue
        effects = item_effects(item, all_ranks=True)
        if stats and not stats & {e["stat"] for e in effects}:
            continue
        if buffs and not buffs & {b.lstrip("-") for b in item_buffs(item)}:
            continue
        if not item["verified"] and not args.include_drafts:
            hidden += 1
            continue
        hits.append(item)

    for item in hits[: args.limit]:
        print_item(args.kind, item, args)
    if len(hits) > args.limit:
        print(f"… {len(hits) - args.limit} more (raise --limit or narrow filters)")
    if hidden:
        print(f"({hidden} draft row(s) hidden — add --include-drafts; drafts are not facts)", file=sys.stderr)
    if not hits:
        print("no matches", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
