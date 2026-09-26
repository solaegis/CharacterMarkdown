"""Phase 3: reconcile the in-game set dump with the wiki-derived sets.

`/cm sets:dump` + `/reloadui` writes CharacterMarkdownSetDump into
SavedVariables/CharacterMarkdown.lua. `import` copies it to
data/sets/raw/game/setdump.json (gitignored — game client text); `parse` then
calls `reconcile()` before normalizing, so:

- every matched set gets its in-game `id` and quality tier;
- every bonus line is verified against the game (`bonus.game_check`); the wiki's
  CP160 gold text is kept, since the game renders default-quality values;
- sets the game has but the wiki lacks become new records (`wiki: null`);
- provisional wiki pages (UESP hasn't filled them in) take the game's bonuses,
  with values mapped back to gold where the mapping is known.
"""

from __future__ import annotations

import json
import os
import re
import sys
import unicodedata
from pathlib import Path
from typing import Any

from .paths import RAW_DIR, slugify

GAME_DUMP = RAW_DIR / "game" / "setdump.json"
DEFAULT_SV = (
    Path.home()
    / "Documents"
    / "Elder Scrolls Online"
    / "live"
    / "SavedVariables"
    / "CharacterMarkdown.lua"
)
SV_GLOBAL = "CharacterMarkdownSetDump"

# ESO API ItemSetType values are enum ints whose numbering isn't documented;
# the collection category path is the readable type signal.
CATEGORY_TYPES = [
    (r"\bMythic", "mythic"),
    (r"\bMonster", "monster"),
    (r"\bClass\b", "class"),
    (r"\bTrial", "trial"),
    (r"\bArena", "arena"),
    (r"\bDungeon", "dungeon"),
    (r"Cyrodiil|Imperial City|Battleground|PvP", "pvp"),
    (r"\bOverland|\bZone", "overland"),
    (r"Craft", "crafted"),
]


# --- SavedVariables (Lua table literal) reader ------------------------------------

_TOKEN = re.compile(
    r'\s*(?:(?P<str>"(?:[^"\\]|\\.)*")|(?P<num>-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?)|'
    r"(?P<kw>true|false|nil)|(?P<name>[A-Za-z_]\w*)|(?P<sym>[{}\[\]=,;]))",
    re.S,
)
_ESCAPES = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\", "'": "'"}


class LuaReader:
    """Just enough Lua to read ESO SavedVariables (tables, strings, numbers, bools)."""

    def __init__(self, text: str) -> None:
        self.text = text
        self.pos = 0

    def _next(self) -> tuple[str, str]:
        m = _TOKEN.match(self.text, self.pos)
        if not m:
            raise ValueError(
                f"unexpected Lua at {self.pos}: {self.text[self.pos : self.pos + 40]!r}"
            )
        self.pos = m.end()
        kind = m.lastgroup or ""
        return kind, m.group(kind)

    def _peek(self) -> tuple[str, str]:
        save = self.pos
        tok = self._next()
        self.pos = save
        return tok

    def value(self) -> Any:
        kind, tok = self._next()
        if kind == "str":
            return re.sub(r"\\(.)", lambda m: _ESCAPES.get(m.group(1), m.group(1)), tok[1:-1])
        if kind == "num":
            v = float(tok)
            return int(v) if v.is_integer() and "." not in tok else v
        if kind == "kw":
            return {"true": True, "false": False, "nil": None}[tok]
        if tok == "{":
            return self._table()
        raise ValueError(f"unexpected token {tok!r} at {self.pos}")

    def _table(self) -> Any:
        out: dict[Any, Any] = {}
        auto = 1
        while True:
            kind, tok = self._peek()
            if tok == "}":
                self._next()
                break
            if tok == "[":
                self._next()
                key = self.value()
                self._expect("]")
                self._expect("=")
                out[key] = self.value()
            elif kind == "name" and self._is_assignment():
                self._next()
                self._expect("=")
                out[tok] = self.value()
            else:
                out[auto] = self.value()
                auto += 1
            if self._peek()[1] in (",", ";"):
                self._next()
        # contiguous 1..n integer keys -> list
        if (
            out
            and all(isinstance(k, int) for k in out)
            and sorted(out) == list(range(1, len(out) + 1))
        ):
            return [out[i] for i in range(1, len(out) + 1)]
        return out

    def _is_assignment(self) -> bool:
        save = self.pos
        self._next()
        nxt = self._peek()[1]
        self.pos = save
        return nxt == "="

    def _expect(self, sym: str) -> None:
        _, tok = self._next()
        if tok != sym:
            raise ValueError(f"expected {sym!r}, got {tok!r} at {self.pos}")

    def global_assignment(self, name: str) -> Any:
        m = re.search(rf"^{re.escape(name)}\s*=\s*", self.text, re.M)
        if not m:
            return None
        self.pos = m.end()
        return self.value()


