#!/usr/bin/env python3
"""Marginal damage value of gear/stat changes for an ESO character.

Model (PvE, CP160, direct/DoT damage):
    damage ∝ (max_resource / 10.5 + power)
             × (1 + crit_chance × crit_damage)
             × (1 − mitigation),   mitigation = max(0, resist − pen) / 660 %, cap 50%
    crit_chance = crit_pct + rating/219 (cap 100%); crit_damage capped at 125%.

Each --option is a set of deltas applied to the base, optionally at partial uptime:
    expected = uptime × with + (1 − uptime) × without
Deltas: crit_rating, crit_pct, cd (crit damage %), pen, power, res (max resource),
        dmg (% damage done, multiplicative bucket).

Example (Masisi: swap Order's Wrath 5pc for Night Mother's Gaze 5pc):
    value_calc.py --base "crit_pct=48.5,cd=88,pen=1930,power=2827,res=27399" \\
      --option "no Order's 5pc: crit_rating=-943,cd=-8" \\
      --option "NMG 5pc: crit_rating=-943,cd=-8 | pen=5948@1.0"

Everything after '|' is applied at the given uptime (@0-1); before it, always on.
Constants are general ESO knowledge (not yet in data/sets): re-check after patches.
"""

from __future__ import annotations

import argparse
import sys

RATING_PER_CRIT_PCT = 219.0
RESIST_PER_MITIGATION_PCT = 660.0
MITIGATION_CAP = 0.50
CRIT_DAMAGE_CAP = 125.0
RESOURCE_PER_POWER = 10.5
DEFAULT_TARGET_RESIST = 18200.0

STAT_KEYS = {"crit_pct", "crit_rating", "cd", "pen", "power", "res", "dmg"}


def parse_stats(text: str) -> dict[str, float]:
    out: dict[str, float] = {}
    for part in filter(None, (p.strip() for p in text.split(","))):
        key, _, val = part.partition("=")
        key = key.strip()
        if key not in STAT_KEYS:
            raise SystemExit(f"unknown stat '{key}' (use: {', '.join(sorted(STAT_KEYS))})")
        out[key] = out.get(key, 0.0) + float(val)
    return out


def damage(stats: dict[str, float], resist: float) -> float:
    power = stats.get("power", 0.0) + stats.get("res", 0.0) / RESOURCE_PER_POWER
    crit = min(1.0, (stats.get("crit_pct", 0.0) + stats.get("crit_rating", 0.0) / RATING_PER_CRIT_PCT) / 100)
    crit_damage = min(CRIT_DAMAGE_CAP, stats.get("cd", 0.0)) / 100
    effective_resist = max(0.0, resist - stats.get("pen", 0.0))
    mitigation = min(MITIGATION_CAP, effective_resist / RESIST_PER_MITIGATION_PCT / 100)
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


def evaluate(base: dict[str, float], option: str, resist: float) -> tuple[str, float]:
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
    return name, sum(damage(s, resist) * w for s, w in scenarios)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--base", required=True, help="live stats, e.g. crit_pct=48.5,cd=88,pen=1930,power=2827,res=27399")
    ap.add_argument("--option", action="append", default=[], help="'name: deltas | deltas@uptime'")
    ap.add_argument("--resist", type=float, default=DEFAULT_TARGET_RESIST, help="target resistance (default 18200)")
    args = ap.parse_args(argv)

    base = parse_stats(args.base)
    ref = damage(base, args.resist)
    crit = base.get("crit_pct", 0) + base.get("crit_rating", 0) / RATING_PER_CRIT_PCT
    print(
        f"base: crit {crit:.1f}% · crit dmg {min(CRIT_DAMAGE_CAP, base.get('cd', 0)):.0f}% · "
        f"pen {base.get('pen', 0):.0f}/{args.resist:.0f} · power-equivalent "
        f"{base.get('power', 0) + base.get('res', 0) / RESOURCE_PER_POWER:.0f}"
    )
    for opt in args.option:
        name, value = evaluate(base, opt, args.resist)
        print(f"{value / ref - 1:+7.2%}  {name}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
