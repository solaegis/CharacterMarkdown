"""Tests for the SavedVariables reader and game/wiki reconciliation. Run: `task setdb:test`."""

from __future__ import annotations

import copy
import unittest

from .reconcile import (
    SV_GLOBAL,
    LuaReader,
    game_bonus_text,
    name_key,
    numbers,
    reconcile,
    strip_markup,
)

# Real SavedVariables shape: another global first, "(N items)" labels, color codes,
# escaped quotes, a split long string. Values render at default quality — crafted
# sets at ~0.87 of CP160 gold (657 -> 573, 300 -> 261).
SV_TEXT = r"""CharacterMarkdownSettings =
{
    ["Default"] =
    {
        ["@SOLAEGIS"] = { ["$AccountWide"] = { ["version"] = 1, }, },
    },
}
CharacterMarkdownSetDump =
{
    ["meta"] =
    {
        ["apiVersion"] = 101051,
        ["championPoints"] = 336,
        ["language"] = "en",
        ["setCount"] = 4,
    },
    ["sets"] =
    {
        [1] =
        {
            ["id"] = 67,
            ["name"] = "Hunding's Rage",
            ["category"] = "Crafted",
            ["bonuses"] =
            {
                [1] = { ["pieces"] = 2, ["perfected"] = false, ["text"] = "(2 items) Adds |cffffff573|r Critical Chance", },
                [2] = { ["pieces"] = 5, ["perfected"] = false, ["text"] = "(5 items) Adds |cffffff261|r Weapon and Spell Damage", },
                [3] = { ["pieces"] = 5, ["perfected"] = false, ["text"] = "(5 items) Reduces the cost of your abilities by 5%.", },
            },
        },
        [2] =
        {
            ["id"] = 68,
            ["name"] = "Law of Julianos",
            ["category"] = "Crafted",
            ["bonuses"] =
            {
                [1] = { ["pieces"] = 4, ["perfected"] = false, ["text"] = "(4 items) When you Block, deal 2400 Magic Damage and restore 900 Magicka.", },
                [2] = { ["pieces"] = 5, ["perfected"] = false, ["text"] = "(5 items) Adds 261 Weapon and Spell Damage", },
            },
        },
        [3] =
        {
            ["id"] = 801,
            ["name"] = "Coup De Grâce",
            ["category"] = "Dungeons & Trials > Dungeons",
            ["bonuses"] =
            {
                [1] = { ["pieces"] = 2, ["perfected"] = false, ["text"] = "(2 items) Adds 261 Weapon and Spell Damage", },
                [2] = { ["pieces"] = 5, ["perfected"] = false, ["textParts"] = { [1] = "(5 items) When you deal \"direct\" ", [2] = "damage, gain 500 Weapon Damage.", }, },
            },
        },
        [4] =
        {
            ["id"] = 999,
            ["name"] = "Brand New Set",
            ["category"] = "Monster Sets",
            ["bonuses"] = { [1] = { ["pieces"] = 1, ["perfected"] = false, ["text"] = "(1 item) Adds 1206 Maximum Health", }, },
        },
    },
}
"""


def wiki_set(name: str, bonuses: list[tuple[int, str]], status: list[str] | None = None) -> dict:
    return {
        "id": None,
        "slug": name_key(name),
        "name": name,
        "type": "special" if status else "crafted",
        "deprecated": False,
        "wiki_status": status or [],
        "max_pieces": max(p for p, _ in bonuses),
        "bonuses": [
            {"pieces": p, "perfected": False, "text": t, "wikitext": t, "links": [], "effects": []}
            for p, t in bonuses
        ],
    }


WIKI = [
    wiki_set(
        "Hunding's Rage",
        [
            (2, "Adds 15-657 Critical Chance"),
            (5, "Adds 6-300 Weapon and Spell Damage"),
            (5, "Reduces the cost of your abilities by 8%."),  # 2nd 5pc line; game says 5%
        ],
    ),
    wiki_set(
        "Law of Julianos",
        [
            (4, "When you Block, deal 1000 Magic Damage and restore 400 Magicka."),
            (5, "Adds 6-300 Weapon and Spell Damage"),
        ],
    ),
    wiki_set("Coup De Grâce", [(2, "Adds 3-129 Weapon and Spell Damage")], status=["incomplete"]),
    wiki_set("Removed Thing", [(2, "Adds 1 Armor")]),
]


