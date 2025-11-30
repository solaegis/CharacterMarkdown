# Champion Points System - Rules & Restrictions

## ESO Champion Points 2.0 System Overview

### Core Mechanics

1. **Total Champion Points (CP)**
   - Earned account-wide through gameplay
   - Maximum theoretical limit: 3600 CP
   - Unlocks at character level 50

2. **Three Disciplines**
   - **⚒️ Craft** (Red) - Discipline ID: 3
   - **⚔️ Warfare** (Blue) - Discipline ID: 1
   - **💪 Fitness** (Green) - Discipline ID: 2

3. **CP Allocation Rules**
   - **Maximum per discipline**: 660 CP (hard cap)
   - **Shared pool**: Unassigned CP can be allocated to any discipline
   - **No minimum**: Disciplines can have 0 CP allocated
   - **Total spent** = sum of all three disciplines' allocated CP
   - **Available (unassigned)** = Total CP - Total spent

### Available CP Display Logic

The game UI shows **two different concepts** that must not be confused:

#### 1. Total Unassigned CP (Shared Pool)
- This is `cpData.available` in the code
- Single value shared across all disciplines
- Can be spent in any discipline
- Example: If you have 246 unassigned CP, you can allocate all 246 to any single discipline (up to the 660 cap)

#### 2. Per-Discipline Remaining Capacity
- This is what the game UI shows in the CP screen
- **Formula**: `remaining = min(660, total CP / 3) - assigned in that discipline`
- Each discipline shows different values based on how much is already allocated
- Example with 769 total CP:
  - Max per discipline = min(660, 769/3) = min(660, 256) = 256
  - Craft: 151 assigned → 256 - 151 = **105 remaining**
  - Warfare: 217 assigned → 256 - 217 = **39 remaining**
  - Fitness: 155 assigned → 256 - 155 = **101 remaining**

### Implementation in CharacterMarkdown

#### Overview Section Display
- Shows **per-discipline remaining capacity** (not shared pool)
- Format: `⚒️ X - ⚔️ Y - 💪 Z`
- Calculated in `src/generators/sections/Overview.lua`

#### Champion Points Section Display
- Summary table shows **total unassigned CP** (shared pool)
- Format: `Total | Spent | Available`
- Discipline breakdowns show individual allocations
- Calculated in `src/generators/sections/ChampionPoints.lua`

### Data Structure

```lua
cpData = {
    total = 769,           -- Total CP earned (account-wide)
    spent = 523,           -- Sum of all disciplines
    available = 246,       -- Unassigned CP (shared pool)
    disciplines = {
        {
            name = "Craft",
            emoji = "⚒️",
            assigned = 151,    -- CP allocated to this discipline
            total = 151,       -- Same as assigned
            skills = { ... }
        },
        {
            name = "Warfare",
            emoji = "⚔️",
            assigned = 217,
            total = 217,
            skills = { ... }
        },
        {
            name = "Fitness",
            emoji = "💪",
            assigned = 155,
            total = 155,
            skills = { ... }
        }
    }
}
```

### Common Pitfalls

❌ **WRONG**: Showing the same `cpData.available` value for all three disciplines
```lua
-- This is incorrect - shows 246 for all three
local craftAvailable = cpData.available
local warfareAvailable = cpData.available
local fitnessAvailable = cpData.available
```

✅ **CORRECT**: Calculating per-discipline remaining capacity
```lua
-- Calculate max per discipline
local maxPerDiscipline = math.min(660, math.floor(cpData.total / 3))

-- Calculate remaining capacity per discipline
for _, discipline in ipairs(cpData.disciplines) do
    local assigned = discipline.assigned or discipline.total or 0
    local remaining = math.max(0, maxPerDiscipline - assigned)
    -- Store remaining for that specific discipline
end
```

### Validation Rules

1. **Total CP validation**: `cpData.available + cpData.spent = cpData.total` (within ±1 for rounding)
2. **Per-discipline cap**: No discipline should have more than 660 CP assigned
3. **Non-negative**: All values (total, spent, available, assigned) must be ≥ 0
4. **Discipline count**: Always exactly 3 disciplines (Craft, Warfare, Fitness)

### API Functions

Key ESO API functions used:
- `GetPlayerChampionPointsEarned()` - Total CP earned (account-wide)
- `GetUnitChampionPoints("player")` - **WARNING**: May return incorrect values, use calculation instead
- `GetNumChampionDisciplines()` - Should always return 3
- `GetChampionDisciplineName(disciplineId)` - Get discipline name
- `GetNumSpentChampionPoints(disciplineType)` - CP spent in a discipline (legacy method)
- `GetChampionPointsInDiscipline(disciplineType)` - Alternative method for spent CP (legacy)

#### Recommended API (ZO_ChampionDisciplineData)
The proper way to get assigned points per discipline:
```lua
-- Access the champion data manager
local manager = CHAMPION_DATA_MANAGER

-- Get discipline data object
local disciplineData = manager:GetChampionDisciplineData(disciplineId)

-- Get assigned points (this is the most reliable method)
local assignedPoints = disciplineData:GetNumSavedPointsTotal()
```

This method is more reliable than the legacy `GetChampionPointsInDiscipline()` function.

### References

- Full implementation details: `docs/CHAMPION_POINTS_FLOW.md`
- Collector code: `src/collectors/Champion.lua`
- Generator code: `src/generators/sections/ChampionPoints.lua`
- Overview display: `src/generators/sections/Overview.lua`
