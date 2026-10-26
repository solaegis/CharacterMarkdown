"""Tests for the support-table parser. Run: `task setdb:test`."""

from __future__ import annotations

import unittest

from .support import (
    COMPANION_LINES,
    _buff_ctx,
    _food_effects,
    _gate,
    _max_rank,
    _named_buffs,
    _normalize,
    merge_buff_sources,
    parse_cp,
    parse_passives,
    parse_skills,
)


def buff(tier: str, group: str, kind: str = "buff") -> dict:
    return {
        "key": f"{tier}_{group.lower()}", "name": f"{tier.capitalize()} {group}", "group": group,
        "tier": tier, "kind": kind, "description": "", "value": 1, "unit": "pct",
        "sources": {"sets": ["Some Set"]},
    }  # fmt: skip


BUFFS = [
    buff("major", "Resolve"),
    buff("major", "Expedition"),
    buff("minor", "Expedition"),
    buff("major", "Brutality"),
    buff("major", "Savagery"),
    buff("major", "Breach", "debuff"),
    buff("minor", "Force"),
    buff("minor", "Berserk"),
    buff("minor", "Protection"),
]
CTX = _buff_ctx(BUFFS)

LIGHTNING_FORM = """{{Online Skill Summary
|line=Storm Calling
|desc=Manifest yourself as pure lightning, dealing '''{{Nowrap|[1230 / 1243 / 1257 / 1270]}}''' [[Online:Shock Damage|Shock Damage]] every '''2''' seconds. While in this form you also gain [[Online:Major Resolve|Major Resolve]], increasing your {{ESO Resistance Link|Physical}} and {{ESO Resistance Link|Spell}} by '''5948'''.
|desc1=Cost: {{ESO Stamina Link|2295}}.<br>Manifest yourself as pure air. While in this form you gain Major Resolve and [[Online:Minor Expedition|Minor Expedition]], increasing your Movement Speed by '''15'''%.
|desc2=Duration: {{Nowrap|[27 / 28 / 29 / 30]}} seconds.<br>Manifest yourself as pure lightning. While in this form you also gain Major Resolve. Activating this grants you [[Online:Major Expedition|Major Expedition]] for '''4''' seconds.
|cost={{ESO Magicka Link|2700}}
|attrib=Magicka
|morph1name=Hurricane
|morph2name=Boundless Storm
}}"""  # fmt: skip

MAGELIGHT = """{{Online Skill Summary
|line=Mages Guild
|desc=Cost: {{ESO Magicka Link|{{Nowrap|[5400 / 5310 / 5220 / 5130]}}}}.<br>Conjure a mote of magelight. While slotted gain [[Online:Major Savagery|Major Savagery]], increasing Critical Chance by '''12'''% and your {{ESO Magicka Link|Max}} is increased by '''{{Nowrap|[2 / 3 / 4 / 5]}}'''%.
}}"""  # fmt: skip

MAGICKA_MASTERY = """{{Online Skill Summary
|line=Breton
|type=Passive
|desc=Reduces the {{ESO Magicka Link}} cost of your abilities by '''2'''%.
|desc2=Reduces the {{ESO Magicka Link}} cost of your abilities by '''4'''%.
|desc3=Reduces the {{ESO Magicka Link}} cost of your abilities by '''7'''%.
}}"""  # fmt: skip


ACCELERATE = """{{Online Skill Summary
|line=Psijic Order
|desc=Cost: {{ESO Magicka Link|{{Nowrap|[4050 / 3960 / 3870 / 3780]}}}}.<br>Bend time and space around you to gain [[Online:Major Expedition|Major Expedition]] for '''4''' seconds and [[Online:Minor Force|Minor Force]] for '''20''' seconds, increasing your [[Online:Movement Speed|Movement Speed]] by '''30'''% and [[Online:Critical Damage|Critical Damage]] by '''10'''%.
|desc1=Casting Time: 1.3 seconds, Cost: {{ESO Magicka Link|{{Nowrap|[3780 / 3690 / 3600 / 3510]}}}}.<br>Bend time and space around you to gain Major Expedition for '''12''' seconds and Minor Force for '''1''' minute, increasing your Movement Speed by '''30'''% and Critical Damage by '''10'''%.
|desc2=Bend time and space around you to gain Major Expedition for '''4''' seconds and Minor Force for '''20''' seconds, increasing your Movement Speed by '''30'''% and Critical Damage by '''10'''%. Activating this ability removes all snares and immobilizations from you and grants immunity to them for '''{{Nowrap|[2 / 2.7 / 3.3 / 4]}}''' seconds.
|cost={{ESO Magicka Link|3780}}
|attrib=Magicka
|morph1name=Channeled Acceleration
|morph2name=Race Against Time
}}"""  # fmt: skip

