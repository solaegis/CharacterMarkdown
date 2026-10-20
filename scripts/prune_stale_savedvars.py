#!/usr/bin/env python3
"""
Prune stale character data from live ESO SavedVariables.

- Rebuild CharacterMarkdown.lua (drop legacy snapshot, nested Default trees,
  cross-account / cross-megaserver perCharacterData)
- Remove character-id keys not in the live ZO NameChange set (after dropping
  the duplicate Sea-Wolf id) from other addon SavedVariables
- Drop stale Sea-Wolf id from ZO_Ingame NameChange

Requires: lua on PATH. Does not modify the repo's examples/ by itself.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
LUA_SCRIPT = SCRIPT_DIR / "prune_stale_savedvars.lua"
DEFAULT_SV = (
    Path.home() / "Documents" / "Elder Scrolls Online" / "live" / "SavedVariables"
)


def find_lua() -> str:
    for name in ("lua", "luajit", "lua5.1"):
        path = shutil.which(name)
        if path:
            return path
    raise SystemExit("error: lua interpreter not found on PATH")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--saved-variables",
        type=Path,
        default=DEFAULT_SV,
        help="Path to ESO SavedVariables directory",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write changes (default is dry-run)",
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=None,
        help="Write JSON report to this path (default: temp under /tmp)",
    )
    args = parser.parse_args()

    sv_dir = args.saved_variables.expanduser().resolve()
    if not sv_dir.is_dir():
        print(f"error: SavedVariables not found: {sv_dir}", file=sys.stderr)
        return 1
    if not LUA_SCRIPT.is_file():
        print(f"error: missing {LUA_SCRIPT}", file=sys.stderr)
        return 1

    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    report_path = args.report or Path(f"/tmp/prune_stale_savedvars-{stamp}.json")
    report_path = report_path.expanduser().resolve()

    lua = find_lua()
    cmd = [
        lua,
        str(LUA_SCRIPT),
        str(sv_dir),
        str(report_path),
        "1" if args.apply else "0",
    ]
    print("Running:", " ".join(cmd))
    print("Mode:", "APPLY" if args.apply else "DRY-RUN")
    proc = subprocess.run(cmd, cwd=str(SCRIPT_DIR))
    if proc.returncode != 0:
        return proc.returncode

    if report_path.is_file():
        data = json.loads(report_path.read_text(encoding="utf-8"))
        print()
        print("=== Summary ===")
        zo = data.get("zo", {})
        print(
            f"ZO live ids: {zo.get('live_id_count')}  "
            f"stale Sea-Wolf present: {zo.get('stale_sea_wolf_present')}"
        )
        cm = data.get("character_markdown", {})
        print(f"CM legacy snapshot: {cm.get('had_legacy_flat_snapshot')}")
        print(f"CM nested Default slices cleared: {cm.get('nested_default_slices_cleared')}")
        print(f"CM PCD sources scanned: {cm.get('pcd_sources_scanned')}")
        print("CM before → after:")
        before = cm.get("before_counts") or {}
        after = cm.get("after_counts") or {}
        keys = sorted(set(before) | set(after))
        for key in keys:
            print(f"  {key}: {before.get(key, 0)} → {after.get(key, 0)}")
        print(f"CM kept entries: {len(cm.get('kept') or [])}")
        addons = data.get("addons") or []
        touched = [a for a in addons if a.get("removed_key_count")]
        print(f"Addon files with stale id keys: {len(touched)}")
        for a in touched:
            print(
                f"  {a['file']}: removed {a['removed_key_count']} keys "
                f"({', '.join(a.get('unique_ids') or [])})"
            )
        print(f"Report: {report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
