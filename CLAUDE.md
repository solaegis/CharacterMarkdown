# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

<!-- AUTO-MANAGED: project-description -->
## Overview

CharacterMarkdown is an ESO (Elder Scrolls Online) addon that exports comprehensive character data in enhanced markdown format. Generates copyable profiles with clickable UESP links for abilities, sets, races, classes, zones, campaigns, and more. Use `/markdown` (or `/cm`) to generate. ESO Lua 5.1 addon; no `goto` statements.

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: build-commands -->
## Build & Development Commands

- **Lint**: `task lint` or `task dev:lint` (Luacheck)
- **Format**: `task format` or `task dev:format` (StyLua)
- **Test**: `task test` or `task dev:test`
- **Validate**: `task validate` or `task dev:validate:all`
- **Build**: `task build` or `task build:release`
- **Install to ESO Live**: `task install:live` (required after code changes for in-game testing)
- **Install dev (symlink)**: `task install:dev`
- **Release**: Push tag `v*` triggers GitHub Actions workflow

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->
## Architecture

Data flow: `Data Collection → Markdown Generation → UI Display`

- **src/api/**: ESO API abstraction (Character, Achievements, Collectibles, Combat, etc.)
- **src/collectors/**: Data gathering only (Inventory, Achievements, Collectibles, etc.)
- **src/generators/sections/**: Markdown creation (Character, Overview, Equipment, ChampionPoints, ChampionDiagram, etc.)
- **src/formatters/**: Output formatters (Markdown.lua)
- **src/links/**: UESP URL generation
- **src/utils/**: Chunking, ChunkingHelpers, Constants, Platform, etc.
- **src/settings/**: Defaults, Initializer, Panel (LibAddonMenu)
- **src/ui/Window.lua**: Display window (protected - requires developer approval to modify)
- **docs/**: ARCHITECTURE.md, CHUNKING.md, CHUNKING_ALGORITHM.md, CHAMPION_POINTS.md, MEMORY_MANAGEMENT.md
- **examples/**: Example markdown output — full profiles (Hadriān.md, Walsingham.md), build guides (Hadriān-build.md); templates in examples/templates/
- **taskfiles/**: Dev, Build, Install, Release, Examples, Docs

Load order in `CharacterMarkdown.addon`. See `docs/ARCHITECTURE.md` for full structure.

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->
## Code Conventions

- **Namespace**: All code in `CharacterMarkdown` (alias `CM`). Pattern: `local CM = CharacterMarkdown`
- **ESO API**: Use `CM.SafeCall()` for single-return ESO calls; `pcall` for multiple returns
- **Debug**: `CM.DebugPrint`, `CM.Info`, `CM.Warn`, `CM.Error` - never `d()` directly
- **Performance**: Cache globals at module level; use `table.concat()` for string building
- **Settings**: Access via `CM.GetSettings()`; defaults in `CM.Settings.Defaults:GetAll()`
- **Commands**: Subcommand pattern `object:action` (e.g. `filter:clear`, `test:import-export`)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: patterns -->
## Detected Patterns

- Collectors return raw data; generators produce markdown
- Chunking: `SplitMarkdownIntoChunks` in Chunking.lua; never split inside Mermaid code blocks; extend or backtrack chunk boundary to keep diagrams intact
- ChunkingHelpers: Line-type detection for chunking; extracted from Chunking.lua
- ChampionDiagram: Mermaid CP diagram in `src/generators/sections/ChampionDiagram.lua`; STAR_MAP for tree positions
- Per-character data in `CharacterMarkdownSettings.perCharacterData[characterId]`; preserve customNotes, customTitle, playStyle on reset
- Chunking constants: EDITBOX_LIMIT=21500, COPY_LIMIT=21500, MAX_DATA_CHARS=20350 (Constants.lua)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: git-insights -->
## Git Insights

Recent: Chunking fixes (never split mermaid blocks), ARCHITECTURE Lua comment syntax, CHANGELOG 2.2.6, README_ESOUI sync. Examples: Hadriān-build (build guide), Hadriān, Walsingham.

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: best-practices -->
## Best Practices

- Run `task install:live` after code changes for in-game testing
- Protected files (Window.lua): request developer approval before modifying
- See `.cursorrules` for full project conventions

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->
## Custom Notes

Add project-specific notes here. This section is never auto-modified.

<!-- END MANUAL -->
