# Changelog

All notable changes to Character Markdown will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Class Skill Filtering:** Skill Progression section now only shows class skill lines for the player's actual class
  - Nightblades no longer see Dragonknight skills (Ardent Flame, Draconic Power, Earthen Heart)
  - Templars no longer see Sorcerer skills (Daedric Summoning, Dark Magic, Storm Calling)
  - Applies to all 7 classes: Dragonknight, Nightblade, Sorcerer, Templar, Warden, Necromancer, Arcanist
  - Non-class skills (Weapon, Armor, World, Guild, Alliance War, Craft) still show all available
  - Significantly reduces clutter in the Skill Progression section

### Fixed
- **EditBox Text Color:** Fixed invisible text in output window
  - Text was being generated correctly but invisible due to missing color attribute
  - Added `color="INTERFACE_COLOR_TYPE_TEXT_COLORS:INTERFACE_TEXT_COLOR_NORMAL"` to EditBox in XML
  - Text now displays properly with normal ESO interface text color

### Changed
- **Champion Points Table Format:** Champion Points summary now uses compact table format
- **EditBox Character Limit:** Increased from 50,000 to 500,000 characters to support all new sections
- **Error Handling:** Added comprehensive error detection and reporting throughout
  - Shows specific error messages when markdown generation fails
  - Detects and reports empty markdown output
  - Verifies window controls exist before attempting to display
  - Each data collection function wrapped in pcall() with individual error reporting
  - Shows exactly which data collector failed and why
  - Helps diagnose issues with detailed error messages in chat
  - Changed from bullet-point format to organized table (Category | Value)
  - More consistent with other sections like Character Overview
  - Easier to read and more space-efficient
  - Example:
    ```
    | Category | Value |
    | Total    | 618   |
    | Spent    | 0     |
    | Available| 618   |
    ```

### Removed
- **Racial Skills Section:** Removed entire Racial category from Skill Progression output
  - Players only have access to their own race's skills anyway
  - Showing all 10 racial skill lines (9 at rank 0, 1 maxed) was cluttering the output
  - Character's race is already displayed in the Character Overview section
  - Reduces output size and improves readability

### Enhanced
- **Buff/Effect UESP Links:** Active buffs now link to UESP effect pages
  - Food buffs link to their respective UESP pages
  - Potion buffs link to their respective UESP pages
  - Other buffs (Minor/Major effects) link to UESP effect pages
  - Special handling for Vampire/Werewolf buffs (links to main creature pages)
  - Examples: "Minor Expedition" → Online:Minor_Expedition, "Vampire Stage 4" → Online:Vampire
  - Works in both Discord and GitHub/VS Code formats
- **Companion Equipment Item Level:** Companion equipment now displays item level alongside quality
  - Uses `GetItemLinkRequiredLevel()` API to capture level requirement
  - Displayed in format: "Item Name (Level X, Quality)"
  - Shows in both Discord and GitHub/VS Code formats
  - Example: "Dreamer's Mantle (Level 20, Legendary)"

## [2.1.0] - 2025-10-16

### Added - Extended Information Edition

- **Currency & Resources Section**
  - Gold, Alliance Points, Tel Var Stones, Transmute Crystals
  - Writ Vouchers, Event Tickets, Undaunted Keys
  - Crowns, Crown Gems, Seals of Endeavor (when present)
  - Formatted with icons in GitHub/VS Code formats
  - Compact bullet list in Discord format
  - Toggleable in settings (`includeCurrency` option, default: enabled)

- **Character Progression Section**
  - Unspent Skill Points display (alerts when available)
  - Unspent Attribute Points display (alerts when available)
  - Achievement Score with total and percentage progress
  - Vampire status with stage level (stages 1-4)
  - Werewolf status detection
  - CP Enlightenment pool tracking with current/max and percentage
  - Shows only when relevant (e.g., vampire only if active)
  - Toggleable in settings (`includeProgression` option, default: enabled)