def read_sv_dump(path: Path) -> dict[str, Any] | None:
    return LuaReader(path.read_text(encoding="utf-8", errors="replace")).global_assignment(
        SV_GLOBAL
    )


# --- text normalization -----------------------------------------------------------


def strip_markup(text: str) -> str:
    """Remove ESO color (|cRRGGBB…|r) and texture (|t…|t) markup."""
    t = re.sub(r"\|c[0-9a-fA-F]{6}", "", text)
    t = t.replace("|r", "")
    t = re.sub(r"\|t[^|]*\|t", "", t)
    return re.sub(r"\s+", " ", t).strip()


def name_key(name: str) -> str:
    n = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode().lower()
    n = re.sub(r"\s*\(set\)$", "", n)
    return re.sub(r"[^a-z0-9]+", "", n)


_PIECES_PREFIX = re.compile(r"^\(\d+\s+(?:perfected\s+)?items?\)\s*", re.I)
_NUM = re.compile(r"(\d+(?:\.\d+)?)(?:-(\d+(?:\.\d+)?))?")
# Tooltips for these are computed from the dumping character's own stats
_CHARACTER_SCALED = re.compile(r"scales? off|based on (?:the higher of )?your|equal to", re.I)
# Proc damage / heal / restore / shield tooltips are computed from the character's stats
# even when the text doesn't say so
_PROC_PAYLOAD = re.compile(
    r"\b(?:Flame|Fire|Frost|Shock|Magic|Physical|Poison|Disease|Bleed|Oblivion) [Dd]amage\b|"
    r"\bheal(?:s|ing)?\b[^.]*\bHealth\b|\brestor(?:e|es|ing)\b|\bdamage shield\b|\babsorbs\b",
    re.I,
)
# "Current bonus: 0" is a live readout of the dumping character's state
_LIVE_READOUT = re.compile(r"\bCurrent\b[^.]*$", re.I)
TIER_TOLERANCE = 0.02
# game value -> gold value is trusted when this share of observations agree
INVERSE_MIN_SHARE = 0.9


def numbers(text: str) -> list[float]:
    """Comparable numbers: CP160 upper end of 'a-b' ranges, as floats."""
    return [float(m.group(2) or m.group(1)) for m in _NUM.finditer(text)]


def wiki_numbers(text: str) -> list[tuple[float, bool]]:
    """(CP160 gold value, is a level-scaled range) per number."""
    return [(float(m.group(2) or m.group(1)), bool(m.group(2))) for m in _NUM.finditer(text)]


def game_bonus_text(b: dict[str, Any]) -> str:
    """Game bonus text without markup or its leading '(2 items)' label."""
    raw = "".join(b["textParts"]) if b.get("textParts") else (b.get("text") or "")
    return _PIECES_PREFIX.sub("", strip_markup(raw))


def category_type(category: str | None) -> str | None:
    if not category:
        return None
    # the leaf decides ("Dungeons & Trials > Dungeons" is a dungeon); path is a fallback
    for text in (category.split(" > ")[-1], category):
        for rx, t in CATEGORY_TYPES:
            if re.search(rx, text, re.I):
                return t
    return None


