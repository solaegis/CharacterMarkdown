# CharacterMarkdown Documentation

## Quick Links

### Users
- **[Installation](#installation)** - Get started in 2 minutes
- **[Usage](#usage)** - Basic commands and features
- **[Settings](#settings)** - Configure the addon

### Developers
- **[Development](#development)** - Local setup and workflow
- **[Architecture](#architecture)** - Code structure
- **[Contributing](#contributing)** - Submit changes

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
/markdown          # Open export window (default format)
/markdown github   # GitHub format
/markdown discord  # Discord format
/markdown vscode   # VS Code format
/markdown quick    # One-line summary
```

### Export Process
1. Run `/markdown` command
2. Window opens with generated markdown
3. Press `Ctrl+C` to copy
4. Paste anywhere

### Formats

**GitHub** - Full tables, collapsible sections, UESP links  
**Discord** - Compact, emoji indicators  
**VS Code** - Similar to GitHub, good for local files  
**Quick** - One-line summary for quick sharing

---

## Settings

Access via **ESC → Settings → Add-Ons → CharacterMarkdown**

### Section Toggles
Enable/disable: Champion Points, Equipment, Skills, Combat Stats, Currency, etc.

### Display Options
- **UESP Links** - Add wiki links to abilities/sets
- **Skill Filters** - Hide maxed skills, set minimum rank
- **Collectibles Detail** - Full lists vs counts

---

## Development

### Prerequisites
- Git
- LuaJIT or Lua 5.1
- ESO client

### Quick Setup
```bash
# Clone repository
git clone https://github.com/yourusername/CharacterMarkdown.git
cd CharacterMarkdown

# Install dependencies
task install:deps

# Link to ESO addons folder
task install:dev

# Test
task test
```

### Development Workflow
1. Edit files in `src/`
2. Use `/reloadui` in ESO to test
3. Run `task lint` before committing
4. Submit pull request

### Testing
```bash
task lint          # Luacheck validation
task test          # Full validation
task install:live  # Install to ESO
```

---

## Architecture

### Directory Structure
```
CharacterMarkdown/
├── CharacterMarkdown.addon    # Manifest
├── CharacterMarkdown.xml      # UI definition
├── src/
│   ├── Core.lua              # Namespace & debug system
│   ├── Commands.lua          # Slash command handler
│   ├── Events.lua            # Event management
│   ├── collectors/           # Data collection modules
│   ├── generators/           # Markdown generation
│   ├── settings/             # Settings management
│   └── ui/                   # Window handler
├── scripts/                  # Build/validation scripts
└── docs/                     # Documentation
```

### Load Order
1. Core.lua - Initialize namespace
2. Utils, Links - Helper functions
3. Collectors - Data gathering
4. Generators - Markdown creation
5. Commands, Events, Settings - User interface
6. Init.lua - Final validation

### Key Patterns
- **Namespace**: All code in `CharacterMarkdown` namespace
- **Error Handling**: All ESO API calls wrapped in `pcall`
- **Performance**: Cached global function lookups
- **Debug**: LibDebugLogger integration (optional)

---

## Contributing

### Quick Start
1. Fork repository
2. Create feature branch
3. Make changes
4. Test in-game
5. Submit pull request

### Code Style
- **Indentation**: 4 spaces
- **Naming**: camelCase variables, PascalCase functions
- **Comments**: Explain "why", not "what"
- **Error Handling**: Use `pcall` for ESO API calls

### Commit Format
```
type(scope): subject

Examples:
feat(collectors): add mount training data
fix(markdown): escape special characters
docs(api): document clipboard limitations
```

### Pull Request Checklist
- [ ] Code follows style guidelines
- [ ] Tested in-game (2+ characters)
- [ ] No new errors/warnings
- [ ] Documentation updated (if needed)
- [ ] CHANGELOG.md updated (if version bump)

---

## Troubleshooting

### Addon Not Loading
- Check all files in correct directory
- Verify `CharacterMarkdown.addon` exists
- Try `/reloadui` in-game

### Settings Not Saving
- Fixed in v2.1.1 - update addon
- Open settings panel once to trigger save

### Debug Messages
- Install LibDebugLogger for clean debug output
- No chat messages in production by default

---

## Resources

- **ESOUI**: https://www.esoui.com/downloads/info4279-CharacterMarkdown.html
- **GitHub**: https://github.com/yourusername/CharacterMarkdown
- **ESO API Docs**: https://wiki.esoui.com/
- **Changelog**: ../CHANGELOG.md
- **License**: ../LICENSE

---

**Version**: 2.1.1  
**ESO API**: 101047 (Gold Road)  
**License**: MIT