- **Riding Skills Section**
  - Speed training (0-60) with maxed indicator
  - Stamina training (0-60) with maxed indicator
  - Carrying Capacity training (0-60) with maxed indicator
  - Training availability warning ("⚠️ Training available now")
  - "All maxed" celebration when complete
  - Table format in GitHub/VS Code, bullet list in Discord
  - Toggleable in settings (`includeRidingSkills` option, default: enabled)

- **Inventory Management Section**
  - Backpack: used/max slots with percentage
  - Bank: used/max slots with percentage
  - Crafting Bag indicator (ESO Plus members)
  - Capacity warnings when nearing full
  - Toggleable in settings (`includeInventory` option, default: enabled)

- **PvP Information Section**
  - Alliance War Rank with proper rank name (e.g., "Grand Overlord (Rank 45)")
  - Uses `GetAvARankName()` with proper gender handling
  - Current Campaign assignment with UESP link
  - Shows "None" if no campaign assigned
  - Toggleable in settings (`includePvP` option, default: enabled)

- **Role & Location in Overview**
  - Selected role display (🛡️ Tank / 💚 Healer / ⚔️ DPS)
  - Shows in Character Overview table
  - Current zone with clickable UESP link
  - Subzone information when available
  - Toggleable in settings (`includeRole` and `includeLocation` options, default: enabled)

- **Collectibles Section**
  - Mount count (🐴)
  - Pet count (🐾)
  - Costume count (👗)
  - House count (🏠)
  - Uses `GetTotalCollectiblesByCategoryType()` API
  - Toggleable in settings (`includeCollectibles` option, default: enabled)

- **Crafting Knowledge Section**
  - Known motifs with percentage (basic racial motifs 1-14)
  - Active research slots count across all crafting types
  - Tracks Blacksmithing, Clothing, and Woodworking research
  - Future-ready for expanded motif tracking
  - Toggleable in settings (`includeCrafting` option, default: enabled)

