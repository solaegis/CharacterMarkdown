#!/usr/bin/env python3
"""Validate example markdown H2 sections against LAM preset expectations."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Content H2 sections (exclude Table of Contents)
H2_PATTERN = re.compile(r"^## (.+)$", re.MULTILINE)

# Expected content sections per settings profile (see docs/settings-presets-matrix.md)
FACTORY_DEFAULTS_SECTIONS = {
    "Overview",
    "Build Notes",
    "Combat Arsenal",
    "Equipment & Active Sets",
    "Champion Points",
    "Character Progress",
    "Companions",
    "Collectibles",
    "Inventory",
    "Crafting Knowledge",
    "Outfit Styles",
    "Guild Membership",
}

SOLO_PVE_SECTIONS = {
    "Overview",
    "Build Notes",
    "Combat Arsenal",
    "Equipment & Active Sets",
    "Champion Points",
    "Character Progress",
    "PvP",
    "Companions",
    "Collectibles",
    "Quest Progress",
    "Armory Builds",
    "Mail",
    "Guild Membership",
}

# Solo PvE markers (settings not on by factory defaults)
SOLO_PVE_MARKERS = (
    "```mermaid",
    "Detailed Skill Morphs",
    '<summary>💁 Assistants',
)


def normalize_h2_title(title: str) -> str:
    """Strip emoji; keep words with ASCII letters (and &)."""
    words = [part for part in title.split() if re.search(r"[A-Za-z]", part) or part == "&"]
    return " ".join(words) if words else title.strip()


def extract_h2_titles(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    titles: set[str] = set()
    for match in H2_PATTERN.finditer(text):
        title = normalize_h2_title(match.group(1).strip())
        titles.add(title)
    titles.discard("Table of Contents")
    return titles


def validate_profile(path: Path, expected: set[str], profile_name: str) -> list[str]:
    issues: list[str] = []
    found = extract_h2_titles(path)
    missing = expected - found
    extra = found - expected
    if missing:
        issues.append(f"{profile_name}: missing sections: {sorted(missing)}")
    if extra:
        issues.append(f"{profile_name}: unexpected sections: {sorted(extra)}")
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "path",
        nargs="?",
        default="examples/solaegis/na/silent_snow_falls.md",
        help="Example markdown file to validate",
    )
    parser.add_argument(
        "--profile",
        choices=("solo-pve", "factory-defaults", "auto"),
        default="auto",
        help="Preset profile to validate against (auto infers from markers)",
    )
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    path = (root / args.path).resolve() if not Path(args.path).is_absolute() else Path(args.path)

    if not path.is_file():
        print(f"error: file not found: {path}", file=sys.stderr)
        return 1

    text = path.read_text(encoding="utf-8", errors="replace")
    profile = args.profile
    if profile == "auto":
        has_solo_markers = any(m in text for m in SOLO_PVE_MARKERS)
        has_solo_sections = "PvP" in extract_h2_titles(path)
        profile = "solo-pve" if (has_solo_markers or has_solo_sections) else "factory-defaults"

    expected = SOLO_PVE_SECTIONS if profile == "solo-pve" else FACTORY_DEFAULTS_SECTIONS
    found = extract_h2_titles(path)
    issues = validate_profile(path, expected, profile)

    print(f"File: {path.relative_to(root) if path.is_relative_to(root) else path}")
    print(f"Profile: {profile}")
    print(f"Sections found ({len(found)}): {sorted(found)}")
    if issues:
        for issue in issues:
            print(f"FAIL: {issue}")
        return 1

    # Structural checks
    collectibles_count = len(re.findall(r"^## .+Collectibles", text, re.MULTILINE))
    if collectibles_count != 1:
        print(f"FAIL: expected 1 Collectibles H2, found {collectibles_count}")
        return 1

    print("OK: sections match preset expectations")
    return 0


if __name__ == "__main__":
    sys.exit(main())
