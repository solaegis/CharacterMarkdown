"""Support tables: passives, skills, consumables and CP stars from the UESP wiki.

These feed marginal-value build math next to the set database. See
docs/SET_SUPPORT_TABLES.md for the contract and the in-game spot-check list.

  fetch  skill-line, skill, CP-star and food pages -> data/sets/raw/wiki/support_tables/
  parse  cached pages -> data/sets/{passives,skills,consumables,cp_stars}.json,
         buff sources merged into buffs.json, report in reports/support_tables.md

Effects reuse the set-bonus normalizer, so they follow the same `$defs/effect`
contract. A row is `verified: true` only when its numbers came straight from the
cited UESP page and every line normalized with full coverage; anything partial
stays a draft and is listed in the report. Damage and healing coefficients are
never stored: skills keep buffs, debuffs, cost, resource and non-buff stat grants.
"""

from __future__ import annotations

import html
import json
import re
import sys
import urllib.parse
from pathlib import Path
from typing import Any

from .fetch import _load, _save, sync_pages
from .normalize import build_ctx, normalize_bonus, split_sentences
from .paths import DATA_DIR, REPO_ROOT, REPORTS_DIR, WIKI_CACHE, slugify
from .wikitext import find_templates, splice_fragments, to_plain

CACHE = WIKI_CACHE / "support_tables"
CP_YAML = REPO_ROOT / "examples" / "templates" / "champion_points.yaml"
PATCH = "u51"
SCHEMA_VERSION = 1

LINE_CATEGORIES = {
    "Category:Online-Skill Lines-Race": "race",
    "Category:Online-Skill Lines-Class": "class",
    "Category:Online-Skill Lines-Weapon": "skill_line",
    "Category:Online-Skill Lines-Armor": "skill_line",
    "Category:Online-Skill Lines-World": "skill_line",
    "Category:Online-Skill Lines-Alliance War": "skill_line",
    "Category:Online-Skill Lines-Guild": "guild",
}

CLASS_LINES = {
    "Dragonknight": ["Ardent Flame", "Draconic Power", "Earthen Heart"],
    "Nightblade": ["Assassination", "Shadow", "Siphoning"],
    "Sorcerer": ["Daedric Summoning", "Dark Magic", "Storm Calling"],
    "Templar": ["Aedric Spear", "Dawn's Wrath", "Restoring Light"],
    "Warden": ["Animal Companions", "Green Balance", "Winter's Embrace"],
    "Necromancer": ["Grave Lord", "Bone Tyrant", "Living Death"],
    "Arcanist": ["Herald of the Tome", "Soldier of Apocrypha", "Curative Runeforms"],
}
LINE_CLASS = {line: cls for cls, lines in CLASS_LINES.items() for line in lines}

# Food and drink the plans quote. UESP computes the effect line from the recipe
# id, so these are fetched rendered (action=parse) rather than as wikitext.
CONSUMABLES = {
    "Solitude Salmon-Millet Soup": "food",
    "Garlic Cod with Potato Crust": "food",
    "Artaeum Pickled Fish Bowl": "food",
    "Bewitched Sugar Skulls": "food",
    "Clockwork Citrus Filet": "food",
    "Jewels of Misrule": "food",
    "Orzorga's Smoked Bear Haunch": "food",
    "Orzorga's Tripe Trifle Pocket": "food",
    "Pack Leader's Bone Broth": "food",
    "Old Aldmeri Orphan Gruel": "food",
    "Artaeum Takeaway Broth": "drink",
    "Ghastly Eye Bowl": "drink",
    "Lava Foot Soup-and-Saltrice": "drink",
    "Witchmother's Potent Brew": "drink",
    "Dubious Camoran Throne": "drink",
    "Orzorga's Red Frothgar": "drink",
    "Candied Jester's Coins": "drink",
}

# U51 alchemy. UESP has no per-potion pages for the merged traits yet, so these
# are drafts: buffs only (restore amounts depend on solvent and are left out).
POTIONS: list[dict[str, Any]] = [
    {
        "name": "Essence of Heroism",
        "buffs": ["major_brutality", "major_savagery"],
        "notes": "U51 merged Weapon/Spell Power and Weapon/Spell Critical. The tri-stat "
        "damage potion that replaced Essence of Spell Power / Weapon Power. Name and "
        "exact trait mix from third-party U51 summaries; check in game.",
    },
    {
        "name": "Essence of Health",
        "buffs": ["major_fortitude"],
        "notes": "Restore Health + Major Fortitude (Health Recovery).",
    },
    {
        "name": "Essence of Magicka",
        "buffs": ["major_intellect"],
        "notes": "Restore Magicka + Major Intellect (Magicka Recovery).",
    },
    {
        "name": "Essence of Stamina",
        "buffs": ["major_endurance"],
        "notes": "Restore Stamina + Major Endurance (Stamina Recovery).",
    },
    {
        "name": "Essence of Immovability",
        "buffs": ["major_resolve"],
        "notes": "Restore Health + Major Resolve + Immovable. Pre-U51 tri-stat tank "
        "potion; trait mix unchanged in the U51 summaries.",
    },
]

