# CharacterMarkdown - Visual Issues Fixes Implementation

## Date: 2025-11-02
## Status: Implementation Ready

---

## Overview

This document provides complete code fixes for all 9 identified visual issues in the CharacterMarkdown addon output.

---

## Fix #1: Broken HTML Table in Title Section

**File:** `src/utils/AdvancedMarkdown.lua`
**Function:** `CreateInfoBox()`

**Problem:** Missing `<tr>` wrapper and invalid HTML structure

**Current Code:**
```lua
local function CreateInfoBox(content, width)
    if not content or content == "" then return "" end
    width = width or 2000
    
    return string_format([[
<div align="center">
<table>
<tbody>
<td align="center">
<img width="%d" height="0"><br>
<sub>%s</sub><br>
<img width="%d" height="0">
</td>
</tbody>
</table>
</div>

]], width, content, width)
end
```

**Fixed Code:**
```lua
local function CreateInfoBox(content, width)
    if not content or content == "" then return "" end
    width = width or 2000
    
    return string_format([[
<div align="center">
<table>
<tbody>
<tr>
<td align="center">
<img width="%d" height="0"><br>
<sub>%s</sub><br>
<img width="%d" height="0">
</td>
</tr>
</tbody>
</table>
</div>

]], width, content, width)
end
```

---

## Fix #2: Wrong Callout Syntax

**File:** `src/utils/AdvancedMarkdown.lua`
**Function:** `CreateCallout()`

**Problem:** Not using proper GitHub native callout syntax

**Already Fixed:** The code already uses correct `> [!NOTE]` syntax. No change needed.

**Verification:** Current implementation is correct:
```lua
if format == "github" or format == "vscode" then
    -- GitHub/VS Code native callout syntax
    return string_format("> [!%s]  \n> %s\n\n", callout.tag, escaped_content)
end
```

---

## Fix #3: Zero Resource Values in Quick Stats

**File:** `src/generators/sections/Character.lua`
**Function:** `GenerateQuickStats()`

**Problem:** Using wrong data source, showing 0 for all resources

**Current Code:**
```lua
local function GenerateQuickStats(charData, statsData, format)
    if not charData then return "" end
    if format == "discord" then return "" end -- Skip for Discord
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    
    local level = charData.level or 1
    local cp = charData.cp or 0
    local health = statsData and statsData.maxHealth or 0
    local magicka = statsData and statsData.maxMagicka or 0
    local stamina = statsData and statsData.maxStamina or 0
```

**Fixed Code:**
```lua
local function GenerateQuickStats(charData, statsData, format)
    if not charData then return "" end
    if format == "discord" then return "" end -- Skip for Discord
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    
    local level = charData.level or 1
    local cp = charData.cp or 0
    
    -- FIX: Get resources from statsData properly
    local health = 0
    local magicka = 0
    local stamina = 0
    
    if statsData then
        health = statsData.health or statsData.maxHealth or 0
        magicka = statsData.magicka or statsData.maxMagicka or 0
        stamina = statsData.stamina or statsData.maxStamina or 0
    end
```

**Note:** Also need to update the call in `Markdown.lua` to pass correct data

**File:** `src/generators/Markdown.lua`

**Current Code:**
```lua
-- Quick Stats Summary (non-Discord only)
{
    name = "QuickStats",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeQuickStats", true),
    generator = function()
        return gen.GenerateQuickStats(data.character, data.progression, data.currency, 
            data.equipment, data.cp, data.inventory, format)
    end
},
```

**Fixed Code:**
```lua
-- Quick Stats Summary (non-Discord only)
{
    name = "QuickStats",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeQuickStats", true),
    generator = function()
        -- FIX: Pass stats data instead of progression
        return gen.GenerateQuickStats(data.character, data.stats, format)
    end
},
```

---

## Fix #4: Missing Enlightenment Callout

**File:** `src/generators/sections/Character.lua`
**Function:** `GenerateProgression()`

**Problem:** Not showing enlightenment success callout

