"""Compact, LLM-facing digest of the set database: data/sets/llm_digest.jsonl.

sets.json carries everything (raw wikitext, links, revisions, per-effect source
text) and is ~4 MB. The digest keeps what a build advisor needs, in a form cheap
enough to attach to every conversation:

- line 1 is a legend (so the reader never has to guess a key);
- then one set per line;
- always-on, self-scoped stat effects become strings: "weapon_damage+129",
  "+minor_slayer" (buff grant); everything else is a short-key object;
- bonus text is kept where the effects may not say it all: signature lines
  (5pc/monster/mythic/perfected), procs, conditions, partial/none coverage,
  and lines the game flagged.

Usage: `task setdb:digest [-- --types trial,dungeon] [--no-text]`
(see docs/prompts/build_advisor_system_prompt.md for the matching prompt).
"""

from __future__ import annotations

import argparse
import json
import sys
from typing import Any

from .paths import DATA_DIR

OUT = DATA_DIR / "llm_digest.jsonl"

LEGEND = {
    "_legend": {
        "about": "ESO item sets, CP160 gold-quality values. One set per line after this legend.",
        "set": {
            "n": "name",
            "id": "in-game setId",
            "t": "type: overland|dungeon|trial|arena|arena_weapon|monster|mythic|crafted|pvp|class|leveling|special",
            "src": "where it drops / is crafted",
            "cls": "class restriction",
            "w": "armor weights: L/M/H",
            "wp": "weapon types allowed",
            "j": "1 if jewelry exists",
            "hs": "1 if monster head+shoulders set",
            "pv": "perfected version slug (this is the normal version)",
            "pf_of": "normal version slug (this is the perfected version)",
            "prov": "provisional: wiki page unfinished or set not on wiki (values from game)",
            "b": "bonus lines",
        },
        "bonus": {
            "p": "pieces required",
            "pf": "1 = needs 5 PERFECTED pieces",
            "x": "effects (below)",
            "tx": "bonus text: on signature lines and wherever effects may not capture everything. Read it for drawbacks.",
            "cov": "partial = effects are a lower bound, read tx; none = only tx is meaningful (absent = full)",
            "chk": "mismatch = the live game disagreed with this text (absent = verified or unchecked)",
        },
        "effect_string": "'stat+N' / 'stat-N' / 'stat+N%': always-on, self. '+buff_key': always-on buff grant (see BUFFS table).",
        "effect_object": {
            "s": "stat (or buff key for buff/debuff)",
            "v": "signed value (negative = reduced, e.g. ability_cost_pct -8 = 8% cheaper)",
            "u": "unit if not flat: pct | seconds",
            "k": "kind: static|conditional|proc|buff_grant|debuff_apply|damage|heal|shield|resource_restore|unmodeled",
            "sc": "scope if not self: group|ally|target|enemy_aoe|target_debuff",
            "c": "condition object",
            "tr": "trigger: on=event, cd=cooldown s, p=chance 0-1, skill/skill_line if the event is a specific skill",
            "d": "duration s",
            "st": "stacks: max, per (value is per stack of X), threshold",
            "dmg": "damage/heal detail: type, over_s (DoT/HoT length), interval_s (tick)",
            "up": "uptime estimate 0-1 (only set for always-on effects so far)",
            "x": "extra: radius, targets, delay, scales_off, window, ...",
        },
    }
}


def _compact_trigger(t: dict[str, Any] | None) -> dict[str, Any] | None:
    if not t:
        return None
    out: dict[str, Any] = {"on": t["on"]}
    if t.get("cooldown_s") is not None:
        out["cd"] = t["cooldown_s"]
    if t.get("chance") is not None:
        out["p"] = t["chance"]
    for k in ("skill", "skill_line", "text"):
        if t.get(k):
            out[k] = t[k]
    return out


def _fmt_num(v: float) -> str:
    return str(int(v)) if float(v).is_integer() else f"{v:g}"


