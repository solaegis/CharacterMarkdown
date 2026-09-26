"""Minimal wikitext helpers: templates, plain-text rendering, and wikitables.

Deliberately small and dependency-free. It only needs to handle what UESP's
ESO pages actually contain, and anything it can't handle should surface in
reports rather than be silently dropped.
"""

from __future__ import annotations

import html
import re
from dataclasses import dataclass, field

ONLYINCLUDE_RE = re.compile(r"<onlyinclude>(.*?)</onlyinclude>", re.S)


def extract_onlyinclude(text: str) -> str:
    return "\n".join(m.strip() for m in ONLYINCLUDE_RE.findall(text))


# --- templates -----------------------------------------------------------------


@dataclass
class Template:
    name: str
    params: list[str]  # positional and "k=v" params, raw wikitext
    start: int
    end: int

    def named(self) -> dict[str, str]:
        out: dict[str, str] = {}
        for p in self.params:
            key, sep, val = p.partition("=")
            if sep and "{{" not in key and "[[" not in key:
                out[key.strip()] = val.strip()
        return out

    def positional(self) -> list[str]:
        return [p.strip() for p in self.params if not _is_named(p)]


def _is_named(param: str) -> bool:
    key, sep, _ = param.partition("=")
    return bool(sep) and "{{" not in key and "[[" not in key


def _match_close(text: str, i: int, open_: str, close: str) -> int:
    """Index just past the `close` that balances the `open_` at text[i]."""
    depth = 0
    n = len(text)
    while i < n:
        if text.startswith(open_, i):
            depth += 1
            i += len(open_)
        elif text.startswith(close, i):
            depth -= 1
            i += len(close)
            if depth == 0:
                return i
        else:
            i += 1
    return -1


def split_top_level(inner: str, sep: str = "|") -> list[str]:
    """Split on `sep` outside nested {{ }} and [[ ]]."""
    parts: list[str] = []
    depth_t = depth_l = 0
    buf_start = 0
    i = 0
    while i < len(inner):
        two = inner[i : i + 2]
        if two == "{{":
            depth_t += 1
            i += 2
            continue
        if two == "}}" and depth_t:
            depth_t -= 1
            i += 2
            continue
        if two == "[[":
            depth_l += 1
            i += 2
            continue
        if two == "]]" and depth_l:
            depth_l -= 1
            i += 2
            continue
        if inner[i] == sep and depth_t == 0 and depth_l == 0:
            parts.append(inner[buf_start:i])
            buf_start = i + 1
        i += 1
    parts.append(inner[buf_start:])
    return parts


def find_templates(text: str, name: str | None = None) -> list[Template]:
    """Top-level templates in `text` (optionally only those called `name`)."""
    out: list[Template] = []
    i = 0
    while True:
        i = text.find("{{", i)
        if i < 0:
            return out
        end = _match_close(text, i, "{{", "}}")
        if end < 0:
            return out
        inner = text[i + 2 : end - 2]
        parts = split_top_level(inner)
        tname = parts[0].strip().replace("_", " ")
        if name is None or tname.lower() == name.lower():
            out.append(Template(tname, parts[1:], i, end))
        i = end


def iter_templates(text: str, _offset: int = 0) -> list[Template]:
    """All templates in `text`, outermost first, including nested ones."""
    out: list[Template] = []
    for tpl in find_templates(text):
        out.append(Template(tpl.name, tpl.params, tpl.start + _offset, tpl.end + _offset))
        inner_start = tpl.start + 2
        out += iter_templates(text[inner_start : tpl.end - 2], _offset + inner_start)
    return out


def splice_fragments(text: str, fragments: dict[str, str]) -> str:
    """Replace raw template fragments with their server-side expansion."""
    for raw in sorted(fragments, key=len, reverse=True):
        text = text.replace(raw, fragments[raw])
    return text


# --- plain text ----------------------------------------------------------------

_TAG_RE = re.compile(r"</?(?:span|div|small|big|sup|sub|b|i|u|font|abbr)\b[^>]*>", re.I)
_BR_RE = re.compile(r"<br\s*/?>", re.I)
_COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
_REF_RE = re.compile(r"<ref[^>]*/>|<ref[^>]*>.*?</ref>", re.S | re.I)
_FILE_LINK_RE = re.compile(r"\[\[(?:File|Image):[^\[\]]*(?:\[\[[^\]]*\]\][^\[\]]*)*\]\]", re.I)
_LINK_RE = re.compile(r"\[\[([^\[\]|]*)(?:\|([^\[\]]*))?\]\]")
_EXTLINK_RE = re.compile(r"\[https?://\S+\s+([^\]]+)\]")


def to_plain(text: str, br: str = " ") -> str:
    """Render (template-expanded) wikitext to readable plain text."""
    t = _COMMENT_RE.sub("", text)
    t = _REF_RE.sub("", t)
    t = _BR_RE.sub(br, t)
    t = _FILE_LINK_RE.sub("", t)
    t = _TAG_RE.sub("", t)
    t = _LINK_RE.sub(lambda m: m.group(2) if m.group(2) is not None else m.group(1), t)
    t = _EXTLINK_RE.sub(r"\1", t)
    # Unexpanded leftover templates (raw, not server-expanded text)
    for tpl in reversed(find_templates(t)):
        t = t[: tpl.start] + _render_template(tpl) + t[tpl.end :]
    t = t.replace("'''", "").replace("''", "")
    t = html.unescape(t).replace("\xa0", " ")
    t = re.sub(r"[ \t]+", " ", t)
    t = re.sub(r" *\n *", "\n", t)
    return t.strip()


