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
- Debug mode toggle in settings UI

---

## [2.1.10] - 2025-01-21

### Added
- **Release Automation**: Enhanced GitHub Actions workflow for automated releases
  - Automatic version updates in README_ESOUI.txt during release process
  - Improved release artifact generation and validation
  - Streamlined ESOUI upload process

### Changed
- **Release Process**: Optimized workflow for better reliability
  - Better error handling in release automation
  - Enhanced ZIP package validation
  - Improved changelog extraction and formatting

---

## [2.1.8] - 2025-01-21

### Added
- **ESOUI Description**: Enhanced README_ESOUI.txt with comprehensive user guide
  - Complete feature overview and installation instructions
  - Detailed command reference and format explanations
  - Professional formatting optimized for ESOUI.com display
  - AI integration use cases and troubleshooting guide

### Changed
- **Documentation**: Updated ESOUI description file for better user experience
  - Streamlined quick start guide for new users
  - Enhanced feature descriptions with clear use cases
  - Professional presentation ready for ESOUI publication

---

## [2.1.7] - 2025-01-21

### Added
- **Documentation Overhaul**: Complete rewrite of README.md for better user experience
  - Concise, professional format with clear quick start guide
  - Comprehensive feature overview and format explanations
  - Better organization with badges and structured sections
- **Enhanced User Guide**: Streamlined docs/README.md with detailed instructions
  - Complete troubleshooting section with common issues
  - Best practices for different use cases (Discord, GitHub, etc.)
  - Advanced features documentation (custom notes, profiles, import/export)
- **Project Cleanup**: Added .gitignore to prevent build artifacts from being committed

### Removed
- **Unnecessary Files**: Cleaned up development artifacts
  - Removed debug scripts (debug_version.sh, test_sed.sh)
  - Deleted example output files in wrong locations
  - Cleaned up empty directories and temporary files
- **Redundant Documentation**: Consolidated documentation structure
  - Removed outdated champion point diagrams
  - Deleted redundant example files
  - Streamlined docs directory structure

### Changed
- **Documentation Structure**: Reorganized for better maintainability
  - Main README.md now focuses on quick start and overview
  - Detailed user guide moved to docs/README.md
  - Cleaner separation between user and developer documentation
- **Project Organization**: Improved file structure and cleanliness
  - Removed build artifacts and temporary files
  - Better organization of documentation files
  - Professional project appearance ready for release

---

## [2.1.6] - 2025-01-21

### Removed
- **Documentation Cleanup**: Removed outdated phase completion files
  - Deleted PHASE1_COMPLETE.md through PHASE8_COMPLETE.md
  - Removed PHASE*_QUICKREF.md files
  - Cleaned up temporary implementation notes and session summaries
- **Temporary Files**: Removed development artifacts
  - Deleted SKILL_MORPHS_GENERATOR_CODE.lua (code already integrated)
  - Removed validate_phase1.sh (phase validation complete)
  - Cleaned up IMPLEMENTATION_NOTES.md and SESSION_SUMMARY.md
- **Redundant Documentation**: Consolidated documentation
  - Removed MISSING_SECTIONS_IMPLEMENTED.md
  - Deleted CRAFTING_FIX.md and FORMAT_IMPROVEMENTS.md
  - Removed SECTIONS_ANALYSIS.md and VISUAL_COMPARISON.md
  - Cleaned up CHANGELOG_build_notes_toggle.md

### Changed
- **Debug Output**: Streamlined initialization logging
  - Reduced verbose debug output during addon startup
  - Removed debug helper functions no longer needed
  - Cleaner console output for better user experience

---

## [2.1.5] - 2025-01-21

### Fixed
- **Build System**: Fixed `.build-ignore` to properly exclude development files
  - Corrected pattern to exclude `README.md` but include `README_ESOUI.txt`
  - Ensures ESOUI description file is included in release packages

### Added
- **Documentation**: Enhanced ESOUI description file (`README_ESOUI.txt`)
  - Added AI assistant use case (ChatGPT, Claude integration)
  - Included GitHub repository link in header
  - Added `/cmdsettings` command documentation
  - Converted to plain ASCII for proper rendering on ESOUI.com
  - Comprehensive feature documentation and troubleshooting guide

### Changed
- **Publishing**: Improved GitHub Actions release workflow
  - Better ZIP structure validation
  - Enhanced changelog extraction
  - Cleaner release artifact naming

---

## [2.1.1] - 2025-01-20

### Fixed
- **Critical**: Fixed settings persistence across game sessions
  - Removed manual `GetWorldName()` nesting that conflicted with ESO's built-in system
  - Settings now persist correctly after `/reloadui` and game restarts

### Added
- **Debug System**: LibDebugLogger integration for professional debug output
  - No chat clutter - debug messages only in LibDebugLogger viewer
  - Multiple log levels with category-based filtering
- **Performance Optimizations**: Cached global function lookups (~10-15% improvement)
- **Error Aggregation**: Better error reporting with consolidated summaries
- **ZIP Validation**: Automated package validation script

### Changed
- **Event System**: Simplified addon load sequence (removed complex retry logic)
- **Manifest**: Updated to v2.1.1 with proper `.addon` extension
- **Code Quality**: All core modules now follow ESO guidelines
  - Namespace protection (zero global pollution)
  - Defensive programming with pcall wrapping
  - Consistent error handling

### Removed
- **Global Function Pollution**: Cleaned up `_G` namespace
- **Duplicate Manifest**: Using only `CharacterMarkdown.addon` format

---

## [2.1.0] - 2025-01-18

### Added
- **Champion Points Display**: Complete CP allocation across all three disciplines
- **UESP Wiki Links**: Automatic hyperlinks for abilities, equipment, races, etc.
- **Multiple Export Formats**: GitHub, Discord, VS Code, and Quick formats
- **DLC/Chapter Tracking**: Display ESO Plus status and owned content
- **Mundus Stone Detection**: Automatically detects active mundus buff
- **Active Buffs Display**: Shows food, potions, and other active effects
- **Companion Information**: Active companion name and stats
- **Currency Tracking**: Gold, AP, Tel Var, Transmutes, Writ Vouchers, and more
- **Riding Skills**: Mount training progress
- **Inventory Capacity**: Backpack and bank usage statistics
- **PvP Data**: Alliance War rank and active campaign

### Changed
- **UI Improvements**: Better window management and user experience
- **Performance**: Optimized data collection and markdown generation
- **Code Structure**: Modular design with separate collectors and generators

---

## [2.0.0] - 2025-01-15

### Added
- **Complete Rewrite**: Modern, modular architecture
- **Character Data Collection**: Comprehensive character information gathering
- **Markdown Generation**: Clean, formatted output for sharing builds
- **Settings System**: User-configurable options for data collection
- **Command Interface**: In-game commands for easy access

### Changed
- **Architecture**: From monolithic to modular design
- **Performance**: Significant improvements in data collection speed
- **Maintainability**: Cleaner, more organized codebase

---

## [1.0.0] - 2025-01-10

### Added
- Initial release
- Basic character data collection
- Simple markdown output
- Core functionality for ESO character builds