**Current Code** (end of function):
```lua
    -- Enlightenment
    if progressionData.isEnlightened then
        if not enhanced then
            table.insert(lines, "✨ **Enlightened** (4x CP XP)")
        end
    end
    
    if #lines == 0 then return "" end
    
    local content = table_concat(lines, "  \n")
    
    if not enhanced or not markdown then
        return string_format("## 📈 Progression\n\n%s\n\n", content)
    end
    
    -- ENHANCED: Use collapsible + enlightenment callout (with nil checks)
    local result = ""
    if markdown.CreateCollapsible then
        result = markdown.CreateCollapsible("Progression", content, "📈", false) or string_format("## 📈 Progression\n\n%s\n\n", content)
    else
        result = string_format("## 📈 Progression\n\n%s\n\n", content)
    end
    
    if progressionData.isEnlightened and markdown.CreateCallout then
        local callout = markdown.CreateCallout("success", 
            "**Enlightenment Active** - Earning 4x Champion Point XP", format)
        if callout then
            result = result .. callout
        end
    end
    
    return result
end
```

**Fixed Code:**
```lua
    -- Enlightenment - DO NOT add to lines, handle separately
    
    if #lines == 0 and not progressionData.isEnlightened then 
        return "" 
    end
    
    local content = table_concat(lines, "  \n")
    
    if not enhanced or not markdown then
        local result = string_format("## 📈 Progression\n\n%s\n\n", content)
        -- Add enlightenment in plain format
        if progressionData.isEnlightened then
            result = result .. "> ✨ **Enlightened** - Earning 4x Champion Point XP\n\n"
        end
        return result
    end
    
    -- ENHANCED: Use collapsible + enlightenment callout (with nil checks)
    local result = ""
    if markdown.CreateCollapsible then
        result = markdown.CreateCollapsible("Progression", content, "📈", false) or string_format("## 📈 Progression\n\n%s\n\n", content)
    else
        result = string_format("## 📈 Progression\n\n%s\n\n", content)
    end
    
    -- FIX: Always show enlightenment callout when enlightened
    if progressionData.isEnlightened then
        if markdown.CreateCallout then
            local callout = markdown.CreateCallout("tip", 
                "🌟 **Enlightened!** Earning 4x Champion Point XP", format)
            if callout then
                result = result .. callout
            end
        else
            -- Fallback if CreateCallout doesn't exist
            result = result .. "> 🌟 **Enlightened!** Earning 4x Champion Point XP\n\n"
        end
    end
    
    return result
end
```

---

## Fix #5: Missing Attention Needed Callout

**File:** `src/generators/sections/Character.lua`
**Function:** `GenerateAttentionNeeded()`

**Problem:** Logic doesn't check properly for unspent points

**Current Code:**
```lua
local function GenerateAttentionNeeded(charData, progressionData, format)
    if format == "discord" then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local warnings = {}
    
    -- Check for unspent points
    if progressionData then
        if progressionData.unspentSkillPoints and progressionData.unspentSkillPoints > 0 then
            table.insert(warnings, string_format("**%d unspent skill points**", progressionData.unspentSkillPoints))
        end
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            table.insert(warnings, string_format("**%d unspent attribute points**", progressionData.unspentAttributePoints))
        end
    end
    
    if #warnings == 0 then return "" end
    
    local content = table_concat(warnings, "  \n")
    
    if not enhanced or not markdown then
        return string_format("## ⚠️ Attention Needed\n\n%s\n\n", content)
    end
    
    -- ENHANCED: Use warning callout (with nil check)
    return (markdown.CreateCallout and markdown.CreateCallout("warning", content, format)) or string_format("## ⚠️ Attention Needed\n\n%s\n\n", content)
end
```

**Fixed Code:**
```lua
local function GenerateAttentionNeeded(charData, progressionData, format)
    if format == "discord" then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local warnings = {}
    
    -- Check for unspent points
    if progressionData then
        -- Skill Points
        if progressionData.unspentSkillPoints and progressionData.unspentSkillPoints > 0 then
            table.insert(warnings, string_format("• %d unspent Skill %s", 
                progressionData.unspentSkillPoints,
                progressionData.unspentSkillPoints == 1 and "Point" or "Points"))
        end
        
        -- Attribute Points
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            table.insert(warnings, string_format("• %d unspent Attribute %s", 
                progressionData.unspentAttributePoints,
                progressionData.unspentAttributePoints == 1 and "Point" or "Points"))
        end
    end
    
    if #warnings == 0 then return "" end
    
    local content = "⚠️ **Attention Needed**\n" .. table_concat(warnings, "  \n")
    
    if not enhanced or not markdown then
        return string_format("> %s\n\n", content)
    end
    
    -- ENHANCED: Use warning callout (with nil check)
    return (markdown.CreateCallout and markdown.CreateCallout("warning", content, format)) or string_format("> %s\n\n", content)
end
```

