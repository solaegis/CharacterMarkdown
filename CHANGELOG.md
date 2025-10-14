# Changelog

All notable changes to Character Markdown will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-14

### Added
- Initial release of Character Markdown addon
- Character identity export (name, race, class, alliance, level, CP, title)
- Mundus stone detection and display
- Comprehensive combat statistics:
  - Primary attributes (Health, Magicka, Stamina)
  - Offensive stats (Weapon/Spell Damage, Critical ratings)
  - Defensive stats (Physical/Spell Resistance, Critical Resistance)
  - Penetration values (Physical/Spell)
- Equipment table with 14 slots:
  - Item names and set bonuses
  - Quality, level, traits
  - Enchantment details
- Active skill lines tracking:
  - All unlocked skill lines
  - Current rank and XP progress
  - Organized by skill type
- Companion system integration:
  - All 8 companions (Bastian through Tanlorin)
  - Unlock status detection
  - Role assignments
  - Rapport level display (approximate)
- Custom UI window:
  - 800x600 resizable, movable window
  - Scrollable text display
  - Copy-paste optimized (Ctrl+A, Ctrl+C instructions)
  - Clean close button
- Slash command `/markdown` for instant export
- Zero-impact performance (on-demand generation only)
- Clean markdown formatting optimized for Discord, Reddit, documentation

### Technical
- API Version support: 101043, 101044
- Event-driven initialization
- Comprehensive error handling
- Number formatting with thousands separators
- Quality color mapping
- Equipment slot name mapping
- Mundus stone detection via buff scanning

## [Unreleased]

## [1.0.1] - 2024-10-14

### Fixed
- Added SafeGetPlayerStat() wrapper to handle nil returns from GetPlayerStat()
- Added nil checks for abilityId in mundus stone detection
- Added nil checks for skill line data
- Wrapped all data collection functions in pcall() for better error handling
- Fixed crash when STAT constants return nil values

### Changed
- Improved error messages with specific function names
- Changed version display in initialization message

### Planned
- Multi-character export (all alts in single document)
- Export presets (customize which sections to include)
- Direct file export to SavedVariables
- HTML export format option
- Detailed ability breakdown (individual skills, not just lines)
- Inventory summary with filters
- Accurate companion rapport API integration
- Quest progress tracking
- Achievement highlights
- Bank/storage overview
- Localization support (French, German, Spanish, Japanese)

### Under Consideration
- Auto-export on level up / significant changes
- Export templates (PvP focused, PvE focused, etc.)
- Comparison mode (before/after equipment changes)
- Integration with popular build-sharing sites
- Screenshot generation alongside markdown
