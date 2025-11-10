# Champion Diagram Enhancement with Pathfinder

## Overview

The Champion Points Mermaid diagram has been enhanced to use the pathfinder utility to discover and display prerequisite relationships between champion skills/stars.

## What Was Added

### 1. **Prerequisite Connection Discovery**

The diagram now uses the cluster API to discover relationships:
- **Cluster Roots**: Uses `IsChampionSkillClusterRoot()` to find cluster center stars
- **Cluster Members**: Uses `GetChampionClusterSkillIds()` to get all skills in a cluster
- **Unlock Status**: Uses `WouldChampionSkillNodeBeUnlocked()` to determine if connections are active

### 2. **Visual Connections in Diagram**

The Mermaid diagram now includes:
- **Solid arrows** (`-->`) for unlocked cluster relationships
- **Dashed arrows** (`-.->`) for prerequisite paths that may unlock skills
- Edge labels showing connection type ("unlocked" or "requires")

### 3. **Enhanced Legend**

Updated visual guide explains:
- ➡️ **Solid Arrow** = Unlocked connection (cluster relationship)
- ⤴️ **Dashed Arrow** = Prerequisite path (may unlock)

## How It Works

1. **Build Node Mapping**: Maps skill IDs to Mermaid node IDs from the STAR_MAP
2. **Discover Clusters**: For each discipline, finds cluster roots and their members
3. **Add Edges**: Creates Mermaid edges showing cluster relationships
4. **Test Unlock Status**: Determines edge style based on whether skills are unlocked

## Code Changes

### Key Functions Used

```lua
-- Discover cluster roots
IsChampionSkillClusterRoot(skillId)

-- Get cluster members
GetChampionClusterSkillIds(rootSkillId)

-- Test unlock status
WouldChampionSkillNodeBeUnlocked(skillId, pendingPoints)
```

### Example Edge Generation

```lua
-- Solid edge for unlocked cluster relationship
rootNode -->|unlocked| clusterNode

-- Dashed edge for prerequisite
baseNode -.-->|requires| advancedNode
```

## Benefits

1. **Visual Structure**: Shows how skills relate to each other in clusters
2. **Unlock Paths**: Visual representation of prerequisite relationships
3. **Better Understanding**: Users can see which skills unlock which others
4. **API-Based**: Uses actual game data, not hardcoded relationships

## Limitations

- **Cluster-Only**: Currently shows cluster relationships (most reliable)
- **Simplified**: Doesn't show all possible prerequisite paths (would be too cluttered)
- **Performance**: Cluster discovery adds some processing time

## Future Enhancements

The pathfinder utility (`ChampionPathfinder.lua`) can be used for:
1. **Detailed Path Finding**: Show minimum point paths to unlock specific skills
2. **Interactive Suggestions**: Highlight which skills to invest in next
3. **Optimization Hints**: Suggest efficient CP allocation paths

## Enabling the Diagram

To enable the diagram:

1. **Add to manifest** (if not already):
   ```
   src/generators/sections/ChampionDiagram.lua
   ```

2. **Enable in settings**:
   ```lua
   CM.settings.includeChampionDiagram = true
   ```

3. **Use in generator**:
   ```lua
   if IsSettingEnabled(settings, "includeChampionDiagram", false) then
       markdown = markdown .. gen.GenerateChampionDiagram(data.cp, format)
   end
   ```

## Testing

The diagram should now show:
- ✅ All invested stars as nodes
- ✅ Cluster relationships as edges
- ✅ Visual indication of unlock status
- ✅ Clear legend explaining connections

## Notes

- Cluster relationships are the most reliable prerequisite data from the API
- For detailed unlock paths, use `CM.utils.GetSkillUnlockRequirements()` directly
- Mermaid diagrams render in GitHub and VS Code viewers, but not in Discord

