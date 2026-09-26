"""Regression tests for the effect normalizer.

Every case here was once modeled wrongly and passed as `full`; they're pinned so
grammar changes can't silently reintroduce the error. Run: `task setdb:test`.
"""

from __future__ import annotations

import unittest

from .normalize import Ctx, normalize_bonus

BUFF_GROUPS = {
    g: {"minor": f"minor_{g}", "major": f"major_{g}"}
    for g in (
        "slayer",
        "aegis",
        "expedition",
        "vitality",
        "protection",
        "defile",
        "force",
        "heroism",
        "maim",
        "breach",
        "brutality",
        "sorcery",
    )
}
DEBUFFS = {
    "minor_defile",
    "major_defile",
    "minor_maim",
    "major_maim",
    "minor_breach",
    "major_breach",
}
CTX = Ctx(
    buff_groups=BUFF_GROUPS,
    buff_kinds={
        k: ("debuff" if k in DEBUFFS else "buff") for g in BUFF_GROUPS.values() for k in g.values()
    },
    skills={"Steadfast Ward", "Grand Healing", "Wall of Elements"},
)


def run(text: str) -> tuple[list[dict], str]:
    effects, coverage, _ = normalize_bonus(text, CTX)
    return effects, coverage


def by_stat(effects: list[dict], stat: str) -> list[dict]:
    return [e for e in effects if e["stat"] == stat]


class FlatStats(unittest.TestCase):
    def test_range_takes_cp160_upper_bound_and_splits_hybrid(self):
        effects, cov = run("Adds 3-129 Weapon and Spell Damage")
        self.assertEqual(cov, "full")
        self.assertEqual({e["stat"] for e in effects}, {"weapon_damage", "spell_damage"})
        self.assertTrue(all(e["value"] == 129 and e["uptime_est"] == 1.0 for e in effects))

    def test_armor_is_both_resistances(self):
        effects, _ = run("Adds 34-1487 Armor")
        self.assertEqual({e["stat"] for e in effects}, {"physical_resistance", "spell_resistance"})


class Buffs(unittest.TestCase):
    def test_at_all_times_is_static_and_explanation_not_double_counted(self):
        effects, cov = run(
            "Gain Minor Slayer at all times, increasing your damage done to Dungeon, Trial, and Arena Monsters by 5%."
        )
        self.assertEqual(cov, "full")
        self.assertEqual([e["stat"] for e in effects], ["minor_slayer"])
        self.assertEqual(effects[0]["uptime_est"], 1.0)

    def test_buff_explanation_generating_not_a_restore(self):
        # Daring Corsair: "generating 1 Ultimate" restates Minor Heroism
        effects, _ = run(
            "After casting a Weapon ability, you gain Minor Heroism for 8 seconds, generating 1 Ultimate every 1.5 seconds while in combat."
        )
        self.assertEqual(by_stat(effects, "restore_ultimate"), [])

    def test_self_inflicted_debuff_scope(self):
        # Pirate Skeleton: the Minor Defile is a drawback on you
        effects, _ = run(
            "When you take damage, you transform into a skeleton and gain Major Protection and Minor Defile for 15 seconds, reducing your damage taken by 10% but reducing your healing received and damage shield strength by 6%."
        )
        self.assertEqual(by_stat(effects, "minor_defile")[0]["scope"], "self")

    def test_timed_buff_from_skill_is_triggered_not_static(self):
        # Mender's Ward was once uptime 1.0
        effects, _ = run(
            "Steadfast Ward applies Major Vitality to your target for 4 seconds, increasing their healing received and damage shield strength by 12%."
        )
        e = by_stat(effects, "major_vitality")[0]
        self.assertEqual(e["trigger"]["on"], "cast_skill")
        self.assertIsNone(e["uptime_est"])


class Conditions(unittest.TestCase):
    def test_negated_while(self):
        # Telvanni Enforcer
        effects, _ = run(
            "While Bracing, increase your Magicka Recovery by 369. While you are not Bracing, increase your Stamina Recovery by 369."
        )
        self.assertEqual(by_stat(effects, "magicka_recovery")[0]["condition"]["type"], "blocking")
        self.assertEqual(
            by_stat(effects, "stamina_recovery")[0]["condition"]["type"], "not_blocking"
        )

    def test_unknown_while_is_never_full(self):
        _, cov = run("While you are riding a flying mount, increase your Max Health by 1000.")
        self.assertNotEqual(cov, "full")

    def test_distance_condition_not_radius(self):
        # Kyne's Kiss
        effects, _ = run(
            "When you deal direct damage while 12 meters or further from your target, you heal for 521 Health and restore 30-1314 Stamina."
        )
        self.assertEqual(
            by_stat(effects, "heal")[0]["condition"], {"type": "distance_min", "meters": 12}
        )

    def test_all_damage_types_kept(self):
        # Xanmeer Spellweaver
        effects, _ = run("Increase your damage done with Flame, Frost, and Shock Damage by 5%.")
        self.assertEqual(effects[0]["condition"]["value"], ["flame", "frost", "shock"])