class Reader(unittest.TestCase):
    def test_reads_global_after_other_tables_with_escapes_and_lists(self):
        dump = LuaReader(SV_TEXT).global_assignment(SV_GLOBAL)
        self.assertEqual(dump["meta"]["championPoints"], 336)
        self.assertIsInstance(dump["sets"], list)
        parts = dump["sets"][2]["bonuses"][1]["textParts"]
        self.assertEqual(parts[0], '(5 items) When you deal "direct" ')

    def test_missing_global_is_none(self):
        self.assertIsNone(LuaReader("Other = { }").global_assignment(SV_GLOBAL))


class Helpers(unittest.TestCase):
    def test_strip_markup(self):
        self.assertEqual(
            strip_markup("Adds |cffffff1487|r Armor|t32:32:icon.dds|t"), "Adds 1487 Armor"
        )

    def test_pieces_label_stripped(self):
        self.assertEqual(
            game_bonus_text({"text": "(5 perfected items) Adds 1 Armor"}), "Adds 1 Armor"
        )

    def test_numbers_use_upper_bound(self):
        self.assertEqual(
            numbers("Adds 15-657 Critical Chance"), numbers("Adds 657 Critical Chance")
        )

    def test_name_key_ignores_accents_and_suffix(self):
        self.assertEqual(name_key("Coup De Grâce"), name_key("Coup De Grace"))
        self.assertEqual(name_key("Agility (set)"), name_key("Agility"))


class Reconcile(unittest.TestCase):
    def setUp(self):
        self.sets = copy.deepcopy(WIKI)
        self.report = reconcile(self.sets, LuaReader(SV_TEXT).global_assignment(SV_GLOBAL))
        self.by = {s["name"]: s for s in self.sets}

    def test_ids_and_tier_assigned(self):
        s = self.by["Hunding's Rage"]
        self.assertEqual(s["id"], 67)
        self.assertAlmostEqual(s["game"]["tier"], 0.87, places=2)

    def test_quality_scaled_values_verify_and_wiki_gold_text_is_kept(self):
        # regression: the first design replaced 657 with the game's default-quality 573
        b = self.by["Hunding's Rage"]["bonuses"][0]
        self.assertEqual(b["game_check"], "verified")
        self.assertEqual(b["text"], "Adds 15-657 Critical Chance")

    def test_same_piece_count_lines_pair_in_order(self):
        # regression: the 2nd 5pc line was once compared against the 1st game line
        five = [b for b in self.by["Hunding's Rage"]["bonuses"] if b["pieces"] == 5]
        self.assertEqual(five[0]["game_check"], "verified")
        self.assertEqual(five[1]["game_check"], "mismatch")
        self.assertEqual(five[1]["game_text"], "Reduces the cost of your abilities by 5%.")
        self.assertEqual(len(self.report["mismatches"]), 1)

    def test_proc_tooltips_are_character_scaled_not_mismatches(self):
        four = next(b for b in self.by["Law of Julianos"]["bonuses"] if b["pieces"] == 4)
        self.assertEqual(four["game_check"], "verified")
        self.assertGreaterEqual(self.report["lines_character_scaled"], 1)

    def test_provisional_page_takes_game_bonuses_mapped_to_gold(self):
        s = self.by["Coup De Grâce"]
        self.assertEqual([b["pieces"] for b in s["bonuses"]], [2, 5])
        # 261 was seen twice as the crafted-tier rendering of 300 -> mapped back to gold
        self.assertEqual(s["bonuses"][0]["text"], "Adds 300 Weapon and Spell Damage")
        self.assertEqual(s["bonuses"][0]["game_values"], "mapped_to_gold")
        self.assertEqual(
            s["bonuses"][1]["text"], 'When you deal "direct" damage, gain 500 Weapon Damage.'
        )
        self.assertEqual(s["type"], "dungeon")

    def test_game_only_and_wiki_only_reported(self):
        self.assertIn("Brand New Set", self.by)
        self.assertEqual(self.by["Brand New Set"]["type"], "monster")
        self.assertEqual(self.by["Brand New Set"]["wiki_status"], ["not_on_wiki"])
        self.assertEqual(self.report["wiki_only"], ["Removed Thing"])


if __name__ == "__main__":
    unittest.main()
