#!/usr/bin/env python3
"""Generate champion_points_reference.md from champion_points.yaml."""

from __future__ import annotations

import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
YAML_PATH = ROOT / "examples/templates/champion_points.yaml"
OUT_PATH = ROOT / "examples/templates/champion_points_reference.md"

DISCIPLINES = (
    ("warfare", "Warfare", "Blue", "Mage"),
    ("fitness", "Fitness", "Red", "Warrior"),
    ("craft", "Craft", "Green", "Thief"),
)


def stage_label(stages: int, points_per_stage: int) -> str:
    if stages == 1:
        return str(points_per_stage)
    return f"{stages} × {points_per_stage}"


def render_table(stars: list[dict]) -> str:
    lines = [
        "| **Star** | **Type** | **Max** | **Stages** |",
        "| :--- | :--- | ---: | :--- |",
    ]
    for star in sorted(stars, key=lambda s: s["name"].lower()):
        star_type = "Slottable" if star.get("slottable") else "Passive"
        stages = stage_label(star["stages"], star["points_per_stage"])
        lines.append(
            f"| **{star['name']}** | {star_type} | {star['max_points']} | {stages} |"
        )
    return "\n".join(lines)


def main() -> int:
    with YAML_PATH.open(encoding="utf-8") as handle:
        data = yaml.safe_load(handle)

    sections: list[str] = [
        "# Champion Point star catalog",
        "",
        "> **Source of truth:** [`champion_points.yaml`](champion_points.yaml) — regenerate with",
        "> `python3 scripts/generate_champion_points_reference.py` after YAML edits.",
        "",
        "Use this catalog when writing **Champion Point Mapping** sections in build plans.",
        "Star names, max point totals, and slottable vs passive type must match this table.",
        "",
        "## Planning rules",
        "",
        "- **Disciplines:** Warfare (Blue), Fitness (Red), Craft (Green). Budget is split across all three.",
        "- **Per-discipline cap:** 660 CP per discipline (or `total CP ÷ 3`, whichever is lower).",
        "- **Slottable limit:** 3 starred abilities per discipline below 900 total CP; **4** at 900+ total CP.",
        "- **Spend totals:** Never exceed a star's **Max** column. Partial spends use the **Stages** increments.",
        "- **Constellation cap:** 4 slotted stars per constellation cluster when the discipline allows 4 slots.",
        "- **Names:** Use exact **Star** labels from this catalog (current in-game names).",
        "",
    ]

    for key, label, color, role in DISCIPLINES:
        stars = data[key]
        slottable = sum(1 for s in stars if s.get("slottable"))
        passive = len(stars) - slottable
        max_sum = sum(s["max_points"] for s in stars)
        sections.extend(
            [
                f"## {label} ({color} — {role})",
                "",
                f"*{len(stars)} stars — {slottable} slottable, {passive} passive — {max_sum} max points if fully invested*",
                "",
                render_table(stars),
                "",
            ]
        )

    OUT_PATH.write_text("\n".join(sections), encoding="utf-8")
    print(f"Wrote {OUT_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
