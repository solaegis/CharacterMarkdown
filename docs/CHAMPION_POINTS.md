# Champion Points System

## Overview

The Champion Points (CP) system unlocks at level 50 and provides account-wide power progression through three disciplines. This document covers the system mechanics, data flow, and markdown generation.

---

## System Mechanics

### Core Concepts

| Concept | Description |
|---------|-------------|
| **Total CP** | Earned account-wide through gameplay (max ~3600) |
| **Three Disciplines** | ⚒️ Craft, ⚔️ Warfare, 💪 Fitness |
| **Maximum per Discipline** | 660 CP (hard cap) |
| **Available CP** | Unassigned points that can be allocated anywhere |

### CP Allocation Rules

1. **Shared Pool**: Unassigned CP can be allocated to any discipline
2. **Discipline Cap**: Each discipline maxes at 660 CP (or `total / 3`, whichever is lower)
3. **Stars/Skills**: Each discipline contains multiple skills (slottable and passive)
4. **Slottable Limit**: 4 skills per discipline at 900+ CP, otherwise 3

### Data Structure

```lua
cpData = {
    total = 769,           -- Total CP earned
    spent = 523,           -- Sum of all disciplines
    available = 246,       -- Unassigned (shared pool)
    disciplines = {
        { name = "Craft", emoji = "⚒️", assigned = 151, skills = {...} },
        { name = "Warfare", emoji = "⚔️", assigned = 217, skills = {...} },
        { name = "Fitness", emoji = "💪", assigned = 155, skills = {...} }
    }
}
```

---

## Data Flow

```
GenerateMarkdown() [Markdown.lua]
      ↓
CollectChampionPointData() [collectors/Champion.lua]
      ↓
GenerateChampionPoints() [sections/ChampionPoints.lua]
      ↓
Markdown output (with optional Mermaid diagram)
```

### Collection Process

1. **Get Total**: `GetPlayerChampionPointsEarned()` - Account-wide total
2. **Get Available**: `GetUnitChampionPoints("player")` - Unspent CP
3. **Per Discipline**: 
   - Use `CHAMPION_DATA_MANAGER:GetChampionDisciplineData(id)`
   - Get assigned points: `disciplineData:GetNumSavedPointsTotal()`
4. **Validation**: `available + spent = total` (±1 tolerance)

### Key API Functions

```lua
GetPlayerChampionPointsEarned()           -- Total CP
GetNumChampionDisciplines()               -- Always 3
GetChampionDisciplineName(id)             -- Discipline name
CHAMPION_DATA_MANAGER                      -- Data manager object
disciplineData:GetNumSavedPointsTotal()   -- Assigned points (reliable)
```

---

## Mermaid Diagram Feature

The optional Mermaid diagram visualizes CP allocations and skill relationships.

### Enabling

```lua
-- In settings
CM.settings.includeChampionDiagram = true
```

### Visual Elements

- **Nodes**: Each invested star with points allocated
- **Solid arrows** (`-->`) : Unlocked cluster relationships
- **Dashed arrows** (`-.->`) : Prerequisite paths that may unlock skills

### Cluster Discovery

Uses ESO API to discover skill relationships:

```lua
IsChampionSkillClusterRoot(skillId)       -- Find cluster centers
GetChampionClusterSkillIds(rootSkillId)   -- Get cluster members
WouldChampionSkillNodeBeUnlocked(id, pts) -- Test unlock status
```

---

## Pathfinder Utility

The pathfinder helps discover minimum paths to unlock specific skills.

### Usage

```lua
local cpData = CM.collectors.CollectChampionPointData()
local result = CM.utils.GetSkillUnlockRequirements(skillId, disciplineIndex, cpData)

if result.isUnlocked then
    d("Already unlocked!")
else
    d(string.format("Need %d points:", result.totalPointsNeeded))
    for _, req in ipairs(result.requirements) do
        d(string.format("  - %s: %d pts", req.skillName, req.pointsNeeded))
    end
end
```

### Return Structure

```lua
{
    isUnlocked = false,
    requirements = {{skillId, skillName, currentPoints, pointsNeeded}, ...},
    totalPointsNeeded = 3,
    clusterRoot = 456,
    targetSkillName = "Master-at-Arms"
}
```

---

## Common Pitfalls

### ❌ Wrong: Using same available value for all disciplines
```lua
-- This shows the shared pool, not per-discipline capacity
local craftAvailable = cpData.available  -- Wrong!
```

### ✅ Correct: Calculate per-discipline remaining
```lua
local maxPerDiscipline = math.min(660, math.floor(cpData.total / 3))
local remaining = math.max(0, maxPerDiscipline - discipline.assigned)
```

---

## Validation Rules

| Rule | Check |
|------|-------|
| Total Balance | `available + spent = total` (±1) |
| Discipline Cap | No discipline > 660 CP |
| Non-negative | All values ≥ 0 |
| Discipline Count | Always exactly 3 |

---

## File References

| File | Purpose |
|------|---------|
| `src/collectors/Champion.lua` | Data collection |
| `src/generators/sections/ChampionPoints.lua` | Markdown generation |
| `src/generators/sections/ChampionDiagram.lua` | Mermaid diagram |
| `src/utils/ChampionPathfinder.lua` | Path discovery |
