# Champion Points Mermaid Diagram Generator - Usage Guide

## Overview

The `ChampionPointsGraph.lua` module now includes a `generateMermaidDiagram()` function that creates beautiful, themed Mermaid flowchart diagrams for ESO Champion Points constellations.

## Function Signature

```lua
ChampionPointsGraph.generateMermaidDiagram(constellationName, characterPoints)
```

### Parameters

- **constellationName** (string): The constellation to generate - `"craft"`, `"warfare"`, or `"fitness"`
- **characterPoints** (table, optional): A table mapping star names to allocated points
  - Format: `{["Star Name"] = pointsAllocated, ...}`
  - If `nil` or empty, all stars shown as unallocated

### Returns

- **string**: Complete Mermaid flowchart diagram ready to render

## Features

### Visual Theming
- **Craft (Green)**: Forest green theme with `#2d5016` primary color
- **Warfare (Red)**: Battle red theme with `#6b1e1e` primary color  
- **Fitness (Blue)**: Ocean blue theme with `#1e4d6b` primary color

### Star Visualization
- **Allocated stars**: Shown with ✅ icon and emphasized styling
- **Unallocated slottable stars**: Shown with 🔲 icon and muted styling
- **Unallocated passive stars**: Shown with ✅ icon and muted styling

### Functional Grouping
Stars are organized into logical subgraphs by function:

**Craft Constellation**:
- 🗡️ Stealth & Thievery
- 🌿 Gathering & Crafting
- 🎣 Fishing
- 🧪 Consumables
- 🐎 Mount & Movement
- ⚡ Utility

**Warfare Constellation**:
- ⚔️ Direct Damage
- 🗡️ Weapon Mastery
- ✨ Magic Damage
- 💚 Healing
- 🛡️ Damage Mitigation
- ⚡ Resource Sustain
- 🔰 Block & Riposte

**Fitness Constellation**:
- 💧 Recovery
- ⚡ Speed & Mobility
- 🛡️ Shield & Block
- ✨ Magic Sustain
- ❤️ Health & Survival
- 🔰 Defensive
- 💨 Evasion & CC

## Usage Examples

### Example 1: Generate diagram with character allocations

```lua
local ChampionPointsGraph = require("src/generators/helpers/ChampionPointsGraph")

-- Character's allocated points
local myPoints = {
    ["Gilded Fingers"] = 50,
    ["Fortune's Favor"] = 50,
    ["Wanderer"] = 50,
    ["Breakfall"] = 50,
    ["Soul Reservoir"] = 30
}

-- Generate diagram
local diagram = ChampionPointsGraph.generateMermaidDiagram("craft", myPoints)

-- Save to file or display
print(diagram)
```

### Example 2: Generate empty constellation (planning view)

```lua
-- Show all stars without allocations
local planningDiagram = ChampionPointsGraph.generateMermaidDiagram("warfare", nil)
```

### Example 3: Integration with Champion collector

```lua
-- From the Champion collector data
local championData = CM.collectors.CollectChampionPointData()

-- Extract points for a specific discipline
local craftPoints = {}
for _, discipline in ipairs(championData.disciplines) do
    if discipline.name == "Craft" then
        for _, skill in ipairs(discipline.allStars) do
            if skill.points > 0 then
                craftPoints[skill.name] = skill.points
            end
        end
        break
    end
end

-- Generate diagram
local diagram = ChampionPointsGraph.generateMermaidDiagram("craft", craftPoints)
```

## Output Format

The generated diagram includes:
1. **Theme configuration** - Mermaid init block with color scheme
2. **Flowchart declaration** - `flowchart TB` (top-to-bottom)
3. **Subgraphs** - Grouped stars by functional category
4. **Node definitions** - Each star with icon, name, and point info
5. **Connections** - Prerequisite arrows with min_points labels
6. **Styling** - CSS classes for allocated vs unallocated stars

## Rendering

The output can be rendered in:
- **Mermaid Live Editor**: https://mermaid.live
- **Markdown files**: GitHub, GitLab, etc. with Mermaid support
- **Documentation sites**: MkDocs, Docusaurus, etc.
- **ESO addon UI**: If integrated with a Mermaid renderer

## Notes

- Node IDs use the star's numeric ID from the game
- Prerequisite connections show the minimum points required
- The diagram matches the visual style of the example templates
- All data is synchronized with `champion_points.yaml`