_SECTION_RE = re.compile(r"^=+\s*(.*?)\s*=+\s*$", re.M)
_RANKS_RE = re.compile(r"\[\s*(-?\d+(?:\.\d+)?)(?:\s*/\s*-?\d+(?:\.\d+)?)+\s*\]")
_RANKS_LAST_RE = re.compile(r"\[\s*(?:-?\d+(?:\.\d+)?\s*/\s*)+(-?\d+(?:\.\d+)?)\s*\]")
_HEADER_RE = re.compile(
    r"^(?:(?:Cost|Duration|Area|Range|Radius|Target|Cast Time|Channel Time)\s*:[^\n]*)$", re.I
)
_COST_NOTE_RE = re.compile(r"^Cost Determined by Highest Max Resource\s*", re.I)
_COST_RE = re.compile(r"(\d[\d,]*)\s+(Magicka|Stamina|Health|Ultimate)\b", re.I)
_BUFF_RE = re.compile(
    r"\b(Major|Minor)\s+([A-Z][a-z]+)((?:(?:,\s*|,?\s+and\s+)(?!Major\b|Minor\b)[A-Z][a-z]+)*)"
)
# Pre-U51 buff names that may still appear in stale text.
U51_ALIAS = {"sorcery": "brutality", "prophecy": "savagery"}


# --- fetch ---------------------------------------------------------------------


def _page_url(title: str) -> str:
    name = title.split(":", 1)[-1].replace(" ", "_")
    return "https://en.uesp.net/wiki/Online:" + urllib.parse.quote(name, safe="_'(),-")


def _sections(wikitext: str) -> dict[str, list[str]]:
    """Skill links on a skill-line page grouped as passive / active / ultimate."""
    out: dict[str, list[str]] = {"passive": [], "active": [], "ultimate": []}
    heads = list(_SECTION_RE.finditer(wikitext))
    for i, h in enumerate(heads):
        name = h.group(1).lower()
        kind = next((k for k in out if k in name), None)
        if kind is None:
            continue
        body = wikitext[h.end() : heads[i + 1].start() if i + 1 < len(heads) else len(wikitext)]
        for tpl in find_templates(body, "Online Skill Link"):
            pos = tpl.positional()
            if pos and pos[0] not in out[kind]:
                out[kind].append(pos[0])
    return out


def _cp_stars() -> list[dict[str, Any]]:
    import yaml

    doc = yaml.safe_load(CP_YAML.read_text())
    stars = []
    for constellation in ("craft", "warfare", "fitness"):
        for star in doc.get(constellation) or []:
            stars.append({**star, "constellation": constellation})
    return stars


def _rendered(client: Any, title: str, dest: Path) -> dict[str, Any] | None:
    """Rendered page text (for recipes, whose effect line is computed)."""
    path = dest / f"{slugify(title)}.json"
    cached = _load(path)
    latest = client.latest_revids([title])
    if title not in latest:
        return None
    if cached and cached.get("revid") == latest[title]:
        return cached
    data = client.call(action="parse", page=title, prop="text|revid")["parse"]
    text = re.sub(r"<(script|style)[^>]*>.*?</\1>", "", data["text"], flags=re.S)
    text = html.unescape(re.sub(r"<[^>]+>", " ", text))
    rec = {
        "title": title,
        "pageid": data["pageid"],
        "revid": data["revid"],
        "text": re.sub(r"\s+", " ", text).strip(),
    }
    _save(path, rec)
    return rec


def _resolve(client: Any, titles: list[str]) -> dict[str, str]:
    """Map each title to its redirect target (titles that aren't redirects map to themselves)."""
    out = {t: t for t in titles}
    for i in range(0, len(titles), 50):
        chunk = titles[i : i + 50]
        data = client.call(action="query", titles="|".join(chunk), redirects="1")
        q = data.get("query", {})
        norm = {n["from"]: n["to"] for n in q.get("normalized", [])}
        redir = {r["from"]: r["to"].split("#")[0] for r in q.get("redirects", [])}
        for t in chunk:
            n = norm.get(t, t)
            out[t] = redir.get(n, n)
    return out


def fetch() -> int:
    from .wiki import WikiClient

    client = WikiClient()
    index: dict[str, Any] = {"lines": {}}
    titles: dict[str, str] = {}
    for cat, category in LINE_CATEGORIES.items():
        for t in client.category_members(cat, namespace=144):
            if "(Companion)" not in t:
                titles[t] = category
    print(f"skill lines: {len(titles)}", file=sys.stderr)
    lines, n = sync_pages(client, sorted(titles), CACHE / "lines", "fragments")
    print(f"  fetched {n}", file=sys.stderr)

    skill_titles: set[str] = set()
    for rec in lines:
        sec = _sections(rec["wikitext"])
        name = rec["title"].split(":", 1)[1]
        index["lines"][name] = {
            "category": titles[rec["title"]],
            "class": LINE_CLASS.get(name),
            **sec,
        }
        skill_titles.update(f"Online:{s}" for k in sec for s in sec[k])
    aliases = _resolve(client, sorted(skill_titles))
    index["aliases"] = {k: v for k, v in aliases.items() if k != v}
    print(f"skills: {len(skill_titles)} ({len(index['aliases'])} redirects)", file=sys.stderr)
    _, n = sync_pages(client, sorted(set(aliases.values())), CACHE / "skills", "fragments")
    print(f"  fetched {n}", file=sys.stderr)

    stars = _cp_stars()
    # Star names that collide with skills or achievements live at "<name> (champion)"
    cp_titles = {f"Online:{s['name']}" for s in stars}
    cp_titles |= {f"{t} (champion)" for t in cp_titles}
    _, n = sync_pages(client, sorted(cp_titles), CACHE / "cp", "fragments")
    print(f"cp stars: {len(stars)} (fetched {n})", file=sys.stderr)

    for title in CONSUMABLES:
        _rendered(client, f"Online:{title}", CACHE / "consumables")
    print(f"consumables: {len(CONSUMABLES)}", file=sys.stderr)

    _save(CACHE / "index.json", index)
    print(f"{client.request_count} requests", file=sys.stderr)
    return 0


