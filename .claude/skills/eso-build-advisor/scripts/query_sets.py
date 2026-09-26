#!/usr/bin/env python3
"""Query the set digest (data/sets/llm_digest.jsonl) without loading all 700 sets.

Examples:
  query_sets.py --name "night mother" --name "order's wrath"        # exact look-ups
  query_sets.py --craftable --stat offensive_penetration --pieces 2 # 2pc pen fillers
  query_sets.py --type monster --stat weapon_damage                 # monster helms with WD
  query_sets.py --craftable --text "Major Breach"                   # bonus text search
  query_sets.py --type mythic --brief                               # names only

Filters AND together; --name, --type and --stat accept repeats (OR within).
Output is one compact line per bonus so it stays readable in a terminal/context.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for p in here.parents:
        if (p / "data" / "sets" / "llm_digest.jsonl").exists():
            return p
    raise SystemExit("data/sets/llm_digest.jsonl not found — run `task setdb:build` in the repo")


def load() -> tuple[dict, list[dict]]:
    lines = (repo_root() / "data" / "sets" / "llm_digest.jsonl").read_text().splitlines()
    return json.loads(lines[0]), [json.loads(line) for line in lines[1:]]


def effect_stats(bonus: dict) -> set[str]:
    out = set()
    for e in bonus.get("x", []):
        if isinstance(e, str):
            m = re.match(r"\+?([a-z_]+)", e)
            if m:
                out.add(m.group(1))
        else:
            out.add(e.get("s", ""))
    return out


def fmt_effect(e) -> str:
    if isinstance(e, str):
        return e
    parts = [e["s"]]
    if "v" in e:
        parts.append(f"{e['v']:+g}{'%' if e.get('u') == 'pct' else ''}")
    parts.append(f"[{e['k']}")
    if "sc" in e:
        parts.append(f"{e['sc']}")
    if "tr" in e:
        tr = e["tr"]
        parts.append("on:" + tr["on"] + (f" cd{tr['cd']:g}" if "cd" in tr else "") + (f" p{tr['p']:g}" if "p" in tr else ""))
    if "d" in e:
        parts.append(f"{e['d']:g}s")
    if "c" in e:
        parts.append("if:" + json.dumps(e["c"], separators=(",", ":")))
    if "st" in e:
        parts.append("stacks:" + json.dumps(e["st"], separators=(",", ":")))
    return " ".join(parts) + "]"


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--name", action="append", help="substring of set name (repeatable)")
    ap.add_argument("--type", action="append", help="set type, e.g. crafted, trial, monster (repeatable)")
    ap.add_argument("--craftable", action="store_true", help="shorthand for --type crafted")
    ap.add_argument("--stat", action="append", help="has an effect on this stat/buff key (repeatable)")
    ap.add_argument("--pieces", type=int, help="with --stat/--text: only match bonuses at exactly N pieces")
    ap.add_argument("--weight", choices=["L", "M", "H"], help="available in this armor weight")
    ap.add_argument("--text", help="regex over bonus text (case-insensitive)")
    ap.add_argument("--include-provisional", action="store_true", help="include prov:1 sets")
    ap.add_argument("--brief", action="store_true", help="names only")
    ap.add_argument("--limit", type=int, default=40)
    args = ap.parse_args(argv)

    _, sets = load()
    types = set(args.type or []) | ({"crafted"} if args.craftable else set())
    names = [n.lower() for n in args.name or []]
    stats = set(args.stat or [])
    text_rx = re.compile(args.text, re.I) if args.text else None

    hits = []
    for s in sets:
        if names and not any(n in s["n"].lower() for n in names):
            continue
        if types and s["t"] not in types:
            continue
        if args.weight and args.weight not in s.get("w", ""):
            continue
        if s.get("prov") and not args.include_provisional and not names:
            continue
        bonuses = [b for b in s["b"] if args.pieces is None or b["p"] == args.pieces]
        if stats and not any(stats & effect_stats(b) for b in bonuses):
            continue
        if text_rx and not any(text_rx.search(b.get("tx", "") + " " + " ".join(map(str, b.get("x", [])))) for b in bonuses):
            continue
        hits.append(s)

    for s in hits[: args.limit]:
        meta = [s["t"]]
        for key, label in (("src", "src"), ("cls", "class"), ("w", "w"), ("wp", "wp")):
            if key in s:
                meta.append(f"{label}={s[key]}")
        if s.get("hs"):
            meta.append("head+shoulders")
        if s.get("prov"):
            meta.append("PROVISIONAL")
        print(f"## {s['n']}  ({'; '.join(meta)})")
        if args.brief:
            continue
        for b in s["b"]:
            flags = "".join(f" {k}={b[k]}" for k in ("cov", "chk") if k in b)
            label = f"{b['p']}pc{' PERFECTED' if b.get('pf') else ''}"
            effects = "; ".join(fmt_effect(e) for e in b.get("x", [])) or "—"
            print(f"  {label}: {effects}{flags}")
            if "tx" in b:
                print(f"      “{b['tx']}”")
    if len(hits) > args.limit:
        print(f"… {len(hits) - args.limit} more (raise --limit or narrow filters)")
    if not hits:
        print("no matches", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