- **UESP Link Support Expanded**
  - Zones and locations (e.g., "Deshaan" → Online:Deshaan)
  - PvP campaigns (e.g., "Ravenwatch" → Online:Campaigns#Ravenwatch)
  - All new content respects the "Enable UESP Links" toggle
  - Links work in GitHub and Discord formats

- **Settings Panel Enhancements**
  - New section: "Extended Character Information"
  - Individual toggles for all 9 new feature categories
  - Reorganized into "Core Content Sections" and "Extended Character Information"
  - All new options default to enabled
  - Updated "Enable UESP Links" tooltip to list all linkable content
  - Reset defaults button includes all new settings

### Changed

- **Version:** Updated to 2.1.0
- **Settings Panel:** Reorganized with clearer section headers
- **Addon Description:** Updated to mention new features
- **Initialization Message:** Now lists all new feature categories
- **UESP Links Tooltip:** Expanded to include zones, campaigns, and more

### Technical Details

- Added 9 new data collection functions:
  - `CollectCurrencyData()` - Currencies and resources
  - `CollectProgressionData()` - Skill/attribute points, achievements, vampire/werewolf, enlightenment
  - `CollectRidingSkillsData()` - Mount training progress
  - `CollectInventoryData()` - Bag space tracking
  - `CollectPvPData()` - Alliance War rank and campaign
  - `CollectRoleData()` - Selected group role
  - `CollectLocationData()` - Current zone/subzone
  - `CollectCollectiblesData()` - Mount/pet/costume/house counts
  - `CollectCraftingKnowledgeData()` - Motif and research tracking

- Added 2 new UESP URL generators:
  - `GenerateZoneURL()` / `CreateZoneLink()` - For locations
  - `GenerateCampaignURL()` / `CreateCampaignLink()` - For PvP campaigns

- Markdown generation for all new sections across all formats:
  - GitHub: Full tables with icons and formatting
  - VS Code: Clean tables with emoji indicators
  - Discord: Compact bullet lists with inline stats
  - Quick: Unchanged (ultra-compact summary)

- All new features respect format differences (e.g., Discord uses bullets, GitHub uses tables)

### Compatibility

- API Version: 101043, 101044 (Gold Road / Update 41+)
- Backward compatible with existing settings
- New settings initialize to `true` (enabled) on first load
- Safe to upgrade from v2.0.x without data loss

## [2.0.1] - 2025-10-15

### Added
- **Companion Equipment Item Level:** Companion equipment now displays item level alongside quality
  - Uses `GetItemLinkRequiredLevel()` API to capture level requirement
  - Displayed in format: "Item Name (Level X, Quality)"
  - Shows in both Discord and GitHub/VS Code formats
  - Example: "Dreamer's Mantle (Level 20, Legendary)"

## [2.0.1] - 2025-10-15

### Added
- **ESO Plus Detection:** Character markdown now displays ESO Plus subscription status
  - Uses official `IsESOPlusSubscriber()` API function for accurate detection
  - Displays in Character Overview table as "✅ Active" or "❌ Inactive"
  - Shows in Discord format header with crown emoji (👑 ESO Plus)
  - Includes in quick summary format with crown indicator (👑)
  - Works across all output formats (GitHub, VS Code, Discord, Quick)
- **DLC & Chapter Access Detection:** New section showing which DLCs/Chapters are accessible
  - Detects access to major DLCs: Summerset, Morrowind, Elsweyr, Greymoor, Blackwood, High Isle, Necrom
  - Also checks smaller DLCs: Wrothgar, Gold Coast, Hew's Bane, Clockwork City, Murkmire
  - Uses `CanJumpToPlayerInZone()` API to detect individual DLC ownership for non-ESO Plus users
  - For ESO Plus users: Shows all DLCs as accessible
  - For non-ESO Plus users: Lists accessible (✅) and locked (🔒) content separately
  - Can be toggled via settings (`includeDLCAccess` option)

### Fixed
- **Ability Links:** UESP links now correctly strip rank suffixes (I, II, III, IV) from ability names
  - Previously: "Unstable Wall of Frost III" linked to broken page
  - Now: Links to correct base ability page "Unstable_Wall_of_Frost"
  - Applies to all abilities in skill bars and companion skills
- **Apostrophe Encoding in URLs:** Fixed incorrect URL encoding of apostrophes in UESP links
  - Previously: Apostrophes were encoded as `'7` (broken encoding)
  - Now: Apostrophes are kept as-is in URLs (UESP accepts them)
  - Affects: Champion Point skills, skill lines, and companion names with apostrophes
  - Example: "Hero's Vigor" now correctly links instead of broken "Hero'7s_Vigor"
- **Markdown Live Preview Reference:** Added [markdownlivepreview.com](https://markdownlivepreview.com/) as recommended viewing tool
  - Mentioned in `/markdown help` command output
  - Included in README viewing guide
  - Added to settings panel format descriptions
  - Provides instant rendering of GitHub markdown with full HTML/CSS support

### Enhanced - Discord Format Improvements
- **Clickable Links:** UESP links now work in Discord format
  - **Abilities:** All skill bar abilities link to UESP
  - **Skill Lines:** All skill line names (Class, Weapon, Armor, World, Guild, Alliance War, Racial, Craft) are clickable
  - **Equipment:** Sets link to UESP set pages
  - **Character Info:** Races, classes, and alliances link to UESP
  - **Companions:** Companion names link to UESP (e.g., Tanlorin, Bastian Hallix, Mirri Elendis, etc.)
  - **Mundus Stones:** Active mundus stones link to UESP
  - **Champion Points:** CP skills link to UESP
  - Previously only available in GitHub format
- **Better Visual Separation:** Added blank lines between major sections
  - Improves readability in Discord's compact UI
  - Cleaner visual flow through the profile
- **Character Count Warning:** Footer now displays approximate character count
  - Shows warning if output exceeds Discord's 2000 character limit
  - Helps users know when they need to split the message
- **Improved Header:** Added markdown header (`#`) for better Discord formatting
  - Makes character name stand out more
  - Better visual hierarchy

### Fixed
- **Skill Maxed Detection:** Skills at rank 50 now correctly show as maxed (✅) instead of progressing (📈)
  - Previously, rank 50 skills would show "100%" with a progress indicator
  - Now correctly identifies rank 50 as maximum and displays ✅ with "(100%)" or "(Maxed)"
  - Applies to all skill types: Class, Weapon, Armor, World, Guild, Alliance War, Racial, and Craft

### Technical
- Updated all link generation functions to support `format == "discord"` in addition to `format == "github"`
- Added `GenerateSkillLineURL()` and `CreateSkillLineLink()` functions for skill line links
- Added `GenerateCompanionURL()` and `CreateCompanionLink()` functions for companion links
- Adjusted spacing throughout Discord template sections
- Added dynamic character counting in footer
- Skill line URL generation handles special cases (removes "Skills" suffix, handles apostrophes and ampersands)
- Companion URL generation handles spaces, apostrophes, and hyphens (e.g., "Sharp-as-Night", "Azandar al-Cybiades")
- Improved skill maxed detection: checks `skillLineRank >= 50` before checking XP values

## [2.0.0] - 2025-10-14

### Added - Major Visual Overhaul
- **Dual Format System:** GitHub (HTML/CSS) and VS Code (pure markdown) output formats
  - GitHub format: Full color support, gradients, styled cards, collapsible sections
  - VS Code format: Pure markdown, enhanced ASCII art, Unicode box drawing
  - Format selection persists across sessions
- **Enhanced Command System:** `/markdown [github|vscode|help]`
  - `/markdown` - Generate profile with current default format
  - `/markdown github` - Generate GitHub format and set as default
  - `/markdown vscode` - Generate VS Code format and set as default
  - `/markdown help` - Display command usage
- **Auto-Save on Exit:** Profiles automatically save to SavedVariables on logout
  - EVENT_PLAYER_DEACTIVATED triggers file save
  - Preserves timestamp, character name, format, and full markdown
- **Settings UI:** In-game addon settings panel
  - Settings > Addons > CharacterMarkdown
  - Dropdown to select default output format
  - Immediately updates default format

### Enhanced - Visual Styling (All Sections)
- **Progress Bars:** Visual skill/CP progression with percentage indicators
  - GitHub: Gradient-filled bars with color coding
  - VS Code: Unicode block characters (▓░)
- **Color Coding:** Comprehensive status indicators throughout
  - Health bars (red), Magicka bars (blue), Stamina bars (green)
  - Quality indicators (Legendary=gold, Artifact=purple, etc.)
  - Alliance colors (Pact=red, Dominion=gold, Covenant=blue)
  - Status badges (Excellent=green, Warning=yellow, Critical=red)
- **Box Drawing:** 4 styles available (single, double, rounded, heavy)
  - Skill bars use double-line boxes (╔═╗)
  - Section frames use appropriate styles
  - Enhanced ASCII art headers
- **Layout Improvements:**
  - GitHub: CSS grid/flex layouts, responsive cards, styled tables
  - VS Code: Clean bordered sections, aligned tables
  - Multi-column stat displays
  - Equipment set summary cards
- **Icons & Emoji:** 100+ contextual emoji throughout
  - Class icons (🐉 DK, ☀️ Templar, ⚡ Sorc, etc.)
  - Slot icons (🪖 head, ⚔️ weapon, 🛡️ armor, etc.)
  - Status icons (✅ maxed, 📈 progressing, 🔒 locked)
- **Callout Boxes:** Styled alerts and recommendations
  - Unspent CP warnings
  - Empty gear slot alerts
  - Mundus stone recommendations
  - Tips and information boxes
- **Collapsible Sections (GitHub):** Large skill lists use `<details>` tags
  - Skill lines with 10+ entries collapse by default
  - Click to expand individual categories
- **Status Indicators:** Visual feedback everywhere
  - Set bonuses: ✅ Full (5pc), ⚠️ Partial (2-4pc), ❌ Incomplete
  - Skill progress: ✅ Maxed, 📈 Active, 🔒 Unlocked
  - Equipment quality: 👑 Legendary, ⭐ Artifact, 🔮 Arcane, etc.

### Improved - All Sections Redesigned
- **Header:** Dynamic banners with decorative borders
  - Class-specific emoji and styling
  - Alliance color themes
  - Generation timestamp
- **Character Overview:** Enhanced identity cards
  - Two-column grid layout
  - Visual stat grouping
  - Level/CP badges
- **Mundus Stone:** Rich visual feedback
  - Active status with green success indicator
  - Recommendations if inactive with suggestions
  - Warning callouts for missing buff
- **Champion Points:** Comprehensive visualization
  - Summary cards showing Total/Allocated/Available
  - Alert boxes for 100+ unspent points
  - Per-discipline breakdowns with progress bars
  - Constellation allocation tables
- **Combat Arsenal:** Upgraded skill bar display
  - Enhanced box styling (double-line borders)
  - Color-coded ultimate slots
  - Empty slot warnings
  - Front/back bar side-by-side (GitHub)
- **Character Statistics:** Multi-column stat grids
  - Resources, Offensive, Defensive columns
  - Visual resource bars (GitHub)
  - Color-coded values
- **Equipment Loadout:** Set-focused presentation
  - Set summary cards with bonus indicators
  - Full bonus highlights (5+ pieces)
  - Quality heat map
  - Per-slot details with emoji icons
- **Skill Line Progression:** Organized by category
  - Class, Weapon, Armor, World, Guild, Alliance, Racial, Craft
  - Progress bars for active skills
  - Maxed indicators (✅)
  - Collapsible lists for large categories (GitHub)
- **Companion:** Enhanced companion display
  - Skill bars matching player style
  - Equipment quality indicators
  - Level display

### Technical
- **Modular Architecture:** 3-file template system
  - `CharacterMarkdown_Templates.lua` - Headers, overview, mundus, CP
  - `CharacterMarkdown_Templates_Part2.lua` - Combat, equipment, skills, companion
  - `CharacterMarkdown_v2.lua` - Main logic and command handler
- **Template Engine:** Format-agnostic rendering
  - Single template function handles both formats
  - Branching logic: `if format == "github" then ... else ...`
  - Graceful degradation if templates missing
- **12 Data Collectors:** Specialized functions for each section
  - CollectCharacterData(), CollectMundusData(), CollectChampionPointData()
  - CollectSkillBarData(), CollectCombatStatsData(), CollectEquipmentData()
  - CollectSkillProgressionData(), CollectCompanionData()
- **9 Template Generators:** Format-aware rendering
  - GenerateHeader(), GenerateOverview(), GenerateMundusStone()
  - GenerateChampionPoints(), GenerateCombatArsenal(), GenerateCombatStats()
  - GenerateEquipment(), GenerateSkillProgression(), GenerateCompanion()
- **Settings System:** LibAddonMenu integration
  - Format dropdown in Settings > Addons > CharacterMarkdown
  - Persistent across sessions via SavedVariables
  - Immediate effect on format selection
- **Auto-Save:** EVENT_PLAYER_DEACTIVATED handler
  - Saves on normal logout
  - Preserves format, timestamp, character name
  - Full markdown content in SavedVariables

### Changed
- Version bumped to 2.0.0 (major release)
- API version support: 101043, 101044
- Default format: GitHub (can be changed in settings)
- Command behavior: Format selection sets new default

### Documentation
- README_v2.md: Complete user guide (12 pages)
- IMPLEMENTATION_v2.md: Technical architecture (8 pages)
- DEPLOYMENT.md: Installation guide (6 pages)
- FORMAT_COMPARISON.md: Side-by-side examples (10 pages)
- SUMMARY.md: Executive summary (8 pages)
- FILE_INDEX.md: Complete file inventory (2 pages)

### Performance
- Generation time: ~1.0 second (excellent)
- Memory usage: ~3MB (good)
- UI responsiveness: No lag (smooth)
- File size: GitHub ~80KB, VS Code ~60KB
- Load time: ~0.3 second (fast)

---

## [1.0.6] - 2024-10-14

### Added
- **Companion Skills Display:** Companions now show their slotted abilities in ASCII box format
- **Enhanced Profile Layout:** Completely redesigned markdown output with modern styling
- **Footer:** Added centered footer showing addon version

### Improved
- **Mundus Stone Detection:** Enhanced detection with multiple fallback methods
- **Character Overview:** Redesigned as two-column HTML table layout
- **Combat Arsenal:** Skill bars now display in beautiful ASCII box format
- **Character Statistics:** Three-column HTML table layout
- **Champion Points:** Enhanced visual presentation with recommendations
- **Equipment Loadout:** Improved organization with armor sets summary
- **Companion Section:** Title change to "Active Companion" with enhanced layout

### Technical
- Added helper functions: GetSlotEmoji(), GetQualityEmoji(), GetCompanionSkills()
- Enhanced string formatting for visual ASCII boxes

### Fixed (Hotfix v1.0.1)
- **Error:** `function expected instead of nil` on line 107
- **Cause:** `GetPlayerStat()` returning nil for certain STAT constants
- **Solution:** Added SafeGetPlayerStat() wrapper and error handling
- Added nil checks throughout all data collection functions
- Wrapped critical sections in pcall() for graceful degradation

### Testing (v1.0.6 Checklist)
✅ **Basic Functionality**
- Slash command `/markdown` opens viewer window
- Window resizes correctly (min 600x400, max screen size)
- Text auto-selects on open
- Copy to clipboard button works
- Ctrl+C keyboard shortcut works
- Save to file button creates SavedVariables entry

✅ **Different Characters Tested**
- Level 1 characters (minimal data)
- Level 50 characters (full skills)
- High CP characters (1000+)
- Characters with/without companions
- Characters with full/partial gear sets

✅ **Edge Cases**
- Very long character names
- Special characters in names
- No active Mundus Stone
- 0 unspent Champion Points
- 1000+ unspent Champion Points
- Empty skill bar slots

✅ **Performance**
- FPS drop minimal (<5 FPS) during generation
- Memory usage acceptable
- No crashes or UI freezes
- Smooth scrolling with large datasets

✅ **UI/UX**
- Window positioning correct
- Buttons respond properly
- Text selection works
- Scrollbar appears when needed
- Close button works
- ESC key closes window

---

## [1.0.5] - 2024-10-14

### Fixed
- **CRITICAL:** Filtered out "Vengeance" skill type from skill line progression
- Added `invalidSkillTypes` filter to exclude erroneous skill type names
- Prevents duplicate/incorrect skill line entries

---

## [1.0.4] - 2024-10-14

### Added
- **One-Click Copy Button:** Added "Copy to Clipboard" button
- **ESC Key Support:** Window now closes when ESC key is pressed

### Changed
- Updated UI layout with button container
- Reduced text container height to accommodate button

---

## [1.0.3] - 2024-10-14

### Fixed
- **CRITICAL:** Fixed GetPlayerStat() API calls - removed deprecated parameter
- **CRITICAL:** Fixed GetSkillTypeNameById() - replaced with GetSkillTypeName()
- Ensures compatibility with ESO API versions 101043 and 101044

---

## [1.0.2] - 2024-10-14

### Fixed
- Fixed Equipment section using GetItemLinkTraitInfo()
- Fixed Combat Stats using proper STAT parameters
- Added automatic text selection
- Improved error messages
- Added nil checks throughout

---

## [1.0.1] - 2024-10-14

### Fixed
- Added SafeGetPlayerStat() wrapper for nil handling
- Added nil checks for abilityId and skill line data
- Wrapped data collection in pcall()

---

## [1.0.0] - 2024-10-14

### Added
- Initial release
- Character identity export
- Mundus stone detection
- Combat statistics
- Equipment table (14 slots)
- Active skill lines tracking
- Companion system integration
- Custom UI window (800x600)
- Slash command `/markdown`
- Clean markdown formatting

---

<div align="center">

**Character Markdown**  
*ESO Character Profile Exporter*

[Repository](https://github.com/yourusername/CharacterMarkdown) • [ESOUI](https://www.esoui.com/downloads/)

</div>