# --- text -----------------------------------------------------------------------


def _max_rank(text: str) -> str:
    """'[27 / 28 / 29 / 30]' -> '30' (rank IV, the value the plans quote)."""
    return _RANKS_LAST_RE.sub(r"\1", text)


def _plain(raw: str, page: dict[str, Any]) -> tuple[str, str]:
    """Return (header, body): the 'Cost: … / Duration: …' prefix line and the tooltip."""
    text = _max_rank(to_plain(splice_fragments(raw, page.get("fragments", {})), br="\n"))
    lines = [ln.strip() for ln in text.split("\n") if ln.strip()]
    header = [ln for ln in lines[:1] if _HEADER_RE.match(ln)]
    body = _COST_NOTE_RE.sub("", " ".join(lines[len(header) :])).strip()
    return (header[0] if header else ""), body


# Passive phrasing the set-bonus grammar doesn't cover, rewritten to a form it does.
REWRITES: list[tuple[re.Pattern[str], str]] = [
    # "Reduces the Magicka cost of your abilities by 7%"
    (
        re.compile(r"\b(reduc\w*|lower\w*) the (Magicka|Stamina|Health) costs? of (your )?", re.I),
        r"\1 the cost of \3\2 ",
    ),
    (
        re.compile(
            r"\b(?:Physical Penetration and Spell Penetration|Spell and Physical Penetration)"
        ),
        "Offensive Penetration",
    ),
    # "gain Major Savagery, increasing Critical Chance by 12% and your Max Magicka is
    # increased by 5%": the second clause is its own grant, not the buff's explainer
    (
        re.compile(
            r"\b((?:Major|Minor) [A-Z][a-z]+, (?:increasing|reducing) [^.]*?by \d+(?:\.\d+)?%?)"
            r" and your "
        ),
        r"\1. Your ",
    ),
    (re.compile(r"\bCritical Chance rating\b"), "Critical Chance"),
    # "grants you and your group 2974 Offensive Penetration for 20 seconds"
    (
        re.compile(
            r"\bgrants? (you and your group|you|your group) (\d+(?:\.\d+)?)(%?) ([A-Z][\w ]+?)"
            r"(?= for| while|[.,])"
        ),
        r"increases the \4 of \1 by \2\3",
    ),
]


def _rewrite(text: str) -> str:
    for rx, repl in REWRITES:
        text = rx.sub(repl, text)
    return text


# UESP prefixes gated passives with an all-caps clause ("WITH BOW EQUIPPED ...").
_GATE_RE = re.compile(r"^((?:WITH|WHILE|WHEN)\b[A-Z0-9' ,\-]*?[A-Z])\s+(?=[A-Z][a-z])")
_GATES: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"^WITH (?:AN? )?(.+?) ABILIT(?:Y|IES) (?:SLOTTED|ACTIVE)$"), "skill_slotted"),
    (re.compile(r"^WHEN (?:AN? )?(.+?) ABILITY IS SLOTTED$"), "skill_slotted"),
    (re.compile(r"^WITH (?:AN? |TWO )?(.+?) EQUIPPED$"), "weapon_equipped"),
    (re.compile(r"^WHILE (?:USING )?(DUAL WIELD)(?:ING)?(?: ATTACKS)?$"), "weapon_equipped"),
    (re.compile(r"^WHILE YOU ARE IN (WEREWOLF) FORM$"), "werewolf"),
]


# Mixed-case gates the set grammar doesn't know: (pattern, condition, replacement).
_SOFT_GATES: list[tuple[re.Pattern[str], dict[str, Any], str]] = [
    (
        re.compile(r"^While slotted(?: on either (?:ability )?bar)?,?\s+(?:you )?(gain)\b", re.I),
        {"type": "slotted"},
        "Gain",
    ),
    (
        re.compile(r"^While slotted(?: on either (?:ability )?bar)?,?\s*", re.I),
        {"type": "slotted"},
        "",
    ),
    (re.compile(r"^While transformed,?\s*", re.I), {"type": "transformed"}, ""),
    (re.compile(r"^While channeling,?\s*", re.I), {"type": "channeled"}, ""),
    (
        re.compile(r"^While you are at Vampire Stage (\d)(?: or higher)?,?\s*", re.I),
        {"type": "vampire_stage"},
        "",
    ),
    (
        re.compile(
            r"^While an? (?:beneficial )?([A-Z][\w' ]+?) ability is active(?: on you)?,?\s*"
        ),
        {"type": "skill_active"},
        "",
    ),
]


def _gate(text: str) -> tuple[dict[str, Any] | None, str]:
    """Split a gate clause off the tooltip -> (condition, rest)."""
    for rx, cond, repl in _SOFT_GATES:
        g = rx.match(text)
        if g:
            c = dict(cond)
            if g.groups() and g.group(1) and not repl:
                c["value"] = int(g.group(1)) if g.group(1).isdigit() else g.group(1)
            rest = repl + text[g.end() :]
            return c, rest[:1].upper() + rest[1:]
    m = _GATE_RE.match(text)
    if not m:
        return None, text
    clause, rest = m.group(1), text[m.end() :]
    for rx, ctype in _GATES:
        g = rx.match(clause)
        if g:
            value = g.group(1).title().replace("'S", "'s")
            cond = {"type": ctype} if ctype == "werewolf" else {"type": ctype, "value": value}
            return cond, rest
    return {"type": "text", "text": clause.lower()}, rest


