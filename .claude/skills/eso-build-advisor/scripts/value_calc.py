#!/usr/bin/env python3
"""Marginal damage value of gear/stat changes for an ESO character.

Model (PvE, CP160, direct/DoT damage):
    damage ∝ (max_resource / resource_per_power + power)
             × (1 + crit_chance × crit_damage)
             × (1 − mitigation),   mitigation = max(0, resist − pen) / resist_per_1% , cap
    crit_chance = crit_pct + rating/rating_per_pct (cap 100%); crit_damage capped.

Each --option is a set of deltas applied to the base, optionally at partial uptime:
    expected = uptime × with + (1 − uptime) × without
Deltas: crit_rating, crit_pct, cd (crit damage %), pen, power, res (max resource),
        dmg (% damage done, multiplicative bucket).

Example (Masisi: swap Order's Wrath 5pc for Night Mother's Gaze 5pc):
    value_calc.py --base "crit_pct=48.5,cd=88,pen=1930,power=2827,res=27399" \\
      --option "no Order's 5pc: crit_rating=-943,cd=-8" \\
      --option "NMG 5pc: crit_rating=-943,cd=-8 | pen=5948@1.0"

Everything after '|' is applied at the given uptime (@0-1); before it, always on.
Constants load from data/sets/caps.json (see docs/SET_SUPPORT_TABLES.md).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

# Fallback if caps.json is missing or a key is absent. Same numbers as the seed file.
_DEFAULT_CAPS = {
    "crit_rating_per_pct": 219.0,
    "resist_per_mitigation_pct": 660.0,
    "mitigation_cap": 0.50,
    "crit_damage_cap": 125.0,
    "resource_per_power": 10.5,
    "pve_dummy_resist": 18200.0,
}

STAT_KEYS = {"crit_pct", "crit_rating", "cd", "pen", "power", "res", "dmg"}


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "data" / "sets" / "schema.json").exists():
            return parent
    return here.parents[4]


def _item_value(item: dict) -> float | None:
    if item.get("value") is None:
        return None
    value = float(item["value"])
    if item.get("key") == "mitigation_cap" and item.get("unit") == "pct":
        return value / 100.0
    return value


def load_caps(path: Path | None = None) -> dict[str, float]:
    """Read data/sets/caps.json; unknown extra keys are ignored."""
    out = dict(_DEFAULT_CAPS)
    caps_path = path if path is not None else repo_root() / "data" / "sets" / "caps.json"
    if not caps_path.is_file():
        return out
    doc = json.loads(caps_path.read_text())
    if doc.get("kind") != "caps":
        raise SystemExit(f"{caps_path}: kind is {doc.get('kind')!r}, expected 'caps'")
    for item in doc.get("items", []):
        key = item.get("key")
        if key not in out:
            continue
        parsed = _item_value(item)
        if parsed is not None:
            out[key] = parsed
    return out


_CAPS = load_caps()
RATING_PER_CRIT_PCT = _CAPS["crit_rating_per_pct"]
RESIST_PER_MITIGATION_PCT = _CAPS["resist_per_mitigation_pct"]
MITIGATION_CAP = _CAPS["mitigation_cap"]
CRIT_DAMAGE_CAP = _CAPS["crit_damage_cap"]
RESOURCE_PER_POWER = _CAPS["resource_per_power"]
DEFAULT_TARGET_RESIST = _CAPS["pve_dummy_resist"]


def parse_stats(text: str) -> dict[str, float]:
    out: dict[str, float] = {}
    for part in filter(None, (p.strip() for p in text.split(","))):
        key, _, val = part.partition("=")
        key = key.strip()
        if key not in STAT_KEYS:
            raise SystemExit(f"unknown stat '{key}' (use: {', '.join(sorted(STAT_KEYS))})")
        out[key] = out.get(key, 0.0) + float(val)
    return out


def damage(stats: dict[str, float], resist: float, caps: dict[str, float] | None = None) -> float:
    c = caps or _CAPS
    rating = c["crit_rating_per_pct"]
    resist_per = c["resist_per_mitigation_pct"]
    mit_cap = c["mitigation_cap"]
    cd_cap = c["crit_damage_cap"]
    res_per_power = c["resource_per_power"]
    power = stats.get("power", 0.0) + stats.get("res", 0.0) / res_per_power
    crit = min(1.0, (stats.get("crit_pct", 0.0) + stats.get("crit_rating", 0.0) / rating) / 100)
    crit_damage = min(cd_cap, stats.get("cd", 0.0)) / 100
    effective_resist = max(0.0, resist - stats.get("pen", 0.0))
    mitigation = min(mit_cap, effective_resist / resist_per / 100)
    return power * (1 + crit * crit_damage) * (1 - mitigation) * (1 + stats.get("dmg", 0.0) / 100)


def apply(base: dict[str, float], delta: dict[str, float]) -> dict[str, float]:
    out = dict(base)
    for k, v in delta.items():
        out[k] = out.get(k, 0.0) + v
    return out


def parse_option(text: str) -> tuple[str, dict[str, float], list[tuple[dict[str, float], float]]]:
    name, _, body = text.partition(":")
    if not body:
        raise SystemExit(f"option needs 'name: deltas' — got {text!r}")
    always, *partials = body.split("|")
    parts = []
    for p in partials:
        deltas, _, uptime = p.partition("@")
        parts.append((parse_stats(deltas), float(uptime) if uptime else 1.0))
    return name.strip(), parse_stats(always), parts


def evaluate(
    base: dict[str, float], option: str, resist: float, caps: dict[str, float] | None = None
) -> tuple[str, float]:
    name, always, partials = parse_option(option)
    stats = apply(base, always)
    # expand every on/off combination of the partial-uptime parts
    scenarios = [(stats, 1.0)]
    for delta, uptime in partials:
        nxt = []
        for s, w in scenarios:
            nxt.append((apply(s, delta), w * uptime))
            nxt.append((s, w * (1 - uptime)))
        scenarios = nxt
    return name, sum(damage(s, resist, caps) * w for s, w in scenarios)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--base", required=True, help="live stats, e.g. crit_pct=48.5,cd=88,pen=1930,power=2827,res=27399")
    ap.add_argument("--option", action="append", default=[], help="'name: deltas | deltas@uptime'")
    ap.add_argument(
        "--resist",
        type=float,
        default=None,
        help="target resistance (default: caps.json pve_dummy_resist or 18200)",
    )
    ap.add_argument("--caps", type=Path, default=None, help="caps.json path (default: data/sets/caps.json)")
    args = ap.parse_args(argv)

    caps = load_caps(args.caps)
    resist = args.resist if args.resist is not None else caps["pve_dummy_resist"]
    rating = caps["crit_rating_per_pct"]
    cd_cap = caps["crit_damage_cap"]
    res_per_power = caps["resource_per_power"]

    base = parse_stats(args.base)
    ref = damage(base, resist, caps)
    crit = base.get("crit_pct", 0) + base.get("crit_rating", 0) / rating
    print(
        f"base: crit {crit:.1f}% · crit dmg {min(cd_cap, base.get('cd', 0)):.0f}% · "
        f"pen {base.get('pen', 0):.0f}/{resist:.0f} · power-equivalent "
        f"{base.get('power', 0) + base.get('res', 0) / res_per_power:.0f}"
    )
    for opt in args.option:
        name, value = evaluate(base, opt, resist, caps)
        print(f"{value / ref - 1:+7.2%}  {name}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