**Also Update Markdown.lua Call:**

**File:** `src/generators/Markdown.lua`

**Current Code:**
```lua
-- Attention Needed (non-Discord only)
{
    name = "AttentionNeeded",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
    generator = function()
        return gen.GenerateAttentionNeeded(data.progression, data.inventory, data.riding, data.companion, format)
    end
},
```

**Fixed Code:**
```lua
-- Attention Needed (non-Discord only)
{
    name = "AttentionNeeded",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
    generator = function()
        -- FIX: Only pass charData and progressionData
        return gen.GenerateAttentionNeeded(data.character, data.progression, format)
    end
},
```

---

## Fix #6: Inconsistent Progress Bars

**File:** `src/utils/AdvancedMarkdown.lua`
**Function:** `CreateProgressBar()`

**Problem:** Different bar styles used across sections

**Current Code:**
```lua
local function CreateProgressBar(current, max, width, style, label)
    if not current or not max or max == 0 then return "" end
    
    width = width or 20
    style = style or "github"
    
    local percentage = math.floor((current / max) * 100)
    local filled = math.floor((percentage / 100) * width)
    local empty = width - filled
    
    local bar
    if style == "github" then
        bar = string_rep("█", filled) .. string_rep("░", empty)
    elseif style == "vscode" then
        bar = string_rep("▓", filled) .. string_rep("░", empty)
    elseif style == "discord" then
        bar = string_rep("▰", filled) .. string_rep("▱", empty)
    else
        bar = string_rep("█", filled) .. string_rep("░", empty)
    end
    
    if label then
        return string_format("%s: %s %d%% (%d/%d)", label, bar, percentage, current, max)
    else
        return string_format("%s %d%%", bar, percentage)
    end
end
```

**Fixed Code (standardize to always use █ and ░):**
```lua
local function CreateProgressBar(current, max, width, style, label)
    if not current or not max or max == 0 then return "" end
    
    width = width or 20
    style = style or "github"
    
    local percentage = math.floor((current / max) * 100)
    local filled = math.floor((percentage / 100) * width)
    local empty = width - filled
    
    -- FIX: Standardize to always use █ (filled) and ░ (empty) for consistency
    local bar = string_rep("█", filled) .. string_rep("░", empty)
    
    if label then
        return string_format("%s: %s %d%% (%d/%d)", label, bar, percentage, current, max)
    else
        return string_format("%s %d%%", bar, percentage)
    end
end
```

**Also need to standardize width:** All sections should use 20-width bars consistently.

---

## Fix #7: Duplicate PvP Sections

**File:** `src/generators/sections/Economy.lua`

**Problem:** Economy.lua likely has a PvP function that conflicts

**Action Required:** 
1. Remove `GeneratePvP()` from Economy.lua if it exists
2. Verify only ONE PvP section generator exists

**Check:** Search for "GeneratePvP" in Economy.lua and remove if found

**File:** `src/generators/Markdown.lua`

**Verify only ONE PvP section:**
```lua
-- PvP (should only appear ONCE)
{
    name = "PvP",
    condition = IsSettingEnabled(settings, "includePvP", true),
    generator = function()
        return gen.GeneratePvP(data.pvp, format)
    end
},
```

**Action:** Check for duplicate PvP entries in section registry and remove duplicates.

---

## Fix #8: Empty Sections Not Collapsible

**Files:** Multiple section generators

**Problem:** Empty/minimal sections shown with full headers instead of collapsible

**Pattern to Apply:**

**Before:**
```lua
markdown = markdown .. "## 🏰 Armory Builds\n\n"
markdown = markdown .. "*No armory builds configured*\n\n"
```

