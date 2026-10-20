"""Tests for the game-patch overlays. Run: `task setdb:test`."""

from __future__ import annotations

import unittest

from .patches import apply_all, u51_buffs, u51_mundus, u51_sets


def buff(tier: str, group: str, value: float, desc: str, **sources) -> dict:
    return {
        "key": f"{tier}_{group.lower()}", "name": f"{tier.capitalize()} {group}", "group": group,
        "tier": tier, "kind": "buff", "description": desc, "value": value, "unit": "pct",
        "sources": sources,
    }  # fmt: skip


def grant(ref: str) -> dict:
    return {"stat": ref, "kind": "buff_grant", "buff_ref": ref, "value": None}


class U51Buffs(unittest.TestCase):
    def setUp(self):
        self.buffs = [
            buff("major", "Brutality", 20, "Increases weapon damage by 20%.", sets=["Rattlecage"]),
            buff(
                "major", "Sorcery", 20, "Increases spell damage by 20%.", sets=["Rattlecage", "X"]
            ),
            buff("minor", "Savagery", 1314, "Increases weapon critical by 1314."),
            buff(
                "minor",
                "Prophecy",
                1314,
                "Increases spell critical by 1314.",
                abilities=["Y", "Exploitation"],
            ),
        ]

    def test_folds_sorcery_and_prophecy(self):
        self.assertTrue(u51_buffs(self.buffs))
        keys = {b["key"] for b in self.buffs}
        self.assertEqual(keys, {"major_brutality", "minor_savagery"})
        brut = next(b for b in self.buffs if b["key"] == "major_brutality")
        self.assertEqual(brut["sources"]["sets"], ["Rattlecage", "X"])
        self.assertEqual(brut["description"], "Increases Weapon and Spell Damage by 20%.")
        sav = next(b for b in self.buffs if b["key"] == "minor_savagery")
        self.assertEqual(sav["sources"]["abilities"], ["Y"])

    def test_idempotent(self):
        u51_buffs(self.buffs)
        self.assertFalse(u51_buffs(self.buffs))


class U51Sets(unittest.TestCase):
    def test_remaps_and_dedupes_grants(self):
        sets = [
            {
                "tags": ["Major Brutality", "Major Sorcery"],
                "bonuses": [{"effects": [grant("major_brutality"), grant("major_sorcery")]}],
            }
        ]
        self.assertTrue(u51_sets(sets))
        self.assertEqual(sets[0]["tags"], ["Major Brutality"])
        self.assertEqual(
            [e["buff_ref"] for e in sets[0]["bonuses"][0]["effects"]], ["major_brutality"]
        )
        self.assertFalse(u51_sets(sets))

    def test_keeps_unrelated_repeat_grants(self):
        on_block = {**grant("minor_resolve"), "trigger": {"on": "block"}}
        effects = [
            grant("minor_resolve"),
            on_block,
            {**grant("major_sorcery"), "trigger": {"on": "kill"}},
        ]
        sets = [{"tags": [], "bonuses": [{"effects": effects + [grant("major_brutality")]}]}]
        u51_sets(sets)
        refs = [e["buff_ref"] for e in sets[0]["bonuses"][0]["effects"]]
        self.assertEqual(
            refs, ["minor_resolve", "minor_resolve", "major_brutality", "major_brutality"]
        )

    def test_lone_prophecy_becomes_savagery(self):
        sets = [{"tags": [], "bonuses": [{"effects": [grant("minor_prophecy")]}]}]
        u51_sets(sets)
        self.assertEqual(sets[0]["bonuses"][0]["effects"][0]["stat"], "minor_savagery")


class U51Mundus(unittest.TestCase):
    def test_warrior_and_apprentice(self):
        vals = {"value": 238, "full_divines_value": 389}
        mundus = [
            {"key": "the_warrior", "effect": "Increases Weapon Damage", **vals},
            {"key": "the_apprentice", "effect": "Increases Spell Damage", **vals},
        ]
        self.assertTrue(u51_mundus(mundus))
        self.assertEqual(mundus[0]["effect"], "Increases Weapon and Spell Damage")
        self.assertEqual(mundus[0]["value"], 238)
        self.assertIsNone(mundus[1]["value"])
        self.assertFalse(u51_mundus(mundus))

    def test_apply_all_reports_nothing_when_wiki_is_current(self):
        out = apply_all(
            [], [], [{"key": "the_warrior", "effect": "Increases Weapon and Spell Damage"}]
        )
        self.assertEqual(out, {"sets": [], "buffs": [], "mundus": []})


if __name__ == "__main__":
    unittest.main()
