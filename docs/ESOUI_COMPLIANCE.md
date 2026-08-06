# CharacterMarkdown — ESOUI Compliance Matrix

Repo-specific status against [ESOUI_BEST_PRACTICES.md](ESOUI_BEST_PRACTICES.md)
(forum sticky rules + ESOUI Wiki manifest requirements).

Last reviewed: 2026-08-05

## Automated checks

```bash
task validate:esoui          # listing + wiki manifest rules
lua scripts/validate-manifest.lua CharacterMarkdown.txt
./scripts/validate-esoui-compliance.sh
```

---

## Section 1 — Manifest technical requirements

| Rule | Artifact | Check | Status |
|------|----------|-------|--------|
| UTF-8 without BOM | [CharacterMarkdown.txt](../CharacterMarkdown.txt) | automated (`validate-manifest.lua`) | Compliant |
| No line longer than 301 bytes | Manifest | automated | Compliant (Description shortened) |
| `## Title:` ≤ 64 characters | Manifest | automated | Compliant |
| `## AddOnVersion:` positive integer | Manifest (`20260805`); bumped by `task version:bump` and release CI | automated | Compliant |
| LAM sort comment | `## This file is AddOnVersion:` mirrors directive (not a real directive) | documented | Compliant |
| `## APIVersion:` six-digit (up to two) | `101050 101049` | automated | Compliant |
| SavedVariables addon-prefixed | `CharacterMarkdownSettings` | manual / matrix | Compliant |
| SV created in `EVENT_ADD_ON_LOADED` | [src/Events.lua](../src/Events.lua) → `Initializer:Initialize()` | manual / matrix | Compliant |
| Per-character SV fields | `customNotes`, `customTitle`, `playStyle` + metadata only — **not** generated markdown | migration strips legacy `markdown` / `markdown_format` | Compliant |
| No manual loading of dependency files | Manifest lists only own `src/` | manual | Compliant |
| `IsLibrary` | Not set (standalone addon) | N/A | Compliant |
| ZeniMax disclaimer | Manifest boilerplate | automated | Compliant |

---

## Section 2 — Before releasing

| Rule | Artifact | Check | Status |
|------|----------|-------|--------|
| Addon review readiness | Release gate | process | Compliant |
| AI disclosure at top of description | [README_ESOUI.txt](../README_ESOUI.txt) | automated | Compliant |
| Credits for reused concepts/assets | README_ESOUI Credits (libs + David Wells advanced-markdown) | automated / listing | Compliant |
| Non-optional deps listed in description | No `DependsOn` / `PCDependsOn` / `ConsoleDependsOn` | automated | Compliant (optional only) |
| Optional deps listed | Credits + Optional libraries section | automated sync | Compliant |
| ZOS / ESOUI prohibited functionality | See attestation below | manual | Compliant |

### ZOS prohibited-functionality attestation

CharacterMarkdown is a **read-only character data exporter**. It:

- Does **not** automate gameplay, combat, movement, or trading
- Does **not** blacklist or degrade other players
- Does **not** paywall features
- Does **not** make hidden network calls beyond ESO client APIs
- Collects and formats data the player already owns for copy/paste outside the game

If a future feature might approach a prohibited category, discuss with ESOUI staff / ZOS before release.

---

## Section 3 — Console-only addons

| Rule | Status |
|------|--------|
| Console-only upload rules | **N/A** — CharacterMarkdown on ESOUI is **PC-only** (`CharacterMarkdown.txt`, not `.addon`) |
| Listing states platform | README_ESOUI includes PC-only note |

---

## Section 4 — Intellectual property and malicious code

| Rule | Status |
|------|--------|
| MIT license stated | [LICENSE](../LICENSE) / [LICENSE.md](../LICENSE.md) in release ZIP |
| No stolen code without credit | Credits in listing; CONTRIBUTING.md for forks |
| No player blacklists / paywalls | Attestation above |

---

## Sections 5–6 — Discontinuation and forks

| Rule | Artifact |
|------|----------|
| Author discontinuation process | [PUBLISHING.md](PUBLISHING.md) — Discontinuing or transferring maintenance |
| Fork / patch / takeover policy | [CONTRIBUTING.md](../CONTRIBUTING.md) |

---

## Section 7 — Pre-release checklist

Mapped to automation where possible. Full list lives in [RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md) under **ESOUI Best Practices**.

| Item | Automation |
|------|------------|
| AddOnVersion integer | `validate-manifest.lua` |
| APIVersion matches client | manual + matrix |
| UTF-8 no BOM / line ≤ 301 | `validate-manifest.lua` |
| SV prefix + ADD_ON_LOADED | matrix |
| No hard deps without listing | `validate-esoui-compliance.sh` |
| AI disclosure + credits | `validate-esoui-compliance.sh` |
| Changelog updated | `validate-esoui-compliance.sh` (warn/entry check) |
| PC platform tagged | README_ESOUI + matrix |

---

## Related

- [ESOUI_BEST_PRACTICES.md](ESOUI_BEST_PRACTICES.md) — canonical rules
- [PUBLISHING.md](PUBLISHING.md) — release and ESOUI upload
- [CONTRIBUTING.md](../CONTRIBUTING.md) — contributions and forks
