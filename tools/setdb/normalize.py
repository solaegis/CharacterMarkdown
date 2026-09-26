"""Phase 2: decompose bonus text into typed, numeric effects.

Clause-level rule grammar over the plain bonus text. Each sentence is scanned
for payloads (stat changes, buffs, damage, heals, shields, restores), the
trigger/condition that gates them, and modifiers (duration, cooldown, chance,
stacks, interval, radius, target count).

Honesty check: every number in a sentence must be consumed by some extracted
field. A sentence with leftover numbers, an unrecognised trigger, or free-text
conditions makes the bonus `partial`, never `full`. Anything left over is kept
as an `unmodeled` effect carrying the raw sentence, so nothing is silently lost.

Value convention: `value` is the signed change to `stat` at CP160 (upper end of
"34-1487" ranges). Costs and damage taken are negative when reduced.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Any

NUM = r"(\d+(?:\.\d+)?)(?:-(\d+(?:\.\d+)?))?"
NUM_RE = re.compile(r"\d+(?:\.\d+)?(?:-\d+(?:\.\d+)?)?")

DAMAGE_TYPES = r"Flame|Fire|Frost|Shock|Magic|Physical|Poison|Disease|Bleed|Oblivion"

# (phrase regex, stats). Searched in order; matched spans are consumed so
# "critical damage done" doesn't also yield damage_done.
STAT_RULES: list[tuple[str, list[str]]] = [
    (
        r"weapon and spell damage|weapon damage and spell damage|spell and weapon damage",
        ["weapon_damage", "spell_damage"],
    ),
    (r"weapon damage", ["weapon_damage"]),
    (r"spell damage", ["spell_damage"]),
    (r"critical damage taken", ["crit_damage_taken_pct"]),
    (
        r"critical damage and critical healing|critical damage and healing",
        ["crit_damage_pct", "crit_healing_pct"],
    ),
    (r"critical damage", ["crit_damage_pct"]),
    (r"critical healing", ["crit_healing_pct"]),
    (r"critical resistance", ["crit_resistance"]),
    (
        r"weapon (?:critical )?and spell critical(?: strike)?(?: ratings?| values?)?"
        r"|weapon critical and spell critical rating|critical chance|critical (?:strike )?rating"
        r"|critical strike chance",
        ["weapon_crit", "spell_crit"],
    ),
    (r"weapon critical", ["weapon_crit"]),
    (r"spell critical", ["spell_crit"]),
    (
        r"offensive penetration|(?:physical and spell|spell and physical) penetration"
        r"|physical penetration|spell penetration",
        ["offensive_penetration"],
    ),
    (
        r"health, magicka,? and stamina recovery",
        ["health_recovery", "magicka_recovery", "stamina_recovery"],
    ),
    (
        r"(?:magicka and stamina|stamina and magicka) recovery",
        ["magicka_recovery", "stamina_recovery"],
    ),
    (r"health recovery", ["health_recovery"]),
    (r"magicka recovery", ["magicka_recovery"]),
    (r"stamina recovery", ["stamina_recovery"]),
    (
        r"(?:max(?:imum)? )?health, magicka,? and stamina",
        ["max_health", "max_magicka", "max_stamina"],
    ),
    (
        r"(?:max(?:imum)? )?(?:magicka and stamina|stamina and magicka)",
        ["max_magicka", "max_stamina"],
    ),
    (r"(?:max(?:imum)? )?health", ["max_health"]),
    (r"(?:max(?:imum)? )?magicka", ["max_magicka"]),
    (r"(?:max(?:imum)? )?stamina", ["max_stamina"]),
    (
        r"\barmor\b|(?:physical and spell|spell and physical) resistances?",
        ["physical_resistance", "spell_resistance"],
    ),
    (r"physical resistance", ["physical_resistance"]),
    (r"spell resistance", ["spell_resistance"]),
    (r"healing taken|healing received", ["healing_taken_pct"]),
    (
        r"damage shield strength|shield strength|strength of (?:your )?damage shields?|damage shields?",
        ["shield_strength_pct"],
    ),
    (
        r"block mitigation|amount of damage (?:they|you) (?:can )?block|amount (?:they|you) can block"
        r"|damage (?:they|you) (?:can )?block",
        ["block_mitigation_pct"],
    ),
    (r"healing done|\bhealing\b", ["healing_done_pct"]),
    (r"damage taken", ["damage_taken_pct"]),
    (r"light and heavy attack damage", ["light_attack_damage", "heavy_attack_damage"]),
    (r"light attack damage", ["light_attack_damage"]),
    (r"heavy attack damage", ["heavy_attack_damage"]),
    (r"damage over time(?: damage)?", ["dot_damage_pct"]),
    (r"direct damage", ["direct_damage_pct"]),
    (r"damage done|\bdamage\b", ["damage_done_pct"]),
    (r"movement speed", ["movement_speed_pct"]),
    (r"mounted speed", ["mounted_speed_pct"]),
    (r"attack speed", ["attack_speed_pct"]),
]
_STAT_RULES = [(re.compile(p, re.I), s) for p, s in STAT_RULES]

RESOURCES = {"health": "health", "magicka": "magicka", "stamina": "stamina", "ultimate": "ultimate"}

SKILL_LINES = {
    "Dual Wield",
    "Two Handed",
    "Bow",
    "Destruction Staff",
    "Restoration Staff",
    "One Hand and Shield",
    "Soul Magic",
    "Support",
    "Assault",
    "Undaunted",
    "Fighters Guild",
    "Mages Guild",
    "Psijic Order",
    "Herald of the Tome",
    "Storm Calling",
    "Dawn's Wrath",
    "Earthen Heart",
    "Green Balance",
    "Curative Runeforms",
    "Siphoning",
    "Shadow",
    "Aedric Spear",
    "Bone Tyrant",
    "Animal Companions",
    "Winter's Embrace",
    "Ardent Flame",
    "Draconic Power",
    "Daedric Summoning",
    "Dark Magic",
    "Assassination",
    "Restoring Light",
    "Grave Lord",
    "Living Death",
    "Soldier of Apocrypha",
    "Werewolf",
    "Vampire",
}

MECHANIC_LINKS = {
    "Heavy Attack",
    "Light Attack",
    "Block",
    "Monsters",
    "Status Effects",
    "Synergy",
    "Combat",
    "taunt",
    "Stun",
    "Stealth",
    "Buffs",
    "Pull",
    "Roll Dodge",
    "Break Free",
    "Burning",
    "Potions",
    "Invisibility",
    "Interrupt",
    "Immobilize",
    "Chilled",
    "Battle Spirit",
    "Summons",
    "Diseased",
    "Concussion",
    "Sundered",
    "Execute",
    "Resurrect",
    "Companions",
    "Off Balance",
    "Snare",
    "Soul Gem",
    "Fear",
    "Knockback",
    "Imperial City",
    "Tel Var Stones",
    "Poisoned",
    "Pickpocketing",
    "Crux",
    "Detection",
    "Mundus Stones",
    "Hemorrhaging",
    "Constitution",
    "Gallop",
    "Healing",
    "Healing Received",
    "Critical Healing",
    "Damage Shield",
    "Movement Speed",
    "Penetration",
    "Physical Penetration",
    "Spell Penetration",
    "Armor",
    "Weapon Damage",
    "Spell Damage",
    "Health",
    "Magicka",
    "Stamina",
    "Ultimate",
    "Weapon Critical (effect)",
    "Spell Critical (effect)",
    "Critical Damage",
    "Critical Resistance",
    "Physical Resistance",
    "Spell Resistance",
}

BENIGN = [
    r"persists through death",
    r"^Current\b",
    r"^(?:Max(?:imum)?|Minimum) Damage:",
    r"cannot refresh|can'?t refresh",
    r"^This (?:effect|bonus) (?:can be blocked|cannot be (?:blocked|dodged|reflected))\.?$",
    r"does not apply to",
    r"cannot affect yourself",
    r"is picked randomly",
    r"^This (?:damage|effect|heal|shield)(?: and \w+)? scales off",
    r"^(?:The )?(?:damage|heal|healing|shield)(?: and (?:damage|heal|healing|shield))? scales? off",
    r"only one .* (?:active )?at a time",
    r"^You can (?:only )?have one\b",
    r"A short audio effect",
    r"^Disable all other item set bonuses",
]
_BENIGN = [re.compile(p, re.I) for p in BENIGN]

TRIGGERS: list[tuple[str, str]] = [
    (r"non[- ]critical", "deal_damage"),
    (r"poison fires|alchemical poison", "poison_proc"),
    (r"shield is broken|shield breaks|shield expires", "shield_break"),
    (
        r"leave sneak|leave stealth|leave invisibility|leav(?:e|ing) (?:sneak|stealth)",
        "leave_stealth",
    ),
    (r"(?:enemy|target)[\w ]* is healed", "enemy_healed"),
    (r"enemy hit has|hit has \d+%", "hit_low_health_target"),
    (r"enemy blocks|enemies block", "enemy_blocks"),
    (r"drink a potion|use a potion|potion", "potion"),
    (r"cleanse", "cleanse"),
    (r"\bexpires?\b|\bends\b", "expire"),
    (r"(?:gain|reach|have)\s+\d+ stacks|\d+ stacks", "stack_threshold"),
    (r"immobiliz|snare", "cc_received"),
    (r"light (?:and|or) heavy attacks?", "light_or_heavy_attack"),
    (r"fully[- ]charged heavy attack|heavy attack", "heavy_attack"),
    (r"light attack", "light_attack"),
    (r"(?:deal|dealing) (?:direct )?critical\b|critically strikes?|critical strike", "deal_crit"),
    (r"take (?:direct )?critical damage", "take_crit"),
    (r"take (?:direct |non-)?(?:\w+ )?damage|are damaged|are hit|damaged by", "take_damage"),
    (r"overheal", "overheal"),
    (r"are healed|receive healing", "be_healed"),
    (r"\bheal(?:s|ing)?\b", "heal"),
    (r"ultimate", "cast_ultimate"),
    (r"synerg", "synergy"),
    (r"\bdies\b|\bkill", "kill"),
    (r"dodge", "dodge"),
    (r"interrupt", "interrupt"),
    (r"taunt", "taunt"),
    (r"\bbash", "bash"),
    (r"\bblock|brac(?:e|ing)", "block"),
    (r"direct damage", "deal_direct_damage"),
    (r"damage over time", "deal_dot"),
    (r"status effect", "apply_status_effect"),
    (r"disabling effect|crowd control|stunned|knocked", "cc_received"),
    (r"break(?:ing)? free", "break_free"),
    (r"damage shield (?:breaks|expires)|shield breaks", "shield_break"),
    (r"apply a damage shield|shield (?:yourself|an ally)", "apply_shield"),
    (r"lose \d+ or more health|single attack", "big_hit_taken"),
    (r"\bpets?\b", "pet_attack"),
    (r"deal (?:flame|frost|shock|poison|disease|magic|physical|bleed)", "deal_damage"),
    (r"negative effect", "cleanse"),
    (r"touch(?:es)? the|pick(?:s)? up", "pickup"),
    (r"within \d+ meters of an enemy", "proximity"),
    (
        r"(?:deal|dealing|do) (?:\w+ )?(?:melee )?damage|damage an enemy|damaging an enemy|martial|melee",
        "deal_damage",
    ),
    (r"^applying\b", "apply_effect"),
    (r"\bdebuff", "apply_debuff"),
    (r"\bcast|activat|\buse\b|using", "cast_ability"),
    (r"resurrect", "resurrect"),
    (r"sprint", "sprint"),
]
_TRIGGERS = [(re.compile(p, re.I), t) for p, t in TRIGGERS]
_TRIGGER_CLAUSE = re.compile(
    r"^(?:When(?:ever)?|After(?!\s+(?:a\s+)?\d)|If|Each time|Every time)\b(.+?),\s*|"
    r"^((?:Dealing|Damaging|Casting|Activating|Using|Healing|Blocking|Completing|Overhealing|"
    r"Applying|Taking|Consuming|Drinking|Breaking|Killing|Interrupting|Dodging|Bashing)\b.+?)(?:,\s*|\s+(?=(?:grants?|gives?|causes?|creates?|applies?|restores?|"
    r"heals?|summons?|increases?|reduces?|draws?|calls?|places?|puts?|sets?)\b))|"
    r"^(Your (?:fully[- ]charged )?(?:Light|Heavy|Light and Heavy) Attacks)\b",
    re.I,
)

CONDITIONS: list[tuple[str, dict[str, Any]]] = [
    (r"while (?:you are )?not (?:actively )?(?:bracing|blocking)", {"type": "not_blocking"}),
    (r"while (?:you are )?not (?:in combat)", {"type": "out_of_combat"}),
    (r"drink buff|food buff|food or drink", {"type": "food_drink_buff"}),
    (r"while (?:you are )?out of combat|out of combat", {"type": "out_of_combat"}),
    (r"while you have an? ([\w ]+?) ability slotted", {"type": "skill_slotted"}),
    (r"while tethered|tether persists", {"type": "tethered"}),
    (r"while you have a damage shield|damage shield on you", {"type": "shielded"}),
    (r"while you have an? ([\w ]+?) equipped", {"type": "weapon_equipped"}),
    (r"siege weapon", {"type": "using_siege"}),
    (r"^While equipped\b", {"type": "equipped"}),
    (r"on your (?:secondary|backup) (?:weapon|bar)", {"type": "backup_bar"}),
    (r"on your (?:primary|front) (?:weapon|bar)", {"type": "front_bar"}),
    (r"\bwhile (?:you are )?in combat\b|\bin combat\b", {"type": "in_combat"}),
    (r"standing still|stand still", {"type": "standing_still"}),
    (r"while (?:you are )?moving", {"type": "moving"}),
    (r"permanent pet active|pets? (?:is|are) active|have a pet active", {"type": "pet_active"}),
    (r"do not have a permanent pet", {"type": "no_pet"}),
    (r"while (?:you are )?(?:actively )?(?:bracing|blocking)(?! not)", {"type": "blocking"}),
    (r"while sprinting", {"type": "sprinting"}),
    (r"while (?:you are )?(?:sneaking|in stealth|invisible)", {"type": "sneaking"}),
    (r"crowd control immunity", {"type": "cc_immune"}),
    (r"werewolf form|in werewolf", {"type": "werewolf"}),
    (r"elemental status effect", {"type": "self_status_effect"}),
    (r"mounted", {"type": "mounted"}),
    (r"battle spirit|cyrodiil|imperial city|battleground", {"type": "pvp_zone"}),
]
_CONDITIONS = [(re.compile(p, re.I), c) for p, c in CONDITIONS]

QUALIFIERS: list[tuple[str, dict[str, Any]]] = [
    (r"dungeon,? trial,? and arena|monsters|dungeon and trial", {"type": "vs_monsters"}),
    (r"\bplayers?\b", {"type": "vs_players"}),
    (r"siege", {"type": "vs_siege"}),
    (r"area of effect|aoe", {"type": "aoe_abilities"}),
    (r"damage over time", {"type": "dot_only"}),
    (r"direct damage|direct attacks|\bdirect\b", {"type": "direct_only"}),
    (r"core combat", {"type": "core_combat_abilities"}),
    (r"healing abilit\w*|healing over time abilit\w*", {"type": "healing_abilities"}),
    (r"\bover time\b", {"type": "dot_only"}),
    (r"summoned|summons?\b", {"type": "pets"}),
    (r"fighter'?s guild", {"type": "skill_line", "name": "Fighters Guild"}),
    (r"\bsprint", {"type": "sprinting"}),
    (r"\bmelee\b", {"type": "melee"}),
    (r"\branged\b", {"type": "ranged"}),
    (r"\bpets?\b|companions?", {"type": "pets"}),
    (r"single target", {"type": "single_target"}),
    (r"\bbash", {"type": "bash"}),
    (r"magicka abilit\w*|magicka healing", {"type": "resource_abilities", "resource": "magicka"}),
    (r"stamina abilit\w*", {"type": "resource_abilities", "resource": "stamina"}),
    (r"non-ultimate", {"type": "non_ultimate"}),
    (r"ultimate abilit\w*", {"type": "ultimate_abilities"}),
    (r"class abilit\w*", {"type": "class_abilities"}),
    (r"weapon skill abilit\w*|weapon abilit\w*", {"type": "weapon_abilities"}),
    (r"light and heavy attacks?", {"type": "attack_type", "attack": "light_and_heavy"}),
    (r"light attacks?", {"type": "attack_type", "attack": "light"}),
    (r"heavy attacks?", {"type": "attack_type", "attack": "heavy"}),
    (r"channeled", {"type": "channeled"}),
    (
        r"\b(flame|fire|frost|shock|poison|disease|magic|physical|bleed|oblivion) (?:abilit\w*|damage|attacks?)",
        {"type": "damage_type"},
    ),
    (
        r"\b(flame|fire|frost|shock|poison|disease|magic|physical|bleed|oblivion)\b",
        {"type": "damage_type"},
    ),
    (
        r"\b(chilled|burning|concussed|concussion|diseased|poisoned|hemorrhaging|sundered|bleeding|off balance|"
        r"marked|snared|immobilized|stunned|afflicted with [\w ]+|(?:major|minor) \w+|chilled|burning)\b",
        {"type": "target_status"},
    ),
    (r"\ball of your abilities|\ball abilities|\byour abilities", {"type": "all_abilities"}),
]
_QUALIFIERS = [(re.compile(p, re.I), q) for p, q in QUALIFIERS]
_STOPWORDS = {
    "your",
    "you",
    "the",
    "their",
    "a",
    "an",
    "to",
    "with",
    "of",
    "for",
    "and",
    "or",
    "by",
    "done",
    "all",
    "while",
    "in",
    "on",
    "at",
    "from",
    "that",
    "this",
    "is",
    "are",
    "be",
    "up",
    "additional",
    "any",
    "other",
    "against",
    "targets",
    "enemies",
    "enemy",
    "target",
    "abilities",
    "ability",
    "attacks",
    "attack",
    "damaging",
    "who",
    "afflicted",
    "amount",
    "can",
    "within",
    "meters",
    "meter",
    "nearby",
    "do",
    "seconds",
    "second",
    "weapons",
    "have",
    "it",
    "its",
    "them",
    "they",
    "bonus",
    "active",
    "increased",
    "radius",
    "magicka",
    "stamina",
}


@dataclass
class Ctx:
    buff_groups: dict[str, dict[str, str]]  # "brutality" -> {"major": "major_brutality", ...}
    buff_kinds: dict[str, str]  # buff key -> "buff" | "debuff"
    skills: set[str] = field(default_factory=set)


_EMPTY_CTX = None  # type: ignore[assignment]


@dataclass
class Sentence:
    text: str
    consumed: set[tuple[int, int]] = field(default_factory=set)
    effects: list[dict[str, Any]] = field(default_factory=list)
    trigger: dict[str, Any] | None = None
    conditions: list[dict[str, Any]] = field(default_factory=list)
    mods: dict[str, Any] = field(default_factory=dict)
    benign: bool = False
    issues: list[str] = field(default_factory=list)

    def eat(self, span: tuple[int, int]) -> None:
        self.consumed.add(span)
        # remember where the most recent payload sits, for position-aware modifiers
        for e in self.effects:
            e.setdefault("_pos", span[0])

    def free(self, span: tuple[int, int]) -> bool:
        a, b = span
        return not any(x < b and a < y for x, y in self.consumed)

    def leftover_numbers(self) -> list[str]:
        return [m.group(0) for m in NUM_RE.finditer(self.text) if self.free(m.span())]


def _num(m: re.Match[str], g: int) -> float:
    """Upper end of an 'a-b' range captured as groups g, g+1."""
    hi = m.group(g + 1) or m.group(g)
    v = float(hi)
    return int(v) if v.is_integer() else v


def _num_span(m: re.Match[str], g: int) -> tuple[int, int]:
    end = m.end(g + 1) if m.group(g + 1) else m.end(g)
    return (m.start(g), end)


# --- phrase resolution -------------------------------------------------------------


ENEMY_OWNER = re.compile(
    r"\bof (?:your|the|that|an?) (?:enemy|enemies|target)\b|\b(?:enemy|target|attacker)'s\b|"
    r"\b(?:enemies|targets)'|\btheir\b(?=.*\b(?:enem|target))",
    re.I,
)


def resolve_stats(phrase: str, ctx: Ctx) -> tuple[list[str], list[dict[str, Any]], str]:
    """Stat phrase -> (stats, qualifier conditions, unexplained remainder)."""
    text = phrase
    stats: list[str] = []
    for rx, names in _STAT_RULES:
        m = rx.search(text)
        if m:
            stats += [s for s in names if s not in stats]
            text = text[: m.start()] + " " + text[m.end() :]
    conds, rest = qualify(text, ctx)
    return stats, conds, rest


def _as_list(v: Any) -> list[Any]:
    return v if isinstance(v, list) else [v]


def qualify(text: str, ctx: Ctx) -> tuple[list[dict[str, Any]], str]:
    conds: list[dict[str, Any]] = []
    for skill in sorted(ctx.skills | SKILL_LINES, key=len, reverse=True):
        if re.search(rf"\b{re.escape(skill)}\b", text):
            kind = "skill_line" if skill in SKILL_LINES else "skill"
            conds.append({"type": kind, "name": skill})
            text = re.sub(rf"\b{re.escape(skill)}\b", " ", text)
    for rx, q in _QUALIFIERS:
        found = list(rx.finditer(text))
        if found:
            c = dict(q)
            if found[0].groups() and c["type"] in ("damage_type", "target_status"):
                prev = next((x for x in conds if x["type"] == c["type"]), None)
                vals = [f.group(1).lower() for f in found]
                if prev:
                    prev["value"] = sorted(set(_as_list(prev["value"]) + vals))
                    text = rx.sub(" ", text)
                    continue
                c["value"] = vals[0] if len(vals) == 1 else sorted(set(vals))
            conds.append(c)
            text = rx.sub(" ", text)
    words = [w for w in re.findall(r"[a-z']+", text.lower()) if w not in _STOPWORDS]
    return conds, " ".join(words)


# --- extractors --------------------------------------------------------------------


def _effect(
    stat: str, value: float | None, unit: str | None, kind: str, raw: str
) -> dict[str, Any]:
    return {
        "stat": stat,
        "value": value,
        "unit": unit,
        "scope": "self",
        "kind": kind,
        "condition": None,
        "trigger": None,
        "duration_s": None,
        "stacks": None,
        "damage": None,
        "buff_ref": None,
        "uptime_est": None,
        "uptime_source": None,
        "raw": raw,
    }


def extract_buffs(s: Sentence, ctx: Ctx) -> None:
    """Major/Minor X (with 'Major A and B' tier carry-over) -> buff_grant/debuff_apply."""
    names = "|".join(sorted((re.escape(g.title()) for g in ctx.buff_groups), key=len, reverse=True))
    rx = re.compile(
        rf"\b(Major|Minor)\s+({names})((?:,?\s+(?:and\s+)?(?:(?:Major|Minor)\s+)?(?:{names})\b)*)"
    )
    first_start = -1
    for m in rx.finditer(s.text):
        if first_start < 0:
            first_start = m.start()
        tier = m.group(1).lower()
        groups = [m.group(2)]
        for extra in re.finditer(rf"(?:(Major|Minor)\s+)?({names})\b", m.group(3) or ""):
            groups.append((extra.group(1) or tier).lower() + ":" + extra.group(2))
        for g in groups:
            t, _, g = g.partition(":") if ":" in g else (tier, "", g)
            key = ctx.buff_groups.get(g.lower(), {}).get(t)
            if not key:
                continue
            kind = "debuff_apply" if ctx.buff_kinds.get(key) == "debuff" else "buff_grant"
            e = _effect(key, None, None, kind, s.text)
            e["buff_ref"] = key
            lead = s.text[max(0, m.start() - 50) : m.start()]
            self_inflicted = re.search(
                r"\b(?:you|yourself)\b[^,.]*\b(?:gain|become|are afflicted)", lead, re.I
            )
            if kind == "debuff_apply" and not self_inflicted:
                e["scope"] = "target_debuff"
            s.effects.append(e)
    if first_start >= 0:
        # ", increasing your X by N" after a buff name restates the buff's value — consume it
        tail = s.text[first_start:]
        for clause in re.finditer(
            r"(?:increasing|reducing|decreasing|generating|draining|restoring)\b[^.]*", tail
        ):
            for m in re.finditer(
                r"(?:\bby\s+|generating\s+|draining\s+|restoring\s+|every\s+)" + NUM,
                clause.group(0),
            ):
                a, b = _num_span(m, 1)
                off = first_start + clause.start()
                s.eat((a + off, b + off))


_INC_RX = re.compile(
    r"\b(increas(?:e|es|ing)|reduc(?:e|es|ing)|decreas(?:e|es|ing)|lower(?:s|ing)?|boost(?:s|ing)?)\s+"
    r"(?!the cost|the costs|costs?\b|the duration)(.+?)\s+by\s+(?:up to\s+|an additional\s+|a further\s+)?"
    + NUM
    + r"(%?)",
    re.I,
)
_ADD_RX = re.compile(
    r"\b(adds?|adding|gains?|gaining|grants?(?: you| them| the target| allies)?|granting(?: you| them)?|"
    r"gives?(?: you| them)?)\s+"
    r"(?:you\s+)?(?:an additional\s+|up to\s+)?"
    + NUM
    + r"(%?)\s+(.+?)(?=[,.;]|\s+(?:for|while|when|to you|and (?:up to|increases|reduces|gain)|per|every|if)\b|$)",
    re.I,
)
_PASSIVE_RX = re.compile(
    r"\byour\s+(.+?)\s+(?:is|are)\s+(increased|reduced)\s+by\s+(?:up to\s+)?" + NUM + r"(%?)", re.I
)


def extract_stats(s: Sentence, ctx: Ctx) -> None:
    for rx, kind in ((_INC_RX, "inc"), (_ADD_RX, "add"), (_PASSIVE_RX, "passive")):
        for m in rx.finditer(s.text):
            if kind == "inc":
                verb, phrase, g, pct = m.group(1).lower(), m.group(2), 3, m.group(5)
            elif kind == "add":
                verb, phrase, g, pct = m.group(1).lower(), m.group(5), 2, m.group(4)
            else:
                verb, phrase, g, pct = m.group(2).lower(), m.group(1), 3, m.group(5)
            span = _num_span(m, g)
            if not s.free(span):
                continue
            enemy = bool(ENEMY_OWNER.search(phrase)) or (
                re.search(r"\btheir\b", phrase, re.I) is not None
                and re.search(r"\benem(?:y|ies)\b|\btargets?\b", s.text, re.I) is not None
                and re.search(r"group members?|allies|ally", s.text, re.I) is None
            )
            stats, conds, rest = resolve_stats(ENEMY_OWNER.sub(" ", phrase), ctx)
            if not stats:
                continue
            value = _num(m, g)
            if verb.startswith(("reduc", "decreas", "lower")):
                value = -value
            unit = "pct" if pct else "flat"
            for st in stats:
                e = _effect(st, value, unit, "static", s.text)
                e["condition"] = _merge_conditions(conds, rest)
                if enemy:
                    e["scope"] = "target_debuff"
                s.effects.append(e)
            s.eat(span)
            # "... by N and <stat> by M" / "... N Health and M Armor"
            tail = s.text[span[1] :]
            for c in re.finditer(
                r"^\s*%?\s*(?:[\w ]*?\s)?and (?:your |an additional )?([A-Za-z][\w ]+?) by "
                + NUM
                + r"(%?)"
                r"|^\s*%?\s*(?:[\w ]*?\s)?and "
                + NUM
                + r"(%?) ([A-Z][\w ]+?)(?=[,.]|\s+(?:for|while|to)\b|$)",
                tail,
            ):
                if c.group(1):
                    ph, gg, pc = c.group(1), 2, c.group(4)
                else:
                    ph, gg, pc = c.group(8), 5, c.group(7)
                st2, cd2, rest2 = resolve_stats(ph, ctx)
                a, b = _num_span(c, gg)
                if st2 and s.free((a + span[1], b + span[1])):
                    v2 = _num(c, gg) * (-1 if value < 0 else 1)
                    for st in st2:
                        e = _effect(st, v2, "pct" if pc else "flat", "static", s.text)
                        e["condition"] = _merge_conditions(cd2, rest2)
                        s.effects.append(e)
                    s.eat((a + span[1], b + span[1]))
            # "decrease X of your enemy by 40% and increase your X by an equal amount"
            if enemy and re.search(r"by an equal amount", s.text, re.I):
                for st in stats:
                    s.effects.append(_effect(st, -value, unit, "static", s.text))


def extract_costs(s: Sentence, ctx: Ctx) -> None:
    rx = re.compile(
        r"\b(?:reduc(?:e|es|ing)|lower(?:s|ing)?)\s+the\s+costs?\s+of\s+(.+?)\s+by\s+" + NUM + r"%"
        r"|\bcosts?\s+of\s+(.+?)\s+(?:is|are)\s+reduced\s+by\s+" + NUM + r"%"
        r"|\b(\d+(?:\.\d+)?)%\s+cost reduction for\s+(.+?)(?=[,.]|$)"
        r"|\b(increas(?:e|es))\s+the\s+cost\s+of\s+(.+?)\s+by\s+" + NUM + r"%",
        re.I,
    )
    for m in rx.finditer(s.text):
        if m.group(1) is not None:
            target, g, sign = m.group(1), 2, -1
        elif m.group(4) is not None:
            target, g, sign = m.group(4), 5, -1
        elif m.group(7) is not None:
            target, value = m.group(8), -float(m.group(7))
            s.eat(m.span(7))
            s.effects.append(_cost_effect(target, value, s.text, ctx))
            continue
        else:
            target, g, sign = m.group(10), 11, 1
        s.eat(_num_span(m, g))
        s.effects.append(_cost_effect(target, sign * _num(m, g), s.text, ctx))


def _cost_effect(target: str, value: float, raw: str, ctx: Ctx) -> dict[str, Any]:
    t = target.lower()
    if re.search(r"\bblock", t) and "sprint" not in t:
        stat = "block_cost_pct"
    elif "break free" in t:
        stat = "break_free_cost_pct"
    elif re.search(r"sprint|dodge|sneak", t) and "abilit" not in t:
        stat = "movement_cost_pct"
    else:
        stat = "ability_cost_pct"
    e = _effect(stat, value, "pct", "static", raw)
    conds, rest = qualify(target, ctx)
    rest = re.sub(
        r"\b(?:abilit(?:y|ies)|block|blocking|sprint|dodge|roll|sneak|break|free|cost)\b", "", rest
    ).strip()
    e["condition"] = _merge_conditions(conds, rest)
    return e


def extract_skill_damage(s: Sentence, ctx: Ctx) -> None:
    pats = [
        re.compile(
            r"\bIncreases? the (?:direct )?damage (?:of )?(.+?) deals by\s+" + NUM + r"(%?)", re.I
        ),
        re.compile(
            r"^(.+?) deals (?:up to )?" + NUM + r"(%?) (?:more|additional|extra) damage", re.I
        ),
        re.compile(
            r"\bIncreases? (?:your )?damage done with (.+?) by (?:up to )?" + NUM + r"(%?)", re.I
        ),
        re.compile(r"\bIncreases? the damage (?:that )?(.+?) deals by\s+" + NUM + r"(%?)", re.I),
    ]
    for rx in pats:
        for m in rx.finditer(s.text):
            span = _num_span(m, 2)
            if not s.free(span):
                continue
            conds, rest = qualify(m.group(1), ctx)
            if not any(c["type"] in ("skill", "skill_line") for c in conds):
                continue
            e = _effect(
                "ability_damage", _num(m, 2), "pct" if m.group(4) else "flat", "static", s.text
            )
            e["condition"] = _merge_conditions(conds, rest)
            s.effects.append(e)
            s.eat(span)


CC_RX = re.compile(
    r"\b(stun(?:s|ning)?|knock(?:s|ing)?(?: \w+)? (?:down|back|into the air)|knockdown|immobiliz\w*|"
    r"snar(?:e|es|ing)|fear(?:s|ing|ed)?|taunt(?:s|ing)?|root(?:s|ing)?)\b[^.]{0,40}?\bfor\s+"
    + NUM
    + r"\s+seconds?",
    re.I,
)


DURATION_RX = re.compile(
    r"\b(increas(?:e|es|ing)|reduc(?:e|es|ing)|extend(?:s|ing)?)\s+the duration of\s+(.+?)\s+by\s+"
    + NUM
    + r"\s*(%|seconds?)",
    re.I,
)
TAKEN_RX = re.compile(
    r"\b(?:take|takes|taking)\s+(?:an additional\s+)?"
    + NUM
    + r"%\s+(more|less|increased|reduced)\s+damage"
    r"(?:\s+from\s+([^,.]+))?",
    re.I,
)
EFFECTIVENESS_RX = re.compile(
    r"\b(reduc(?:e|es|ing)|increas(?:e|es|ing))\s+the effectiveness of\s+(.+?)\s+by\s+"
    + NUM
    + r"%",
    re.I,
)


def extract_misc(s: Sentence, ctx: Ctx) -> None:
    t = s.text
    for m in DURATION_RX.finditer(t):
        span = _num_span(m, 3)
        if not s.free(span):
            continue
        sign = -1 if m.group(1).lower().startswith("reduc") else 1
        target = m.group(2)
        incoming = re.search(r"\bon you\b|applied to you|you are affected", target, re.I)
        e = _effect(
            "incoming_cc_duration" if incoming else "effect_duration",
            sign * _num(m, 3),
            "pct" if m.group(5) == "%" else "seconds",
            "static",
            t,
        )
        e["extra"] = {"applies_to": re.sub(r"\s+(?:on you|applied to you)$", "", target).strip()}
        s.effects.append(e)
        s.eat(span)
    for m in TAKEN_RX.finditer(t):
        span = _num_span(m, 1)
        if not s.free(span):
            continue
        more = m.group(3).lower() in ("more", "increased")
        subject = t[: m.start()]
        enemy = re.search(r"\b(?:enemy|enemies|target|them|they)\b", subject[-60:], re.I)
        e = _effect("damage_taken_pct", _num(m, 1) * (1 if more else -1), "pct", "static", t)
        if enemy or more:
            e["scope"] = "target_debuff"
        conds, rest = qualify(m.group(4) or "", ctx)
        e["condition"] = _merge_conditions(conds, rest)
        s.effects.append(e)
        s.eat(span)
    for m in EFFECTIVENESS_RX.finditer(t):
        span = _num_span(m, 3)
        if not s.free(span):
            continue
        sign = -1 if m.group(1).lower().startswith("reduc") else 1
        tgt = m.group(2).lower()
        stat = "incoming_snare_effectiveness_pct" if "snare" in tgt else "effect_effectiveness_pct"
        e = _effect(stat, sign * _num(m, 3), "pct", "static", t)
        e["extra"] = {"applies_to": m.group(2).strip()}
        s.effects.append(e)
        s.eat(span)


def extract_cc(s: Sentence) -> None:
    for m in CC_RX.finditer(s.text):
        span = _num_span(m, 2)
        if not s.free(span):
            continue
        word = m.group(1).lower()
        kind = next(
            k for k in ("stun", "knock", "immobiliz", "snar", "fear", "taunt", "root") if k in word
        )
        e = _effect(
            f"cc_{ {'knock': 'knockdown', 'immobiliz': 'immobilize', 'snar': 'snare'}.get(kind, kind) }",
            None,
            None,
            "debuff_apply",
            s.text,
        )
        e["scope"] = "enemy_aoe" if re.search(r"enemies", s.text, re.I) else "target"
        e["duration_s"] = _num(m, 2)
        s.effects.append(e)
        s.eat(span)


def extract_damage_heal(s: Sentence) -> None:
    t = s.text
    for m in re.finditer(
        r"\b(?:deal|deals|dealing)\s+(?:an additional\s+|up to\s+)"
        + NUM
        + r"(%?)\s+(?:more\s+|additional\s+|extra\s+)?damage"
        r"|\b(?:deal|deals|dealing)\s+" + NUM + r"(%?)\s+(?:more|additional|extra)\s+damage",
        t,
        re.I,
    ):
        g = 1 if m.group(1) is not None else 4
        span = _num_span(m, g)
        if s.free(span):
            e = _effect(
                "attack_damage", _num(m, g), "pct" if m.group(g + 2) else "flat", "static", t
            )
            conds, rest = qualify(t[: m.start()] + " " + t[m.end() :], _EMPTY_CTX)
            e["condition"] = _merge_conditions(conds, "") if conds else None
            s.effects.append(e)
            s.eat(span)
    for m in re.finditer(NUM + rf"\s+({DAMAGE_TYPES})\s+[Dd]amage", t):
        span = _num_span(m, 1)
        if not s.free(span):
            continue
        e = _effect("proc_damage", _num(m, 1), "flat", "damage", t)
        e["scope"] = "enemy_aoe" if re.search(r"enemies|all enemies|area", t, re.I) else "target"
        e["damage"] = {"type": m.group(3).lower().replace("fire", "flame")}
        s.effects.append(e)
        s.eat(span)
    heal_rx = re.compile(
        r"\b(?:heal(?:s|ing)?|restor(?:e|es|ing))\s+(?:you\s+|yourself\s+|them\s+|the target\s+|"
        r"you and (?:your )?group members(?: near \w+)?\s+|group members\s+)?(?:for\s+)?"
        + NUM
        + r"\s+Health\b"
        r"|\bheal(?:s|ing)? for\s+" + NUM + r"\s+Health",
        re.I,
    )
    heal_rx2 = re.compile(r"\bheal(?:s|ing)?\b[^.]{0,80}?\bfor\s+" + NUM + r"\s+Health", re.I)
    for m in list(heal_rx.finditer(t)) + list(heal_rx2.finditer(t)):
        g = 1 if m.re is heal_rx2 else (1 if m.group(1) else 3)
        span = _num_span(m, g)
        if not s.free(span):
            continue
        e = _effect("heal", _num(m, g), "flat", "heal", t)
        if re.search(r"group members?|allies|ally", t, re.I):
            e["scope"] = "group"
        s.effects.append(e)
        s.eat(span)
    for m in re.finditer(r"damage shield that absorbs (?:up to )?" + NUM + r"\s+damage", t, re.I):
        span = _num_span(m, 1)
        if not s.free(span):
            continue
        e = _effect("damage_shield", _num(m, 1), "flat", "shield", t)
        if re.search(r"group members|allies", t, re.I):
            e["scope"] = "group"
        s.effects.append(e)
        s.eat(span)
    for m in re.finditer(r"\blos(?:e|es|ing)\s+" + NUM + r"\s+(Health|Magicka|Stamina)\b", t, re.I):
        span = _num_span(m, 1)
        if s.free(span):
            s.effects.append(
                _effect(f"restore_{m.group(3).lower()}", -_num(m, 1), "flat", "resource_restore", t)
            )
            s.eat(span)
    restore_rx = re.compile(
        r"\b(?:restor(?:e|es|ing)|generat(?:e|es|ing)|gain(?:s|ing)?|grants?)\s+(?:you\s+)?(?:up to\s+)?"
        + NUM
        + r"\s+(Magicka|Stamina|Ultimate)((?:,?\s*(?:and\s+)?(?:Magicka|Stamina|Health))*)\b",
        re.I,
    )
    for m in restore_rx.finditer(t):
        span = _num_span(m, 1)
        if not s.free(span):
            continue
        resources = [m.group(3)] + re.findall(r"Magicka|Stamina|Health", m.group(4) or "", re.I)
        for r in resources:
            e = _effect(f"restore_{r.lower()}", _num(m, 1), "flat", "resource_restore", t)
            if re.search(r"group members|allies", t, re.I):
                e["scope"] = "group"
            s.effects.append(e)
        s.eat(span)


_OPENERS = [
    (re.compile(r"^(?:At|Upon reaching|On reaching)\s+\d+\s+stacks\b", re.I), "stack_threshold"),
    (re.compile(r"^Every\s+(?:\d+(?:\.\d+)?\s+seconds?|second)\b", re.I), "periodic"),
    (re.compile(r"^Consuming a corpse|corpse", re.I), "consume_corpse"),
    (re.compile(r"^Bar swap|weapon swap|swap(?:ping)? (?:bars|weapons)", re.I), "bar_swap"),
]


def extract_trigger(s: Sentence, ctx: Ctx) -> None:
    for rx, name in _OPENERS:
        if rx.search(s.text):
            s.trigger = {"on": name, "chance": None, "cooldown_s": None}
            return
    text = re.sub(r"^While [^,]{3,60},\s*(?=\w)", "", s.text)
    m = _TRIGGER_CLAUSE.search(text)
    if not m:
        return
    clause = next(g for g in m.groups() if g)
    for rx, name in _TRIGGERS:
        if rx.search(clause):
            s.trigger = {"on": name, "chance": None, "cooldown_s": None}
            break
    else:
        s.trigger = {"on": "other", "chance": None, "cooldown_s": None, "text": clause.strip()}
    conds, _ = qualify(clause, ctx)
    for c in conds:
        if c["type"] in ("skill", "skill_line"):
            s.trigger[c["type"]] = c["name"]
            if s.trigger["on"] in ("other", "cast_ability"):
                s.trigger["on"] = "cast_skill"
            break


def skill_subject_trigger(s: Sentence, ctx: Ctx) -> None:
    """'Steadfast Ward applies …' / 'The initial heal of Grand Healing …' -> cast_skill."""
    if s.trigger or not s.effects:
        return
    if all(e["stat"] == "ability_damage" for e in s.effects):
        return  # the skill is the condition ("Wall of Elements deals N more"), not a trigger
    head = s.text[:80]
    for skill in sorted(ctx.skills, key=len, reverse=True):
        if re.search(rf"\b{re.escape(skill)}\b", head):
            s.trigger = {"on": "cast_skill", "chance": None, "cooldown_s": None, "skill": skill}
            return


def extract_conditions(s: Sentence) -> None:
    t = s.text
    for rx, c in _CONDITIONS:
        m = rx.search(t)
        if m and not (
            c["type"] == "blocking" and any(x["type"] == "not_blocking" for x in s.conditions)
        ):
            c = dict(c)
            if m.groups() and m.group(1):
                c["value"] = m.group(1).strip()
            if c["type"] == "equipped":
                continue  # "While equipped" = always on
            s.conditions.append(c)
    rx = re.compile(
        r"\b(?:under|below|less than|above|over|more than|greater than)\s+"
        + NUM
        + r"%\s+(?:of (?:your|their) (?:max(?:imum)? )?)?(Health|Magicka|Stamina)",
        re.I,
    )
    for m in rx.finditer(t):
        below = re.match(r"under|below|less", m.group(0), re.I) is not None
        who = (
            "target"
            if re.search(
                r"target|enemy|enemies|them\b|ally|member",
                t[max(0, m.start() - 40) : m.start()],
                re.I,
            )
            else "self"
        )
        s.conditions.append(
            {
                "type": f"{'target_' if who == 'target' else ''}{m.group(3).lower()}_{'below' if below else 'above'}",
                "pct": _num(m, 1),
            }
        )
        s.eat(_num_span(m, 1))
    rx2 = re.compile(
        r"\b(Health|Magicka|Stamina) is (?:(above|over|below|under|less than|more than|greater than)\s+)?"
        + NUM
        + r"%(?:\s+or\s+(less|more|lower|higher))?",
        re.I,
    )
    rx3 = re.compile(
        r"\b(?:have|has|at)\s+"
        + NUM
        + r"%\s+or\s+(more|less|higher|lower)\s+(?:of (?:your|their) )?(Health|Magicka|Stamina)"
        r"|\b(?:have|has|at)\s+"
        + NUM
        + r"%\s+(Health|Magicka|Stamina)\s+or\s+(more|less|higher|lower)",
        re.I,
    )
    for m in rx3.finditer(t):
        g, res, word = (1, m.group(4), m.group(3)) if m.group(1) else (5, m.group(7), m.group(8))
        span = _num_span(m, g)
        if not s.free(span):
            continue
        who = (
            "target_"
            if re.search(r"enemy|target|they\b|them\b", t[max(0, m.start() - 30) : m.start()], re.I)
            else ""
        )
        below = word.lower() in ("less", "lower")
        s.conditions.append(
            {"type": f"{who}{res.lower()}_{'below' if below else 'above'}", "pct": _num(m, g)}
        )
        s.eat(span)
    for m in rx2.finditer(t):
        span = _num_span(m, 3)
        if not s.free(span):
            continue
        word = (m.group(2) or m.group(5) or "").lower()
        below = word in ("below", "under", "less than", "less", "lower")
        s.conditions.append(
            {"type": f"{m.group(1).lower()}_{'below' if below else 'above'}", "pct": _num(m, 3)}
        )
        s.eat(span)
    for m in re.finditer(
        r"\b" + NUM + r"\s+meters? or (further|farther|more|less|closer)(?: away)? from", t, re.I
    ):
        far = m.group(3).lower() in ("further", "farther", "more")
        s.conditions.append(
            {"type": "distance_min" if far else "distance_max", "meters": _num(m, 1)}
        )
        s.eat(_num_span(m, 1))
    for m in re.finditer(
        r"(?:reaching (?:the |its )?maximum|maximum) at\s+" + NUM + r"%\s+(Health|Magicka|Stamina)",
        t,
        re.I,
    ):
        s.conditions.append(
            {"type": f"missing_{m.group(3).lower()}_scaling", "max_at_pct": _num(m, 1)}
        )
        s.eat(_num_span(m, 1))
    for m in re.finditer(
        r"against (?:targets|enemies) (?:affected by|with) (?:your )?(.+?)(?=[,.]|$)", t, re.I
    ):
        s.conditions.append({"type": "target_has", "effect": m.group(1).strip()})


MODS: list[tuple[str, str]] = [
    (r"for\s+NUM\s+seconds?\s+per\s+NUM\s+Ultimate spent", "duration_per_ult"),
    (
        r"(?:can|may)(?: only)?\s+(?:occur|trigger|be (?:triggered|summoned|created|applied|affected by this set)|happen)(?: once)?\s+every\s+NUM\s+seconds?",
        "cooldown",
    ),
    (r"once every\s+NUM\s+seconds?", "cooldown"),
    (r"once every half(?: a)? second", "cooldown_half"),
    (r"once (?:every|per) second", "cooldown_one"),
    (r"NUM%\s+chance", "chance"),
    (
        r"(?:stacking|stacks?)\s+up to\s+NUM\s+times|up to (?:a )?maximum of\s+NUM\s+(?:times|stacks)"
        r"|up to\s+NUM\s+(?:stacks|times)|NUM stacks max|max(?:imum)? of\s+NUM\s+stacks",
        "stacks",
    ),
    (
        r"(?:At|after reaching|when you (?:reach|gain)|After|Upon)\s+NUM(?:\s+or more)?\s+stacks"
        r"|After stacking\s+NUM\b",
        "stack_threshold",
    ),
    (r"within\s+NUM\s+seconds?", "window"),
    (r"after (?:a\s+)?NUM[- ]seconds?(?: delay)?", "delay"),
    (r"over\s+NUM\s+seconds?", "over"),
    (r"every\s+NUM\s+seconds?", "interval"),
    (r"(?<!once )(?:per|each|every) second", "interval_one"),
    (r"for\s+NUM\s+seconds?", "duration"),
    (r"reduced to\s+NUM\s+seconds?\s+against players", "pvp_duration"),
    (r"(?:reduced|decreased) to\s+NUM%", "pvp_value"),
    (r"NUM\s*(?:-|\s)?meters?", "radius"),
    (
        r"(?:up to|the closest|closest|and)\s+NUM\s+(?:other\s+|nearby\s+)?(?:group members|allies|enemies|targets)"
        r"|NUM\s+(?:other\s+)?(?:group members|allies)",
        "targets",
    ),
    (r"for\s+NUM%\s+of the (?:damage|healing)", "ratio"),
    (r"NUM\s+times the amount", "multiplier"),
    (r"NUM%\s+of\s+(?:Ultimate spent|your|its|the)", "ratio"),
    (r"(?:level|rank)\s+NUM", "level"),
]
_MODS = [(re.compile(p.replace("NUM", NUM), re.I), k) for p, k in MODS]


PER_RX = re.compile(
    r"\bfor (?:every|each)\s+([^,.]+?)(?=,|\.|$| up to| stacking)|\bper\s+(?!second\b|\d)([a-z][^,.]*?)(?=,|\.|$| up to)",
    re.I,
)


def extract_per(s: Sentence) -> None:
    m = PER_RX.search(s.text)
    if m and s.effects:
        per = (m.group(1) or m.group(2)).strip()
        for e in s.effects:
            if e["kind"] != "buff_grant":
                e["stacks"] = {**(e["stacks"] or {}), "per": per}


def extract_mods(s: Sentence) -> None:
    for rx, key in _MODS:
        for m in rx.finditer(s.text):
            if key in ("cooldown_half", "cooldown_one", "interval_one"):
                base = key.split("_")[0]
                s.mods.setdefault(base, 0.5 if key.endswith("half") else 1)
                s.mods.setdefault("_pos_" + base, m.start())
                continue
            if m.lastindex is None:
                continue
            g = next(i for i in range(1, (m.lastindex or 0) + 1, 2) if m.group(i))
            span = _num_span(m, g)
            if not s.free(span):
                continue
            s.eat(span)
            s.mods.setdefault("_pos_" + key, span[0])
            if key == "duration_per_ult":
                s.mods["duration_per_ult"] = [_num(m, 1), _num(m, 3)]
                s.eat(_num_span(m, 3))
            else:
                s.mods.setdefault(key, _num(m, g))


def _merge_conditions(conds: list[dict[str, Any]], rest: str) -> dict[str, Any] | None:
    out = list(conds)
    if rest.strip():
        out.append({"type": "text", "text": rest.strip()})
    if not out:
        return None
    return out[0] if len(out) == 1 else {"type": "all", "of": out}


# --- sentence & bonus drivers ------------------------------------------------------


def split_sentences(text: str) -> list[str]:
    parts = re.split(r"(?<=[.!?])\s+(?=[A-Z])", text.strip())
    return [p.strip() for p in parts if p.strip()]


def analyse_sentence(text: str, ctx: Ctx) -> Sentence:
    s = Sentence(text)
    if any(rx.search(text) for rx in _BENIGN):
        s.benign = True
    extract_conditions(s)
    extract_trigger(s, ctx)
    extract_buffs(s, ctx)
    extract_costs(s, ctx)
    extract_misc(s, ctx)
    extract_skill_damage(s, ctx)
    extract_cc(s)
    extract_damage_heal(s)
    extract_stats(s, ctx)
    skill_subject_trigger(s, ctx)
    extract_mods(s)
    extract_per(s)
    return s


ALLY_TARGET = re.compile(
    r"\b(?:your|the) target gains\b|\bgrants? (?:them|the target|your target)\b|\bapplies [\w ]+ to your target\b"
    r"(?=.*\b(?:heal|shield|buff|Major|Minor)\b)",
    re.I,
)


CONTINUATION = re.compile(
    r"^(?:After|Then|This|These|The|It|Each|Every|At|Upon|While (?:this|the|it)|Enemies|Group members|"
    r"You and|Your target|They|That|Its|Additionally|Also|Once)\b|\bthen\b",
    re.I,
)


SETUP = re.compile(
    r"\b(appl(?:y|ies|ying)|summon(?:s|ing)?|creat(?:e|es|ing)|plac(?:e|es|ing)|put(?:s|ting)?|"
    r"leav(?:e|es|ing)|spawn(?:s|ing)?|mark(?:s|ing)?|draws?|calls?|conjur\w*|become|becomes|"
    r"stacks? of|a stack|charge stack)\b",
    re.I,
)


MODIFIER_ONLY = re.compile(
    r"^(?:This|These|The|Each|A|Group members|Enemies|You)\b.*\b(?:can|may|only|every|stack|lasts?|scales?)\b",
    re.I,
)


def normalize_bonus(text: str, ctx: Ctx) -> tuple[list[dict[str, Any]], str, list[str]]:
    """Return (effects, coverage, issues) for one bonus line."""
    sentences = [analyse_sentence(t, ctx) for t in split_sentences(text)]
    effects: list[dict[str, Any]] = []
    issues: list[str] = []
    pending_unmodeled: list[str] = []
    carried_trigger: dict[str, Any] | None = None

    for s in sentences:
        leftovers = [] if s.benign else s.leftover_numbers()
        if s.effects:
            if (
                s.trigger is None
                and carried_trigger is not None
                and (
                    CONTINUATION.search(s.text)
                    or any(e["duration_s"] for e in s.effects)
                    or "duration" in s.mods
                )
            ):
                s.trigger = dict(carried_trigger)
            if s.trigger is not None and s.trigger["on"] not in ("stack_threshold",):
                carried_trigger = s.trigger
            _apply(s, s.effects)
            effects += s.effects
        elif s.mods and effects and (MODIFIER_ONLY.search(s.text) or not s.trigger):
            # "This effect can occur once every 10 seconds." -> every payload so far
            _apply(s, [e for e in effects if e["kind"] != "unmodeled"], only_mods=True)
        elif s.benign:
            pass
        elif s.mods and not leftovers and MODIFIER_ONLY.search(s.text):
            # cooldown/stack note for a sentence that was already reported
            continue
        elif SETUP.search(s.text) and not leftovers:
            # "Light Attacks apply Eagle's Mark to your target for 12 seconds." — the payload
            # follows in the next sentence and inherits this trigger
            carried_trigger = s.trigger or carried_trigger
            continue
        else:
            pending_unmodeled.append(s.text)
            issues.append(f"no payload: {s.text[:90]}")
            continue
        if leftovers:
            issues.append(f"unconsumed {leftovers} in: {s.text[:90]}")
        if s.trigger and s.trigger["on"] == "other":
            issues.append(f"unknown trigger: {s.trigger.get('text', '')[:60]}")
        for e in s.effects:
            if _has_text_condition(e["condition"]):
                issues.append(
                    f"free-text condition on {e['stat']}: {_cond_text(e['condition'])[:60]}"
                )
            if (
                e["duration_s"] is not None
                and e["trigger"] is None
                and e["kind"] in ("static", "conditional", "buff_grant", "debuff_apply")
            ):
                issues.append(f"timed {e['stat']} without a trigger")
            if (
                e["kind"] in ("damage", "heal", "shield", "resource_restore")
                and e["trigger"] is None
                and e["condition"] is None
            ):
                issues.append(f"{e['kind']} without a trigger")
        if (
            s.effects
            and not s.trigger
            and not s.conditions
            and re.search(r"\bwhile\b", s.text, re.I)
            and not re.search(r"^While equipped\b", s.text)
        ):
            issues.append(f"unrecognized while-condition: {s.text[:70]}")
        if (
            s.effects
            and re.search(r"\bfor (?:every|each)\b|\bper (?!second|stack\b)(?!\d)", s.text, re.I)
            and not any(e["stacks"] for e in s.effects)
        ):
            issues.append(f"per-X scaling not modeled: {s.text[:70]}")

    for raw in pending_unmodeled:
        effects.append(_effect("unmodeled", None, None, "unmodeled", raw))

    for e in effects:
        if (
            e["kind"] in ("static", "buff_grant")
            and e["trigger"] is None
            and e["condition"] is None
            and e["duration_s"] is None
        ):
            e["uptime_est"], e["uptime_source"] = 1.0, "static"

    for e in effects:
        e.pop("_pos", None)
    modeled = [e for e in effects if e["kind"] != "unmodeled"]
    if not modeled:
        coverage = "none"
    elif issues:
        coverage = "partial"
    else:
        coverage = "full"
    return effects, coverage, issues


def _apply(s: Sentence, effects: list[dict[str, Any]], only_mods: bool = False) -> None:
    for e in effects:
        if not only_mods:
            if s.trigger:
                e["trigger"] = dict(s.trigger)
                if e["kind"] == "static":
                    e["kind"] = "proc"
            conds = list(s.conditions)
            if e["condition"]:
                conds.insert(0, e["condition"])
            if conds:
                e["condition"] = conds[0] if len(conds) == 1 else {"type": "all", "of": conds}
                if e["kind"] == "static":
                    e["kind"] = "conditional"
            if (
                re.search(r"\bgroup members?\b|\ballies\b|\bally\b", s.text, re.I)
                and e["scope"] == "self"
            ):
                e["scope"] = "group"
            if e["scope"] == "self" and ALLY_TARGET.search(s.text) and e["kind"] not in ("damage",):
                e["scope"] = "ally"
        m = s.mods
        if e["trigger"] is None and ("cooldown" in m or "chance" in m):
            if only_mods:
                continue  # a trailing cooldown note doesn't turn a static bonus into a proc
            e["trigger"] = {"on": "other", "chance": None, "cooldown_s": None}
        if e["trigger"] is not None:
            if "cooldown" in m:
                e["trigger"]["cooldown_s"] = m["cooldown"]
            if "chance" in m:
                e["trigger"]["chance"] = round(m["chance"] / 100, 4)
        # interval ("… per second") belongs to the nearest payload; a timed area only
        # applies to damage/heal that ticks, not to an instant hit in the same sentence
        pos = e.get("_pos")
        payloads = [x for x in effects if x.get("_pos") is not None]
        nearest = None
        if "_pos_interval" in m and payloads:
            nearest = min(payloads, key=lambda x: abs(x["_pos"] - m["_pos_interval"]))
        ticks = "interval" in m and (
            nearest is None or len(payloads) == 1 or (pos is not None and pos == nearest["_pos"])
        )
        instant = (
            e["kind"] in ("resource_restore", "damage", "heal") and not ticks and "over" not in m
        )
        if "duration" in m and e["duration_s"] is None and not instant:
            e["duration_s"] = m["duration"]
        if "over" in m and e["kind"] in ("damage", "heal"):
            e["damage"] = {**(e["damage"] or {}), "over_s": m["over"]}
        if "stacks" in m:
            e["stacks"] = {**(e["stacks"] or {}), "max": m["stacks"]}
        if "stack_threshold" in m:
            e["stacks"] = {**(e["stacks"] or {}), "threshold": m["stack_threshold"]}
        extra = {
            k: v
            for k, v in m.items()
            if k
            in (
                "radius",
                "targets",
                "delay",
                "duration_per_ult",
                "pvp_duration",
                "window",
                "pvp_value",
                "ratio",
                "multiplier",
                "level",
            )
        }
        if "interval" in m and ticks:
            extra["interval"] = m["interval"]
        if extra:
            e["extra"] = {**e.get("extra", {}), **extra}
            if e["kind"] in ("damage", "heal") and "interval" in extra:
                e["damage"] = {**(e["damage"] or {}), "interval_s": extra["interval"]}
        scaling = _scaling(s.text)
        if scaling and e["kind"] in ("damage", "heal", "shield"):
            e["extra"] = {**e.get("extra", {}), "scales_off": scaling}


def _scaling(text: str) -> str | None:
    t = text.lower()
    if (
        "higher of your weapon and spell damage" in t
        or "higher of your weapon or spell damage" in t
    ):
        return "max_power"
    if (
        "higher of your max magicka or stamina" in t
        or "higher of your maximum magicka or stamina" in t
    ):
        return "max_resource"
    if "your max health" in t or "your maximum health" in t:
        return "max_health"
    if "your max magicka" in t:
        return "max_magicka"
    if "your max stamina" in t:
        return "max_stamina"
    return None


def _has_text_condition(c: dict[str, Any] | None) -> bool:
    if not c:
        return False
    if c.get("type") == "text":
        return True
    return any(_has_text_condition(x) for x in c.get("of", []))


def _cond_text(c: dict[str, Any]) -> str:
    if c.get("type") == "text":
        return c["text"]
    return "; ".join(_cond_text(x) for x in c.get("of", []) if _has_text_condition(x))


# --- corpus-level ------------------------------------------------------------------


_EMPTY_CTX = Ctx({}, {}, set())


def build_ctx(buffs: list[dict[str, Any]], sets: list[dict[str, Any]]) -> Ctx:
    groups: dict[str, dict[str, str]] = {}
    kinds: dict[str, str] = {}
    for b in buffs:
        if b["tier"]:
            groups.setdefault(b["group"].lower(), {})[b["tier"]] = b["key"]
            kinds[b["key"]] = b["kind"]
    buff_pages = {f"{t.title()} {g.title()}" for g, tiers in groups.items() for t in tiers}
    skills: set[str] = set()
    for s in sets:
        for b in s["bonuses"]:
            for link in b["links"]:
                name = link.split(":", 1)[-1]
                if (
                    link.startswith("Online:")
                    and name not in MECHANIC_LINKS
                    and name not in SKILL_LINES
                    and name not in buff_pages
                    and not re.search(rf"\b(?:{DAMAGE_TYPES}) Damage$", name)
                    and name in b["text"]
                ):
                    skills.add(name)
    return Ctx(groups, kinds, skills)


def normalize_sets(sets: list[dict[str, Any]], buffs: list[dict[str, Any]]) -> dict[str, Any]:
    """Fill every bonus's effects in place; return coverage stats + issue list."""
    ctx = build_ctx(buffs, sets)
    stats: dict[str, dict[str, int]] = {}
    issues: list[dict[str, Any]] = []
    for s in sets:
        for b in s["bonuses"]:
            effects, coverage, probs = normalize_bonus(b["text"], ctx)
            b["effects"] = effects
            b["coverage"] = coverage
            if s["deprecated"]:
                continue
            bucket = "signature" if b["pieces"] == s["max_pieces"] or b["perfected"] else "stat"
            stats.setdefault(bucket, {"full": 0, "partial": 0, "none": 0})[coverage] += 1
            if coverage != "full":
                issues.append(
                    {
                        "set": s["name"],
                        "slug": s["slug"],
                        "type": s["type"],
                        "pieces": b["pieces"],
                        "coverage": coverage,
                        "text": b["text"],
                        "issues": probs,
                    }
                )
    return {"coverage": stats, "issues": issues, "skills": sorted(ctx.skills)}
