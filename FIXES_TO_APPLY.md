# CharacterMarkdown Visual Issues - Comprehensive Fix Plan

## Overview
This document details all fixes to be applied to address the 9 critical visual issues identified in the markdown output.

---

## Issue #1: Broken HTML Table in Title Section 🔴 HIGH

### Problem
Missing `<tr>` wrapper in title display HTML table, causing invalid structure.

### Location
`src/generators/sections/Character.lua` - `CreateInfoBox` function usage

### Fix
Replace the broken `CreateInfoBox` call with proper centered div. The current `CreateInfoBox` implementation creates an overly complex HTML structure with invisible images as spacers.

### Code Change
```lua
-- IN: src/generators/sections/Character.lua, GenerateHeader function

-- OLD (around line 93-98):
if title ~= "" and markdown.CreateInfoBox then
    local titleBox = markdown.CreateInfoBox(string_format("**Title:** %s", title))
    if titleBox then
        header = header .. titleBox
    end
end

-- NEW:
if title ~= "" then
    if markdown.CreateCenteredBlock then
        header = header .. markdown.CreateCenteredBlock(string_format("**Title:** %s", title))
    else
        header = header .. string_format("\n**Title:** %s\n\n", title)
    end
end
```

---

## Issue #2: Wrong Callout Syntax 🟡 MEDIUM

### Problem
Using plain blockquote `>` instead of GitHub callout syntax `> [!NOTE]`

### Location
`src/generators/sections/Character.lua` - `GenerateQuickStats` function (already uses CreateCallout)

### Status
✅ **ALREADY FIXED** - The code already calls `markdown.CreateCallout("note", content, format)` which generates proper `> [!NOTE]` syntax.

### Verification Needed
Check if the issue is in the actual rendered output or if `CreateCallout` has a bug.

---

## Issue #3: Zero Resource Values 🔴 HIGH

### Problem
Quick stats showing `Health: 0 | Magicka: 0 | Stamina: 0` instead of actual values

### Location
`src/generators/sections/Character.lua` - `GenerateQuickStats` function

### Root Cause
Function is trying multiple field names but may not be getting the correct data structure from collectors.

### Fix
Add better fallback logic and debug logging:

```lua
-- IN: src/generators/sections/Character.lua, GenerateQuickStats function

-- REPLACE lines 155-165 with:
local function GenerateQuickStats(charData, statsData, format)
    if not charData then return "" end
    if format == "discord" then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    
    local level = charData.level or 1
    local cp = charData.cp or 0
    
    -- FIX: Get resources with better fallback chain
    local health = 0
    local magicka = 0
    local stamina = 0
    
    if statsData then
        -- Try multiple field name variations
        health = statsData.health or statsData.maxHealth or statsData.Health or statsData.MaxHealth or 0
        magicka = statsData.magicka or statsData.maxMagicka or statsData.Magicka or statsData.MaxMagicka or 0
        stamina = statsData.stamina or statsData.maxStamina or statsData.Stamina or statsData.MaxStamina or 0
        
        -- Debug: Log what we found
        if health == 0 and magicka == 0 and stamina == 0 then
            CM.DebugPrint("QUICKSTATS", "⚠️ All resources are 0. statsData structure:")
            if CM.debug then
                for k, v in pairs(statsData) do
                    CM.DebugPrint("QUICKSTATS", string.format("  %s = %s", tostring(k), tostring(v)))
                end
            end
        end
    else
        CM.DebugPrint("QUICKSTATS", "⚠️ statsData is nil!")
    end
    
    -- Rest of function continues...
```

---

## Issue #4: Missing Enlightenment Callout 🟡 MEDIUM

### Problem
No enlightenment status callout in progression section

### Location
`src/generators/sections/Character.lua` - `GenerateProgression` function (lines 289-291)

### Status
⚠️ **PARTIALLY IMPLEMENTED** - Code exists but uses wrong callout type

### Fix
Change callout type from "success" to "tip" (which renders as [!TIP] in GitHub):

```lua
-- IN: src/generators/sections/Character.lua, GenerateProgression function

-- REPLACE lines 289-291:
if progressionData.isEnlightened and markdown.CreateCallout then
    local callout = markdown.CreateCallout("tip",  -- Changed from "success" to "tip"
        "🌟 **Enlightened!** Earning 4x Champion Point XP", format)
    if callout then
        result = result .. callout
    end
end
```

---

## Issue #5: Missing Attention Needed Callout 🟡 MEDIUM

### Problem
No warning callout for unspent points

### Location
`src/generators/Markdown.lua` - Section registry

### Status
✅ **ALREADY IMPLEMENTED** - `GenerateAttentionNeeded` is already in the section registry and is being called.

### Verification Needed
Check if the function is properly detecting unspent points from progressionData.

### Additional Fix
Add inventory and riding warnings to attention needed:

```lua
-- IN: src/generators/sections/Character.lua, GenerateAttentionNeeded function

-- REPLACE entire function with:
local function GenerateAttentionNeeded(progressionData, inventoryData, ridingData, companionData, format)
    if format == "discord" then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local warnings = {}
    
    -- Check for unspent points
    if progressionData then
        if progressionData.unspentSkillPoints and progressionData.unspentSkillPoints > 0 then
            table.insert(warnings, string.format("⚠️ **%d unspent skill points**", progressionData.unspentSkillPoints))
        end
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            table.insert(warnings, string.format("⚠️ **%d unspent attribute points**", progressionData.unspentAttributePoints))
        end
    end
    
    -- Check inventory capacity warnings (>90%)
    if inventoryData then
        if inventoryData.backpackPercent and inventoryData.backpackPercent >= 90 then
            table.insert(warnings, string.format("🎒 **Backpack nearly full** (%d%%)", inventoryData.backpackPercent))
        end
        if inventoryData.bankPercent and inventoryData.bankPercent >= 90 then
            table.insert(warnings, string.format("🏦 **Bank nearly full** (%d%%)", inventoryData.bankPercent))
        end
    end
    
    -- Check riding skill training available
    if ridingData then
        local speed = ridingData.speed or 0
        local stamina = ridingData.stamina or 0
        local capacity = ridingData.capacity or 0
        if speed < 60 or stamina < 60 or capacity < 60 then
            local incomplete = {}
            if speed < 60 then table.insert(incomplete, "Speed") end
            if stamina < 60 then table.insert(incomplete, "Stamina") end
            if capacity < 60 then table.insert(incomplete, "Capacity") end
            table.insert(warnings, string.format("🐴 **Riding training available**: %s", table.concat(incomplete, ", ")))
        end
    end
    
    -- Check companion rapport low
    if companionData and companionData.active and companionData.rapport then
        if companionData.rapport < 1000 then -- Low rapport threshold
            table.insert(warnings, string.format("💔 **Companion rapport low**: %s (%d)", 
                companionData.name or "Unknown", companionData.rapport))
        end
    end
    
    if #warnings == 0 then return "" end
    
    local content = table.concat(warnings, "  \n")
    
    if not enhanced or not markdown then
        return string.format("## ⚠️ Attention Needed\n\n%s\n\n", content)
    end
    
    -- ENHANCED: Use warning callout
    return (markdown.CreateCallout and markdown.CreateCallout("warning", content, format)) or 
           string.format("## ⚠️ Attention Needed\n\n%s\n\n", content)
end
```

Then update the Markdown.lua call:

```lua
-- IN: src/generators/Markdown.lua, GetSectionRegistry function

-- FIND (around line 100):
{
    name = "AttentionNeeded",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
    generator = function()
        return gen.GenerateAttentionNeeded(data.progression, data.inventory, data.riding, data.companion, format)
    end
},
```

---

## Issue #6: Inconsistent Progress Bar Symbols 🟡 MEDIUM

### Problem
Different bar characters used: `█` vs `▓` and `░`

### Location
`src/utils/AdvancedMarkdown.lua` - `CreateProgressBar` function

### Status
✅ **ALREADY FIXED** - The code comment on line 273 says "STANDARDIZED: Always use █ (filled) and ░ (empty)"

### Verification Needed
Check if other sections are manually creating bars instead of using this function.

### Additional Check Required
Search all section files for `▓` character to find any hardcoded progress bars.

---

## Issue #7: Duplicate PvP Sections 🔴 HIGH

### Problem
Two separate PvP sections with conflicting data

### Location
- `src/generators/sections/Economy.lua` - `GeneratePvP` (⚔️ PvP Information)
- `src/generators/sections/PvPStats.lua` - `GeneratePvPStats` (⚔️ PvP Statistics)

### Root Cause
Two different collectors and generators for related PvP data:
1. `CollectPvPData` → `GeneratePvP` (basic info)
2. `CollectPvPStatsData` → `GeneratePvPStats` (detailed stats)

### Fix Option 1: Merge into one section
Consolidate both into a single comprehensive PvP section.

### Fix Option 2: Rename and differentiate
Keep both but make the distinction clearer:
- "⚔️ PvP Overview" (basic rank + campaign)
- "📊 PvP Statistics" (detailed combat stats)

### Recommended Fix: Merge into one section