# --- reconcile --------------------------------------------------------------------
#
# The game renders set bonuses at each set's default drop quality, not gold: every
# level-scaled value in a set shares one ratio to the wiki's CP160 gold value
# (crafted ~0.87, overland ~0.91, dungeon ~0.94, trial/monster ~0.96-0.97). Proc
# and heal tooltips are computed from the dumping character's stats. So the dump
# *verifies* the wiki rather than replacing it:
#   - ranged values must sit on the set's single tier;
#   - fixed values must match, unless the line scales off the character;
#   - the wiki's gold text is kept; mismatches are flagged with the game text.
# Only where the wiki has nothing usable (provisional pages, game-only sets) is
# game text used, with values mapped back to gold via observed pairs.


def load_dump() -> dict[str, Any] | None:
    try:
        return json.loads(GAME_DUMP.read_text())
    except FileNotFoundError:
        return None


def _grouped(bonuses: list[dict[str, Any]]) -> dict[tuple[int, bool], list[dict[str, Any]]]:
    """Bonus lines by (pieces, perfected), in order — a set can have several 5pc lines."""
    out: dict[tuple[int, bool], list[dict[str, Any]]] = {}
    for b in bonuses:
        out.setdefault((b["pieces"], bool(b.get("perfected"))), []).append(b)
    return out


def _pairs(s: dict[str, Any], g: dict[str, Any]):
    """Yield (wiki bonus, game text) for lines present in both, paired in order."""
    wiki = _grouped(s["bonuses"])
    for key, game_lines in _grouped(g.get("bonuses", [])).items():
        for b, gb in zip(wiki.get(key, []), game_lines, strict=False):
            yield b, game_bonus_text(gb)


