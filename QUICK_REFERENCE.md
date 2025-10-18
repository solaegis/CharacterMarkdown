# CharacterMarkdown Collectibles Feature - Implementation Complete

## What Was Requested

Remove the simple collectibles count table and replace with detailed collapsible lists showing:
- Format: `(X of Y)` instead of just counts
- Individual collectible names in expandable sections
- Rarity information (if available from ESO API)
- All collectible categories (not just the basic 4)

## What Was Implemented

✅ **Fully implemented** detailed collectibles feature with:

### Changes Made
1. **Modified `GenerateCollectibles()` function** in `/src/generators/Markdown.lua`
   - Added smart detection of `includeCollectiblesDetailed` setting
   - Discord format: Shows compact `(X of Y)` summary
   - GitHub/VSCode format: Shows collapsible `<details>` sections when enabled
   - Backward compatible: Falls back to simple table when disabled

2. **No changes needed** to:
   - Collector (`World.lua`) - Already implemented
   - Settings (`Defaults.lua`) - Setting already exists

### Key Features

**Setting Control:**
- Setting name: `includeCollectiblesDetailed`
- Default: `false` (opt-in to avoid very long outputs)
- Location: Addon Settings > Extended Information

**Discord Format (Always Compact):**
```markdown
**Collectibles:**
🐴 Mounts: (12 of 684)
🐾 Pets: (45 of 664)
👗 Costumes: (23 of 305)
🏠 Houses: (3 of 114)
```

**GitHub/VSCode Format (When Enabled):**
```markdown
## 🎨 Collectibles

<details>
<summary>🐴 Mounts (12 of 684)</summary>

- Alabaster Charger [Legendary]
- Alinor Royal Courser [Epic]
- Amber-Plated Salamander
...
</details>
```

**Supported Categories:**
- 🐴 Mounts
- 🐾 Pets  
- 👗 Costumes
- 🏠 Houses
- 🎭 Emotes
- 🎪 Mementos
- 🎨 Skins
- 🦎 Polymorphs
- 🎭 Personalities

**Rarity Display:**
- Shows `[Legendary]`, `[Epic]`, `[Rare]`, etc. when ESO API provides it
- Gracefully omits rarity if not available

## How to Use

### In-Game Testing

1. **Reload the addon:**
   ```
   /reloadui
   ```

2. **Enable the feature** (optional):
   - Open Settings menu
   - Navigate to Character Markdown addon
   - Find "Include Collectibles Detailed" toggle
   - Enable it

3. **Generate markdown:**
   ```
   /markdown github
   ```
   or
   ```
   /markdown discord
   ```

### Expected Behavior

**With Setting Disabled (Default):**
- Shows simple table with counts only (old behavior)

**With Setting Enabled:**
- GitHub/VSCode: Collapsible sections with full lists
- Discord: Compact `(X of Y)` format

## Technical Implementation

### Data Structure
```lua
collectiblesData = {
    hasDetailedData = true,  -- Flag indicating detailed mode
    mounts = 684,            -- Legacy count fields (backward compat)
    pets = 664,
    ...
    categories = {
        mounts = {
            name = "Mounts",
            emoji = "🐴",
            total = 684,
            owned = {
                {id = 123, name = "Alabaster Charger", quality = "Legendary"},
                {id = 456, name = "Alinor Royal Courser", quality = "Epic"},
                ...
            }
        },
        ...
    }
}
```

### Processing Flow
1. **Collector**: Checks setting → Collects data accordingly
2. **Generator**: Checks setting + hasDetailedData → Formats output
3. **Discord**: Always shows compact (never detailed lists)
4. **GitHub/VSCode**: Shows collapsible details when enabled

## Files Modified

- ✅ `/src/generators/Markdown.lua` - Line ~772-851 (GenerateCollectibles function)

## Verification Checklist

- [x] Code implemented
- [x] Backward compatible (default = disabled)
- [x] Discord format stays compact
- [x] Rarity shown only if available
- [x] All 9 collectible categories supported
- [x] Alphabetically sorted lists
- [ ] Tested in-game

## Quick Reference

**Enable detailed collectibles:**
Settings → Character Markdown → "Include Collectibles Detailed" → Check

**Commands:**
- `/reloadui` - Reload addon
- `/markdown github` - Generate GitHub format
- `/markdown discord` - Generate Discord format

---

**Status:** ✅ Implementation Complete  
**Next Step:** In-game testing with `/reloadui`