_WEAPON_TYPE_RE = re.compile(r"^(?:Each )?(sword|axe|mace|dagger)s?\b", re.I)
_MODELABLE = re.compile(r"\d|\b(?:Major|Minor) [A-Z]")


def _normalize(
    text: str, ctx: Any, tag: bool = False
) -> tuple[list[dict[str, Any]], str, list[str]]:
    if not text:
        return [], "full", []
    # A gate opens a segment that runs until the next gated sentence.
    segments: list[tuple[dict[str, Any] | None, list[str]]] = []
    base: dict[str, Any] | None = None
    split = re.sub(r":\s+(?=(?:Each )?(?:Sword|Axe|Mace|Dagger))", ". ", text, flags=re.I)
    for sentence in split_sentences(split):
        gate, rest = _gate(sentence)
        if gate:
            base = gate
        # "Swords increase … Axes increase …": one alternative per weapon type
        wt = _WEAPON_TYPE_RE.match(rest)
        if wt:
            cond = {"type": "weapon_type", "value": wt.group(1).lower()}
            gate = cond if base is None else {"type": "all", "of": [base, cond]}
            segments.append((gate, []))
        elif gate or not segments or segments[-1][0] is not base:
            segments.append((base, []))
        # Number-free sentences without a named buff are flavour text or mechanics
        # with nothing to model ("Rock and stone shield your heart ...").
        if _MODELABLE.search(rest):
            segments[-1][1].append(rest)
    effects: list[dict[str, Any]] = []
    issues: list[str] = []
    coverage = "full"
    rank = {"full": 0, "partial": 1, "none": 2}
    for gate, sentences in segments:
        if not sentences:
            continue
        e, c, i = _normalize_segment(" ".join(sentences), gate, ctx)
        if tag:
            for x in e:
                x["_coverage"] = c  # per sentence group; the caller pops it
        effects += e
        issues += i
        coverage = max(coverage, c, key=rank.__getitem__)
    for e in effects:
        e["raw"] = text
    return _tidy(effects, text), coverage, issues


def _normalize_segment(
    body: str, gate: dict[str, Any] | None, ctx: Any
) -> tuple[list[dict[str, Any]], str, list[str]]:
    effects, coverage, issues = normalize_bonus(_rewrite(body), ctx)
    for e in effects:
        if gate and e["kind"] != "unmodeled":
            c = e["condition"]
            e["condition"] = dict(gate) if c is None else {"type": "all", "of": [gate, c]}
            if e["kind"] == "static":
                e["kind"] = "conditional"
    if gate and gate["type"] == "text" and coverage == "full":
        coverage = "partial"
        issues.append(f"unrecognized gate: {gate['text']}")
    return effects, coverage, issues


_GROUP_RE = re.compile(r"\byou and your group\b|\byour group\b", re.I)


def _tidy(effects: list[dict[str, Any]], text: str) -> list[dict[str, Any]]:
    """Support-table fixes on top of the set grammar's output."""
    out: list[dict[str, Any]] = []
    for e in effects:
        c = e["condition"]
        # "you and your group" is a scope, not a free-text condition
        if c and c.get("type") == "text" and c.get("text") == "group" and _GROUP_RE.search(text):
            e["condition"] = None
            e["scope"] = "group"
            if e["kind"] == "conditional":
                e["kind"] = "static"
        if "flanking" in text and e["kind"] in ("static", "conditional") and not e["condition"]:
            e["condition"] = {"type": "flanking"}
            e["kind"] = "conditional"
        out.append(e)
    # "damage done with direct damage attacks by 6%" comes out as two stats;
    # keep one, gated on direct damage.
    direct = [e for e in out if e["stat"] == "direct_damage_pct"]
    for d in direct:
        twin = next(
            (
                e
                for e in out
                if e is not d
                and e["stat"] in ("damage_done_pct", "damage_taken_pct")
                and abs(e["value"] or 0) == abs(d["value"] or 0)
            ),
            None,
        )
        if twin:
            twin["condition"] = {"type": "direct_only"}
            twin["kind"] = "conditional"
            out.remove(d)
    return out


def _buff_ctx(buffs: list[dict[str, Any]]) -> Any:
    ctx = build_ctx(buffs, [])
    for old, new in U51_ALIAS.items():
        if new in ctx.buff_groups:
            ctx.buff_groups.setdefault(old, ctx.buff_groups[new])
    return ctx


def _named_buffs(text: str, ctx: Any) -> tuple[list[str], list[str], list[str]]:
    """Major/Minor buff names in tooltip text -> (buffs, debuffs, unknown names)."""
    buffs: list[str] = []
    debuffs: list[str] = []
    unknown: list[str] = []
    for m in _BUFF_RE.finditer(text):
        tier = m.group(1).lower()
        groups = [m.group(2)] + re.findall(r"[A-Z][a-z]+", m.group(3) or "")
        for i, g in enumerate(groups):
            key = ctx.buff_groups.get(g.lower(), {}).get(tier)
            if key is None:
                # "Major Resolve and Minor Expedition" is two matches; a trailing
                # capitalised word that isn't a buff group just ends the list.
                if i == 0:
                    unknown.append(f"{m.group(1)} {g}")
                break
            dest = debuffs if ctx.buff_kinds.get(key) == "debuff" else buffs
            if key not in dest:
                dest.append(key)
    return buffs, debuffs, unknown


