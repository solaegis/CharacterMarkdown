"""Tests for the support-table parser. Run: `task setdb:test`."""

from __future__ import annotations

import unittest

from .support import (
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


def page(title: str, wikitext: str) -> dict:
    return {"title": title, "revid": 1, "wikitext": wikitext, "fragments": {}}


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


class Merge(unittest.TestCase):
    def test_keeps_set_sources(self):
        buffs = [buff("major", "Resolve")]
        merge_buff_sources(buffs, {"major_resolve": {"skills": ["Lightning Form"]}})
        self.assertEqual(buffs[0]["sources"], {"sets": ["Some Set"], "skills": ["Lightning Form"]})


if __name__ == "__main__":
    unittest.main()
