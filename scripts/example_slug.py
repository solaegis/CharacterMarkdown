"""Slugify ESO character display names for example filenames."""

from __future__ import annotations

import re
import unicodedata

_TRANSLITERATIONS = {
    "æ": "ae",
    "Æ": "ae",
    "ā": "a",
    "Ā": "a",
    "ī": "i",
    "Ī": "i",
    "ø": "o",
    "Ø": "o",
    "ö": "o",
    "Ö": "o",
    "ł": "l",
    "Ł": "l",
}


def slugify(name: str) -> str:
    """Convert display name to lowercase underscore slug."""
    text = name.strip()
    for src, dst in _TRANSLITERATIONS.items():
        text = text.replace(src, dst)
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "_", text)
    text = re.sub(r"_+", "_", text)
    return text.strip("_")


def account_slug(handle: str) -> str:
    """@SOLAEGIS -> solaegis"""
    return handle.lstrip("@").lower()


def location_slug(server_text: str) -> str:
    """NA Megaserver -> na, EU Megaserver -> eu"""
    upper = server_text.upper()
    if "EU" in upper:
        return "eu"
    if "NA" in upper:
        return "na"
    return "unknown"