_STAT_LINK_RE = re.compile(r"^ESO (.+) Link$")


def _render_template(tpl: Template) -> str:
    pos = tpl.positional()
    m = _STAT_LINK_RE.match(tpl.name)
    if m:
        # {{ESO Stamina Link|Maximum}} -> "Maximum Stamina";
        # {{ESO Resistance Link|Physical|||y}} -> "Physical Resistance"
        prefix = pos[0] if pos else ""
        return f"{to_plain(prefix)} {m.group(1)}".strip()
    if tpl.name.lower().startswith("icon"):
        return ""
    return to_plain(pos[-1]) if pos else ""


def link_targets(text: str) -> list[str]:
    """Targets of internal [[links]] (namespace prefixes normalised to 'Online:')."""
    out = []
    for m in _LINK_RE.finditer(text):
        target = m.group(1).split("#")[0].strip().replace("_", " ")
        if target.startswith("ON:"):
            target = "Online:" + target[3:]
        out.append(target)
    return out


# --- wikitables ----------------------------------------------------------------

_ATTR_SPAN_RE = re.compile(r"\b(rowspan|colspan)\s*=\s*\"?(\d+)", re.I)


@dataclass
class Cell:
    text: str
    header: bool = False
    rowspan: int = 1
    colspan: int = 1


@dataclass
class Table:
    caption: str = ""
    rows: list[list[Cell]] = field(default_factory=list)
    heading: str = ""  # nearest preceding == heading ==

    def grid(self) -> list[list[Cell]]:
        """Rows with rowspan/colspan expanded so every row has absolute columns."""
        grid: list[list[Cell]] = []
        carry: dict[int, tuple[Cell, int]] = {}  # col -> (cell, rows remaining)
        for row in self.rows:
            out: list[Cell] = []
            col = 0
            cells = iter(row)
            pending = next(cells, None)
            while pending is not None or any(c >= col for c in carry):
                if col in carry:
                    cell, left = carry[col]
                    out.append(cell)
                    if left <= 1:
                        del carry[col]
                    else:
                        carry[col] = (cell, left - 1)
                    col += 1
                    continue
                if pending is None:
                    col += 1
                    if col > 200:
                        break
                    continue
                for _ in range(pending.colspan):
                    out.append(pending)
                    if pending.rowspan > 1:
                        carry[col] = (pending, pending.rowspan - 1)
                    col += 1
                pending = next(cells, None)
            grid.append(out)
        return grid


def _split_cells(line: str, marker: str) -> list[str]:
    # "a || b || c" (or "!!" for headers) on one line; keep nested links/templates intact
    sep = "!!" if marker == "!" else "||"
    parts: list[str] = []
    buf_start = 0
    depth = 0
    i = 0
    while i < len(line):
        two = line[i : i + 2]
        if two in ("{{", "[["):
            depth += 1
            i += 2
            continue
        if two in ("}}", "]]") and depth:
            depth -= 1
            i += 2
            continue
        if two == sep and depth == 0:
            parts.append(line[buf_start:i])
            buf_start = i + 2
            i += 2
            continue
        i += 1
    parts.append(line[buf_start:])
    return parts


def _make_cell(raw: str, header: bool) -> Cell:
    # "attrs | content" — the first top-level single pipe separates attributes
    parts = split_top_level(raw, "|")
    attrs, content = ("", raw) if len(parts) == 1 else (parts[0], "|".join(parts[1:]))
    if attrs and not re.search(r"=|^\s*$", attrs):
        # not an attribute block (e.g. "a | b" inside content) — treat all as content
        attrs, content = "", raw
    cell = Cell(content.strip(), header=header)
    for key, val in _ATTR_SPAN_RE.findall(attrs):
        setattr(cell, key.lower(), int(val))
    return cell


def parse_tables(text: str) -> list[Table]:
    tables: list[Table] = []
    stack: list[Table] = []
    heading = ""
    current: Cell | None = None
    for line in text.split("\n"):
        s = line.strip()
        hm = re.match(r"^(={2,6})\s*(.*?)\s*\1\s*$", s)
        if hm and not stack:
            heading = to_plain(hm.group(2))
            continue
        if s.startswith("{|"):
            stack.append(Table(heading=heading))
            current = None
            continue
        if not stack:
            continue
        tbl = stack[-1]
        if s.startswith("|}"):
            tables.append(stack.pop())
            current = None
            continue
        if s.startswith("|+"):
            tbl.caption = s[2:].strip()
            continue
        if s.startswith("|-"):
            tbl.rows.append([])
            current = None
            continue
        if s.startswith("!") or s.startswith("|"):
            marker = s[0]
            if not tbl.rows:
                tbl.rows.append([])
            for raw in _split_cells(s[1:], marker):
                current = _make_cell(raw, header=marker == "!")
                tbl.rows[-1].append(current)
            continue
        if current is not None:  # continuation of a multi-line cell
            current.text += "\n" + line
    return [t for t in tables if any(t.rows)]
