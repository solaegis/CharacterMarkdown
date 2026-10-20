"""Stage 2b: game-patch overlays for changes the UESP wiki hasn't caught up with yet.

Each patch is idempotent and self-disabling: it only rewrites records that still
carry the pre-patch wiki text, so once UESP is updated the patch becomes a no-op
and can be deleted. `apply_all` returns the ids of patches that changed anything;
parse.run records them in each envelope's `source.patches`.
"""

from __future__ import annotations

from typing import Any

# --- Update 51 (live 2026-09-28): buff hybridization ----------------------------
#
# Sorcery is folded into Brutality (Weapon and Spell Damage) and Prophecy into
# Savagery (Weapon and Spell Critical). The Warrior mundus becomes hybrid and
# The Apprentice stops giving damage (Experience and Inspiration gain instead).

U51 = "u51"
U51_MERGE = {"sorcery": "brutality", "prophecy": "savagery"}
U51_DESCRIPTIONS = {
    "brutality": "Increases Weapon and Spell Damage by {v}%.",
    "savagery": "Increases Weapon and Spell Critical by {v}.",
}
U51_TAGS = {"Major Sorcery", "Minor Sorcery", "Major Prophecy", "Minor Prophecy"}
# Class passives that granted Minor Sorcery/Prophecy were given new buffs instead
# (Illuminate: group Armor; Exploitation: group Offensive Penetration).
U51_REPLACED_SOURCES = {"Illuminate", "Exploitation"}


def _merge_sources(dst: dict[str, list[str]], src: dict[str, list[str]]) -> None:
    for kind, names in src.items():
        have = dst.setdefault(kind, [])
        have.extend(n for n in names if n not in have and n not in U51_REPLACED_SOURCES)


def u51_buffs(buffs: list[dict[str, Any]]) -> bool:
    by_key = {b["key"]: b for b in buffs}
    removed = {
        f"{tier}_{old}"
        for old in U51_MERGE
        for tier in ("major", "minor")
        if f"{tier}_{old}" in by_key
    }
    if not removed:
        return False
    for key in removed:
        tier, old = key.split("_", 1)
        target = by_key.get(f"{tier}_{U51_MERGE[old]}")
        if target:
            _merge_sources(target["sources"], by_key[key]["sources"])
    for group, template in U51_DESCRIPTIONS.items():
        for tier in ("major", "minor"):
            if b := by_key.get(f"{tier}_{group}"):
                b["description"] = template.format(v=b["value"])
    buffs[:] = [b for b in buffs if b["key"] not in removed]
    return True


def _same_grant(a: dict[str, Any], b: dict[str, Any]) -> bool:
    keys = ("buff_ref", "kind", "trigger", "condition", "duration_s", "scope")
    return all(a.get(k) == b.get(k) for k in keys)


def u51_sets(sets: list[dict[str, Any]]) -> bool:
    changed = False
    for s in sets:
        if U51_TAGS & set(s.get("tags", [])):
            s["tags"] = [t for t in s["tags"] if t not in U51_TAGS]
            changed = True
        for bonus in s["bonuses"]:
            kept: list[dict[str, Any]] = []
            for e in bonus["effects"]:
                tier, _, group = (e.get("buff_ref") or "").partition("_")
                if group in U51_MERGE:
                    changed = True
                    new = f"{tier}_{U51_MERGE[group]}"
                    e = {**e, "buff_ref": new, "stat": new}
                    # "Gain Major Brutality and Sorcery" -> one grant, not two
                    if any(_same_grant(e, k) for k in kept):
                        continue
                kept.append(e)
            bonus["effects"] = kept
    return changed


def u51_mundus(mundus: list[dict[str, Any]]) -> bool:
    changed = False
    for m in mundus:
        if m["key"] == "the_warrior" and "Spell" not in m["effect"]:
            m["effect"] = "Increases Weapon and Spell Damage"
            changed = True
        elif m["key"] == "the_apprentice" and "Spell Damage" in m["effect"]:
            m["effect"] = "Increases Experience and Inspiration gained (no combat stat)"
            m["value"] = m["full_divines_value"] = None
            changed = True
    return changed


def apply_all(
    sets: list[dict[str, Any]], buffs: list[dict[str, Any]], mundus: list[dict[str, Any]]
) -> dict[str, list[str]]:
    """Apply every patch in order; returns {output kind: [patch ids that changed it]}."""
    applied: dict[str, list[str]] = {"sets": [], "buffs": [], "mundus": []}
    if u51_buffs(buffs):
        applied["buffs"].append(U51)
    if u51_sets(sets):
        applied["sets"].append(U51)
    if u51_mundus(mundus):
        applied["mundus"].append(U51)
    return applied