class Scope(unittest.TestCase):
    def test_enemy_resistance_debuff_and_mirror(self):
        # Farstrider
        effects, _ = run(
            "When you deal direct damage with a Blink, Charge, Leap, Teleport, or Pull ability, decrease the Critical Resistance of your enemy by 40% and increase your Critical Resistance by an equal amount for 10 seconds."
        )
        scopes = sorted((e["scope"], e["value"]) for e in by_stat(effects, "crit_resistance"))
        self.assertEqual(scopes, [("self", 40), ("target_debuff", -40)])

    def test_enemy_their_damage_taken(self):
        # Prior Thierric
        effects, _ = run(
            "Enemies within the whirlwind take 283 Physical damage each second and increase their damage taken from your area of effect abilities by 5%."
        )
        self.assertEqual(by_stat(effects, "damage_taken_pct")[0]["scope"], "target_debuff")

    def test_ally_target_after_heal_crit(self):
        # The Blind
        effects, _ = run(
            "When your healing critically strikes, your target gains a Hydroglass Damage Shield that absorbs up to 62-2692 damage for 6 seconds."
        )
        self.assertEqual(by_stat(effects, "damage_shield")[0]["scope"], "ally")


class Modifiers(unittest.TestCase):
    def test_trailing_cooldown_applies_to_all_procs_but_not_statics(self):
        effects, _ = run(
            "Reduce the cost of your Weapon abilities by 10% Magicka or Stamina. After casting a Weapon ability, you gain Minor Heroism for 8 seconds. This effect can occur every 8 seconds."
        )
        self.assertIsNone(by_stat(effects, "ability_cost_pct")[0]["trigger"])
        self.assertEqual(by_stat(effects, "minor_heroism")[0]["trigger"]["cooldown_s"], 8)

    def test_once_every_second_is_cooldown_not_interval(self):
        effects, _ = run(
            "When an enemy you recently damaged dies, you restore 57-2454 Magicka and gain Major Expedition for 8 seconds. These effects can occur once every second."
        )
        e = by_stat(effects, "restore_magicka")[0]
        self.assertEqual(e["trigger"]["cooldown_s"], 1)
        self.assertNotIn("interval", e.get("extra", {}))
        self.assertIsNone(e["duration_s"])  # instant restore doesn't inherit the buff duration

    def test_instant_hit_does_not_inherit_area_tick(self):
        # Thunder Caller
        effects, _ = run(
            "Dealing damage with a fully-charged Heavy Attack calls a bolt of lightning at your target, dealing 467 Shock Damage and leaving a 4 meter lightning crater at their location for 7 seconds, dealing 467 Shock Damage per second to enemies inside."
        )
        bolt, crater = by_stat(effects, "proc_damage")
        self.assertIsNone(bolt["duration_s"])
        self.assertEqual(crater["duration_s"], 7)
        self.assertEqual(crater["damage"]["interval_s"], 1)

    def test_shared_phrase_payloads_tick_together(self):
        # Perfected Grand Rejuvenation
        effects, _ = run(
            "The initial heal of Grand Healing invigorates you and group members affected for 6 seconds, restoring 5-224 Magicka and Stamina every 2 seconds."
        )
        self.assertTrue(all(e["duration_s"] == 6 for e in effects))

    def test_per_x_scaling_recorded(self):
        effects, cov = run(
            "Increase your damage done against enemies by 2% for each Damage Shield on them."
        )
        self.assertEqual(effects[0]["stacks"]["per"], "Damage Shield on them")


class Honesty(unittest.TestCase):
    def test_leftover_number_is_partial(self):
        _, cov = run(
            "Increase your Health Recovery by 2% of your sum total Physical Resistance, up to 1320."
        )
        self.assertNotEqual(cov, "full")

    def test_nonsense_is_unmodeled_with_raw_kept(self):
        effects, cov = run("While crouched, you can see Witnesses and Guards through walls.")
        self.assertEqual(cov, "none")
        self.assertEqual(effects[0]["kind"], "unmodeled")
        self.assertIn("Witnesses", effects[0]["raw"])


if __name__ == "__main__":
    unittest.main()
