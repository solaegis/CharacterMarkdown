# CharacterMarkdown - User Guide

## 📖 Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Settings & Configuration](#settings--configuration)
- [Output Formats](#output-formats)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Via Minion (Recommended)
1. Install [Minion](https://minion.mmoui.com/)
2. Search for "CharacterMarkdown"
3. Click Install
4. Launch ESO

### Manual Installation
1. Download from [ESOUI](https://www.esoui.com/downloads/info4279-CharacterMarkdown.html)
2. Extract ZIP to: `Documents/Elder Scrolls Online/live/AddOns/`
3. Launch ESO
4. Enable addon in character select screen

---

## Basic Usage

### Commands
```
/markdown          # Open export window (default GitHub format)
/markdown github   # GitHub format with full tables
/markdown discord  # Discord-optimized format
/markdown vscode   # VS Code format
/markdown quick    # One-line summary
```

### Export Process
1. **Run Command**: Type `/markdown` in chat
2. **Window Opens**: Generated markdown appears in window
3. **Copy**: Click "Select All" button or Ctrl+A, then Ctrl+C
4. **Paste**: Paste anywhere (Discord, GitHub, forums, etc.)

### First Time Setup
- The addon will create default settings automatically
- Access settings via the Settings button in the export window
- Or use the Addon Menu (ESC → AddOns → CharacterMarkdown)

---

## Settings & Configuration

### Accessing Settings
- **In-Game**: `/markdown` → Settings button
- **Addon Menu**: ESC → AddOns → CharacterMarkdown

### Core Settings

#### Data Sections
Control which information appears in your markdown:

**Core Sections** (Always recommended)
- ✅ Champion Points
- ✅ Skill Bars
- ✅ Equipment
- ✅ Combat Stats
- ✅ Attributes

**Extended Sections** (Optional)
- 🔧 Currency & Inventory
- 🔧 DLC Access
- 🔧 Collectibles
- 🔧 Crafting Knowledge
- 🔧 PvP Information

#### Link Settings
- **Ability Links**: UESP links for skills and abilities
- **Set Links**: UESP links for equipment sets
- **Race/Class Links**: UESP links for character info

#### Filters
- **Minimum Skill Rank**: Hide skills below this rank
- **Equipment Quality**: Only show items of this quality or higher
- **Hide Empty Slots**: Don't show empty equipment slots

### Profile System

#### Built-in Profiles
- **Full Documentation**: Everything enabled (comprehensive)
- **PvE Build**: Focus on trials/dungeons
- **PvP Build**: Optimized for Cyrodiil/Battlegrounds
- **Discord Share**: Compact format for Discord
- **Quick Reference**: Just the essentials

#### Custom Profiles
1. Configure settings as desired
2. Go to Settings → Profiles
3. Click "Save Profile"
4. Enter a name
5. Use "Load Profile" to switch between configurations

---

## Output Formats

### GitHub Format (Default)
**Best for**: GitHub README files, detailed documentation
- Full tables with rich formatting
- Collapsible sections
- Comprehensive UESP links
- Progress bars and emojis

### Discord Format
**Best for**: Discord servers, chat sharing
- Compact tables optimized for Discord
- Essential information only
- Discord-compatible formatting
- Shorter length

### VS Code Format
**Best for**: Code editors, plain text
- Clean, readable format
- Minimal formatting
- No special characters
- Easy to read in editors

### Quick Format
**Best for**: Status updates, brief summaries
- One-line character summary
- Key stats only
- Perfect for status messages

---

## Advanced Features

### Custom Notes
Add personal build notes that appear in your markdown:

```
/markdown notes "This is my main PvE DPS build for trials"
/markdown notes "Updated for Gold Road - testing new sets"
/markdown notes ""  # Clear notes
```

### Settings Import/Export
**Export**: Save your settings to share with others
**Import**: Load settings from another player

1. Go to Settings → Import/Export
2. Click "Export Settings" to copy to clipboard
3. Share the text with others
4. Others can "Import Settings" and paste your configuration

### Debug Mode
Enable debug mode for troubleshooting:
1. Go to Settings → Advanced
2. Enable "Debug Mode"
3. Check chat for detailed information
4. Disable when done troubleshooting

---

## Testing & Validation

CharacterMarkdown includes built-in validation tests to ensure markdown output is correct:

### Run Tests
```
/markdown test
```

This validates:
- HTML structure integrity
- Callout syntax correctness
- Resource value accuracy
- Progress bar consistency
- Section presence and formatting

For detailed testing information, see the [Testing Guide](../TESTING_GUIDE.md).

---

## Troubleshooting

### Common Issues

#### Addon Not Loading
- **Check**: Character select screen → AddOns → CharacterMarkdown enabled
- **Try**: `/reloadui` command
- **Verify**: Files extracted to correct folder

#### Empty Output
- **Check**: You're logged in with a character (not character select)
- **Try**: `/reloadui` then `/markdown` again
- **Verify**: Character is level 1+ (some data requires level 1+)

#### Missing Data
- **Champion Points**: Requires level 50+
- **Skills**: Some skills unlock at specific levels
- **Equipment**: Must have items equipped
- **Companion**: Requires active companion

#### Settings Not Saving
- **Check**: ESO has write permissions to Documents folder
- **Try**: Restart ESO completely
- **Verify**: No antivirus blocking file access

### Getting Help

#### Debug Information
1. Enable Debug Mode in settings
2. Run `/markdown` command
3. Check chat for error messages
4. Copy error messages when reporting issues

#### Reporting Issues
Include this information:
- ESO version
- CharacterMarkdown version
- Error messages (if any)
- Steps to reproduce the issue
- Screenshots (if helpful)

#### Support Channels
- **GitHub Issues**: [Report bugs](https://github.com/yourusername/CharacterMarkdown/issues)
- **ESOUI Comments**: [Addon page](https://www.esoui.com/downloads/info4279-CharacterMarkdown.html)
- **Discord**: ESO Addon Development community

---

## Tips & Best Practices

### For Discord Sharing
- Use Discord format for best compatibility
- Keep notes brief and relevant
- Consider using Quick format for status updates

### For GitHub Documentation
- Use GitHub format for full documentation
- Add custom notes for build explanations
- Include screenshots of your character

### For Build Sharing
- Use PvE or PvP profiles as starting points
- Add detailed custom notes
- Export settings to share your configuration

### Performance
- Disable unused sections for faster generation
- Use Quick format for frequent updates
- Clear custom notes if they become outdated

---

**Need more help?** 
- Check the [Development Guide](DEVELOPMENT.md) for technical details
- Review the [Testing Guide](../TESTING_GUIDE.md) for validation procedures
- [Report an issue](https://github.com/yourusername/CharacterMarkdown/issues)