# --- parse ---------------------------------------------------------------------


def _display(title: str) -> str:
    """'Online:Betty Netch (skill)' -> 'Betty Netch' (UESP disambiguator dropped)."""
    return re.sub(r"\s*\([^)]*\)$", "", title.split(":", 1)[1])


def _summary(page: dict[str, Any]) -> dict[str, str] | None:
    tpls = find_templates(page["wikitext"], "Online Skill Summary")
    return tpls[0].named() if tpls else None


def _rank_descs(fields: dict[str, str]) -> list[str]:
    keys = ["desc"] + [f"desc{i}" for i in range(1, 10) if f"desc{i}" in fields]
    # Passives number ranks desc, desc2, desc3 (desc1 is rank 1 when present)
    if "desc1" in fields and "desc" in fields:
        keys.remove("desc")
    out: list[str] = []
    for k in keys:
        if fields.get(k) and fields[k] not in out:
            out.append(fields[k])
    return out


def parse_passives(
    index: dict[str, Any], pages: dict[str, dict[str, Any]], ctx: Any
) -> tuple[list[dict[str, Any]], list[str], list[dict[str, Any]]]:
    items: list[dict[str, Any]] = []
    warnings: list[str] = []
    issues: list[dict[str, Any]] = []
    aliases = index.get("aliases", {})
    for line, info in sorted(index["lines"].items()):
        for name in info["passive"]:
            title = aliases.get(f"Online:{name}", f"Online:{name}")
            page = pages.get(title)
            name = _display(title)
            fields = _summary(page) if page else None
            if not fields:
                warnings.append(f"passive {line}/{name}: no Online Skill Summary")
                continue
            ranks = []
            full = True
            for r, desc in enumerate(_rank_descs(fields), 1):
                _, body = _plain(desc, page)
                effects, coverage, probs = _normalize(body, ctx)
                if coverage != "full":
                    full = False
                    issues.append(
                        {
                            "kind": "passive",
                            "name": name,
                            "line": line,
                            "rank": r,
                            "coverage": coverage,
                            "text": body,
                            "issues": probs,
                        }
                    )
                ranks.append({"rank": r, "effects": effects})
            if not ranks:
                warnings.append(f"passive {line}/{name}: no rank text")
                continue
            items.append(
                {
                    "key": slugify(name),
                    "name": name,
                    "category": info["category"],
                    "line": line,
                    "ranks": ranks,
                    "patch": PATCH,
                    "verified": full,
                    "uesp": _page_url(page["title"]),
                }
            )
    return _dedupe_keys(items, "line"), warnings, issues


SKILL_STAT_KINDS = {"static", "conditional"}
# Player stat grants a skill can carry. Damage/healing modifiers of the skill
# itself (execute scaling, "this ability deals 20% more") are coefficients.
SKILL_STATS = {
    "max_health",
    "max_magicka",
    "max_stamina",
    "health_recovery",
    "magicka_recovery",
    "stamina_recovery",
    "weapon_damage",
    "spell_damage",
    "weapon_crit",
    "spell_crit",
    "crit_damage_pct",
    "crit_resistance",
    "offensive_penetration",
    "physical_resistance",
    "spell_resistance",
    "healing_taken_pct",
    "damage_taken_pct",
    "block_mitigation_pct",
}
SLOTTED_STATS = {"damage_done_pct", "healing_done_pct"}


def _cost(text: str) -> tuple[int | None, str | None]:
    m = _COST_RE.search(text)
    if not m:
        return None, None
    return int(m.group(1).replace(",", "")), m.group(2).lower()


def parse_skills(
    index: dict[str, Any], pages: dict[str, dict[str, Any]], ctx: Any
) -> tuple[list[dict[str, Any]], list[str], list[dict[str, Any]]]:
    items: list[dict[str, Any]] = []
    warnings: list[str] = []
    issues: list[dict[str, Any]] = []
    for line, info in sorted(index["lines"].items()):
        for kind in ("ultimate", "active"):
            for name in info[kind]:
                title = index.get("aliases", {}).get(f"Online:{name}", f"Online:{name}")
                page = pages.get(title)
                name = _display(title)
                f = _summary(page) if page else None
                if not f:
                    warnings.append(f"skill {line}/{name}: no Online Skill Summary")
                    continue
                cost_text = _max_rank(to_plain(f.get("cost", "")))
                base_cost, base_res = _cost(cost_text)
                if base_res is None:
                    attrib = (f.get("attrib") or "").lower()
                    base_res = attrib if attrib in ("magicka", "stamina", "health") else None
                    if kind == "ultimate":
                        base_res = "ultimate"
                    elif re.match(r"\s*free\b", cost_text, re.I) or attrib == "none":
                        base_res, base_cost = "none", 0
                variants = [(name, None, f.get("desc", ""))]
                for i in (1, 2):
                    if f.get(f"morph{i}name"):
                        variants.append((f[f"morph{i}name"], name, f.get(f"desc{i}", "")))
                for vname, base, desc in variants:
                    header, body = _plain(desc, page)
                    cost, res = _cost(header) if header else (None, None)
                    if cost is None:
                        cost, res = base_cost, base_res
                    if " or " in (f.get("attrib") or ""):
                        res = None  # Arcanist: cost uses the highest max resource
                    buffs, debuffs, unknown = _named_buffs(body, ctx)
                    for u in unknown:
                        warnings.append(f"skill {vname}: {u} is not in buffs.json")
                    effects, coverage, probs = _normalize(body, ctx, tag=True)
                    stat_effects = [
                        e
                        for e in effects
                        if e["kind"] in SKILL_STAT_KINDS
                        and not e["buff_ref"]
                        and (
                            e["stat"] in SKILL_STATS
                            or (e["stat"] in SLOTTED_STATS and _slotted(e["condition"]))
                        )
                        and _stat_grant(e, body)
                    ]
                    # Verified when every sentence group that yielded a kept stat
                    # parsed fully; unrelated damage text doesn't hold it back.
                    stats_full = all(e["_coverage"] == "full" for e in stat_effects)
                    for e in effects:
                        e.pop("_coverage", None)
                    if not body:
                        warnings.append(f"skill {vname}: empty tooltip")
                    items.append(
                        {
                            "key": slugify(vname),
                            "name": vname,
                            "base": base,
                            "skill_line": line,
                            "class": info["class"],
                            "resource": res,
                            "cost": cost,
                            "buffs_granted": buffs,
                            "debuffs_applied": debuffs,
                            "effects": stat_effects,
                            "patch": PATCH,
                            "verified": bool(body)
                            and cost is not None
                            and not unknown
                            and stats_full,
                            "uesp": _page_url(page["title"] if base is None else f"Online:{vname}"),
                        }
                    )
                    if not stats_full:
                        issues.append(
                            {
                                "kind": "skill",
                                "name": vname,
                                "line": line,
                                "coverage": coverage,
                                "text": body,
                                "issues": probs,
                            }
                        )
    return _dedupe_keys(items, "skill_line"), warnings, issues


