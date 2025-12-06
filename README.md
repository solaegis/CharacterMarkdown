# CharacterMarkdown

[![API](https://img.shields.io/badge/ESO_API-101048-green.svg)](https://www.esoui.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.2.0-orange.svg)](CHANGELOG.md)

**Export comprehensive ESO character data in beautiful markdown format** with clickable UESP links for abilities, sets, races, classes, zones, and more.

## ✨ Features

- **📊 Complete Character Profile** - Level, CP, attributes, skills, equipment, combat stats
- **🎯 Multiple Formats** - Markdown (Default), TONL (Data)
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
/markdown (or /cm)           # Generate Markdown format (default)
/tonl                        # Generate TONL data format

# Settings management
/markdown help               # Show available commands
/markdown version            # Show version
/markdown settings           # Open settings panel
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

### Markdown Format (Default)
- Full tables with collapsible sections
- Rich formatting with emojis and progress bars
- Comprehensive UESP links
- Perfect for GitHub README files and documentation

### TONL Format
- Structured data format (Tom's Obvious, Minimal Language)
- Machine-readable export
- Best for data processing and external tools

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

## 🔧 Advanced Features

### Custom Notes
Add personal build notes that appear in your markdown:
```
/markdown notes "This is my main PvE DPS build for trials"
```

### Profile Management
- Per-character custom notes and titles
- Per-character play style tags
- Settings saved per account

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

## 🙏 Credits & Attributions

- **Diamond Metal Texture** - Thank you to [A2_GAMES](https://opengameart.org/content/diamond-metal-anti-slip-surface-stencil-grt6png) for the beautiful diamond metal texture (CC0 License) used in the UI

---

**Made with ❤️ for the ESO community**