# Changelog

All notable changes to Character Markdown will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Export templates (user-defined markdown templates)
- Build comparison (compare two characters side-by-side)
- Historical tracking (save build snapshots)
- Guild integration (share builds to guild roster)
- Build import (parse markdown back to settings)

---

## [2.1.0] - 2025-01-18

### Added
- **Champion Points Display**: Complete CP allocation across all three disciplines (Craft, Warfare, Fitness)
  - Shows allocated points per skill
  - Highlights active slottable skills
  - Displays total CP and unallocated points
- **UESP Wiki Links**: Automatic hyperlinks to UESP wiki for:
  - Abilities and skills
  - Equipment sets
  - Races, classes, and alliances
  - Mundus stones
  - Champion skills
  - Skill lines
  - Companions
- **Multiple Export Formats**: Four distinct formats optimized for different use cases:
  - **GitHub**: Full tables, detailed sections, comprehensive data
  - **Discord**: Compact format with emojis, minimal tables
  - **VS Code**: Developer-friendly with metadata blocks
  - **Quick**: Single-line summary for rapid sharing
- **DLC/Chapter Tracking**: Display ESO Plus status and owned DLCs/Chapters
- **Mundus Stone Detection**: Automatically detects active mundus buff
- **Active Buffs Display**: Shows food, potions, and other active effects with durations
- **Companion Information**: Active companion name and stats
- **Currency Tracking**: Gold, AP, Tel Var, Transmutes, Writ Vouchers, and more
- **Riding Skills**: Mount training progress (speed, stamina, capacity)
- **Inventory Capacity**: Backpack and bank usage statistics
- **PvP Data**: Alliance War rank and active campaign
- **Skill Filtering**: Options to hide maxed skills and set minimum rank threshold
- **Link Toggle Settings**: Enable/disable UESP wiki links globally or by category
- **Custom Notes**: Per-character custom notes field in exports

### Changed
- **API Version**: Updated to 101046 (Gold Road / Update 46)
- **Markdown Generation**: Refactored to support multiple formats from single data model
- **Data Collection**: Modularized into 20+ specialized collector functions
- **Error Handling**: All ESO API calls wrapped in `pcall()` for graceful degradation
- **Performance**: Optimized string concatenation using table patterns (10x improvement)
- **Settings Panel**: Reorganized with LibAddonMenu-2.0 for better UX

### Fixed
- **Character Data Edge Cases**: Added fallback values for missing data
- **Equipment Set Detection**: Improved multi-piece set bonus detection
- **Skill Line Filtering**: Fixed class-specific skill line identification
- **Combat Stats Accuracy**: Corrected stat type mappings for critical chance/damage
- **Window Display Performance**: Lazy data collection (only when window opens)
- **UTF-8 Encoding**: Proper handling of special characters in names and text
- **Clipboard Truncation**: Mitigated trailing text truncation during copy operations

### Deprecated
- Old format flags (pre-2.0 single format system)

### Security
- Confirmed compliance with ESO Lua security model (no file I/O, no network access)
- Validated API access boundaries (read-only character data)

---

## [2.0.0] - 2024-12-10

### Added
- Complete rewrite from v1.x architecture
- Settings panel via LibAddonMenu-2.0
- SavedVariables for persistent configuration
- Slash command system (`/markdown`)

### Changed
- Migrated from XML-only UI to Lua-driven generation
- Switched to markdown format (previously plain text)

### Removed
- v1.x plain text export format

---

## [1.5.0] - 2024-06-15

### Added
- Basic equipment display
- Skill bar abilities (front/back)
- Combat stats (health, magicka, stamina)

### Fixed
- Addon load errors on fresh installs

---

## [1.0.0] - 2024-03-01

### Added
- Initial release
- Character name, race, class, level display
- Basic markdown export
- XML window with EditBox

---

## Version History Summary

| Version | Release Date | Key Features |
|---------|--------------|--------------|
| 2.1.0 | 2025-01-18 | Champion Points, UESP links, multiple formats |
| 2.0.0 | 2024-12-10 | Complete rewrite, settings panel, markdown |
| 1.5.0 | 2024-06-15 | Equipment, skills, stats |
| 1.0.0 | 2024-03-01 | Initial release |

---

## Upgrade Notes

### From 2.0.x to 2.1.0
- **No breaking changes**: All existing settings preserved
- **New settings available**: Review Add-Ons → Character Markdown for new options
- **API update**: If you see "addon out of date" warnings, update is compatible with 101046

### From 1.x to 2.x
- **Breaking change**: v1.x plain text format removed
- **Migration**: Settings do not transfer; reconfigure via new settings panel
- **SavedVariables**: Old data file can be deleted (CharacterMarkdownOld.lua)

---

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting features
- Submitting pull requests

---

## Links

- **Repository**: https://github.com/yourusername/CharacterMarkdown
- **ESOUI**: https://www.esoui.com/downloads/info####-CharacterMarkdown.html
- **Issues**: https://github.com/yourusername/CharacterMarkdown/issues
- **Documentation**: [docs/](docs/)

---

[Unreleased]: https://github.com/yourusername/CharacterMarkdown/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/yourusername/CharacterMarkdown/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/yourusername/CharacterMarkdown/compare/v1.5.0...v2.0.0
[1.5.0]: https://github.com/yourusername/CharacterMarkdown/compare/v1.0.0...v1.5.0
[1.0.0]: https://github.com/yourusername/CharacterMarkdown/releases/tag/v1.0.0