MEDICINAL_USE = """{{Online Skill Summary
|line=Alchemy
|type=Passive
|desc=When using [[Online:Potions|potion]]s, resulting effects last 10% longer.
|desc2=When using potions, resulting effects last 20% longer.
|desc3=When using potions, resulting effects last 30% longer.
}}"""  # fmt: skip

CONCENTRATION = """{{Online Skill Summary
|line=Light Armor
|type=Passive
|desc=Increases your {{ESO Physical Penetration Link|||y}} and {{ESO Spell Penetration Link}} by '''469''' for each piece of [[Online:Light Armor|Light Armor]] worn.
|desc2=Increases your {{ESO Physical Penetration Link|||y}} and {{ESO Spell Penetration Link}} by '''939''' for each piece of Light Armor worn.
}}"""  # fmt: skip


def page(title: str, wikitext: str) -> dict:
    return {"title": title, "revid": 1, "wikitext": wikitext, "fragments": {}}


def line_index(line: str, category: str, passive=(), active=()) -> dict:
    return {
        "lines": {
            line: {
                "category": category, "class": None, "passive": list(passive),
                "active": list(active), "ultimate": [],
            }
        }
    }  # fmt: skip


class Text(unittest.TestCase):
    def test_max_rank_takes_rank_four(self):
        self.assertEqual(_max_rank("for [27 / 28 / 29 / 30] seconds"), "for 30 seconds")

    def test_caps_gate_becomes_condition(self):
        cond, rest = _gate("WITH BOW EQUIPPED Increases your Weapon Damage by 10.")
        self.assertEqual(cond, {"type": "weapon_equipped", "value": "Bow"})
        self.assertEqual(rest, "Increases your Weapon Damage by 10.")

    def test_slotted_gate_keeps_the_grant_verb(self):
        cond, rest = _gate("While slotted you gain Major Savagery.")
        self.assertEqual(cond, {"type": "slotted"})
        self.assertEqual(rest, "Gain Major Savagery.")

    def test_named_buffs_split_buff_and_debuff(self):
        b, d, unknown = _named_buffs(
            "Gain Major Resolve and Minor Expedition, then apply Major Breach. Major Nonsense.", CTX
        )
        self.assertEqual(b, ["major_resolve", "minor_expedition"])
        self.assertEqual(d, ["major_breach"])
        self.assertEqual(unknown, ["Major Nonsense"])

    def test_sorcery_reads_as_brutality(self):
        b, _, _ = _named_buffs("Gain Major Sorcery.", CTX)
        self.assertEqual(b, ["major_brutality"])

    def test_flavour_sentences_are_dropped(self):
        effects, coverage, _ = _normalize(
            "Rock and stone shield your heart. Increases your Max Health by 1000.", CTX
        )
        self.assertEqual(coverage, "full")
        self.assertEqual([(e["stat"], e["value"]) for e in effects], [("max_health", 1000)])

    def test_group_grant_is_group_scope(self):
        effects, _, _ = _normalize(
            "Attempting to activate a Dark Magic skill grants you and your group 2974 "
            "Offensive Penetration for 20 seconds.",
            CTX,
        )
        e = effects[0]
        self.assertEqual(
            (e["stat"], e["value"], e["scope"]), ("offensive_penetration", 2974, "group")
        )

    def test_weapon_type_alternatives(self):
        effects, _, _ = _normalize(
            "WITH A TWO-HANDED WEAPON EQUIPPED Grants a bonus based on the type of weapon "
            "equipped: Swords increase your Weapon Damage by 258. Axes increase your Critical "
            "Damage done by 12%.",
            CTX,
        )
        types = {e["stat"]: e["condition"]["of"][1]["value"] for e in effects}
        self.assertEqual(types, {"weapon_damage": "sword", "crit_damage_pct": "axe"})


class Food(unittest.TestCase):
    def test_shared_suffix_and_prefix(self):
        effects, coverage, _ = _food_effects(
            "Increase Max Health by 4620, Max Stamina and Max Magicka by 4250, and Stamina and "
            "Magicka Recovery by 462",
            "raw",
        )
        self.assertEqual(coverage, "full")
        self.assertEqual(
            [(e["stat"], e["value"]) for e in effects],
            [
                ("max_health", 4620),
                ("max_stamina", 4250),
                ("max_magicka", 4250),
                ("stamina_recovery", 462),
                ("magicka_recovery", 462),
            ],
        )

    def test_stops_at_flavour_text(self):
        effects, _, _ = _food_effects(
            "Increase Max Health by 4312 and Health Recovery by 406 Wrothgar's hearth-wives by 2",
            "raw",
        )
        self.assertEqual(len(effects), 2)


