from __future__ import annotations

import re
import unicodedata
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = REPO_ROOT / "data" / "sets"
RAW_DIR = DATA_DIR / "raw"
WIKI_CACHE = RAW_DIR / "wiki"
SET_PAGES = WIKI_CACHE / "sets"
SUPPORT_PAGES = WIKI_CACHE / "support"
REPORTS_DIR = DATA_DIR / "reports"
OVERRIDES_DIR = DATA_DIR / "overrides"
SCHEMA_FILE = DATA_DIR / "schema.json"


def slugify(title: str) -> str:
    """'Online:Kjalnar's Nightmare' -> 'kjalnars_nightmare' (stable, ASCII)."""
    name = title.split(":", 1)[-1]
    name = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    name = re.sub(r"['’`]", "", name.lower())
    return re.sub(r"[^a-z0-9]+", "_", name).strip("_")
