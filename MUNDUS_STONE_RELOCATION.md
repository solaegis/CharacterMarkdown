# Mundus Stone Relocation - Implementation Summary

## Change Overview
**Date:** 2025-01-19  
**Version:** v2.1.0+  
**Change Type:** UI Restructuring

## What Changed

Relocated the **Mundus Stone** information from a standalone section into the **Character Overview** table.

### Before
```
## 📊 Character Overview
[Character attributes table]

## 🪨 Mundus Stone
✅ Active: The Thief
```

### After
```
## 📊 Character Overview
| Attribute | Value |
|:----------|:------|
| **Race** | High Elf |
| **Class** | Sorcerer |
| ...
| **🪨 Mundus Stone** | The Thief |
| **Role** | DPS |
| **Location** | Stros M'Kai |
```

## Behavior by Format

### GitHub / VS Code
- **Mundus is now IN the Character Overview table** (new location)
- Standalone Mundus section removed
- Displayed only if a mundus stone is active

### Discord
- **Mundus remains a separate section** (unchanged)
- Keeps compact Discord format intact

### Quick
- No change (quick format doesn't include mundus)

## Technical Implementation

### Modified Function: `GenerateOverview()`
**Location:** `src/generators/Markdown.lua` ~line 549

**New signature:**
```lua
function GenerateOverview(characterData, roleData, locationData, buffsData, mundusData, settings, format)
```

**Added parameter:** `mundusData`

**New code block (inserted after Title):**
```lua
-- Mundus Stone
if mundusData and mundusData.active then
    local mundusText = CreateMundusLink(mundusData.name, format)
    markdown = markdown .. "| **🪨 Mundus Stone** | " .. mundusText .. " |\n"
end
```

### Modified: Main Generation Flow
**Location:** `src/generators/Markdown.lua` ~line 388

**Before:**
```lua
if format ~= "discord" then
    markdown = markdown .. GenerateOverview(characterData, roleData, locationData, buffsData, settings, format)
end
```

**After:**
```lua
if format ~= "discord" then
    markdown = markdown .. GenerateOverview(characterData, roleData, locationData, buffsData, mundusData, settings, format)
end
```

### Modified: Mundus Section Call
**Location:** `src/generators/Markdown.lua` ~line 453

**Before:**
```lua
-- Mundus
markdown = markdown .. GenerateMundus(mundusData, format)
```

**After:**
```lua
-- Mundus (Discord only - for other formats it's in Overview table)
if format == "discord" then
    markdown = markdown .. GenerateMundus(mundusData, format)
end
```

## Rationale

### Why This Change?

1. **Improved Information Density**: Mundus Stone is a core character attribute alongside Race, Class, and Alliance
2. **Reduced Section Bloat**: Eliminates a standalone section with a single line of content
3. **Better Visual Flow**: Character identity information is now consolidated in one table
4. **Maintains Discord Compatibility**: Preserves Discord's compact format preference

### Design Decision: Discord Exception

Discord format keeps the standalone section because:
- Discord users prefer separate labeled sections over dense tables
- The compact `**Mundus:** The Thief` format works better for mobile viewing
- Maintains consistency with other Discord formatting conventions

## Testing Checklist

- [ ] Verify GitHub format shows Mundus in Overview table
- [ ] Verify VS Code format shows Mundus in Overview table
- [ ] Verify Discord format still shows standalone Mundus section
- [ ] Verify Quick format unchanged (no mundus shown)
- [ ] Verify Mundus link generation works in all formats
- [ ] Verify behavior when NO mundus stone is active (should not show row)
- [ ] Verify table formatting is correct (no broken pipes)

## Related Settings

This change does NOT introduce new settings. Mundus display is controlled by existing settings:
- ~~`includeMundus`~~ (no such setting exists - mundus always shows if active)
- Mundus only shows if `mundusData.active == true`

## Future Considerations

### Potential Setting Addition
If users want to hide mundus stone entirely, a new setting could be added:
```lua
settings.includeMundus = true  -- default
```

This would require:
1. Adding check in `GenerateOverview()`: `if settings.includeMundus ~= false and mundusData and mundusData.active then`
2. Adding check in `GenerateMundus()` call (Discord): `if settings.includeMundus ~= false and format == "discord" then`
3. Adding setting to `src/settings/Defaults.lua`
4. Adding toggle to `src/settings/Panel.lua`

**Current Status:** NOT IMPLEMENTED (mundus always shows if active)

## Files Modified

- `src/generators/Markdown.lua` - 3 changes
  1. Updated `GenerateOverview()` function signature (+1 parameter)
  2. Added Mundus row to Overview table generation
  3. Wrapped `GenerateMundus()` call in Discord format check

## Backward Compatibility

✅ **Fully backward compatible**
- No breaking changes to existing functionality
- All existing profiles will render correctly
- No settings migration needed
- Discord format behavior unchanged

## Visual Examples

### GitHub/VS Code Output
```markdown
## 📊 Character Overview

| Attribute | Value |
|:----------|:------|
| **Race** | High Elf |
| **Class** | Sorcerer |
| **Alliance** | Aldmeri Dominion |
| **Level** | 50 |
| **Champion Points** | 627 |
| **ESO Plus** | ✅ Active |
| **🪨 Mundus Stone** | [The Thief](https://en.uesp.net/wiki/Online:The_Thief_(Mundus_Stone)) |
| **Role** | ⚔️ DPS |
| **Location** | Stros M'Kai |
| **🎯 Attributes** | Magicka: 20,000 • Health: 18,000 • Stamina: 15,000 |
```

### Discord Output
```
# **Pelatiah**
High Elf Sorcerer • L50 • CP627 • 👑 ESO Plus
*Aldmeri Dominion*

**Mundus:** [The Thief](https://en.uesp.net/wiki/Online:The_Thief_(Mundus_Stone))

[rest of profile]
```

## Commit Message
```
feat(ui): Move Mundus Stone into Character Overview table

- Consolidated mundus stone information into Overview table for GitHub/VSCode formats
- Maintains standalone section for Discord format (better mobile UX)
- Improves information density by eliminating single-line standalone section
- No breaking changes or new settings required

Closes #[issue-number]
```
