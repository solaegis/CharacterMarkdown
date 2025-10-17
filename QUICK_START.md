# CharacterMarkdown Optimized Layout - Quick Start

## What This Provides

**Size Reduction:** 37-40% (from ~12k to ~7.5k characters)

**Key Features:**
- ✅ Multi-column overview table (7 sections in 1)
- ✅ Side-by-side skill bar comparison
- ✅ Condensed equipment display (3 columns vs 5)
- ✅ Smart skill filtering (hides maxed, shows in-progress only)
- ✅ Compact companion section
- ✅ Inline stat summaries

## Quick Integration (15 minutes)

### Step 1: Add Setting (30 seconds)

Edit `CharacterMarkdown_Settings.lua`, add this line to the settings table:

```lua
useOptimizedLayout = true,
```

### Step 2: Load Module (1 minute)

In `CharacterMarkdown.lua`, find this line (around line 1800-2000):

```lua
-- =====================================================
-- MARKDOWN GENERATION (Using Templates)
-- =====================================================
```

**ADD BEFORE** that section:

```lua
-- =====================================================
-- LOAD OPTIMIZED LAYOUT MODULE
-- =====================================================
local OptimizedLayout = nil
local success, module = pcall(function()
    return require("CharacterMarkdown_OptimizedLayout")
end)

if success then
    OptimizedLayout = module
    d("[CharacterMarkdown] ✅ Optimized layout module loaded")
else
    d("[CharacterMarkdown] ⚠️ Optimized layout module not found, using standard layout")
end
```

### Step 3: Add Branch Logic (10 minutes)

Inside the `GenerateMarkdown()` function, after these lines:

```lua
local settings = CharacterMarkdownSettings or {}
local markdown = ""
```

**ADD:**

```lua
-- Check if optimized layout should be used
local useOptimized = (format == "github" and 
                     settings.useOptimizedLayout and 
                     OptimizedLayout ~= nil)

if useOptimized then
    d("[CharacterMarkdown] 📝 Using optimized GitHub layout")
end
```

### Step 4: Wrap Section Generation

Find where sections are generated (after all data collection). Wrap the GitHub format sections in a conditional:

```lua
if useOptimized and format == "github" then
    -- OPTIMIZED LAYOUT
    
    -- Header (standard)
    markdown = markdown .. "# " .. (characterData.name or "Unknown") .. "\n\n"
    local raceText = CreateRaceLink(characterData.race, format)
    local classText = CreateClassLink(characterData.class, format)
    local allianceText = CreateAllianceLink(characterData.alliance, format)
    markdown = markdown .. "**" .. raceText .. " " .. classText .. "**  \n"
    markdown = markdown .. "**Level " .. (characterData.level or 0) .. "** • **CP " .. FormatNumber(characterData.cp or 0) .. "**  \n"
    markdown = markdown .. "*" .. allianceText .. "*\n\n---\n\n"
    
    -- Combined Overview
    if settings.includeProgression ~= false then
        markdown = markdown .. OptimizedLayout.GenerateOverview(
            characterData, progressionData, currencyData, ridingData,
            inventoryData, collectiblesData, roleData, locationData, format
        )
        markdown = markdown .. "---\n\n"
    end
    
    -- Champion Points
    if settings.includeChampionPoints ~= false and cpData.total >= 10 then
        markdown = markdown .. OptimizedLayout.GenerateChampionPoints(cpData, format)
        markdown = markdown .. "---\n\n"
    end
    
    -- Skill Bars
    markdown = markdown .. OptimizedLayout.GenerateSkillBars(skillBarData, format)
    markdown = markdown .. "---\n\n"
    
    -- Combat Stats
    if settings.includeCombatStats ~= false then
        markdown = markdown .. OptimizedLayout.GenerateCombatStats(statsData, characterData)
        markdown = markdown .. "---\n\n"
    end
    
    -- Equipment
    if settings.includeEquipment ~= false then
        markdown = markdown .. OptimizedLayout.GenerateEquipment(equipmentData, format)
        markdown = markdown .. "---\n\n"
    end
    
    -- Skills
    if settings.includeSkills ~= false then
        markdown = markdown .. OptimizedLayout.GenerateSkills(skillData, format)
        markdown = markdown .. "---\n\n"
    end
    
    -- Companion
    if settings.includeCompanion ~= false then
        markdown = markdown .. OptimizedLayout.GenerateCompanion(companionData, format)
        if companionData.active then
            markdown = markdown .. "---\n\n"
        end
    end

else
    -- STANDARD LAYOUT - keep all existing section generation code here
    
end
```

## Test In-Game

```
/reloadui
/markdown github
```

**Expected output:**
```
[CharacterMarkdown] ✅ Optimized layout module loaded
[CharacterMarkdown] 📝 Using optimized GitHub layout
[CharacterMarkdown] ✅ Markdown generation complete. Length: 7523 characters
```

## Rollback

If issues occur:

```lua
-- In CharacterMarkdown_Settings.lua
useOptimizedLayout = false,
```

Then `/reloadui`

## What Gets Optimized

### Before (12k characters)
- Vertical single-column tables
- All skills shown
- All currencies shown
- 7 separate overview sections

### After (7.5k characters)
- Multi-column compact tables
- Only in-progress skills
- Only meaningful currencies (>0)
- 1 combined overview table

## Need More Detail?

See the full integration guide for step-by-step instructions and troubleshooting.
