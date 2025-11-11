# Armory Builds Update

## Overview

Updated the Armory Builds collector and generator to use the correct ESO Lua API functions and provide comprehensive build information.

## Changes Made

### 1. Collector (`src/collectors/ArmoryBuilds.lua`)

#### API Functions Updated

**Old (Non-existent) Functions:**
- `GetNumArmoryBuilds()` ❌
- `GetArmoryBuildInfo()` ❌
- `GetNumArmoryBuildEquipmentSlots()` ❌
- `GetArmoryBuildEquipmentSlotInfo()` ❌
- `GetNumArmoryBuildSkillBars()` ❌
- `GetArmoryBuildSkillBarSlotInfo()` ❌
- `GetArmoryBuildChampionPoints()` ❌

**New (Correct) Functions:**
- `GetNumUnlockedArmoryBuilds()` ✅
- `GetArmoryBuildName(buildIndex)` ✅
- `GetArmoryBuildIconIndex(buildIndex)` ✅
- `GetArmoryBuildAttributeSpentPoints(buildIndex, attributeType)` ✅
- `GetArmoryBuildSkillsTotalSpentPoints(buildIndex)` ✅
- `GetArmoryBuildChampionSpentPointsByDiscipline(buildIndex, disciplineId)` ✅
- `GetArmoryBuildSlotBoundId(buildIndex, slotIndex, hotbarCategory)` ✅
- `GetArmoryBuildEquipSlotItemLinkInfo(buildIndex, equipSlot)` ✅
- `GetArmoryBuildEquippedOutfitIndex(buildIndex)` ✅
- `GetArmoryBuildCurseType(buildIndex)` ✅
- `GetArmoryBuildPrimaryMundusStone(buildIndex)` ✅
- `GetArmoryBuildSecondaryMundusStone(buildIndex)` ✅

#### New Data Collected

Each armory build now collects:

1. **Basic Info:**
   - Build name
   - Icon index
   - Slot index

2. **Attributes:**
   - Health points allocated
   - Magicka points allocated
   - Stamina points allocated

3. **Champion Points:**
   - Craft discipline points
   - Warfare discipline points
   - Fitness discipline points
   - Total champion points

4. **Equipment:**
   - All equipped items (head, chest, legs, weapons, jewelry, etc.)
   - Item names and links
   - Support for both weapon bars (main and backup)

5. **Hotbar Abilities:**
   - Primary bar abilities (slots 3-8)
   - Backup bar abilities (slots 3-8)
   - Ability names and IDs

6. **Mundus Stones:**
   - Primary mundus stone
   - Secondary mundus stone (if applicable)

7. **Additional Info:**
   - Curse type (Vampire/Werewolf)
   - Total skill points spent
   - Equipped outfit index

#### Data Structure

```lua
{
    armory = {
        unlocked = number,  -- Number of unlocked build slots
        builds = {
            {
                index = number,
                name = string,
                iconIndex = number,
                attributes = {
                    health = number,
                    magicka = number,
                    stamina = number
                },
                champion = {
                    craft = number,
                    warfare = number,
                    fitness = number,
                    total = number
                },
                equipment = {
                    {slot = number, name = string, link = string},
                    ...
                },
                hotbars = {
                    {
                        category = number,  -- 1=Primary, 2=Backup
                        abilities = {
                            {slot = number, id = number, name = string},
                            ...
                        }
                    },
                    ...
                },
                mundus = {
                    primary = string,
                    secondary = string  -- Optional
                },
                curse = string,  -- "Vampire" or "Werewolf" or nil
                skillPoints = number,
                outfitIndex = number
            },
            ...
        }
    }
}
```

### 2. Generator (`src/generators/sections/ArmoryBuilds.lua`)

#### Removed Features

- **Build Templates section** - Removed as the API functions used didn't exist
- **Active/Inactive status** - Not available in ESO API

#### New Display Features

**Discord Format:**
- Shows unlocked slots count
- Lists build names with brief summary
- Shows skill points and curse type

**Standard Format:**
- Shows unlocked slots at the top
- Each build displayed as a subsection with:
  - Build name as heading
  - Summary table with:
    - Skill Points
    - Attributes (Health/Magicka/Stamina)
    - Champion Points (Craft/Warfare/Fitness)
    - Mundus Stones
    - Curse type
    - Outfit index
  - Equipment table with all items
  - Hotbar sections for Primary and Backup bars

#### Helper Functions

Added formatting functions for cleaner output:
- `FormatAttributes()` - Formats attribute allocations
- `FormatChampionPoints()` - Formats CP by discipline
- `FormatMundusStones()` - Formats primary/secondary mundus

### 3. Equipment Slot Mapping

Properly maps ESO equipment slot IDs to readable names:
- Slot 0 → Head
- Slot 1 → Neck
- Slot 2 → Chest
- Slot 3 → Shoulders
- Slot 4 → Main Hand
- Slot 5 → Off Hand
- Slot 6 → Waist
- Slot 7 → Legs
- Slot 8 → Feet
- Slot 11 → Ring 1
- Slot 12 → Ring 2
- Slot 13 → Hands
- Slot 20 → Backup Main
- Slot 21 → Backup Off

## Example Output

### Discord Format
```
**Armory Builds:** 2 slots unlocked (2 configured)
• **PvE DPS** (310 SP, Vampire)
• **PvP Tank** (305 SP)
```

### Standard Format
```markdown
## 🏰 Armory Builds

**Unlocked Slots:** 2

### PvE DPS

| Property | Value |
|:---------|:------|
| **Skill Points** | 310 |
| **Attributes** | 10 Health, 64 Magicka, 0 Stamina |
| **Champion Points** | 1800 total (600 Craft, 600 Warfare, 600 Fitness) |
| **Mundus Stones** | The Thief |
| **Curse** | Vampire |
| **Outfit Index** | 1 |

#### Equipment (14 items)

| Slot | Item |
|:-----|:-----|
| Head | Mother's Sorrow Helmet |
| Chest | Medusa Robe |
...

#### Primary Bar (6 abilities)

- Crystal Weapon
- Force Pulse
- Inner Light
...

#### Backup Bar (6 abilities)

- Unstable Wall of Elements
- Mystic Orb
...
```

## Benefits

1. **Accurate API Usage:** Uses only documented ESO Lua API functions
2. **Comprehensive Data:** Captures all aspects of armory builds
3. **Better Organization:** Clean separation of concerns between collector and generator
4. **Error Handling:** Uses `CM.SafeCall()` for all ESO API calls
5. **User-Friendly Output:** Clear, organized display of build information
6. **Multiple Formats:** Optimized output for both Discord and standard markdown

## Testing

To test the updated armory builds section:

1. Load the addon in ESO
2. Create one or more armory builds using the Armory Station
3. Run `/markdown` to generate character profile
4. Check the "Armory Builds" section for:
   - Correct number of unlocked slots
   - All configured builds listed
   - Detailed information for each build
   - Equipment and abilities properly displayed

## Notes

- The Armory system saves builds but doesn't track which one is "active"
- The system only shows builds that have been configured (have a name)
- Empty build slots are not displayed
- All API calls are safely wrapped with error handling
- Follows Lua 5.1 compatibility (no goto statements)