class Tables(unittest.TestCase):
    def test_passive_ranks(self):
        index = {
            "lines": {"Breton": {"category": "race", "class": None, "passive": ["Magicka Mastery"]}}
        }
        pages = {"Online:Magicka Mastery": page("Online:Magicka Mastery", MAGICKA_MASTERY)}
        items, warnings, _ = parse_passives(index, pages, CTX)
        self.assertEqual(warnings, [])
        p = items[0]
        self.assertEqual([r["rank"] for r in p["ranks"]], [1, 2, 3])
        e = p["ranks"][-1]["effects"][0]
        self.assertEqual((e["stat"], e["value"]), ("ability_cost_pct", -7))
        self.assertTrue(p["verified"])

    def test_skill_morphs_cost_and_buffs(self):
        index = {
            "lines": {
                "Storm Calling": {
                    "category": "class", "class": "Sorcerer", "passive": [],
                    "active": ["Lightning Form"], "ultimate": [],
                }
            }
        }  # fmt: skip
        pages = {"Online:Lightning Form": page("Online:Lightning Form", LIGHTNING_FORM)}
        items, _, _ = parse_skills(index, pages, CTX)
        by = {i["name"]: i for i in items}
        self.assertEqual(by["Lightning Form"]["cost"], 2700)
        self.assertEqual(by["Hurricane"]["resource"], "stamina")
        self.assertEqual(by["Hurricane"]["cost"], 2295)
        self.assertEqual(by["Hurricane"]["buffs_granted"], ["major_resolve", "minor_expedition"])
        self.assertEqual(
            by["Boundless Storm"]["buffs_granted"], ["major_resolve", "major_expedition"]
        )
        self.assertEqual(by["Boundless Storm"]["base"], "Lightning Form")
        # Major Resolve's explainer is not a separate resistance grant
        self.assertEqual(by["Lightning Form"]["effects"], [])

    def test_slotted_stat_grant_kept(self):
        index = {
            "lines": {
                "Mages Guild": {
                    "category": "guild", "class": None, "passive": [], "active": ["Magelight"],
                    "ultimate": [],
                }
            }
        }  # fmt: skip
        pages = {"Online:Magelight": page("Online:Magelight", MAGELIGHT)}
        items, _, _ = parse_skills(index, pages, CTX)
        s = items[0]
        self.assertEqual(s["cost"], 5130)
        self.assertEqual(s["buffs_granted"], ["major_savagery"])
        self.assertEqual([(e["stat"], e["value"]) for e in s["effects"]], [("max_magicka", 5)])

    def test_cp_per_stage_is_max_rank(self):
        star = {
            "id": 25, "name": "Deadly Aim", "constellation": "warfare", "slottable": True,
            "stages": 2, "points_per_stage": 25, "max_points": 50, "prerequisites": [],
        }  # fmt: skip
        text = (
            "{{Online Champion 2.0 Summary\n|desc=Increase your damage done with single "
            "target attacks by 3% per stage.\n}}"
        )
        items, _, _ = parse_cp([star], {"Online:Deadly Aim": page("Online:Deadly Aim", text)}, CTX)
        e = items[0]["effects"][0]
        self.assertEqual((e["stat"], e["value"]), ("damage_done_pct", 6))
        self.assertTrue(items[0]["verified"])