def reconcile(sets: list[dict[str, Any]], dump: dict[str, Any]) -> dict[str, Any]:
    """Mutate `sets` in place with game data; return a report."""
    meta = dump.get("meta", {})
    report: dict[str, Any] = {
        "meta": meta,
        "matched": 0,
        "lines_verified": 0,
        "lines_character_scaled": 0,
        "mismatches": [],
        "structure_diffs": [],
        "mixed_tier_sets": [],
        "game_only": [],
        "wiki_only": [],
        "filled_from_game": [],
        "tiers": {},
    }

    by_key = {name_key(s["name"]): s for s in sets}
    matched: list[tuple[dict[str, Any], dict[str, Any]]] = []
    game_only: list[dict[str, Any]] = []
    for g in sorted(dump.get("sets", []), key=lambda x: x["id"]):
        s = by_key.get(name_key(g["name"]))
        (matched.append((s, g)) if s else game_only.append(g))

    # pass 1: per-set tier, and game-value -> gold-value observations
    tiers: dict[str, float] = {}
    inverse: dict[float, dict[float, int]] = {}
    for s, g in matched:
        if s["wiki_status"]:
            continue
        ratios = []
        for b, text in _pairs(s, g):
            wn, gn = wiki_numbers(b["text"]), numbers(text)
            if len(wn) != len(gn):
                continue
            for (wv, ranged), gv in zip(wn, gn, strict=True):
                if ranged and wv >= 100:  # small values round too coarsely to date a tier
                    ratios.append(gv / wv)
                if ranged:
                    inverse.setdefault(gv, {}).setdefault(wv, 0)
                    inverse[gv][wv] += 1
        if ratios:
            ratios.sort()
            tiers[s["slug"]] = ratios[len(ratios) // 2]
            if ratios[-1] - ratios[0] > TIER_TOLERANCE:
                report["mixed_tier_sets"].append(
                    f"{s['name']}: ratios {sorted({round(r, 2) for r in ratios})}"
                )
    gold = {
        gv: max(c, key=c.get)
        for gv, c in inverse.items()
        if max(c.values()) / sum(c.values()) >= INVERSE_MIN_SHARE
    }

    # pass 2: annotate
    seen: set[str] = set()
    for s, g in matched:
        seen.add(name_key(s["name"]))
        report["matched"] += 1
        s["id"] = g["id"]
        s["game"] = {
            "api_type": g.get("apiType"),
            "category": g.get("category"),
            "libsets_type": g.get("libSetsType"),
            "max_equipped": g.get("maxEquipped"),
            "tier": round(tiers[s["slug"]], 3) if s["slug"] in tiers else None,
        }
        ctype = category_type(g.get("category"))
        if ctype and (s["type"] == "special" or s["wiki_status"]):
            s["type"] = ctype
        if s["wiki_status"] or not s["bonuses"]:
            s["bonuses"] = [_bonus(gb, gold) for gb in g.get("bonuses", [])]
            s["max_pieces"] = max((b["pieces"] for b in s["bonuses"]), default=0)
            report["filled_from_game"].append(s["name"])
            continue
        _verify(s, g, tiers.get(s["slug"]), gold, report)

    for g in game_only:
        new = _record_from_game(g, gold)
        sets.append(new)
        report["game_only"].append(f"{g['name']} (id {g['id']})")
        seen.add(name_key(g["name"]))
    for s in sets:
        if name_key(s["name"]) not in seen and not s["deprecated"]:
            report["wiki_only"].append(s["name"])
    report["tiers"] = _tier_summary(sets)
    sets.sort(key=lambda x: x["slug"])
    return report


def _verify(
    s: dict[str, Any],
    g: dict[str, Any],
    tier: float | None,
    gold: dict[float, float],
    report: dict[str, Any],
) -> None:
    label = s["name"]
    wiki = _grouped(s["bonuses"])
    appended = False
    for key, game_lines in _grouped(g.get("bonuses", [])).items():
        have = len(wiki.get(key, []))
        for gb in game_lines[have:]:
            s["bonuses"].append(_bonus(gb, gold))
            appended = True
            report["structure_diffs"].append(
                f"{label} {gb['pieces']}pc: line missing on wiki (added from game)"
            )
        if have > len(game_lines):
            report["structure_diffs"].append(
                f"{label} {key[0]}pc: wiki has {have} lines, game has {len(game_lines)}"
            )
    if appended:  # keep the wiki's line order otherwise
        s["bonuses"].sort(key=lambda b: (b["pieces"], b["perfected"]))

    for b, text in _pairs(s, g):
        tag = f"{label} {b['pieces']}pc{' (perfected)' if b['perfected'] else ''}"
        wn, gn = wiki_numbers(b["text"]), numbers(text)
        if len(wn) != len(gn):
            b["game_check"], b["game_text"] = "structure_diff", text
            report["structure_diffs"].append(
                f"{tag}: wiki `{b['text'][:90]}` vs game `{text[:90]}`"
            )
            continue
        scaled_by_character = bool(
            _CHARACTER_SCALED.search(b["text"]) or _PROC_PAYLOAD.search(b["text"])
        )
        live = _LIVE_READOUT.search(b["text"])
        live_from = len(wiki_numbers(b["text"][: live.start()])) if live else len(wn)
        problems = []
        for i, ((wv, ranged), gv) in enumerate(zip(wn, gn, strict=True)):
            if i >= live_from:
                continue  # live counter, not a bonus value
            if ranged:
                # integer rounding: 15 x 0.91 = 13.65 is shown as 14
                if tier is not None and wv and abs(gv - wv * tier) > max(1.0, TIER_TOLERANCE * wv):
                    problems.append(f"{wv:g}→{gv:g} off tier {tier:.2f}")
            elif wv != gv and not scaled_by_character:
                problems.append(f"{wv:g}≠{gv:g}")
        if problems:
            b["game_check"], b["game_text"] = "mismatch", text
            report["mismatches"].append(f"{tag}: {', '.join(problems)} — game `{text[:110]}`")
        else:
            b["game_check"] = "verified"
            report["lines_verified"] += 1
            if scaled_by_character and any(
                not r and w != v for (w, r), v in zip(wn, gn, strict=True)
            ):
                report["lines_character_scaled"] += 1


def _to_gold(text: str, gold: dict[float, float]) -> tuple[str, bool]:
    changed = False

    def sub(m: re.Match[str]) -> str:
        nonlocal changed
        v = float(m.group(0))
        if v in gold and gold[v] != v:
            changed = True
            g = gold[v]
            return str(int(g)) if g.is_integer() else str(g)
        return m.group(0)

    return re.sub(r"\d+(?:\.\d+)?", sub, text), changed


def _tier_summary(sets: list[dict[str, Any]]) -> dict[str, float]:
    by_type: dict[str, list[float]] = {}
    for s in sets:
        t = (s.get("game") or {}).get("tier")
        if t:
            by_type.setdefault(s["type"], []).append(t)
    return {k: round(sorted(v)[len(v) // 2], 3) for k, v in sorted(by_type.items())}


def _bonus(gb: dict[str, Any], gold: dict[float, float]) -> dict[str, Any]:
    """A bonus from game text, with level-scaled values mapped back to gold where known."""
    text, rescaled = _to_gold(game_bonus_text(gb), gold)
    return {
        "pieces": gb["pieces"],
        "perfected": bool(gb.get("perfected")),
        "text": text,
        "wikitext": text,
        "links": [],
        "effects": [],
        "source": "game",
        "game_values": "mapped_to_gold" if rescaled else "as_rendered",
    }


def _record_from_game(g: dict[str, Any], gold: dict[float, float]) -> dict[str, Any]:
    bonuses = [_bonus(gb, gold) for gb in g.get("bonuses", [])]
    classes = g.get("classes")
    return {
        "id": g["id"],
        "slug": slugify(g["name"]),
        "name": g["name"],
        "uesp": None,
        "wiki": None,
        "type": category_type(g.get("category")) or "special",
        "class": classes or None,
        "source": None,
        "dlc": None,
        "added_in": [],
        "deprecated": False,
        "wiki_status": ["not_on_wiki"],
        "slots": {
            "settype": None,
            "weights": [],
            "weapons": [],
            "jewelry": False,
            "head_shoulders": False,
        },
        "max_pieces": max((b["pieces"] for b in bonuses), default=0),
        "perfected_of": None,
        "perfected_variant": None,
        "tags": [],
        "bonuses": bonuses,
        "roles": [],
        "pros": [],
        "cons": [],
        "confidence": "auto",
        "game": {
            "api_type": g.get("apiType"),
            "category": g.get("category"),
            "libsets_type": g.get("libSetsType"),
            "max_equipped": g.get("maxEquipped"),
            "tier": None,
        },
    }


# --- CLI: import ------------------------------------------------------------------


def run_import(argv: list[str]) -> int:
    sv = Path(argv[0]).expanduser() if argv else Path(os.environ.get("ESO_SV", DEFAULT_SV))
    if not sv.exists():
        print(f"SavedVariables not found: {sv}\n(pass a path, or set ESO_SV)", file=sys.stderr)
        return 1
    dump = read_sv_dump(sv)
    if not dump or not dump.get("sets"):
        print(
            f"No {SV_GLOBAL} in {sv}.\n"
            "In game: /cm sets:dump, wait for 'Set dump complete', then /reloadui.",
            file=sys.stderr,
        )
        return 1
    meta = dump.get("meta", {})
    GAME_DUMP.parent.mkdir(parents=True, exist_ok=True)
    GAME_DUMP.write_text(json.dumps(dump, ensure_ascii=False, indent=1) + "\n")
    print(
        f"✓ imported {len(dump['sets'])} sets (API {meta.get('apiVersion')}, "
        f"CP {meta.get('championPoints')}, {meta.get('language')}) -> {GAME_DUMP}",
        file=sys.stderr,
    )
    return 0
