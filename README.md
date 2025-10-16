# Character Markdown v2.0.1 - Visual Enhancement Edition

Comprehensive ESO character profile exporter with dual format support, enhanced visual styling, and ESO Plus detection.

## 🎨 New Features in v2.0

### Multiple Format Support
- **GitHub Format** (Default) - Full HTML/CSS styling, color gradients, badges, collapsible sections
- **VS Code Format** - Pure markdown with ASCII art, enhanced box drawing, ANSI-compatible colors
- **Discord Format** - Discord-optimized markdown with clickable links, compact layout, and character count warnings
- **Quick Format** - Ultra-compact one-line summary

### Visual Enhancements
- 📊 Progress bars for skill progression and CP allocation
- 🎨 Color-coded stats with visual health indicators
- 📦 Enhanced box drawing with multiple styles (single, double, rounded, heavy)
- 🏷️ Status badges and indicators
- 📋 Collapsible sections for large skill lists (GitHub)
- 💡 Callout boxes for warnings, tips, and information
- 🎯 Smart layout with responsive grids and cards

### Command System
```bash
/markdown          # Generate profile (uses current default format)
/markdown github   # Generate GitHub-optimized profile
/markdown vscode   # Generate VS Code-optimized profile
/markdown discord  # Generate Discord-optimized profile with clickable links
/markdown quick    # Generate quick one-line summary
/markdown help     # Show command usage
```

### Auto-Save Feature
Profiles are automatically saved to `SavedVariables/CharacterMarkdown.lua` when:
- Client exits normally
- Player logs out
- Addon is unloaded

## 📦 Installation

### Standard Installation
1. Download the addon
2. Extract to `Documents/Elder Scrolls Online/live/AddOns/CharacterMarkdown/`
3. Ensure these files are present:
   - `CharacterMarkdown_v2.txt` (manifest)
   - `CharacterMarkdown_v2.lua` (main code)
   - `CharacterMarkdown_Templates.lua` (visual templates part 1)
   - `CharacterMarkdown_Templates_Part2.lua` (visual templates part 2)
   - `CharacterMarkdown.xml` (UI definition)

### Upgrading from v1.x
Simply replace existing files. Settings and saved profiles are preserved.

## 🎯 Usage

### Basic Workflow
1. Log into ESO with your character
2. Type `/markdown` or `/markdown github` in chat
3. Profile window opens with pre-selected text
4. Press `Ctrl+C` to copy to clipboard
5. Paste into your markdown viewer of choice
6. Profile auto-saves on exit

### Format Selection

#### GitHub Format (Default)
Perfect for:
- GitHub READMEs and wikis
- Websites supporting HTML in markdown
- Rich documentation platforms
- Maximum visual appeal

Features:
- Full color support with hex codes
- CSS-styled cards and grids
- Collapsible `<details>` sections
- HTML tables with custom styling
- Progress bars with gradients
- Badges and shields

#### VS Code Format
Perfect for:
- VS Code markdown preview
- Plain text environments
- Terminal-based viewers
- Maximum compatibility

Features:
- Pure markdown (no HTML)
- Enhanced ASCII box drawing
- Unicode progress bars
- Emoji-based color coding
- Tree diagrams
- Bordered sections

#### Discord Format
Perfect for:
- Discord chat messages
- Discord embeds
- Guild/clan communication
- Quick character sharing

Features:
- **Comprehensive Clickable UESP Links:**
  - All skill bar abilities
  - All skill lines (Class, Weapon, Armor, World, Guild, Alliance War, Racial, Craft)
  - Equipment sets
  - Races, classes, and alliances
  - Companion names (Tanlorin, Bastian Hallix, Mirri Elendis, etc.)
  - Mundus stones
  - Champion Point skills
- Compact layout optimized for Discord's UI
- Better visual separation between sections
- Character count warnings (Discord has 2000 char limit)
- Emoji icons and status indicators
- Code blocks for stats and ultimates

### Viewing Your Markdown