```lua
-- IN: src/generators/sections/PvPStats.lua

-- REPLACE entire GeneratePvPStats function with merged version:
local function GeneratePvPStats(pvpData, pvpStatsData, format)
    InitializeUtilities()
    
    -- Require at least one data source
    if not pvpData and not pvpStatsData then
        return ""
    end
    
    -- Merge data from both sources
    local rank = 0
    local rankName = "None"
    local allianceName = ""
    local campaignName = ""
    local campaignType = ""
    local campaignStatus = ""
    
    -- Get basic info from pvpData (from CollectPvPData)
    if pvpData then
        rank = pvpData.rank or 0
        rankName = pvpData.rankName or "None"
        allianceName = pvpData.allianceName or ""
        campaignName = pvpData.campaignName or ""
    end
    
    -- Get detailed stats from pvpStatsData (from CollectPvPStatsData)
    local stats = {}
    if pvpStatsData then
        -- Override with pvpStatsData if it has better/more complete info
        if pvpStatsData.rank and pvpStatsData.rank > 0 then
            rank = pvpStatsData.rank
            rankName = pvpStatsData.rankName or rankName
        end
        if pvpStatsData.allianceName and pvpStatsData.allianceName ~= "" then
            allianceName = pvpStatsData.allianceName
        end
        if pvpStatsData.campaign and pvpStatsData.campaign.name then
            campaignName = pvpStatsData.campaign.name
            campaignType = pvpStatsData.campaign.type or ""
            campaignStatus = pvpStatsData.campaign.status or ""
        end
        stats = pvpStatsData.stats or {}
    end
    
    -- Generate output
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**PvP:**\n"
        
        if rank > 0 and rankName ~= "" then
            markdown = markdown .. "• Rank: " .. rankName .. " (Rank " .. rank .. ")\n"
        else
            markdown = markdown .. "• Rank: None (Rank 0)\n"
        end
        
        if allianceName and allianceName ~= "" then
            markdown = markdown .. "• Alliance: " .. allianceName .. "\n"
        end
        
        if campaignName and campaignName ~= "" then
            markdown = markdown .. "• Campaign: " .. campaignName
            if campaignType ~= "" then
                markdown = markdown .. " (" .. campaignType .. ")"
            end
            markdown = markdown .. "\n"
        end
        
        if stats.kills and stats.kills > 0 then
            markdown = markdown .. "• Kills: " .. FormatNumber(stats.kills) .. "\n"
        end
        if stats.deaths and stats.deaths > 0 then
            markdown = markdown .. "• Deaths: " .. FormatNumber(stats.deaths) .. "\n"
        end
        if stats.assists and stats.assists > 0 then
            markdown = markdown .. "• Assists: " .. FormatNumber(stats.assists) .. "\n"
        end
        
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## ⚔️ PvP\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        
        if rank > 0 and rankName ~= "" then
            markdown = markdown .. "| **Alliance War Rank** | " .. rankName .. " (Rank " .. rank .. ") |\n"
        else
            markdown = markdown .. "| **Alliance War Rank** | None (Rank 0) |\n"
        end
        
        if allianceName and allianceName ~= "" then
            markdown = markdown .. "| **Alliance** | " .. allianceName .. " |\n"
        end
        
        if campaignName and campaignName ~= "" then
            local campaignLink = CreateCampaignLink and CreateCampaignLink(campaignName, format) or campaignName
            markdown = markdown .. "| **Campaign** | " .. campaignLink
            if campaignType ~= "" then
                markdown = markdown .. " (" .. campaignType .. ")"
            end
            markdown = markdown .. " |\n"
            
            if campaignStatus and campaignStatus ~= "" then
                markdown = markdown .. "| **Campaign Status** | " .. campaignStatus .. " |\n"
            end
        end
        
        if stats.kills or stats.deaths or stats.assists or stats.morale then
            local combatStats = {}
            if stats.kills and stats.kills > 0 then
                table.insert(combatStats, "Kills: " .. FormatNumber(stats.kills))
            end
            if stats.deaths and stats.deaths > 0 then
                table.insert(combatStats, "Deaths: " .. FormatNumber(stats.deaths))
            end
            if stats.assists and stats.assists > 0 then
                table.insert(combatStats, "Assists: " .. FormatNumber(stats.assists))
            end
            if stats.morale and stats.morale > 0 then
                table.insert(combatStats, "Morale: " .. FormatNumber(stats.morale))
            end
            
            if #combatStats > 0 then
                markdown = markdown .. "| **Combat Stats** | " .. table.concat(combatStats, " • ") .. " |\n"
            end
        end
        
        markdown = markdown .. "\n---\n\n"
    end
    
    return markdown
end

-- Keep the function name but now it handles both data sources
CM.generators.sections.GeneratePvP = GeneratePvPStats
CM.generators.sections.GeneratePvPStats = GeneratePvPStats
```

Then update Markdown.lua to remove duplicate and pass both data sources:

```lua
-- IN: src/generators/Markdown.lua, GetSectionRegistry function

-- REMOVE the old "PvP" section entry (around line 143)
-- MODIFY the "PvP Stats" section entry (around line 277):
{
    name = "PvP",
    condition = IsSettingEnabled(settings, "includePvP", true),
    generator = function()
        return gen.GeneratePvPStats(data.pvp, data.pvpStats, format)
    end
},
```

