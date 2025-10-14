# Character Markdown

A comprehensive ESO addon that exports detailed character data in markdown format for easy sharing, analysis, or documentation.

## Features

- **Complete Character Profile**: Name, race, class, alliance, level, champion points, title
- **Combat Statistics**: Full offensive and defensive stats including damage, critical ratings, resistances, and penetration
- **Equipment Details**: All 14 equipment slots with item names, set bonuses, quality, level, traits, and enchantments
- **Active Skill Lines**: All unlocked skill lines with progression tracking
- **Mundus Stone**: Currently active mundus buff
- **Companion Status**: All companions with unlock status, roles, and rapport levels
- **Copy-Paste Ready**: Clean markdown output in a scrollable UI window

## Installation

1. **Download or Clone** this repository
2. **Locate your ESO AddOns folder**:
   - **Windows**: `Documents/Elder Scrolls Online/live/AddOns/`
   - **Mac**: `Documents/Elder Scrolls Online/live/AddOns/`
3. **Copy the entire `CharacterMarkdown` folder** into your AddOns directory
4. **Launch ESO** and ensure addons are enabled in the character select screen

## Usage

### Basic Usage

1. Log in to any character
2. Type `/markdown` in the chat window
3. A window will appear with your character data in markdown format
4. Press **Ctrl+A** (or **Cmd+A** on Mac) to select all text
5. Press **Ctrl+C** (or **Cmd+C** on Mac) to copy
6. Paste into your preferred application (Discord, Reddit, Google Docs, etc.)

### Output Example

```markdown
## Character Identity

- **Name:** Valandril Stormblade
- **Race:** High Elf
- **Class:** Sorcerer
- **Alliance:** Aldmeri Dominion
- **Level:** 50
- **Champion Points:** 1,847
- **Title:** The Flawless Conqueror

## Mundus Stone

- **Active Mundus:** The Thief

## Attributes & Combat Stats

### Primary Attributes
- **Health:** 18,940
- **Magicka:** 42,387
- **Stamina:** 12,456
...
```

## Technical Details

### API Version
- Supports API versions 101043 and 101044 (update as needed)

### File Structure
```
CharacterMarkdown/
├── CharacterMarkdown.txt   # Addon manifest
├── CharacterMarkdown.xml   # UI window definition
├── CharacterMarkdown.lua   # Main logic and data collection
└── README.md              # This file
```

### Data Collection

The addon uses official ESO API functions:
- `GetUnitName()`, `GetUnitRace()`, `GetUnitClass()` - Character identity
- `GetPlayerStat()` - Combat statistics
- `GetItemLink()`, `GetItemLinkSetInfo()` - Equipment data
- `GetSkillLineInfo()` - Skill progression
- `GetUnitBuffInfo()` - Active buffs (mundus detection)
- `IsCollectibleUnlocked()` - Companion unlock status

### Performance Considerations

- **On-Demand Generation**: Data is only collected when `/markdown` is executed
- **No Background Processing**: Zero performance impact during normal gameplay
- **Minimal Memory**: ~50KB memory footprint when window is closed
- **No Saved Variables Bloat**: Optional settings storage only

## Customization

### Modifying Output Format

Edit `CharacterMarkdown.lua` to customize the markdown structure:

```lua
-- Example: Add custom section
local function GetCustomData()
    local markdown = "## My Custom Section\n\n"
    -- Your data collection here
    return markdown
end

-- Then add to GenerateMarkdown()
markdown = markdown .. GetCustomData()
```

### Changing Window Appearance

Edit `CharacterMarkdown.xml` to modify UI:

```xml
<!-- Change window size -->
<Dimensions x="1000" y="700" />

<!-- Change font -->
font="ZoFontGameLarge"
```

## Known Limitations

1. **Companion Rapport**: Current implementation shows approximate rapport detection. For exact values, additional API integration needed.
2. **Character Limit**: Output is limited to ~50,000 characters (well above typical usage)
3. **Active Character Only**: Exports current character only; multi-character export requires separate executions
4. **No Automatic Updates**: Data snapshot is static; re-run `/markdown` after equipment/skill changes

## Troubleshooting

### Window doesn't appear
- Check AddOns are enabled at character select
- Verify folder is named exactly `CharacterMarkdown`
- Check for errors with `/reloadui`

### Missing data sections
- Ensure you're using a supported API version (101043+)
- Check for conflicting addons that override UI elements

### Copy-paste issues
- Use Ctrl+A then Ctrl+C (don't click-drag to select)
- For very long outputs, copy in chunks if your application has paste limits

## Future Enhancements

Planned features:
- [ ] Multi-character export (all alts in one document)
- [ ] Saved presets (export specific sections)
- [ ] Direct file export option
- [ ] HTML export format
- [ ] Skill ability details (not just skill lines)
- [ ] Inventory summary option

## Contributing

Contributions welcome! Areas needing improvement:
- Companion rapport accurate detection
- Additional combat stats (sustain, recovery rates)
- Localization support (currently English only)

## Support

- **Issues**: Report bugs or request features via GitHub issues
- **ESOUI**: [Link to ESOUI page if published]
- **Discord**: [Your Discord if applicable]

## License

MIT License - Free to use, modify, and distribute.

## Credits

- **Author**: lvavasour
- **ESO API**: ZeniMax Online Studios
- **Community**: ESO addon developer community

## Changelog

### Version 1.0.0 (2024-10-14)
- Initial release
- Core character identity export
- Combat stats (offensive, defensive, penetration)
- Equipment table with full details
- Active skill lines tracking
- Mundus stone detection
- Companion unlock status
- Clean markdown UI with copy-paste functionality
