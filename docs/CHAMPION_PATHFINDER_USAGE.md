# Champion Point Pathfinder - Usage Guide

## Overview

The Champion Pathfinder utility helps find the minimum path (which stars and how many points) needed to unlock a specific champion skill/star.

## Limitations

The ESO API doesn't directly expose the prerequisite graph structure. The pathfinder uses:
- `WouldChampionSkillNodeBeUnlocked()` to test unlock status
- `GetChampionClusterSkillIds()` to understand cluster relationships
- Systematic testing to discover prerequisites

**Note:** This is an approximation. The actual unlock requirements may be more complex than what the pathfinder can discover.

## Functions

### `GetSkillUnlockRequirements(targetSkillId, disciplineIndex, cpData)`

Simpler function that uses cluster information to find requirements.

**Parameters:**
- `targetSkillId` (integer): The skill ID you want to unlock
- `disciplineIndex` (integer): 1=Craft, 2=Warfare, 3=Fitness
- `cpData` (table): CP data from `CollectChampionPointData()`

**Returns:**
```lua
{
    isUnlocked = false,
    requirements = {
        {skillId = 123, skillName = "Deadly Aim", currentPoints = 0, pointsNeeded = 1},
        ...
    },
    totalPointsNeeded = 3,
    clusterRoot = 456,
    targetSkillId = targetSkillId,
    targetSkillName = "Master-at-Arms"
}
```

**Example:**
```lua
local cpData = CM.collectors.CollectChampionPointData()
local skillId = 12345  -- Example skill ID
local disciplineIndex = 2  -- Warfare

local result = CM.utils.GetSkillUnlockRequirements(skillId, disciplineIndex, cpData)
if result then
    if result.isUnlocked then
        d("Skill is already unlocked!")
    else
        d(string.format("Need %d points to unlock %s:", result.totalPointsNeeded, result.targetSkillName))
        for _, req in ipairs(result.requirements) do
            d(string.format("  - %s: %d points (currently %d)", 
                req.skillName, req.pointsNeeded, req.currentPoints))
        end
    end
end
```

### `FindMinimumPathToSkill(targetSkillId, disciplineIndex, cpData)`

More complex function that attempts to find the actual minimum path using BFS.

**Note:** This is experimental and may not always find the optimal path due to API limitations.

## How It Works

1. **Check if already unlocked**: Uses `WouldChampionSkillNodeBeUnlocked(skillId, 0)`

2. **Find cluster**: Uses `IsChampionSkillClusterRoot()` and `GetChampionClusterSkillIds()` to find which cluster the skill belongs to

3. **Discover prerequisites**: Tests unlock conditions for skills in the same cluster

4. **Build path**: Returns the minimum set of skills that need points

## Integration

To use in your code:

```lua
-- In a command or function
local cpData = CM.collectors.CollectChampionPointData()

-- Find a skill by name
local targetSkillName = "Master-at-Arms"
local disciplineIndex = 2  -- Warfare

-- Get skill ID (you'd need to iterate through skills to find it)
local targetSkillId = nil
for _, discipline in ipairs(cpData.disciplines) do
    if discipline.name == "Warfare" then
        for _, star in ipairs(discipline.allStars) do
            if star.name == targetSkillName then
                targetSkillId = star.skillId
                break
            end
        end
    end
end

if targetSkillId then
    local result = CM.utils.GetSkillUnlockRequirements(targetSkillId, disciplineIndex, cpData)
    -- Use result...
end
```

## Future Improvements

- Better prerequisite discovery using systematic testing
- Cache prerequisite graph structure
- Visual path display in markdown
- Integration with CP allocation suggestions

