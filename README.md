# CharacterMarkdown

[![Version](https://img.shields.io/badge/version-2.1.1-blue.svg)](CHANGELOG.md)
[![API](https://img.shields.io/badge/ESO_API-101047-green.svg)](https://www.esoui.com/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

Generate comprehensive markdown character profiles for Elder Scrolls Online.

---

## Features

- **Complete Character Data** - Stats, equipment, skills, Champion Points
- **Skill Bars** - Front/back bars with UESP wiki links
- **Multiple Formats** - GitHub (tables), Discord (compact), VS Code, Quick
- **DLC Tracking** - ESO Plus status, owned chapters
- **Currencies** - Gold, AP, Tel Var, Transmutes, Writ Vouchers
- **Companion Info** - Active companion equipment and skills
- **Collectibles** - Mounts, pets, costumes, houses
- **Customizable** - Enable/disable sections, filter skills

---

## Installation

### Via Minion
1. Install [Minion](https://minion.mmoui.com/)
2. Search "CharacterMarkdown"
3. Click Install

### Manual
1. Download from [ESOUI](https://www.esoui.com/downloads/info4279-CharacterMarkdown.html)
2. Extract to `Documents/Elder Scrolls Online/live/AddOns/`
3. Launch ESO

---

## Usage

### Commands
```
/markdown          # Open window (default format)
/markdown github   # GitHub format
/markdown discord  # Discord format
/markdown vscode   # VS Code format
/markdown quick    # One-line summary
```

### Process
1. Run `/markdown` command
2. Window opens with generated markdown
3. Press `Ctrl+C` to copy
4. Paste anywhere

---

## Formats

### GitHub
Full tables with alignment, collapsible sections, UESP links.  
**Best for**: README files, wikis, documentation

### Discord
Compact format with emoji indicators, no large tables.  
**Best for**: Discord servers, chat sharing

### VS Code
Similar to GitHub, renders well in VS Code preview.  
**Best for**: Local markdown files

### Quick
Single-line summary.  
**Example**: `Pelatiah • L50 CP627 👑 • Impe DK • Mother's Sorrow(5), Silks of the Sun(5)`

---

## Configuration

**ESC → Settings → Add-Ons → CharacterMarkdown**

- **Section Toggles** - Enable/disable: CP, Equipment, Skills, Stats, Currency
- **UESP Links** - Add wiki links to abilities and sets
- **Skill Filters** - Hide maxed skills, set minimum rank threshold
- **Collectibles** - Show full lists or counts only

---

## Sample Output

<details>
<summary>Expand to see example</summary>

```markdown
# Pelatiah

**Imperial Dragonknight**  
**Level 50 • CP 627 • Ebonheart Pact**

## ⚔️ Combat Setup

### Front Bar (Destruction Staff)
1. [Molten Whip](https://en.uesp.net/wiki/Online:Molten_Whip) - Spammable
2. [Engulfing Flames](https://en.uesp.net/wiki/Online:Engulfing_Flames) - DoT
3. [Eruption](https://en.uesp.net/wiki/Online:Eruption) - Ground AoE
4. [Wall of Elements](https://en.uesp.net/wiki/Online:Wall_of_Elements) - Channel
5. [Inner Light](https://en.uesp.net/wiki/Online:Inner_Light) - Passive
6. **Ultimate**: [Standard of Might](https://en.uesp.net/wiki/Online:Standard_of_Might)

### Back Bar (Restoration Staff)
1. [Rapid Regeneration](https://en.uesp.net/wiki/Online:Rapid_Regeneration) - HoT
2. [Combat Prayer](https://en.uesp.net/wiki/Online:Combat_Prayer) - Buff
3. [Healing Springs](https://en.uesp.net/wiki/Online:Healing_Springs) - Ground HoT
4. [Elemental Drain](https://en.uesp.net/wiki/Online:Elemental_Drain) - Debuff
5. [Inner Light](https://en.uesp.net/wiki/Online:Inner_Light) - Passive
6. **Ultimate**: [Aggressive Warhorn](https://en.uesp.net/wiki/Online:Aggressive_Warhorn)

## 🎒 Equipment

| Slot | Item | Set | Quality | Trait |
|------|------|-----|---------|-------|
| Head | Mother's Sorrow Hat | Mother's Sorrow | Epic | Divines |
| Chest | Silks of the Sun Cuirass | Silks of the Sun | Epic | Divines |

## ⭐ Champion Points (627 total)

### Warfare (200 CP)
- **Thaumaturge** - 50
- **Master-at-Arms** - 50
- **Deadly Aim** - 30
```

</details>

---

## Documentation

- **[User Guide](docs/README.md)** - Installation, usage, settings
- **[Development](docs/DEVELOPMENT.md)** - Local setup, workflow, testing
- **[Architecture](docs/ARCHITECTURE.md)** - Code structure, patterns
- **[API Reference](docs/API_REFERENCE.md)** - ESO Lua API patterns
- **[Publishing](docs/PUBLISHING.md)** - Release process

---

## Development

### Quick Setup
```bash
git clone https://github.com/yourusername/CharacterMarkdown.git
cd CharacterMarkdown
task install:deps    # Install tools
task install:dev     # Link to ESO
```

### Workflow
```bash
# Edit files in src/
# Test: /reloadui in ESO
task lint            # Validate code
task test            # Full tests
```

### Release
```bash
task version:bump -- patch    # Update version
# Edit CHANGELOG.md
git commit -am "Release v2.1.2"
git tag v2.1.2
git push origin main --tags   # Auto-deploys via GitHub Actions
```

---

## Troubleshooting

**Addon not loading**: Check files in `AddOns/CharacterMarkdown/`, try `/reloadui`  
**Settings not saving**: Fixed in v2.1.1 - update addon  
**Debug messages**: Install LibDebugLogger for clean debug output

---

## Contributing

Contributions welcome! See [DEVELOPMENT.md](docs/DEVELOPMENT.md).

1. Fork repository
2. Create feature branch
3. Make changes and test
4. Submit pull request

---

## License

MIT License - see [LICENSE](LICENSE)

---

## Acknowledgments

- **ESO Community** - Feedback and testing
- **UESP** - Comprehensive wiki data
- **LibAddonMenu-2.0** - Settings framework
- **LibDebugLogger** - Debug system
- **ESOUI** - Addon distribution

---

**Made for the Elder Scrolls Online community** ❤️