def _slotted(cond: dict[str, Any] | None) -> bool:
    if not cond:
        return False
    if cond.get("type") == "slotted":
        return True
    return any(_slotted(c) for c in cond.get("of", []))


# Clauses that only explain what a named buff does ("gain Major Resolve,
# increasing your Physical Resistance by 5948") are not separate stat grants.
_BUFF_EXPLAINER = re.compile(
    r"\b(?:Major|Minor) [A-Z][a-z]+(?:(?:,| and) (?:Major |Minor )?[A-Z][a-z]+)*,?\s+"
    r"(?:increasing|reducing)[^.]*?\bby \d+(?:\.\d+)?%?"
)


def _stat_grant(effect: dict[str, Any], body: str) -> bool:
    """Keep self stat grants like 'While slotted, Max Magicka is increased by 5%'."""
    if effect["scope"] not in ("self", "group", "ally"):
        return False
    value = effect["value"]
    if value is None:
        return False
    num = f"{value:g}"
    for sentence in re.split(r"(?<=[.!?])\s+", body):
        if re.search(rf"(?<![\d.]){re.escape(num)}(?![\d])", _BUFF_EXPLAINER.sub("", sentence)):
            return True
    return False


def _dedupe_keys(items: list[dict[str, Any]], field: str) -> list[dict[str, Any]]:
    seen: dict[str, int] = {}
    for it in items:
        seen[it["key"]] = seen.get(it["key"], 0) + 1
    out = []
    taken: set[str] = set()
    for it in items:
        if seen[it["key"]] > 1:
            # Same name in two lines (rare): the second copy is a duplicate of a
            # shared passive; keep both but namespace the key by its line.
            it["key"] = f"{it['key']}_{slugify(it[field])}"
        if it["key"] in taken:
            continue
        taken.add(it["key"])
        out.append(it)
    return out


_PER_STAGE = re.compile(r"(\d+(?:\.\d+)?)(%?)((?:\s+[A-Z][\w']*)*)\s+per stage", re.I)


def parse_cp(
    stars: list[dict[str, Any]], pages: dict[str, dict[str, Any]], ctx: Any
) -> tuple[list[dict[str, Any]], list[str], list[dict[str, Any]]]:
    items: list[dict[str, Any]] = []
    warnings: list[str] = []
    issues: list[dict[str, Any]] = []
    for s in stars:
        page, tpls = None, []
        for title in (f"Online:{s['name']}", f"Online:{s['name']} (champion)"):
            cand = pages.get(title)
            found = find_templates(cand["wikitext"], "Online Champion 2.0 Summary") if cand else []
            if found:
                page, tpls = cand, found
                break
        desc = ""
        if tpls:
            desc = _plain(tpls[0].named().get("desc", ""), page)[1]
        else:
            warnings.append(f"cp {s['name']}: no UESP summary")
        stages = int(s["stages"])
        # Linear stars: "3% per stage" -> the max-rank total
        text = _PER_STAGE.sub(
            lambda m, n=stages: f"{float(m.group(1)) * n:g}{m.group(2)}{m.group(3)}", desc
        )
        effects, coverage, probs = _normalize(text, ctx)
        if s["constellation"] == "craft":
            effects = [e for e in effects if e["kind"] != "unmodeled"]
        elif coverage != "full":
            issues.append(
                {
                    "kind": "cp",
                    "name": s["name"],
                    "coverage": coverage,
                    "text": desc,
                    "issues": probs,
                }
            )
        for e in effects:
            e["raw"] = desc
        items.append(
            {
                "id": int(s["id"]),
                "key": slugify(s["name"]),
                "name": s["name"],
                "constellation": s["constellation"],
                "slottable": bool(s["slottable"]),
                "max_points": int(s["max_points"]),
                "stages": stages,
                "points_per_stage": int(s["points_per_stage"]),
                "prerequisites": [
                    {"star": p["star"], "min_points": int(p["min_points"])}
                    for p in s.get("prerequisites") or []
                ],
                "effects": effects,
                "patch": PATCH,
                "verified": bool(desc) and (coverage == "full" or s["constellation"] == "craft"),
                "uesp": _page_url(page["title"]) if page else None,
            }
        )
    return items, warnings, issues


