"""Tests for the LLM digest encoding. Run: `task setdb:test`."""

from __future__ import annotations

import unittest

from .digest import LEGEND, compact_bonus, compact_effect


def effect(**kw) -> dict:
    base = {
        "stat": "weapon_damage", "value": 129, "unit": "flat", "scope": "self", "kind": "static",
        "condition": None, "trigger": None, "duration_s": None, "stacks": None, "damage": None,
        "buff_ref": None, "uptime_est": 1.0, "uptime_source": "static", "raw": "…",
    }  # fmt: skip
    return {**base, **kw}


class Effects(unittest.TestCase):
    def test_always_on_stat_is_a_string(self):
        self.assertEqual(compact_effect(effect()), "weapon_damage+129")
        self.assertEqual(
            compact_effect(effect(stat="ability_cost_pct", value=-8, unit="pct")),
            "ability_cost_pct-8%",
        )

    def test_always_on_buff_is_plus_key(self):
        e = effect(
            stat="minor_slayer", value=None, unit=None, kind="buff_grant", buff_ref="minor_slayer"
        )
        self.assertEqual(compact_effect(e), "+minor_slayer")

    def test_proc_keeps_structure_with_short_keys(self):
        e = effect(
            kind="proc", uptime_est=None, duration_s=10,
            trigger={"on": "dodge", "chance": None, "cooldown_s": 5, "skill": None},
            condition={"type": "in_combat"},
        )  # fmt: skip
        out = compact_effect(e)
        self.assertEqual(out["s"], "weapon_damage")
        self.assertEqual(out["tr"], {"on": "dodge", "cd": 5})
        self.assertEqual(out["d"], 10)
        self.assertEqual(out["c"], {"type": "in_combat"})
        self.assertNotIn("up", out)

    def test_group_scope_is_not_collapsed_to_a_string(self):
        self.assertIsInstance(compact_effect(effect(scope="group")), dict)


class Bonuses(unittest.TestCase):
    def bonus(self, **kw) -> dict:
        base = {"pieces": 5, "perfected": False, "text": "Adds 129 Weapon Damage",
                "coverage": "full", "effects": [effect()]}  # fmt: skip
        return {**base, **kw}

    def test_simple_stat_line_drops_text(self):
        self.assertNotIn("tx", compact_bonus(self.bonus(pieces=2), keep_text=True, signature=False))

    def test_signature_line_keeps_text_for_drawbacks(self):
        # Oakensoul: "unable to swap bars" has no number, so effects look complete
        out = compact_bonus(self.bonus(), keep_text=True, signature=True)
        self.assertEqual(out["tx"], "Adds 129 Weapon Damage")

    def test_partial_and_flagged_are_marked(self):
        out = compact_bonus(
            self.bonus(coverage="partial", game_check="mismatch"), keep_text=True, signature=False
        )
        self.assertEqual((out["cov"], out["chk"]), ("partial", "mismatch"))
        self.assertIn("tx", out)

    def test_coverage_none_keeps_text_even_without_text_mode(self):
        b = self.bonus(
            coverage="none", effects=[effect(stat="unmodeled", kind="unmodeled", value=None)]
        )
        out = compact_bonus(b, keep_text=False, signature=False)
        self.assertIn("tx", out)
        self.assertNotIn("x", out)

    def test_perfected_flag(self):
        self.assertEqual(
            compact_bonus(self.bonus(perfected=True), keep_text=False, signature=True)["pf"], 1
        )


class Legend(unittest.TestCase):
    def test_legend_documents_every_short_key(self):
        keys = (
            set(LEGEND["_legend"]["set"])
            | set(LEGEND["_legend"]["bonus"])
            | set(LEGEND["_legend"]["effect_object"])
        )
        for k in (
            "n",
            "t",
            "w",
            "hs",
            "pv",
            "prov",
            "p",
            "pf",
            "tx",
            "cov",
            "chk",
            "s",
            "v",
            "k",
            "sc",
            "tr",
            "st",
            "dmg",
            "up",
        ):
            self.assertIn(k, keys)


if __name__ == "__main__":
    unittest.main()