---

## Issue #8: Empty Sections Not Collapsible 🟢 LOW

### Problem
Empty/minimal sections shown with full headers, not collapsible

### Locations
- Armory Builds
- Tales of Tribute
- Other sections with minimal data

### Fix
Wrap empty/minimal sections in collapsible:

```lua
-- IN: src/generators/sections/ArmoryBuilds.lua

local function GenerateArmoryBuilds(armoryData, format)
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local markdown = CM.utils and CM.utils.markdown
    
    if not armoryData or #armoryData == 0 then
        local content = "*No armory builds configured*"
        
        if format == "discord" then
            return ""  -- Skip entirely for Discord
        end
        
        if enhanced and markdown and markdown.CreateCollapsible then
            return markdown.CreateCollapsible("Armory Builds", content, "🏰", false)
        else
            return "## 🏰 Armory Builds\n\n" .. content .. "\n\n---\n\n"
        end
    end
    
    -- Rest of function for populated data...
end
```

Apply similar pattern to TalesOfTribute.lua and other minimal sections.

---

## Issue #9: Confusing Morph Symbols 🟡 MEDIUM

### Problem
Morph choice indicators unclear

### Location
`src/generators/sections/Skills.lua` (assumed, need to find skill morphs section)

### Current Symbols
```
✅ = Skill is morphed (confusing)
⚪ = Morph not chosen (unclear)
🔒 = Skill not morphed (confusing)
```

### New Symbols
```
⚔️ = Morphed skill header
✅ = This morph is CHOSEN
❌ = This morph is NOT chosen
🔒 = Skill not yet morphed
```

### Fix
```lua
-- IN: src/collectors/SkillMorphs.lua or skills section generator

-- When generating morph display:
if skillIsMorphed then
    header = string.format("**[%s](%s)** (Rank %d) - ⚔️ Morphed\n\n", 
        skillName, link, rank)
    
    -- Morph 1
    if morph1IsChosen then
        header = header .. string.format("  ✅ **Morph 1**: [%s](%s) **← CHOSEN**\n", 
            morph1Name, morph1Link)
    else
        header = header .. string.format("  ❌ Morph 1: [%s](%s)\n", 
            morph1Name, morph1Link)
    end
    
    -- Morph 2
    if morph2IsChosen then
        header = header .. string.format("  ✅ **Morph 2**: [%s](%s) **← CHOSEN**\n", 
            morph2Name, morph2Link)
    else
        header = header .. string.format("  ❌ Morph 2: [%s](%s)\n", 
            morph2Name, morph2Link)
    end
else
    header = string.format("🔒 **[%s](%s)** (Rank %d) - Not yet morphed\n\n", 
        skillName, link, rank)
end
```

---

## Implementation Order

### Phase 1: Critical Fixes (30 minutes)
1. ✅ Fix broken HTML table (Issue #1)
2. ✅ Fix zero resource values (Issue #3)
3. ✅ Remove duplicate PvP sections (Issue #7)

### Phase 2: Medium Priority (20 minutes)
4. ✅ Fix enlightenment callout (Issue #4)
5. ✅ Enhance attention needed (Issue #5)
6. ✅ Fix morph symbols (Issue #9)

### Phase 3: Polish (15 minutes)
7. ✅ Make empty sections collapsible (Issue #8)
8. ✅ Verify progress bar consistency (Issue #6)
9. ✅ Verify callout syntax (Issue #2)

---

## Testing Checklist

After applying fixes:
- [ ] Generate markdown with all settings ON
- [ ] Verify title displays correctly (no broken HTML)
- [ ] Verify callouts render with [!NOTE] syntax
- [ ] Verify resource values are NOT zero
- [ ] Verify only ONE PvP section appears
- [ ] Verify enlightenment callout appears when enlightened
- [ ] Verify attention warnings show for unspent points
- [ ] Verify progress bars use consistent █ and ░ characters
- [ ] Verify empty sections are collapsible
- [ ] Verify morph choices are clearly indicated

---

## Files Requiring Updates

1. `src/generators/sections/Character.lua` - Issues #1, #3, #4, #5
2. `src/generators/sections/PvPStats.lua` - Issue #7 (merge function)
3. `src/generators/sections/Economy.lua` - Issue #7 (deprecate GeneratePvP)
4. `src/generators/Markdown.lua` - Issue #7 (update registry)
5. `src/generators/sections/ArmoryBuilds.lua` - Issue #8
6. `src/generators/sections/TalesOfTribute.lua` - Issue #8
7. `src/collectors/SkillMorphs.lua` or skills generator - Issue #9
8. `src/utils/AdvancedMarkdown.lua` - Issue #6 (verification only)

---

**Status:** Documentation complete. Ready to implement fixes.