# The effect line ends at its duration ("... for 2 hours."); flavour text follows.
_EFFECT_RE = re.compile(r"Effect\(s\)\s+(.+?\bfor \d+ (?:hours?|minutes?)\.)")
_DURATION_RE = re.compile(r"\s*\bfor (\d+) (hour|hours|minute|minutes)\b\.?", re.I)
_FOOD_PART_RE = re.compile(r"((?:[A-Z][a-z]+ ?)+(?:(?:,| and) (?:[A-Z][a-z]+ ?)+)*) by (\d+)%?")
FOOD_STATS = {
    "max health": "max_health",
    "max magicka": "max_magicka",
    "max stamina": "max_stamina",
    "health recovery": "health_recovery",
    "magicka recovery": "magicka_recovery",
    "stamina recovery": "stamina_recovery",
}


def _food_effects(body: str, raw: str) -> tuple[list[dict[str, Any]], str, list[str]]:
    """'Increase Max Health by 4620, Max Stamina and Max Magicka by 4250, ...'."""
    effects: list[dict[str, Any]] = []
    issues: list[str] = []
    rest = re.sub(r"^Increase\s+", "", body)
    end = 0
    for m in _FOOD_PART_RE.finditer(rest):
        if rest[end : m.start()].strip(" ,").removeprefix("and").strip():
            break  # past the effect line, into flavour text
        end = m.end()
        names = [n.strip().lower() for n in re.split(r",\s*|\s+and\s+", m.group(1).strip())]
        # "Stamina and Magicka Recovery" / "Max Stamina and Magicka": share the
        # last name's suffix or the first name's prefix
        last = names[-1]
        for i, n in enumerate(names):
            if n not in FOOD_STATS and last.endswith(" recovery"):
                names[i] = f"{n} recovery"
            elif n not in FOOD_STATS and names[0].startswith("max "):
                names[i] = f"max {n}"
        for name in names:
            stat = FOOD_STATS.get(name)
            if stat is None:
                issues.append(f"unknown food stat: {name}")
                continue
            effects.append(
                {
                    "stat": stat,
                    "value": int(m.group(2)),
                    "unit": "flat",
                    "scope": "self",
                    "kind": "static",
                    "condition": None,
                    "trigger": None,
                    "duration_s": None,
                    "stacks": None,
                    "damage": None,
                    "buff_ref": None,
                    "uptime_est": 1.0,
                    "uptime_source": "static",
                    "raw": raw,
                }
            )
    if not end:
        issues.append(f"unparsed: {rest}")
    coverage = "full" if effects and not issues else ("partial" if effects else "none")
    return effects, coverage, issues


def parse_consumables(
    pages: dict[str, dict[str, Any]], ctx: Any
) -> tuple[list[dict[str, Any]], list[str], list[dict[str, Any]]]:
    items: list[dict[str, Any]] = []
    warnings: list[str] = []
    issues: list[dict[str, Any]] = []
    for name, category in CONSUMABLES.items():
        page = pages.get(f"Online:{name}")
        m = _EFFECT_RE.search(page["text"]) if page else None
        if not m:
            warnings.append(f"consumable {name}: no effect line on UESP")
            continue
        text = m.group(1).strip()
        dur = _DURATION_RE.search(text)
        duration = None
        if dur:
            duration = int(dur.group(1)) * (3600 if dur.group(2).startswith("hour") else 60)
            body = (text[: dur.start()] + text[dur.end() :]).strip()
        else:
            body = text
        effects, coverage, probs = _food_effects(body, text)
        if coverage != "full":
            issues.append(
                {
                    "kind": "consumable",
                    "name": name,
                    "coverage": coverage,
                    "text": text,
                    "issues": probs,
                }
            )
        buffs, _, _ = _named_buffs(text, ctx)
        items.append(
            {
                "key": slugify(name),
                "name": name,
                "category": category,
                "duration_s": duration,
                "effects": [e for e in effects if not e["buff_ref"]],
                "buffs_granted": buffs,
                "notes": "CP150 gold (legendary) recipe. Duration before Rationer.",
                "patch": PATCH,
                "verified": coverage == "full" and duration is not None,
                "uesp": _page_url(page["title"]),
            }
        )
    for p in POTIONS:
        items.append(
            {
                "key": slugify(p["name"]),
                "name": p["name"],
                "category": "potion",
                "duration_s": None,
                "effects": [],
                "buffs_granted": p["buffs"],
                "notes": p["notes"] + " Duration depends on reagents and Medicinal Use.",
                "patch": PATCH,
                "verified": False,
                "uesp": None,
            }
        )
        warnings.append(f"consumable {p['name']}: U51 potion drafted without a UESP page")
    return items, warnings, issues


# Buff sources the tables found, merged into buffs.json `sources`.
def buff_sources(
    passives: list[dict[str, Any]],
    skills: list[dict[str, Any]],
    consumables: list[dict[str, Any]],
    cp: list[dict[str, Any]],
) -> dict[str, dict[str, list[str]]]:
    out: dict[str, dict[str, list[str]]] = {}

    def add(key: str, kind: str, name: str) -> None:
        names = out.setdefault(key, {}).setdefault(kind, [])
        if name not in names:
            names.append(name)

    for s in skills:
        for k in s["buffs_granted"] + s["debuffs_applied"]:
            add(k, "skills", s["name"])
    for p in passives:
        for r in p["ranks"]:
            for e in r["effects"]:
                if e["buff_ref"]:
                    add(e["buff_ref"], "passives", p["name"])
    for c in consumables:
        for k in c["buffs_granted"]:
            add(k, "consumables", c["name"])
    for star in cp:
        for e in star["effects"]:
            if e["buff_ref"]:
                add(e["buff_ref"], "cp", star["name"])
    return out


