# CharacterMarkdown

> **Generate comprehensive markdown character profiles for Elder Scrolls Online**

[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](CHANGELOG.md)
[![API Version](https://img.shields.io/badge/ESO_API-101046-green.svg)](https://www.esoui.com/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

---

## 🎮 Overview

CharacterMarkdown is an ESO addon that generates detailed markdown-formatted character profiles. Export your character's stats, equipment, skills, Champion Points, and more in multiple formats optimized for GitHub, Discord, VS Code, or quick summaries.

### ✨ Key Features

- **📊 Complete Character Data** - Stats, attributes, progression, titles
- **⚔️ Combat Arsenal** - Front/back skill bars with UESP wiki links
- **🎒 Equipment Details** - Worn gear, set bonuses, quality, traits
- **⭐ Champion Points** - Full CP allocation across all disciplines
- **📜 Skill Progression** - All skill lines with ranks and progress
- **🗺️ DLC Access** - Track owned chapters and DLC
- **💰 Currency Tracking** - Gold, AP, Tel Var, Transmutes, and more
- **👥 Companion Info** - Active companion equipment and skills
- **🎨 Collectibles** - Mounts, pets, costumes, houses
- **Multiple Export Formats** - GitHub, Discord, VS Code, Quick

---

## 📚 Documentation

### Quick Start
- **[Installation & Setup](docs/SETUP.md)** - Get started in 5 minutes
- **[Release Process](docs/RELEASE.md)** - How releases work
- **[Publishing Guide](docs/PUBLISHING.md)** - First-time ESOUI setup

### Development
- **[Development Guide](docs/DEVELOPMENT.md)** - Local development workflow
- **[Architecture](docs/ARCHITECTURE.md)** - Technical deep-dive
- **[API Reference](docs/API_REFERENCE.md)** - ESO Lua API patterns
- **[Contributing](docs/CONTRIBUTING.md)** - How to contribute

### Examples
- **[Champion Points](docs/examples/champion-points.md)** - Sample CP allocation

---

## 🚀 Quick Start

### Installation

**Option 1: ESOUI (Minion)**
1. Install [Minion](https://minion.mmoui.com/)
2. Search for "CharacterMarkdown"
3. Click Install

**Option 2: Manual**
1. Download latest release from [ESOUI](https://www.esoui.com/downloads/info####-CharacterMarkdown.html)
2. Extract to: `Documents/Elder Scrolls Online/live/AddOns/`
3. Launch ESO

### Usage

**In-Game Commands:**
```
/markdown              # Open export window
/markdown github       # Export in GitHub format
/markdown discord      # Export in Discord format  
/markdown vscode       # Export in VS Code format
/markdown quick        # One-line summary
```

**Export Process:**
1. Run `/markdown` command
2. Generated markdown appears in window
3. Press `Ctrl+A` (Select All)
4. Press `Ctrl+C` (Copy)
5. Paste anywhere (GitHub, Discord, VSCode, etc.)

---

## 📋 Export Formats

### GitHub Format
**Best for:** README files, wikis, documentation

**Features:**
- Full tables with alignment
- Collapsible sections
- UESP wiki links for all abilities and sets
- Optimized for GitHub Markdown rendering

### Discord Format
**Best for:** Sharing builds in Discord servers

**Features:**
- Compact format (no large tables)
- Emoji indicators
- Less whitespace
- Works great in Discord messages

### VS Code Format
**Best for:** Local markdown files

**Features:**
- Similar to GitHub
- Renders well in VS Code preview
- Good for build documentation

### Quick Format
**Best for:** One-line summaries

**Example:**
```
Pelatiah • L50 CP627 👑 • Impe DK • Mother's Sorrow(5), Silks of the Sun(5)
```

---

## 🛠️ Configuration

Open settings via **ESC → Settings → Add-Ons → CharacterMarkdown**

### Section Toggles
- ✅ Champion Points
- ✅ Equipment
- ✅ Skills
- ✅ Combat Stats
- ✅ Currency
- ✅ Collectibles
- ... and more!

### Display Options
- **Enable UESP Links** - Add wiki links to abilities/sets
- **Skill Filters** - Hide maxed skills, minimum rank threshold
- **Collectibles Detail** - Show full lists vs counts only

---

## 🖼️ Sample Output

<details>
<summary>Click to expand sample character profile</summary>

```markdown
# Pelatiah

**Imperial Dragonknight**  
**Level 50** • **CP 627**  
*Ebonheart Pact*

---

## 📊 Character Overview

| Attribute | Value |
|:----------|:------|
| **Level** | 50 |
| **Champion Points** | 627 |
| **Class** | [Dragonknight](https://en.uesp.net/wiki/Online:Dragonknight) |
| **Race** | [Imperial](https://en.uesp.net/wiki/Online:Imperial) |
| **Alliance** | [Ebonheart Pact](https://en.uesp.net/wiki/Online:Ebonheart_Pact) |
| **Title** | *Daedric Lord Slayer* |
| **ESO Plus** | ✅ Active |
| **🎯 Attributes** | Magicka: 49 • Health: 15 • Stamina: 0 |
| **🪨 Mundus Stone** | [The Atronach](https://en.uesp.net/wiki/Online:The_Atronach_(Mundus_Stone)) |
| **🍖 Active Buffs** | Other: [Major Prophecy](https://en.uesp.net/wiki/Online:Major_Prophecy), [Major Savagery](https://en.uesp.net/wiki/Online:Major_Savagery) |
| **Location** | [Summerset](https://en.uesp.net/wiki/Online:Summerset) |

... (rest of profile)
```

</details>

---

## ⚙️ Requirements

- **ESO Version:** Update 46 (Gold Road) or later
- **API Version:** 101046
- **Dependencies:** 
  - [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html) (for settings panel)

---

## 🐛 Known Issues

- **Clipboard Truncation:** In rare cases, the last ~50 characters may be truncated when copying large outputs (>10KB). This affects only the footer and not character data.
- **PTS Compatibility:** Test addon on PTS before major ESO updates.

---

## 🗺️ Roadmap

### v2.2.0 (Planned)
- [ ] Housing furniture count
- [ ] Antiquities progress
- [ ] Trial/Dungeon achievements
- [ ] Custom template system

### v3.0.0 (Future)
- [ ] Multi-character comparison
- [ ] Build sharing/importing
- [ ] Cloud sync (optional)
- [ ] HTML export format

---

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

### Ways to Contribute
- 🐛 Report bugs
- 💡 Suggest features  
- 📝 Improve documentation
- 🔧 Submit pull requests
- ⭐ Star the repository

---

## 📜 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- **ESOUI Community** - For addon development resources
- **UESP Wiki** - For comprehensive ESO documentation
- **LibAddonMenu-2.0** - For settings panel framework
- **Contributors** - Everyone who has helped improve this addon

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/CharacterMarkdown/issues)
- **Discussions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/CharacterMarkdown/discussions)
- **ESOUI:** [Addon Page](https://www.esoui.com/downloads/info####-CharacterMarkdown.html)

---

<div align="center">

**Made with ❤️ for the ESO community**

[⭐ Star on GitHub](https://github.com/YOUR_USERNAME/CharacterMarkdown) • [📥 Download](https://www.esoui.com/downloads/info####-CharacterMarkdown.html) • [📖 Documentation](docs/)

</div>