def compact_effect(e: dict[str, Any]) -> str | dict[str, Any]:
    simple = (
        e["trigger"] is None
        and e["condition"] is None
        and e["duration_s"] is None
        and e["stacks"] is None
        and e["scope"] == "self"
        and not e.get("extra")
    )
    if simple and e["kind"] == "static" and e["value"] is not None:
        sign = "+" if e["value"] >= 0 else "-"
        unit = {"pct": "%", "seconds": "s"}.get(e["unit"] or "", "")
        return f"{e['stat']}{sign}{_fmt_num(abs(e['value']))}{unit}"
    if simple and e["kind"] == "buff_grant" and e["buff_ref"]:
        return f"+{e['buff_ref']}"

    out: dict[str, Any] = {"s": e["buff_ref"] or e["stat"]}
    if e["value"] is not None:
        out["v"] = e["value"]
    if e["unit"] in ("pct", "seconds"):
        out["u"] = e["unit"]
    out["k"] = e["kind"]
    if e["scope"] != "self":
        out["sc"] = e["scope"]
    for src, dst in (("condition", "c"), ("duration_s", "d"), ("stacks", "st"), ("damage", "dmg")):
        if e[src] not in (None, {}, []):
            out[dst] = e[src]
    tr = _compact_trigger(e["trigger"])
    if tr:
        out["tr"] = tr
    if e["uptime_est"] is not None:
        out["up"] = e["uptime_est"]
    if e.get("extra"):
        out["x"] = e["extra"]
    return out


def compact_bonus(b: dict[str, Any], keep_text: bool, signature: bool) -> dict[str, Any]:
    out: dict[str, Any] = {"p": b["pieces"]}
    if b["perfected"]:
        out["pf"] = 1
    fx = [compact_effect(e) for e in b["effects"] if e["kind"] != "unmodeled"]
    if fx:
        out["x"] = fx
    coverage = b.get("coverage", "none")
    flagged = b.get("game_check") in ("mismatch", "structure_diff")
    # Signature lines (5pc, monster 2pc, mythic, perfected) always keep their text:
    # drawbacks like Oakensoul's "unable to swap bars" carry no number, so the
    # normalizer can't be relied on to capture them.
    needs_text = signature or coverage != "full" or flagged or any(isinstance(f, dict) for f in fx)
    if keep_text and needs_text:
        out["tx"] = b["text"]
    elif coverage == "none":
        out["tx"] = b["text"]  # nothing else to go on
    if coverage != "full":
        out["cov"] = coverage
    if flagged:
        out["chk"] = "mismatch"
    return out


def compact_set(s: dict[str, Any], keep_text: bool) -> dict[str, Any]:
    out: dict[str, Any] = {"n": s["name"]}
    if s["id"] is not None:
        out["id"] = s["id"]
    out["t"] = s["type"]
    if s["source"]:
        out["src"] = s["source"]
    if s["class"]:
        out["cls"] = s["class"]
    slots = s["slots"]
    if slots["weights"]:
        out["w"] = "".join(w[0].upper() for w in slots["weights"])
    if slots["weapons"]:
        out["wp"] = ",".join(slots["weapons"])
    if slots["jewelry"]:
        out["j"] = 1
    if slots["head_shoulders"]:
        out["hs"] = 1
    if s["perfected_variant"]:
        out["pv"] = s["perfected_variant"]
    if s["perfected_of"]:
        out["pf_of"] = s["perfected_of"]
    if s["wiki_status"]:
        out["prov"] = 1
    out["b"] = [
        compact_bonus(b, keep_text, signature=b["pieces"] == s["max_pieces"] or b["perfected"])
        for b in s["bonuses"]
    ]
    return out


def build(types: set[str] | None, keep_text: bool) -> list[str]:
    sets = json.loads((DATA_DIR / "sets.json").read_text())["items"]
    lines = [json.dumps(LEGEND, ensure_ascii=False, separators=(",", ":"))]
    for s in sets:
        if s["deprecated"] or (types and s["type"] not in types):
            continue
        lines.append(
            json.dumps(compact_set(s, keep_text), ensure_ascii=False, separators=(",", ":"))
        )
    return lines


def run(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(prog="setdb digest", description=__doc__.split("\n\n")[0])
    ap.add_argument("--types", help="comma-separated set types to include (default: all)")
    ap.add_argument(
        "--no-text", action="store_true", help="drop bonus text except where coverage is none"
    )
    ap.add_argument("--out", help=f"output path (default: {OUT.relative_to(DATA_DIR.parents[1])})")
    args = ap.parse_args(argv)

    types = {t.strip() for t in args.types.split(",")} if args.types else None
    lines = build(types, keep_text=not args.no_text)
    out = OUT if not args.out else __import__("pathlib").Path(args.out)
    out.write_text("\n".join(lines) + "\n")
    size = out.stat().st_size
    print(
        f"✓ digest: {len(lines) - 1} sets, {size / 1024:.0f} KB (~{size // 4 // 1000}k tokens) -> {out}",
        file=sys.stderr,
    )
    return 0