def merge_buff_sources(
    buffs: list[dict[str, Any]], sources: dict[str, dict[str, list[str]]]
) -> int:
    """Replace the support-table source lists (sets stay as parse.py wrote them)."""
    changed = 0
    for b in buffs:
        add = sources.get(b["key"], {})
        for kind in ("skills", "passives", "consumables", "cp"):
            new = sorted(add.get(kind, []))
            if b["sources"].get(kind, []) != new:
                changed += 1
                if new:
                    b["sources"][kind] = new
                else:
                    b["sources"].pop(kind, None)
    return changed


def merge_from_tables(buffs: list[dict[str, Any]]) -> int:
    """Re-apply buff sources from the support tables already on disk (for parse.py)."""
    tables = {}
    for name in ("passives", "skills", "consumables", "cp_stars"):
        path = DATA_DIR / f"{name}.json"
        if not path.exists():
            return 0
        tables[name] = json.loads(path.read_text())["items"]
    sources = buff_sources(
        tables["passives"], tables["skills"], tables["consumables"], tables["cp_stars"]
    )
    return merge_buff_sources(buffs, sources)


def _envelope(kind: str, items: list[dict[str, Any]], pages: list[dict[str, Any]]) -> dict:
    return {
        "schema_version": SCHEMA_VERSION,
        "kind": kind,
        "source": {
            "wiki": "en.uesp.net",
            "max_revid": max((p["revid"] for p in pages), default=None),
            "pages": len(pages),
            "patches": [PATCH],
        },
        "count": len(items),
        "items": items,
    }


def _load_pages(sub: str) -> dict[str, dict[str, Any]]:
    return {p["title"]: p for f in sorted((CACHE / sub).glob("*.json")) if (p := _load(f))}


def _write(name: str, doc: dict[str, Any]) -> None:
    (DATA_DIR / name).write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n")


def parse() -> int:
    index = _load(CACHE / "index.json")
    if not index:
        print("no cached support pages — run `support-fetch` first", file=sys.stderr)
        return 1
    buffs_doc = json.loads((DATA_DIR / "buffs.json").read_text())
    ctx = _buff_ctx(buffs_doc["items"])
    skill_pages = _load_pages("skills")
    cp_pages = _load_pages("cp")
    food_pages = _load_pages("consumables")

    passives, w1, i1 = parse_passives(index, skill_pages, ctx)
    skills, w2, i2 = parse_skills(index, skill_pages, ctx)
    cp, w3, i3 = parse_cp(_cp_stars(), cp_pages, ctx)
    consumables, w4, i4 = parse_consumables(food_pages, ctx)

    skill_srcs = list(skill_pages.values())
    _write("passives.json", _envelope("passives", passives, skill_srcs))
    _write("skills.json", _envelope("skills", skills, skill_srcs))
    _write("cp_stars.json", _envelope("cp_stars", cp, list(cp_pages.values())))
    _write("consumables.json", _envelope("consumables", consumables, list(food_pages.values())))

    sources = buff_sources(passives, skills, consumables, cp)
    changed = merge_buff_sources(buffs_doc["items"], sources)
    _write("buffs.json", buffs_doc)

    warnings = w1 + w2 + w3 + w4
    write_report(
        {"passives": passives, "skills": skills, "cp_stars": cp, "consumables": consumables},
        warnings,
        i1 + i2 + i3 + i4,
    )
    for name, items in (
        ("passives", passives),
        ("skills", skills),
        ("cp_stars", cp),
        ("consumables", consumables),
    ):
        ok = sum(1 for i in items if i["verified"])
        print(f"{name}: {len(items)} ({ok} verified)", file=sys.stderr)
    print(f"buffs.json: {changed} source lists updated; {len(warnings)} warnings", file=sys.stderr)
    return 0


def write_report(
    tables: dict[str, list[dict[str, Any]]], warnings: list[str], issues: list[dict[str, Any]]
) -> None:
    out = [
        "# Support tables report",
        "",
        "Generated by `python -m tools.setdb support-parse`. Rows below are drafts",
        "(`verified: false`) until the text normalizes fully or an in-game tooltip",
        "confirms them. See docs/SET_SUPPORT_TABLES.md for the spot-check list.",
        "",
        "| Table | Rows | Verified |",
        "|---|---:|---:|",
    ]
    for name, items in tables.items():
        ok = sum(1 for i in items if i["verified"])
        out.append(f"| {name} | {len(items)} | {ok} |")
    out += ["", f"## Warnings ({len(warnings)})", ""]
    out += [f"- {w}" for w in warnings] or ["None."]
    out += ["", f"## Partial normalization ({len(issues)})", ""]
    for i in issues:
        where = f"{i.get('line', '')} / " if i.get("line") else ""
        rank = f" rank {i['rank']}" if i.get("rank") else ""
        out.append(f"- **{where}{i['name']}**{rank} ({i['coverage']}): {i['text']}")
        for p in i["issues"]:
            out.append(f"  - {p}")
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    (REPORTS_DIR / "support_tables.md").write_text("\n".join(out) + "\n")
