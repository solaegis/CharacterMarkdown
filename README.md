# CharacterMarkdown

[![API](https://img.shields.io/badge/ESO_API-101047-green.svg)](https://www.esoui.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.1.7-orange.svg)](CHANGELOG.md)

**Export comprehensive ESO character data in beautiful markdown format** with clickable UESP links for abilities, sets, races, classes, zones, and more.

## ✨ Features

- **📊 Complete Character Profile** - Level, CP, attributes, skills, equipment, combat stats
- **🎯 Multiple Formats** - GitHub, Discord, VS Code, Quick summary
- **🔗 Smart Links** - Automatic UESP links for abilities, sets, races, classes
- **⚙️ Customizable** - Extensive settings and profile system
- **🎨 Rich Output** - Tables, emojis, progress bars, collapsible sections
- **📱 Copy & Paste** - One-click copy to clipboard

## 🚀 Quick Start

### Installation
1. **Via Minion**: Search "CharacterMarkdown" → Install
2. **Manual**: Download from [ESOUI](https://www.esoui.com/downloads/info4279-CharacterMarkdown.html)

### Usage
```
/markdown          # Open export window
/markdown github   # GitHub format (default)
/markdown discord  # Discord format
/markdown vscode   # VS Code format
/markdown quick    # One-line summary

# Settings management
/cmdsettings export  # Export settings to YAML
/cmdsettings import  # Import settings from YAML
```

### Export Process
1. Run `/markdown` command in-game
2. Window opens with generated markdown
3. Click "Select All" → Copy (Ctrl+C)
4. Paste anywhere (Discord, GitHub, forums, etc.)

## 📋 What's Included

### Core Information
- **Character**: Name, race, class, alliance, level, CP
- **Attributes**: Magicka, health, stamina allocation
- **Combat Stats**: Resources, power, resistances, recovery
- **Equipment**: Gear, sets, mundus stone, active buffs
- **Skills**: Skill bars, progression, morphs

### Extended Data
- **Economy**: Gold, currencies, inventory status
- **Progression**: Achievement score, riding skills, enlightenment
- **Content**: DLC access, collectibles, crafting knowledge
- **PvP**: Alliance War rank, campaign assignment
- **Companion**: Active companion stats and equipment

## 🎨 Output Formats

### GitHub Format (Default)
- Full tables with collapsible sections
- Rich formatting with emojis and progress bars
- Comprehensive UESP links
- Perfect for GitHub README files

### Discord Format
- Compact tables optimized for Discord
- Essential information only
- Discord-compatible formatting

### VS Code Format
- Clean, readable format
- Optimized for code editors
- Minimal formatting

### Quick Format
- One-line character summary
- Perfect for status updates

## ⚙️ Settings & Customization

Access settings via:
- **In-game**: `/markdown` → Settings button
- **Addon Menu**: CharacterMarkdown settings panel

### Key Settings
- **Sections**: Enable/disable specific data sections
- **Links**: Toggle UESP links for abilities and sets
- **Filters**: Minimum skill ranks, equipment quality
- **Profiles**: Save/load different configuration sets

### Built-in Profiles
- **Full Documentation** - Everything enabled
- **PvE Build** - Focus on trials/dungeons
- **PvP Build** - Optimized for Cyrodiil/Battlegrounds
- **Discord Share** - Compact format
- **Quick Reference** - Essentials only

## 🔧 Advanced Features

### Settings Export/Import

Export and import settings in a human-readable YAML format:

**Export**: `/cmdsettings export`
- Opens a window with all settings in organized YAML format
- Text is pre-selected for easy copying
- Organized into logical groups for readability

**Import**: `/cmdsettings import`
- Paste YAML settings and import them
- Supports **partial imports** - only import the settings you provide
- Validates types and reports errors
- Requires grouped format (use export to see the structure)

**Example - Partial Import**:
```yaml
# Only change link settings
links:
  enableAbilityLinks: false
  enableSetLinks: true
```

### Custom Notes
Add personal build notes that appear in your markdown:
```
/markdown notes "This is my main PvE DPS build for trials"
```

### Profile Management
- Save custom settings as profiles
- Import/export settings between characters
- Share profiles with other players

### Error Handling
- Comprehensive error reporting
- Graceful degradation if data unavailable
- Debug mode for troubleshooting

## 📖 Documentation

- **[User Guide](docs/README.md)** - Detailed usage instructions and troubleshooting
- **[Development Guide](docs/DEVELOPMENT.md)** - Setup, contribution, and code style
- **[Architecture](docs/ARCHITECTURE.md)** - Code structure, patterns, and data flow
- **[API Reference](docs/API_REFERENCE.md)** - ESO Lua API usage patterns
- **[Memory Management](docs/MEMORY_MANAGEMENT.md)** - Efficient memory practices and best patterns
- **[Publishing Guide](docs/PUBLISHING.md)** - Release and distribution process
- **[Testing Guide](TESTING_GUIDE.md)** - Validation and testing procedures
- **[Changelog](CHANGELOG.md)** - Complete version history

## 🤝 Contributing

We welcome contributions! See [Development Guide](docs/DEVELOPMENT.md) for:
- Local setup instructions
- Code style guidelines
- Testing procedures
- Pull request process

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🔗 Links

- **[ESOUI Download](https://www.esoui.com/downloads/info4279-CharacterMarkdown.html)**
- **[GitHub Repository](https://github.com/yourusername/CharacterMarkdown)**
- **[Issue Tracker](https://github.com/yourusername/CharacterMarkdown/issues)**
- **[UESP Wiki](https://en.uesp.net/wiki/Online:Main_Page)**

---

**Made with ❤️ for the ESO community**