class Hardening(unittest.TestCase):
    def test_accelerate_morphs_grant_minor_force(self):
        index = line_index("Psijic Order", "guild", active=["Accelerate"])
        pages = {"Online:Accelerate": page("Online:Accelerate", ACCELERATE)}
        items, _, _ = parse_skills(index, pages, CTX)
        by = {i["name"]: i for i in items}
        for name in ("Accelerate", "Channeled Acceleration", "Race Against Time"):
            self.assertEqual(by[name]["buffs_granted"], ["major_expedition", "minor_force"], name)
            self.assertTrue(by[name]["verified"], name)
        self.assertEqual(by["Accelerate"]["cost"], 3780)
        # "Casting Time: …, Cost: …" header carries the morph's own cost
        self.assertEqual(by["Channeled Acceleration"]["cost"], 3510)

    def test_medicinal_use_duration_ranks(self):
        index = line_index("Alchemy", "skill_line", passive=["Medicinal Use"])
        pages = {"Online:Medicinal Use": page("Online:Medicinal Use", MEDICINAL_USE)}
        items, _, _ = parse_passives(index, pages, CTX)
        p = items[0]
        self.assertTrue(p["verified"])
        self.assertEqual(
            [[(e["stat"], e["value"]) for e in r["effects"]] for r in p["ranks"]],
            [
                [("potion_duration_pct", 10)],
                [("potion_duration_pct", 20)],
                [("potion_duration_pct", 30)],
            ],
        )

    def test_concentration_is_per_light_piece(self):
        index = line_index("Light Armor", "skill_line", passive=["Concentration"])
        pages = {"Online:Concentration": page("Online:Concentration", CONCENTRATION)}
        items, _, _ = parse_passives(index, pages, CTX)
        effects = items[0]["ranks"][1]["effects"]
        self.assertEqual(len(effects), 1)
        e = effects[0]
        self.assertEqual((e["stat"], e["value"]), ("offensive_penetration", 939))
        self.assertEqual(e["stacks"], {"per": "piece of Light Armor worn"})
        self.assertTrue(items[0]["verified"])

    def test_thaumaturge_is_dot_only(self):
        star = {
            "id": 27, "name": "Thaumaturge", "constellation": "warfare", "slottable": True,
            "stages": 2, "points_per_stage": 25, "max_points": 50, "prerequisites": [],
        }  # fmt: skip
        text = (
            "{{Online Champion 2.0 Summary\n|desc=Increases your damage done with damage over "
            "time effects by 3% per stage.\n}}"
        )
        items, _, _ = parse_cp(
            [star], {"Online:Thaumaturge": page("Online:Thaumaturge", text)}, CTX
        )
        self.assertEqual(
            [(e["stat"], e["value"], e["condition"]) for e in items[0]["effects"]],
            [("dot_damage_pct", 6, None)],
        )
        self.assertTrue(items[0]["verified"])

    def test_activation_gate_becomes_trigger(self):
        effects, coverage, _ = _normalize(
            "WHEN ACTIVATING AN AEDRIC SPEAR ABILITY Gain Minor Berserk and Minor Protection for "
            "6 seconds, increasing damage done and reducing damage taken by 5%.",
            CTX,
        )
        self.assertEqual(coverage, "full")
        self.assertEqual([e["buff_ref"] for e in effects], ["minor_berserk", "minor_protection"])
        for e in effects:
            self.assertEqual(e["trigger"]["on"], "cast_skill")
            self.assertEqual(e["duration_s"], 6)
            self.assertIsNone(e["condition"])

    def test_buff_restatement_is_not_a_second_grant(self):
        effects, coverage, _ = _normalize(
            "WITH BOW EQUIPPED Grants you Major Expedition for 4 seconds after you use Roll "
            "Dodge. Major Expedition increases your Movement Speed by 30%.",
            CTX,
        )
        self.assertEqual(coverage, "full")
        self.assertEqual(len(effects), 1)
        self.assertEqual(effects[0]["trigger"]["on"], "dodge")

    def test_disease_and_poison_resist(self):
        effects, coverage, _ = _normalize(
            "Increases your Max Health by 1000 and your Disease and Poison Resistance by 2310.", CTX
        )
        self.assertEqual(coverage, "full")
        self.assertEqual(
            sorted((e["stat"], e["value"]) for e in effects),
            [("disease_resistance", 2310), ("max_health", 1000), ("poison_resistance", 2310)],
        )

    def test_capture_window_is_not_always_on(self):
        effects, _, _ = _normalize(
            "Increases your Weapon Damage and Spell Damage by 10% for 10 minutes after you "
            "capture a Lumber Mill, Farm, Mine, or Keep.",
            CTX,
        )
        self.assertTrue(effects)
        for e in effects:
            self.assertEqual(e["kind"], "proc")
            self.assertEqual(e["duration_s"], 600)
            self.assertEqual(e["trigger"]["on"], "capture_objective")

    def test_companion_lines_skipped_at_parse(self):
        self.assertIn("Ardent Warrior", COMPANION_LINES)
        index = line_index("Ardent Warrior", "class", active=["Accelerate"])
        pages = {"Online:Accelerate": page("Online:Accelerate", ACCELERATE)}
        items, _, _ = parse_skills(index, pages, CTX)
        self.assertEqual(items, [])


class Merge(unittest.TestCase):
    def test_keeps_set_sources(self):
        buffs = [buff("major", "Resolve")]
        merge_buff_sources(buffs, {"major_resolve": {"skills": ["Lightning Form"]}})
        self.assertEqual(buffs[0]["sources"], {"sets": ["Some Set"], "skills": ["Lightning Form"]})


if __name__ == "__main__":
    unittest.main()