**GitHub Format:**
- Paste directly into GitHub READMEs, issues, or wikis
- Preview at [Markdown Live Preview](https://markdownlivepreview.com/) - instant rendering with full HTML/CSS support
- Use any GitHub-compatible markdown viewer

**VS Code Format:**
- Open VS Code
- Create a new `.md` file
- Paste content
- Press `Ctrl+Shift+V` (Windows/Linux) or `Cmd+Shift+V` (Mac) for preview

**Discord Format:**
- Paste directly into any Discord channel
- Links will be clickable and emojis will render
- Split into multiple messages if over 2000 characters

### Keyboard Shortcuts
- `Ctrl+C` - Copy selected text (while window is focused)
- `Esc` - Close profile window

## 📊 Profile Sections

### Header
- Character name with decorative borders
- Race, class, alliance with color coding
- Level and Champion Points
- ESO Plus subscription status (👑 Active / ❌ Inactive)
- Active title
- Generation timestamp

### Character Overview
- Identity card (race, class, alliance, title)
- ESO Plus status detection (uses official `IsESOPlusSubscriber()` API)
- Progression summary (level, CP)
- Visual stat cards

### DLC & Chapter Access
- Automatic detection of accessible DLCs and Chapters
- Shows Summerset, Morrowind, Elsweyr, Greymoor, Blackwood, High Isle, Necrom, and more
- For ESO Plus: All DLCs marked as accessible
- For non-ESO Plus: Individual ownership detection using zone accessibility
- Visual indicators: ✅ Accessible, 🔒 Locked

### Mundus Stone
- Active buff detection
- Recommendations if not active
- Visual status indicators

### Champion Points
- Summary cards (Total, Allocated, Available)
- Warning alerts for unspent points
- Discipline breakdown with progress bars
- Per-constellation allocation tables
- Visual percentage indicators

### Combat Arsenal
- Front and back bar layouts
- Ultimate abilities
- 5 ability slots per bar
- Empty slot indicators
- Enhanced box styling

### Character Statistics
- Resource pools (Health, Magicka, Stamina)
- Offensive stats (Weapon/Spell Power)
- Defensive stats (Resistances)
- Visual resource bars (GitHub)
- Three-column grid layout

### Equipment Loadout
- Set summary with piece counts
- Full bonus indicators
- Per-item details with emoji icons
- Quality color coding
- Trait information
- Backup bar equipment

### Skill Line Progression
- All skill categories (Class, Weapon, Armor, World, Guild, etc.)
- Rank and XP progress indicators
- Maxed skill indicators (✅)
- Unlocked but minimal progress (🔒)
- Progress bars for active skills
- Collapsible lists for large categories (GitHub)

### Active Companion
- Companion name and level
- Ability loadout
- Equipment details
- Quality indicators

## 🎨 Visual Enhancement Details

### Progress Bars
```
GitHub:  ██████████ 100%
VS Code: ▓▓▓▓▓▓▓▓▓▓ 100%
```

### Status Indicators
- 🟢 Excellent
- 🟡 Good  
- 🟠 Warning
- 🔴 Critical
- ✅ Maxed
- ⚠️ Empty/Missing

### Box Styles
- **Single**: `┌─┐│└─┘` - Default, clean
- **Double**: `╔═╗║╚═╝` - Emphasis, headers
- **Rounded**: `╭─╮│╰─╯` - Modern, friendly
- **Heavy**: `┏━┓┃┗━┛` - Strong emphasis

### Color Coding

#### GitHub Format
- Health bars: `#aa0000` (red gradient)
- Magicka bars: `#0000aa` (blue gradient)
- Stamina bars: `#00aa00` (green gradient)
- Excellent status: `#00ff00`
- Warning status: `#ffaa00`
- Critical status: `#ff0000`
- Alliance colors:
  - Aldmeri Dominion: `#F4D03F` (gold)
  - Daggerfall Covenant: `#5DADE2` (blue)
  - Ebonheart Pact: `#E74C3C` (red)

#### VS Code Format
- Emoji-based color indicators
- ANSI-compatible when possible
- Visual symbols for status

## 💾 File Structure

### SavedVariables Format
```lua
CharacterMarkdownSettings = {
    currentFormat = "github",  -- Last used format
    lastExport = {
        timestamp = 1234567890,
        characterName = "CharacterName",
        format = "github",
        markdown = "...full markdown content..."
    }
}
```

### File Location
`Documents/Elder Scrolls Online/live/SavedVariables/CharacterMarkdown.lua`

## 🔧 Configuration

### Changing Default Format
Edit `SavedVariables/CharacterMarkdown.lua`:
```lua
CharacterMarkdownSettings = {
    currentFormat = "vscode"  -- or "github"
}
```

Or simply use the command with your preferred format - it becomes the new default.

## 🐛 Troubleshooting

### Templates Not Loading
**Symptom**: Profile generates but looks basic/minimal

**Solution**:
1. Ensure all template files are present
2. Check load order in manifest (.txt file)
3. Look for warnings in chat on addon load

### Empty Sections
**Symptom**: Some sections show "No data" or are missing

**Common Causes**:
- Data not available (e.g., no companion summoned)
- Need to open relevant UI first (e.g., Champion menu for detailed CP)
- Protected functions blocked in combat

**Solution**: 
- Ensure you're out of combat
- Open and close relevant game menus
- Try generating profile again

### Copy Not Working
**Symptom**: Ctrl+C doesn't copy text

**Solution**:
1. Click inside the text box first
2. Ensure text is selected (should be auto-selected)
3. Try manually selecting text with mouse
4. Use right-click → Copy if available

### Window Not Showing
**Symptom**: Command runs but no window appears

**Solution**:
1. Check if window is off-screen (try resetting UI)
2. Look for error messages in chat
3. Verify CharacterMarkdown.xml is present
4. `/reloadui` and try again

## 📝 Template Customization

Advanced users can customize templates by editing:
- `CharacterMarkdown_Templates.lua` - Headers, overview, mundus, CP
- `CharacterMarkdown_Templates_Part2.lua` - Combat, equipment, skills, companion

Key functions:
```lua
Templates.GenerateHeader(characterData, format)
Templates.GenerateOverview(characterData, format)
Templates.GenerateMundusStone(mundusData, format)
Templates.GenerateChampionPoints(cpData, format)
TemplatesPart2.GenerateCombatArsenal(skillBarData, format)
TemplatesPart2.GenerateCombatStats(statsData, format)
TemplatesPart2.GenerateEquipment(equipmentData, format)
TemplatesPart2.GenerateSkillProgression(skillData, format)
TemplatesPart2.GenerateCompanion(companionData, format)
```

## 🎯 Future Enhancements

Planned features:
- Export to PDF
- Direct GitHub Gist upload
- Build analyzer integration
- Comparison mode (multiple characters)
- Historical tracking
- DPS parse integration
- Guild roster export

## 📜 Changelog

### v2.0.1 (2025-10-15)
- **NEW**: ESO Plus detection and display
  - Uses official `IsESOPlusSubscriber()` API function for accurate detection
  - Shows in Character Overview table (✅ Active / ❌ Inactive)
  - Displays in Discord format header with crown emoji (👑 ESO Plus)
  - Includes in quick summary format with crown indicator
  - Works across all output formats
- **NEW**: DLC & Chapter Access detection
  - Automatically detects which DLCs/Chapters are accessible
  - Works for both ESO Plus and non-ESO Plus users
  - Shows Summerset, Morrowind, Elsweyr, Greymoor, Blackwood, High Isle, Necrom, and more
  - Individual ownership detection for non-ESO Plus users
- **FIXED**: Ability rank suffixes (I, II, III, IV) now stripped from UESP links
- **FIXED**: Apostrophe encoding in UESP URLs corrected
- Added Markdown Live Preview reference (markdownlivepreview.com)

### v2.0.0 (2025-10-14)
- **BREAKING**: Complete visual overhaul
- Added dual format support (GitHub/VS Code)
- Enhanced all visual elements
- Added auto-save on exit
- New command system with format selection
- Progress bars for skills and CP
- Color-coded stats and indicators
- Collapsible sections (GitHub)
- Enhanced box drawing
- Status badges and callouts
- Improved equipment grid layout
- Better skill tree visualization

### v1.0.6 (Previous)
- Basic markdown export
- Single window with copy functionality
- Core data collection

## 🤝 Contributing

Contributions welcome! Areas of interest:
- Additional visual themes
- New output formats
- Data analysis features
- Performance optimizations
- Bug fixes

## 📄 License

See LICENSE file for details.

## 🙏 Credits

- **Author**: solaegis
- **ESO UI Framework**: ZeniMax Online Studios
- **Community**: ESOUI.com forums

## 📞 Support

- **Issues**: GitHub Issues
- **Forum**: ESOUI.com
- **In-game**: @solaegis

---

<div align="center">

**Character Markdown v2.0.1**  
*Enhanced Visual Profiles for Elder Scrolls Online*

</div>