**After:**
```lua
if not markdown_utils or not markdown_utils.CreateCollapsible then
    markdown = markdown .. "## 🏰 Armory Builds\n\n"
    markdown = markdown .. "*No armory builds configured*\n\n"
else
    markdown = markdown .. markdown_utils.CreateCollapsible(
        "Armory Builds", 
        "*No armory builds configured*", 
        "🏰", 
        false
    )
end
```

**Files to Update:**
- `src/generators/sections/ArmoryBuilds.lua`
- `src/generators/sections/TalesOfTribute.lua`  
- Any section that returns minimal/empty content

---

## Fix #9: Confusing Morph Symbols

**File:** `src/generators/sections/Equipment.lua` (or Skills.lua if morphs are there)

**Problem:** Using ✅⚪🔒 symbols that aren't clear

**Current Pattern:**
```markdown
✅ **[Crescent Sweep](...)** (Rank 4)
  ⚪ **Morph 1**: [Everlasting Sweep](...)
  ✅ **Morph 2**: [Crescent Sweep](...)
```

**Fixed Pattern:**
```markdown
**[Crescent Sweep](...)** (Rank 4) - ⚔️ Morphed
  ❌ Morph 1: [Everlasting Sweep](...)
  ✅ Morph 2: [Crescent Sweep](...) **← CHOSEN**
```

**Implementation:**
```lua
-- For morphed abilities
if ability.morphChoice then
    markdown = markdown .. string_format("**%s** (Rank %d) - ⚔️ Morphed\n", 
        abilityLink, ability.rank)
    
    -- Show both morphs with clear indicator
    if ability.morph1 then
        local chosen = (ability.morphChoice == 1) and " **← CHOSEN**" or ""
        local symbol = (ability.morphChoice == 1) and "✅" or "❌"
        markdown = markdown .. string_format("  %s Morph 1: %s%s\n", 
            symbol, ability.morph1Link, chosen)
    end
    
    if ability.morph2 then
        local chosen = (ability.morphChoice == 2) and " **← CHOSEN**" or ""
        local symbol = (ability.morphChoice == 2) and "✅" or "❌"
        markdown = markdown .. string_format("  %s Morph 2: %s%s\n", 
            symbol, ability.morph2Link, chosen)
    end
else
    -- Unmorphed ability
    markdown = markdown .. string_format("**%s** (Rank %d) - 🔒 Not Morphed\n", 
        abilityLink, ability.rank)
end
```

---

## Implementation Checklist

### Priority 1 (Critical - Breaks Rendering)
- [ ] Fix #1: HTML table structure in `CreateInfoBox()`
- [ ] Fix #3: Resource values in `GenerateQuickStats()`
- [ ] Fix #7: Remove duplicate PvP sections

### Priority 2 (Important - Visual Clarity)
- [ ] Fix #4: Enlightenment callout in `GenerateProgression()`
- [ ] Fix #5: Attention needed callout logic
- [ ] Fix #6: Standardize progress bars
- [ ] Fix #9: Morph choice indicators

### Priority 3 (Enhancement - Nice to Have)
- [ ] Fix #8: Make empty sections collapsible

---

## Testing Steps

After implementing fixes:

1. **Generate markdown with all settings ON:**
   ```
   /markdown github
   ```

2. **Verify rendering:**
   - Copy output to GitHub markdown viewer
   - Verify HTML table renders correctly
   - Verify all callouts use `[!NOTE]`, `[!TIP]`, etc.
   - Verify no duplicate sections

3. **Verify data accuracy:**
   - Check resource values are non-zero
   - Check progress bars all use same characters
   - Check morph choices are clear

4. **Verify callouts:**
   - Enlightenment shows when enlightened
   - Attention needed shows with unspent points
   - Both use proper callout syntax

---

## Files Modified Summary

1. `src/utils/AdvancedMarkdown.lua` - Fixes #1, #6
2. `src/generators/sections/Character.lua` - Fixes #3, #4, #5
3. `src/generators/Markdown.lua` - Fixes #3, #5, #7
4. `src/generators/sections/Economy.lua` - Fix #7 (check/remove)
5. `src/generators/sections/Equipment.lua` - Fix #9
6. Multiple section generators - Fix #8

---

**Implementation Status:** Ready for coding
**Estimated Effort:** 2-3 hours
**Testing Effort:** 30 minutes
