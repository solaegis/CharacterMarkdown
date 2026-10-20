#!/usr/bin/env python3
"""
Verify example character markdown files match ESO SavedVariables triples.

Character identity: (account, location, slug) where slug is slugified display name.
Same slug may exist under different accounts OR locations, not both duplicated.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from example_slug import account_slug, location_slug, slugify

Triple = tuple[str, str, str]  # account, location, slug

PROFILE_SUFFIXES = ("_plan", "_crafting")
SKIP_DIRS = {"templates", "fixtures"}
VALID_BASENAME = re.compile(r"^[a-z0-9_]+\.md$")


@dataclass
class Issue:
    level: str  # error | warn
    message: str


def parse_zo_ingame(path: Path, default_location: str) -> set[Triple]:
    """Extract character triples from ZO_Ingame.lua (single location stamp).

    Prefer parse_zo_live_characters() + CharacterMarkdown megaserver triples for
    multi-megaserver accounts; this helper remains for callers that pass --location.
    """
    live = parse_zo_live_characters(path)
    return {(account, default_location, slug) for account, slug in live}


def parse_zo_live_characters(path: Path) -> set[tuple[str, str]]:
    """Return (account_slug, character_slug) pairs present in ZO_Ingame.lua."""
    text = path.read_text(encoding="utf-8", errors="replace")
    live: set[tuple[str, str]] = set()
    current_account: str | None = None

    for line in text.splitlines():
        account_match = re.match(r'^\s{8}\["(@[^"]+)"\]\s*=\s*$', line)
        if account_match:
            current_account = account_slug(account_match.group(1))
            continue

        char_match = re.match(r'^\s{12}\["([^"]+)"\]\s*=\s*$', line)
        if char_match and current_account:
            name = char_match.group(1)
            if name.startswith("@") or name == "$AccountWide":
                continue
            live.add((current_account, slugify(name)))

    return live


def _megaserver_to_location(megaserver: str) -> str | None:
    upper = megaserver.upper()
    if "EU" in upper:
        return "eu"
    if "NA" in upper:
        return "na"
    return None


def parse_character_markdown_sv(
    path: Path, default_location: str | None = None
) -> set[Triple]:
    """Extract (account, location, slug) from CharacterMarkdown megaserver PCD.

    Walks Default/@account/$AccountWide/(NA|EU) Megaserver/perCharacterData.
    When default_location is set, only that megaserver's triples are returned.
    """
    text = path.read_text(encoding="utf-8", errors="replace")
    triples: set[Triple] = set()
    stack: list[tuple[int, str]] = []

    lines = text.splitlines()
    for i, line in enumerate(lines):
        key_match = re.match(r'^(\s*)\["([^"]+)"\]\s*=\s*(.*)$', line)
        if not key_match:
            continue
        indent = len(key_match.group(1))
        key = key_match.group(2)
        rest = key_match.group(3).strip()
        while stack and stack[-1][0] >= indent:
            stack.pop()
        stack.append((indent, key))
        path_keys = [k for _, k in stack]

        if not (
            key.isdigit()
            and "perCharacterData" in path_keys
            and rest == ""
            and "Default" in path_keys
        ):
            continue

        # Require Default / @account / $AccountWide / Megaserver / ... / perCharacterData / id
        # Reject nested corrupt Default trees (second Default after megaserver).
        try:
            d_idx = path_keys.index("Default")
            account_key = path_keys[d_idx + 1]
            if not account_key.startswith("@"):
                continue
            megaserver = next(
                (k for k in path_keys if k.endswith("Megaserver")),
                None,
            )
            if not megaserver:
                continue
            ms_idx = path_keys.index(megaserver)
            pcd_idx = path_keys.index("perCharacterData")
            if "Default" in path_keys[ms_idx + 1 : pcd_idx]:
                continue
        except (ValueError, IndexError):
            continue

        location = _megaserver_to_location(megaserver)
        if location is None:
            continue
        if default_location is not None and location != default_location:
            continue

        body = "\n".join(lines[i + 1 : i + 25])
        account_match = re.search(r'\["_accountName"\]\s*=\s*"(@[^"]+)"', body)
        name_match = re.search(r'\["_characterName"\]\s*=\s*"([^"]+)"', body)
        account = account_slug(account_match.group(1) if account_match else account_key)
        if not name_match:
            continue
        triples.add((account, location, slugify(name_match.group(1))))

    return triples


def parse_profile_metadata(path: Path) -> tuple[str | None, str | None, str | None]:
    """Return (account, location, h1_title) from markdown."""
    content = path.read_text(encoding="utf-8", errors="replace")
    account = None
    location = None
    h1 = None

    account_match = re.search(r"\|\s*\*\*Account\*\*\s*\|\s*(@[^\s|]+)", content)
    if account_match:
        account = account_slug(account_match.group(1))

    server_match = re.search(
        r"\|\s*\*\*Server\*\*\s*\|\s*(?:\[)?([^\]|]+?)(?:\]\([^)]*\))?\s*\|",
        content,
    )
    if server_match:
        location = location_slug(server_match.group(1))

    h1_match = re.search(r"^#\s+(.+?)\s*(?:\(|$)", content, re.MULTILINE)
    if h1_match:
        h1 = h1_match.group(1).strip()

    return account, location, h1


def is_profile_file(path: Path) -> bool:
    stem = path.stem
    if stem.endswith(PROFILE_SUFFIXES):
        return False
    if path.name == "README.md":
        return False
    parts = path.parts
    if "examples" not in parts:
        return False
    idx = parts.index("examples")
    rel_parts = parts[idx + 1 :]
    if not rel_parts or rel_parts[0] in SKIP_DIRS:
        return False
    # Must be under examples/{account}/{location}/
    if len(rel_parts) < 3:
        return False
    return True


def is_plan_file(path: Path) -> bool:
    return path.stem.endswith("_plan")


def collect_example_profiles(examples_dir: Path) -> dict[Triple, list[Path]]:
    """Map triple -> profile paths (detect duplicates)."""
    profiles: dict[Triple, list[Path]] = {}
    for path in examples_dir.rglob("*.md"):
        if not is_profile_file(path):
            continue
        parts = path.relative_to(examples_dir).parts
        account, location = parts[0], parts[1]
        slug = path.stem
        triple = (account, location, slug)
        profiles.setdefault(triple, []).append(path)
    return profiles


def collect_flat_misplaced(examples_dir: Path) -> list[Path]:
    """Character-like .md files directly under examples/{account}/ (no location)."""
    misplaced: list[Path] = []
    for account_dir in examples_dir.iterdir():
        if not account_dir.is_dir() or account_dir.name in SKIP_DIRS:
            continue
        for path in account_dir.glob("*.md"):
            misplaced.append(path)
    return misplaced


def check_plan_links(examples_dir: Path) -> list[Issue]:
    issues: list[Issue] = []
    for path in examples_dir.rglob("*_plan.md"):
        if "fixtures" in path.parts or "templates" in path.parts:
            continue
        content = path.read_text(encoding="utf-8", errors="replace")
        for match in re.finditer(r"\]\(([^)]+\.md)\)", content):
            link = match.group(1)
            if link.startswith("http"):
                continue
            target = (path.parent / link).resolve()
            if not target.exists():
                issues.append(
                    Issue("warn", f"Broken plan link in {path}: {link}")
                )
    return issues


def infer_default_location(saved_variables: Path) -> str:
    parent = saved_variables.parent.name.lower()
    if parent == "liveeu":
        return "eu"
    return "na"


def run_checks(
    saved_variables: Path,
    examples_dir: Path,
    default_location: str | None,
    allow_orphan_examples: bool,
) -> list[Issue]:
    issues: list[Issue] = []

    zo_path = saved_variables / "ZO_Ingame.lua"
    if not zo_path.exists():
        issues.append(Issue("error", f"Missing {zo_path}"))
        return issues

    zo_live = parse_zo_live_characters(zo_path)
    cm_path = saved_variables / "CharacterMarkdown.lua"
    if not cm_path.exists():
        issues.append(Issue("error", f"Missing {cm_path}"))
        return issues

    # Source of truth for (account, location, slug): CM megaserver namespaces
    sv_triples = parse_character_markdown_sv(cm_path, default_location)

    for account, location, slug in sorted(sv_triples):
        if (account, slug) not in zo_live:
            issues.append(
                Issue(
                    "warn",
                    f"CharacterMarkdown.lua has {(account, location, slug)} "
                    f"but ZO_Ingame.lua has no matching account/name",
                )
            )

    # Characters in ZO with no CM row at any location (after optional location filter)
    cm_account_slugs = {(a, s) for a, _, s in sv_triples}
    if default_location is None:
        for account, slug in sorted(zo_live - cm_account_slugs):
            issues.append(
                Issue(
                    "warn",
                    f"ZO_Ingame.lua has ({account}, {slug}) but "
                    f"CharacterMarkdown.lua has no perCharacterData row",
                )
            )

    profiles = collect_example_profiles(examples_dir)
    example_triples = set(profiles.keys())

    for triple in sorted(sv_triples):
        if triple not in example_triples:
            issues.append(
                Issue(
                    "error",
                    f"Missing example profile: examples/{triple[0]}/{triple[1]}/{triple[2]}.md",
                )
            )

    if not allow_orphan_examples:
        for triple in sorted(example_triples - sv_triples):
            paths = profiles[triple]
            account, location, slug = triple
            # True orphan: not in CM and name absent from ZO entirely
            if (account, slug) not in zo_live:
                issues.append(
                    Issue(
                        "error",
                        f"Orphan example (not in SavedVariables): {paths[0]}",
                    )
                )
            else:
                issues.append(
                    Issue(
                        "error",
                        f"Example location mismatch (live in ZO, not in CM "
                        f"{location}): {paths[0]}",
                    )
                )

    for triple, paths in profiles.items():
        if len(paths) > 1:
            joined = ", ".join(str(p) for p in paths)
            issues.append(Issue("error", f"Duplicate triple {triple}: {joined}"))

    for path in collect_flat_misplaced(examples_dir):
        issues.append(
            Issue(
                "error",
                f"Misplaced file (missing location directory): {path}",
            )
        )

    for path in examples_dir.rglob("*.md"):
        if "fixtures" in path.parts or "templates" in path.parts:
            continue
        if path.name == "README.md":
            continue
        if not VALID_BASENAME.match(path.name):
            issues.append(
                Issue(
                    "error",
                    f"Invalid filename (use lowercase underscores): {path}",
                )
            )

    for triple, paths in profiles.items():
        path = paths[0]
        meta_account, meta_location, h1 = parse_profile_metadata(path)
        account, location, slug = triple

        if meta_account and meta_account != account:
            issues.append(
                Issue(
                    "error",
                    f"Path account '{account}' != markdown Account '@{meta_account}': {path}",
                )
            )
        if meta_location and meta_location != location:
            issues.append(
                Issue(
                    "error",
                    f"Path location '{location}' != markdown Server '{meta_location}': {path}",
                )
            )
        if h1 and slugify(h1) != slug:
            issues.append(
                Issue(
                    "warn",
                    f"H1 '{h1}' slugifies to '{slugify(h1)}' not '{slug}': {path}",
                )
            )

    issues.extend(check_plan_links(examples_dir))
    return issues


def delete_true_orphan_examples(
    saved_variables: Path,
    examples_dir: Path,
) -> list[Path]:
    """Delete example profiles absent from CM and ZO. Returns deleted paths."""
    zo_live = parse_zo_live_characters(saved_variables / "ZO_Ingame.lua")
    cm_triples = parse_character_markdown_sv(
        saved_variables / "CharacterMarkdown.lua", None
    )
    profiles = collect_example_profiles(examples_dir)
    deleted: list[Path] = []
    for triple, paths in profiles.items():
        account, _location, slug = triple
        if triple in cm_triples:
            continue
        if (account, slug) in zo_live:
            continue
        for path in paths:
            path.unlink()
            deleted.append(path)
            plan = path.with_name(path.stem + "_plan.md")
            if plan.is_file():
                plan.unlink()
                deleted.append(plan)
    return deleted


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verify example characters match SavedVariables triples",
    )
    parser.add_argument(
        "--saved-variables",
        type=Path,
        default=Path.home()
        / "Documents/Elder Scrolls Online/live/SavedVariables",
        help="Path to ESO SavedVariables directory",
    )
    parser.add_argument(
        "--examples",
        type=Path,
        default=Path("examples"),
        help="Path to examples directory",
    )
    parser.add_argument(
        "--location",
        choices=("na", "eu"),
        default=None,
        help="Limit CM SV scan to one megaserver (default: both NA and EU)",
    )
    parser.add_argument(
        "--allow-orphan-examples",
        action="store_true",
        help="Do not fail on example profiles missing from SavedVariables",
    )
    parser.add_argument(
        "--delete-orphans",
        action="store_true",
        help="Delete example profiles absent from both CM and ZO (and paired _plan.md)",
    )
    args = parser.parse_args()

    saved_variables = args.saved_variables.expanduser().resolve()
    examples_dir = args.examples.resolve()
    # None = both megaservers from CharacterMarkdown.lua
    default_location = args.location

    if not examples_dir.is_dir():
        print(f"error: examples directory not found: {examples_dir}", file=sys.stderr)
        return 1

    if args.delete_orphans:
        deleted = delete_true_orphan_examples(saved_variables, examples_dir)
        if deleted:
            print(f"Deleted {len(deleted)} orphan file(s):")
            for path in deleted:
                print(f"  {path}")
        else:
            print("No true orphan example files to delete.")

    issues = run_checks(
        saved_variables,
        examples_dir,
        default_location,
        args.allow_orphan_examples,
    )

    errors = [i for i in issues if i.level == "error"]
    warns = [i for i in issues if i.level == "warn"]

    for issue in issues:
        prefix = "ERROR" if issue.level == "error" else "WARN"
        print(f"{prefix}: {issue.message}")

    print()
    loc_label = default_location or "na+eu"
    print(
        f"Checked SV location={loc_label}, "
        f"{len(errors)} error(s), {len(warns)} warning(s)"
    )

    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
